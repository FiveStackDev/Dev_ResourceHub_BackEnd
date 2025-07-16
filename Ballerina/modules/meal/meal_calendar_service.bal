import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerina/jwt;
import ResourceHub.database;
import ResourceHub.common;

@http:ServiceConfig { 
    cors: { 
        allowOrigins: ["http://localhost:5173", "*"], 
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"], 
        allowHeaders: ["Content-Type", "Authorization"] 
    } 
} 
service /calendar on database:mainListener { 
    // Only admin, manager, and User can view all meal events
    resource function get mealevents(http:Request req) returns MealEvent[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        stream<MealEvent, sql:Error?> resultStream = 
            database:dbClient->query(`SELECT requestedmeals.requestedmeal_id, requestedmeals.meal_time_id as mealtime_id, mealtimes.mealtime_name, requestedmeals.meal_type_id as mealtype_id, mealtypes.mealtype_name, users.username, users.user_id, requestedmeals.submitted_date, requestedmeals.meal_request_date, requestedmeals.org_id
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            JOIN mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            JOIN mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE requestedmeals.org_id = ${orgId}`); 
        MealEvent[] events = []; 
        check resultStream.forEach(function(MealEvent event) { 
            events.push(event); 
        }); 
        return events; 
    } 

    // Only admin, manager, and User can view their own meal events
    resource function get mealevents/[int userid](http:Request req) returns MealEvent[]|error { 
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        stream<MealEvent, sql:Error?> resultStream = 
            database:dbClient->query(`SELECT requestedmeals.requestedmeal_id, requestedmeals.meal_time_id as mealtime_id, mealtimes.mealtime_name, requestedmeals.meal_type_id as mealtype_id, mealtypes.mealtype_name, users.username, users.user_id, requestedmeals.submitted_date, requestedmeals.meal_request_date, requestedmeals.org_id
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            JOIN mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            JOIN mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE requestedmeals.user_id = ${userid} AND requestedmeals.org_id = ${orgId}`); 
        MealEvent[] events = []; 
        check resultStream.forEach(function(MealEvent event) { 
            events.push(event); 
        }); 
        return events; 
    } 

    // Only admin and manager can add meal events
    resource function post mealevents/add(http:Request req, @http:Payload MealEvent event) returns json|error { 
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add meal events");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(` 
            INSERT INTO requestedmeals (meal_time_id, meal_type_id, user_id, submitted_date, meal_request_date, org_id)
            VALUES (${event.mealtime_id}, ${event.mealtype_id}, ${event.user_id}, ${event.submitted_date}, ${event.meal_request_date}, ${orgId}) 
        `); 
        if result.affectedRowCount == 0 {
            return {message: "Failed to add meal event"};
        }
        return {message: "Meal event added successfully"};
    }

    // Only admin and manager can delete meal events
    resource function delete mealevents/[int id](http:Request req) returns json|error { 
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete meal events");
        }
        
        int orgId = check common:getOrgId(payload);
        
        sql:ExecutionResult result = check database:dbClient->execute(` 
            DELETE FROM requestedmeals WHERE requestedmeal_id = ${id} AND org_id = ${orgId}
        `); 
        if result.affectedRowCount == 0 {
            return {message: "Meal event not found or you don't have permission to delete it"};
        }
        return {message: "Meal event deleted successfully"}; 
    } 
} 

public function startCalendarService() returns error? { 
    io:println("Calander service started on port 9090"); 
}