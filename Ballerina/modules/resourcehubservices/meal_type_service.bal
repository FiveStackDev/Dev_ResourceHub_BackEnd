import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

// Defines the structure of a MealType record
public type MealType record {|
    int mealtype_id?;
    string mealtype_name;
    string mealtype_image_url;
|};

// CORS configuration for allowing specific cross-origin requests
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

// Service handling CRUD operations for meal types

service /mealtype on ln {
    // Only admin, manager, and User can view meal types
    resource function get details(http:Request req) returns MealType[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<MealType, sql:Error?> resultStream =
            dbClient->query(`SELECT mealtype_id, mealtype_name , mealtype_image_url  FROM mealtypes`);
        MealType[] mealtypes = [];
        check resultStream.forEach(function(MealType meal) {
            mealtypes.push(meal);
        });
        return mealtypes;
    }

    // Only admin and manager can add meal types
    resource function post add(http:Request req, @http:Payload MealType mealType) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add meal types");
        }
        io:println("Received meal type data: " + mealType.toJsonString());
        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO mealtypes (mealtype_name, mealtype_image_url)
            VALUES (${mealType.mealtype_name}, ${mealType.mealtype_image_url})
        `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            mealType.mealtype_id = lastInsertId;
        }
        return {
            message: "Meal type added successfully",
            mealType: mealType
        };
    }

    // Only admin and manager can update meal types
    resource function put details/[int id](http:Request req, @http:Payload MealType mealType) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update meal types");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE mealtypes 
            SET mealtype_name = ${mealType.mealtype_name}, mealtype_image_url = ${mealType.mealtype_image_url}
            WHERE mealtype_id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found"
            };
        }
        return {
            message: "Meal type updated successfully",
            mealType: mealType
        };
    }

    // Only admin and manager can delete meal types
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete meal types");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM mealtypes WHERE mealtype_id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found"
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
