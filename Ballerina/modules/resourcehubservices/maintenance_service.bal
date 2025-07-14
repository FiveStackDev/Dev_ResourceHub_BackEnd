import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

// Helper function to extract and validate JWT token and return payload

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

service /maintenance on ln {
    // Only admin, manager, and User can view maintenance details
    resource function get details(http:Request req) returns Maintenance[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<Maintenance, sql:Error?> resultStream =
            dbClient->query(`SELECT 
                u.profile_picture_url AS profilePicture,
                u.username AS username,
                m.name AS name,
                m.description,
                m.priority_level AS priorityLevel,
                m.status,
                m.submitted_date,
                m.maintenance_id ,
                u.user_id as user_id
                FROM maintenance m
                JOIN users u ON m.user_id = u.user_id;
        `);
        Maintenance[] maintenances = [];
        check resultStream.forEach(function(Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }

    // Only admin and manager can add maintenance requests
    resource function post add(http:Request req, @http:Payload Maintenance maintenance) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add maintenance requests");
        }
        sql:ExecutionResult result = check dbClient->execute(
            `INSERT INTO maintenance (name, user_id, description, priority_level, status, submitted_date)
                                   VALUES (${maintenance.name}, ${maintenance.user_id}, ${maintenance.description}, 
                                           ${maintenance.priorityLevel}, 'Pending', NOW())`
        );
        if (result.affectedRowCount == 0) {
            return error("Failed to add maintenance request");
        }
        return {"message": "Maintenance request has been added "};
    }

    // Only admin and manager can delete maintenance requests
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete maintenance requests");
        }
        sql:ExecutionResult result = check dbClient->execute(
            `DELETE FROM maintenance WHERE maintenance_id = ${id}`
        );
        if (result.affectedRowCount == 0) {
            return error("No maintenance found with the given ID");
        }
        return {"message": "Maintenance request has been deleted "};
    }

    // Only admin and manager can update maintenance requests
    resource function put details/[int id](http:Request req, @http:Payload Maintenance maintenance) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update maintenance requests");
        }
        sql:ExecutionResult result = check dbClient->execute(
            `UPDATE maintenance 
            SET description = ${maintenance.description}, 
            priority_level = ${maintenance.priorityLevel}, 
            status = ${maintenance.status ?: "Pending"} 
            WHERE maintenance_id = ${id}`
        );
        if (result.affectedRowCount == 0) {
            return error("No maintenance found with the given ID");
        }
        return {"message": "Maintenance request has been updated "};
    }

    // Only admin, manager, and User can view notifications
    resource function get notification(http:Request req) returns Notification[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<Notification, sql:Error?> resultstream = dbClient->query(
            `select m.submitted_date,u.username,m.description,m.priority_level AS priorityLevel,m.status,m.name
            from notification n
            join users u on n.user_id=u.user_id
            join maintenance m on n.maintenance_id=m.maintenance_id`
            );
        Notification[] notifications = [];
        check resultstream.forEach(function(Notification notification) {
            notifications.push(notification);
        });
        return notifications;
    }

    // Only admin and manager can add notifications
    resource function post addnotification(http:Request req, @http:Payload Notification notification) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add notifications");
        }
        sql:ExecutionResult result = check dbClient->execute(`
        insert into notification (user_id,maintenance_id)
        values(${notification.user_id},${notification.maintenance_id})`
        );
        if (result.affectedRowCount == 0) {
            return error("Failed to add notification");
        }
        return {"message": "Notification request has been updated."};
    }
}

public function startMaintenanceManagementService() returns error? {
    io:println("Maintenance Management service started on port: 9090");
}
