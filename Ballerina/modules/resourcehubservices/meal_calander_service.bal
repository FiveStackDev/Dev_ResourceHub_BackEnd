import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

public type MealEvent record {|
    int requestedmeal_id?;
    int mealtime_id;
    int mealtype_id;
    string mealtype_name?;
    string mealtime_name?;
    string username?;
    int user_id;
    string submitted_date;
    string meal_request_date;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /calendar on ln {
    // Only admin, manager, and User can view all meal events
    resource function get mealevents(http:Request req) returns MealEvent[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<MealEvent, sql:Error?> resultStream =
            dbClient->query(`SELECT requestedmeals.requestedmeal_id, mealtime_id,mealtimes.mealtime_name , mealtype_id,mealtypes.mealtype_name , username,users.user_id, submitted_date, meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id`);
        MealEvent[] events = [];
        check resultStream.forEach(function(MealEvent event) {
            events.push(event);
        });
        return events;
    }

    // Only admin, manager, and User can view their own meal events
    resource function get mealevents/[int userid](http:Request req) returns MealEvent[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<MealEvent, sql:Error?> resultStream =
            dbClient->query(`SELECT requestedmeals.requestedmeal_id, mealtime_id,mealtimes.mealtime_name , mealtype_id,mealtypes.mealtype_name , username,users.user_id, submitted_date, meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id 
            WHERE requestedmeals.user_id = ${userid}`);
        MealEvent[] events = [];
        check resultStream.forEach(function(MealEvent event) {
            events.push(event);
        });
        return events;
    }

    // Only admin and manager can add meal events
    resource function post mealevents/add(http:Request req, @http:Payload MealEvent event) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add meal events");
        }
        sql:ExecutionResult result = check dbClient->execute(` 
            INSERT INTO requestedmeals (meal_time_id, meal_type_id, user_id, submitted_date, meal_request_date) 
            VALUES (${event.mealtime_id}, ${event.mealtype_id}, ${event.user_id}, ${event.submitted_date}, ${event.meal_request_date}) 
        `);
        if result.affectedRowCount == 0 {
            return {message: "Failed to add meal event"};
        }
        return {message: "Meal event added successfully", event: event};
    }

    // Only admin and manager can delete meal events
    resource function delete mealevents/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete meal events");
        }
        sql:ExecutionResult result = check dbClient->execute(` 
            DELETE FROM requestedmeals WHERE requestedmeal_id = ${id} 
        `);
        if result.affectedRowCount == 0 {
            return {message: "Meal event not found"};
        }
        return {message: "Meal event deleted successfully"};
    }
}

public function startCalendarService() returns error? {
    io:println("Calander service started on port 9090");
}
