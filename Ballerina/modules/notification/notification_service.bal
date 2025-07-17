import ResourceHub.common;
import ResourceHub.database;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /notification on database:notificationListener {
    // Only admin, manager, and User can view notifications
    resource function get notification(http:Request req) returns Notification[]|error{
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        int org_id = check common:getOrgId(payload);
        int user_id = check common:getUserId(payload);

        stream< Notification ,sql:Error?> resultstream = database:dbClient->query(
            `select n.notification_id, n.user_id, n.type, n.reference_id, n.title, n.message, 
            n.is_read, n.created_at, n.org_id, n.priority, u.username, u.profile_picture_url
            from notification n
            join users u on n.user_id = u.user_id
            where n.user_id = ${user_id} and n.org_id = ${org_id}
            order by n.created_at desc`
        );
        Notification[] notifications = [];
        check resultstream.forEach(function(Notification notification){
            notifications.push(notification);
        });
        check resultstream.close(); // Ensure stream is closed
        return notifications;
    }

    // Only admin and manager can add notifications
    resource function post addnotification(http:Request req, @http:Payload NotificationInput notificationInput) returns json|error{
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add notifications");
        }
        int org_id = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            insert into notification (user_id, type, reference_id, title, message, org_id, priority)
            values(${notificationInput.user_id}, ${notificationInput.'type}, ${notificationInput.reference_id}, 
                   ${notificationInput.title}, ${notificationInput.message}, ${org_id}, ${notificationInput.priority})`
        );
        if (result.affectedRowCount == 0) {
            return error("Failed to add notification");
        }
        return {"message": "Notification has been added successfully."};
    }

    // Mark notification as read
    resource function put markread/[int notification_id](http:Request req) returns json|error{
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        int org_id = check common:getOrgId(payload);
        int user_id = check common:getUserId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
        update notification 
        set is_read = true 
        where notification_id = ${notification_id} and user_id = ${user_id} and org_id = ${org_id}`
        );
        
        if (result.affectedRowCount == 0) {
            return error("Notification not found or you don't have permission to update it");
        }
        return {"message": "Notification marked as read."};
    }

    // Send maintenance notification to all users in org
    resource function post sendMaintenanceNotification(http:Request req, @http:Payload NotificationInput notificationInput) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to send notifications");
        }
        int org_id = check common:getOrgId(payload);
        // Get all user IDs in org
        stream<record {int user_id;}, sql:Error?> userStream = database:dbClient->query(
            `select user_id from users where org_id = ${org_id}`
        );
        int count = 0;
        error? resultStatus = userStream.forEach(function(record {int user_id;} userRec) {
            // For large orgs, consider batching these inserts instead of one-by-one
            var result = database:dbClient->execute(`
                insert into notification (user_id, type, reference_id, title, message, org_id, priority)
                values(${userRec.user_id}, ${notificationInput.'type}, ${notificationInput.reference_id},
                       ${notificationInput.title}, ${notificationInput.message}, ${org_id}, ${notificationInput.priority})`
            );
            if result is sql:ExecutionResult {
                count = count + (result.affectedRowCount ?: 0);
            }
        });
        check userStream.close(); // Ensure stream is closed
        if resultStatus is error {
            return {"message": "Failed to send maintenance notification"};
        }
        return {"message": "Maintenance notification sent to all users.", "count": count};
    }

    // Send asset request notification to selected user
    resource function post sendAssetNotification(http:Request req, @http:Payload NotificationInput notificationInput) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to send notifications");
        }
        int org_id = check common:getOrgId(payload);
        sql:ExecutionResult result = check database:dbClient->execute(`
            insert into notification (user_id, type, reference_id, title, message, org_id, priority)
            values(${notificationInput.user_id}, ${notificationInput.'type}, ${notificationInput.reference_id},
                   ${notificationInput.title}, ${notificationInput.message}, ${org_id}, ${notificationInput.priority})`
        );
        if (result.affectedRowCount == 0) {
            return error("Failed to add asset notification");
        }
        return {"message": "Asset notification sent."};
    }

    // Delete notification (user can delete their own)
    resource function delete deleteNotification/[int notification_id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        int user_id = check common:getUserId(payload);
        int org_id = check common:getOrgId(payload);
        sql:ExecutionResult result = check database:dbClient->execute(`
            delete from notification where notification_id = ${notification_id} and user_id = ${user_id} and org_id = ${org_id}`
        );
        if (result.affectedRowCount == 0) {
            return error("Notification not found or you don't have permission to delete it");
        }
        return {"message": "Notification deleted."};
    }

    // Get unread notification count for user
    resource function get unreadCount(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        int user_id = check common:getUserId(payload);
        int org_id = check common:getOrgId(payload);
        stream<record {int unread_count;}, sql:Error?> countStream = database:dbClient->query(
            `select count(*) as unread_count from notification where user_id = ${user_id} and org_id = ${org_id} and is_read = false`
        );
        var result = countStream.next();
        int unread = 0;
        if result is record {| record {| int unread_count; anydata...; |} value; |} {
            unread = result.value.unread_count;
        }
        check countStream.close(); // Ensure stream is closed
        return {"unread_count": unread};
    }
}

public function startNotificationService() returns error? {
    io:println("Notification service started on port: 9093");
}
