import ballerina/http;
import ballerina/sql;
import ballerina/io;
import ballerina/jwt;
import ResourceHub.database;
import ResourceHub.common;

// CORS configuration for allowing specific cross-origin requests
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

// Service handling CRUD operations for meal types
service /mealtype on database:mainListener{
    // Only admin, manager, and User can view meal types
    resource function get details(http:Request req) returns MealType[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        stream<MealType, sql:Error?> resultStream = 
            database:dbClient->query(`SELECT mealtype_id, mealtype_name, mealtype_image_url, org_id FROM mealtypes WHERE org_id = ${orgId}`);
        MealType[] mealtypes = [];
        check resultStream.forEach(function(MealType meal) {
            mealtypes.push(meal);
        });
        return mealtypes;
    }

    // Only admin and manager can add meal types
    resource function post add(http:Request req, @http:Payload MealType mealType) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add meal types");
        }
        
        int orgId = check common:getOrgId(payload);
        
        io:println("Received meal type data: " + mealType.toJsonString());
        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO mealtypes (mealtype_name, mealtype_image_url, org_id)
            VALUES (${mealType.mealtype_name}, ${mealType.mealtype_image_url}, ${orgId})
        `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            return {
                message: "Meal type added successfully",
                mealtype_id: lastInsertId,
                mealType: mealType
            };
        }
        return {
            message: "Failed to add meal type"
        };
    }

    // Only admin and manager can update meal types
    resource function put details/[int id](http:Request req, @http:Payload MealType mealType) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update meal types");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE mealtypes SET mealtype_name = ${mealType.mealtype_name}, mealtype_image_url = ${mealType.mealtype_image_url}
            WHERE mealtype_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found or you don't have permission to update it"
            };
        }
        return {
            message: "Meal type updated successfully",
            mealType: mealType
        };
    }

    // Only admin and manager can delete meal types
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete meal types");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM mealtypes WHERE mealtype_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found or you don't have permission to delete it"
            };
        }
        return {
            message: "Meal type deleted successfully"
        };
    }

    // Handle preflight CORS requests
    resource function options .() returns http:Ok {
        return http:OK;
    }
}

// Log service start
public function startMealTypeService() returns error? {
    io:println("Meal Type service started on port 9090");
}