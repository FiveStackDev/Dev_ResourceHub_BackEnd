import ResourceHub.common;
import ResourceHub.database;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

public type Notification record {|
    int maintenance_id;
    int user_id;
    string name?;
    string description?;
    string priorityLevel?;
    string status?;
    string submitted_date?;
    string profilePicture?;
    string username?;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /notification on database:ln {
    // Only admin, manager, and User can view notifications
    resource function get details(http:Request req) returns Notification[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access notifications");
        }

        stream<Notification, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
                m.maintenance_id,
                m.user_id,
                m.name,
                m.description,
                m.priority_level as priorityLevel,
                m.status,
                m.submitted_date,
                u.profile_picture_url as profilePicture,
                u.username
            FROM maintenance m
            JOIN users u ON m.user_id = u.user_id
            WHERE m.status = 'pending'
            ORDER BY m.submitted_date DESC
        `);

        Notification[] notifications = [];
        check resultStream.forEach(function(Notification notification) {
            notifications.push(notification);
        });
        return notifications;
    }

    // Only admin and manager can add notifications
    resource function post add(http:Request req, @http:Payload Notification notification) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add notifications");
        }

        // This could be used to create custom notifications or system alerts
        // For now, we'll just return a success message
        return {message: "Notification functionality not implemented yet"};
    }
}

public function startNotificationService() returns error? {
    io:println("Notification service started on port: 9090");
}
