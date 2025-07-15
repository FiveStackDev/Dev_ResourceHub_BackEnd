import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerina/jwt;
import ResourceHub.database;
import ResourceHub.common;

public type Maintenance record {|
    int maintenance_id?;
    int user_id;
    string? name;
    string description;
    string priorityLevel;
    string status?;
    string submitted_date?;
    string profilePicture?;
    string username?;
|};

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

service /maintenance on database:ln {
    // Only admin, manager, and User can view maintenance details
    resource function get details(http:Request req) returns Maintenance[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<Maintenance, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
                m.maintenance_id,
                m.user_id,
                m.name,
                m.description,
                m.priorityLevel,
                m.status,
                m.submitted_date,
                u.profile_picture_url as profilePicture,
                u.username
            FROM maintenance m
            JOIN users u ON m.user_id = u.user_id
        `);
        Maintenance[] maintenances = [];
        check resultStream.forEach(function(Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }

    // Only admin and manager can add maintenance requests
    resource function post add(http:Request req, @http:Payload Maintenance maintenance) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add maintenance requests");
        }
        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO maintenance (user_id, name, description, priorityLevel, status, submitted_date)
            VALUES (${maintenance.user_id}, ${maintenance.name ?: ""}, ${maintenance.description}, 
                    ${maintenance.priorityLevel}, 'pending', NOW())
        `);
        if (result.affectedRowCount == 0) {
            return {message: "Failed to add maintenance request"};
        }
        return {message: "Maintenance request has been added "};
    }

    // Only admin and manager can delete maintenance requests
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete maintenance requests");
        }
        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM maintenance WHERE maintenance_id = ${id}
        `);
        if (result.affectedRowCount == 0) {
            return {message: "Maintenance request not found"};
        }
        return {message: "Maintenance request has been deleted "};
    }

    // Only admin and manager can update maintenance requests
    resource function put details/[int id](http:Request req, @http:Payload Maintenance maintenance) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update maintenance requests");
        }
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE maintenance 
            SET name = ${maintenance.name ?: ""}, 
                description = ${maintenance.description}, 
                priorityLevel = ${maintenance.priorityLevel}, 
                status = ${maintenance.status ?: "pending"}
            WHERE maintenance_id = ${id}
        `);
        if (result.affectedRowCount == 0) {
            return {message: "Maintenance request not found"};
        }
        return {message: "Maintenance request has been updated"};
    }

    // Only admin, manager, and User can view notifications
    resource function get notification(http:Request req) returns Notification[]|error{
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access notifications");
        }

        stream<Notification, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
                m.maintenance_id,
                m.user_id,
                m.name,
                m.description,
                m.priorityLevel,
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
    resource function post addnotification(http:Request req, @http:Payload Notification notification) returns json|error{
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add notifications");
        }

        // This could be used to create custom notifications or system alerts
        // For now, we'll just return a success message
        return {message: "Notification functionality not implemented yet"};
    }
}

public function startMaintenanceManagementService() returns error? {
    io:println("Maintenance Management service started on port: 9090");
}
