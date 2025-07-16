import ballerina/http;
import ballerina/sql;
import ballerina/io;
import ballerina/jwt;
import ResourceHub.database;
import ResourceHub.common;

// CORS configuration for cross-origin requests
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

// MealTime service with CRUD operations
service /mealtime on database:mainListener{
    // Only admin, manager, and User can view mealtime details
    resource function get details(http:Request req) returns MealTime[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        stream<MealTime, sql:Error?> resultStream = 
            database:dbClient->query(`SELECT mealtime_id, mealtime_name, mealtime_image_url, org_id FROM mealtimes WHERE org_id = ${orgId}`);
        MealTime[] mealtimes = [];
        check resultStream.forEach(function(MealTime meal) {
            mealtimes.push(meal);
        });
        return mealtimes;
    }

    // Only admin and manager can add mealtime records
    resource function post add(http:Request req, @http:Payload MealTime mealTime) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add mealtime records");
        }
        
        int orgId = check common:getOrgId(payload);
        
        io:println("Received meal time data: " + mealTime.toJsonString());
        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO mealtimes (mealtime_name, mealtime_image_url, org_id)
            VALUES (${mealTime.mealtime_name}, ${mealTime.mealtime_image_url}, ${orgId})
        `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            return {
                message: "Meal time added successfully",
                mealtime_id: lastInsertId,
                mealTime: mealTime
            };
        }
        return {
            message: "Failed to add meal time"
        };
    }

    // Only admin and manager can update mealtime records
    resource function put details/[int id](http:Request req, @http:Payload MealTime mealTime) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update mealtime records");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE mealtimes SET mealtime_name = ${mealTime.mealtime_name}, mealtime_image_url = ${mealTime.mealtime_image_url}
            WHERE mealtime_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found or you don't have permission to update it"
            };
        }
        return {
            message: "Meal time updated successfully",
            mealTime: mealTime
        };
    }

    // Only admin and manager can delete mealtime records
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete mealtime records");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM mealtimes WHERE mealtime_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found or you don't have permission to delete it"
            };
        }
        return {
            message: "Meal time deleted successfully"
        };
    }
}

// Logs service start on port 9090
public function startMealTimeService() returns error? {
    io:println("Meal Time service started on port 9090");
}