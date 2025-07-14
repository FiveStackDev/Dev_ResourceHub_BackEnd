import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

// Defines the structure of a MealTime object
public type MealTime record {|
    int mealtime_id?;
    string mealtime_name;
    string mealtime_image_url;
|};

// CORS configuration for cross-origin requests
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

// MealTime service with CRUD operations

service /mealtime on ln {
    // Only admin, manager, and User can view mealtime details
    resource function get details(http:Request req) returns MealTime[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<MealTime, sql:Error?> resultStream =
            dbClient->query(`SELECT mealtime_id,mealtime_name , mealtime_image_url FROM mealtimes`);
        MealTime[] mealtimes = [];
        check resultStream.forEach(function(MealTime meal) {
            mealtimes.push(meal);
        });
        return mealtimes;
    }

    // Only admin and manager can add mealtime records
    resource function post add(http:Request req, @http:Payload MealTime mealTime) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add mealtime records");
        }
        io:println("Received meal time data: " + mealTime.toJsonString());
        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO mealtimes (mealtime_name, mealtime_image_url)
            VALUES (${mealTime.mealtime_name}, ${mealTime.mealtime_image_url})
        `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            mealTime.mealtime_id = lastInsertId;
        }
        return {
            message: "Meal time added successfully",
            mealTime: mealTime
        };
    }

    // Only admin and manager can update mealtime records
    resource function put details/[int id](http:Request req, @http:Payload MealTime mealTime) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update mealtime records");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE mealtimes 
            SET mealtime_name = ${mealTime.mealtime_name}, mealtime_image_url = ${mealTime.mealtime_image_url}
            WHERE mealtime_id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found"
            };
        }
        return {
            message: "Meal time updated successfully",
            mealTime: mealTime
        };
    }

    // Only admin and manager can delete mealtime records
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete mealtime records");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM mealtimes WHERE mealtime_id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found"
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
