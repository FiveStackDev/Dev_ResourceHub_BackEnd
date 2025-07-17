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

service /maintenance on database:mainListener {
    // Only admin, manager, and User can view maintenance details
    resource function get details(http:Request req) returns Maintenance[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        stream<Maintenance, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
            m.maintenance_id,
            m.user_id,
            m.name,
            m.description,
            m.priority_level as priorityLevel,
            m.status,
            m.submitted_date,
            u.profile_picture_url as profilePicture,
            u.username,
            m.org_id
            FROM maintenance m
            JOIN users u ON m.user_id = u.user_id
            WHERE m.org_id = ${orgId}
        `);
        Maintenance[] maintenances = [];
        check resultStream.forEach(function(Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }

    resource function get details/[int user_id](http:Request req) returns Maintenance[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        stream<Maintenance, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
            m.maintenance_id,
            m.user_id,
            m.name,
            m.description,
            m.priority_level as priorityLevel,
            m.status,
            m.submitted_date,
            u.profile_picture_url as profilePicture,
            u.username,
            m.org_id
            FROM maintenance m
            JOIN users u ON m.user_id = u.user_id
            WHERE m.user_id = ${user_id} AND m.org_id = ${orgId}
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
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add maintenance requests");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO maintenance (user_id, name, description, priority_level, status, submitted_date, org_id)
            VALUES (${maintenance.user_id}, ${maintenance.name ?: ""}, ${maintenance.description}, 
                    ${maintenance.priorityLevel}, 'pending', NOW(), ${orgId})
        `);
        if (result.affectedRowCount == 0) {
            return {message: "Failed to add maintenance request"};
        }
        return {message: "Maintenance request has been added "};
    }

    // Only admin and manager can delete maintenance requests
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete maintenance requests");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM maintenance WHERE maintenance_id = ${id} AND org_id = ${orgId}
        `);
        if (result.affectedRowCount == 0) {
            return {message: "Maintenance request not found or you don't have permission to delete it"};
        }
        return {message: "Maintenance request has been deleted "};
    }

    // Only admin and manager can update maintenance requests
    resource function put details/[int id](http:Request req, @http:Payload Maintenance maintenance) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update maintenance requests");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE maintenance 
            SET name = ${maintenance.name ?: ""}, 
                description = ${maintenance.description}, 
                priority_level = ${maintenance.priorityLevel}, 
                status = ${maintenance.status ?: "pending"}
            WHERE maintenance_id = ${id} AND org_id = ${orgId}
        `);
        if (result.affectedRowCount == 0) {
            return {message: "Maintenance request not found or you don't have permission to update it"};
        }
        return {message: "Maintenance request has been updated"};
    }
}

public function startMaintenanceManagementService() returns error? {
    io:println("Maintenance Management service started on port: 9090");
}
