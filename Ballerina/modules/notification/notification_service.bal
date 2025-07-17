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
            n.is_read, n.created_at, n.org_id, u.username, u.profile_picture_url
            from notification n
            join users u on n.user_id = u.user_id
            where n.user_id = ${user_id} and n.org_id = ${org_id}
            order by n.created_at desc`
            );
            Notification[] notifications =[];
            check resultstream.forEach(function(Notification notification){
                notifications.push(notification);
            });
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
        insert into notification (user_id, type, reference_id, title, message, org_id)
        values(${notificationInput.user_id}, ${notificationInput.'type}, ${notificationInput.reference_id}, 
               ${notificationInput.title}, ${notificationInput.message}, ${org_id})`
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
}

public function startNotificationService() returns error? {
    io:println("Notification service started on port: 9093");
}
