import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;
import ballerina/time;

// Dashboard User Service to handle user dashboard data
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /dashboard/user on ln {

    // Only admin, manager, and User can view user dashboard stats
    resource function get stats/[int userId](http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        // Query for meals today (assuming meal_request_date is a timestamp)
        record {|int meals_today;|} mealsTodayResult = check dbClient->queryRow(
            `SELECT COUNT(requestedmeal_id) AS meals_today 
             FROM requestedmeals 
             WHERE user_id = ${userId} 
             AND DATE(meal_request_date) = CURRENT_DATE`
        );
        int mealsToday = mealsTodayResult.meals_today;

        // Query for total assets borrowed by the user
        record {|int assets_count;|} assetsResult = check dbClient->queryRow(
            `SELECT COUNT(requestedasset_id) AS assets_count 
             FROM requestedassets
             WHERE user_id = ${userId}`
        );
        int assetsCount = assetsResult.assets_count;

        // Query for total maintenance requests by the user
        record {|int maintenance_count;|} maintenanceResult = check dbClient->queryRow(
            `SELECT COUNT(maintenance_id) AS maintenance_count 
             FROM maintenance 
             WHERE user_id = ${userId}`
        );
        int maintenanceCount = maintenanceResult.maintenance_count;

        // Query for monthly meal counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyMealStream = dbClient->query(
            `SELECT EXTRACT(MONTH FROM meal_request_date) AS month, COUNT(requestedmeal_id) AS count 
             FROM requestedmeals
             WHERE user_id = ${userId} 
             GROUP BY EXTRACT(MONTH FROM meal_request_date) 
             ORDER BY month`
        );
        int[] mealsMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyMealStream
            do {
                mealsMonthlyData[row.month - 1] = row.count;
            };

        // Query for monthly asset request counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyAssetStream = dbClient->query(
            `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(requestedasset_id) AS count 
             FROM requestedassets
             WHERE user_id = ${userId} 
             GROUP BY EXTRACT(MONTH FROM submitted_date) 
             ORDER BY month`
        );
        int[] assetsMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyAssetStream
            do {
                assetsMonthlyData[row.month - 1] = row.count;
            };

        // Query for monthly maintenance request counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyMaintenanceStream = dbClient->query(
            `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(maintenance_id) AS count 
             FROM maintenance 
             WHERE user_id = ${userId} 
             GROUP BY EXTRACT(MONTH FROM submitted_date) 
             ORDER BY month`
        );
        int[] maintenanceMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyMaintenanceStream
            do {
                maintenanceMonthlyData[row.month - 1] = row.count;
            };

        // Construct the JSON response
        return {
            "mealsToday": mealsToday,
            "assets": assetsCount,
            "maintenanceRequests": maintenanceCount,
            "mealsMonthlyData": mealsMonthlyData,
            "assetsMonthlyData": assetsMonthlyData,
            "maintenanceMonthlyData": maintenanceMonthlyData
        };
    }

    // Get user recent activities
    // Get recent activities for a given user
    // Get recent activities for a given user
    resource function get activities/[int userId]() returns json[]|error {
        json[] activities = [];

        // Fetch the last meal request
        stream<record {|
            string requestedmeal_id;
            string meal_type_id;
            time:Date meal_request_date;
        |}, sql:Error?> mealStream = dbClient->query(
            `SELECT requestedmeal_id, meal_type_id, meal_request_date 
             FROM requestedmeals 
             WHERE user_id = ${userId} 
             ORDER BY meal_request_date DESC 
             LIMIT 1`
        );
        check from var meal in mealStream
            do {
                // Convert time:Date to string (e.g., "2025-05-02T00:00:00Z")
                string dateStr = meal.meal_request_date.year.toString() + "-" +
                                meal.meal_request_date.month.toString().padStart(2, "0") + "-" +
                                meal.meal_request_date.day.toString().padStart(2, "0");
                activities.push({
                    "id": meal.requestedmeal_id,
                    "type": "meal",
                    "title": "Last Meal Request",
                    "description": "Your " + meal.meal_type_id + " request has been processed",
                    "timestamp": dateStr
                });
            };

        // Fetch the last maintenance request
        stream<record {|
            string maintenance_id;
            string description;
            time:Date submitted_date;
        |}, sql:Error?> maintenanceStream = dbClient->query(
            `SELECT  maintenance_id, description, submitted_date 
             FROM maintenance 
             WHERE user_id = ${userId} 
             ORDER BY submitted_date DESC 
             LIMIT 1`
        );
        check from var maintenance in maintenanceStream
            do {
                // Convert time:Date to string
                string dateStr = maintenance.submitted_date.year.toString() + "-" +
                                maintenance.submitted_date.month.toString().padStart(2, "0") + "-" +
                                maintenance.submitted_date.day.toString().padStart(2, "0");
                activities.push({
                    "id": maintenance.maintenance_id,
                    "type": "maintenance",
                    "title": "Last Maintenance notified",
                    "description": "Your maintenance request for " + maintenance.description + " has been processed",
                    "timestamp": dateStr
                });
            };

        // Fetch the last asset request
        stream<record {|
            string requestedasset_id;
            string asset_name;
            time:Date submitted_date;
        |}, sql:Error?> assetStream = dbClient->query(
            `SELECT ar.requestedasset_id, a.asset_name, submitted_date 
             FROM requestedassets ar 
             join assets a on a.asset_id=ar.asset_id
             WHERE user_id = ${userId} 
             ORDER BY submitted_date DESC 
             LIMIT 1`
        );
        check from var asset in assetStream
            do {
                // Convert time:Date to string
                string dateStr = asset.submitted_date.year.toString() + "-" +
                                asset.submitted_date.month.toString().padStart(2, "0") + "-" +
                                asset.submitted_date.day.toString().padStart(2, "0");
                activities.push({
                    "id": asset.requestedasset_id,
                    "type": "asset",
                    "title": "Last Asset Request",
                    "description": asset.asset_name + " has been assigned to you",
                    "timestamp": dateStr
                });
            };

        return activities;
    }

    // Get quick actions available for the user

    resource function options .() returns http:Ok {
        return http:OK;
    }
}

public function startDashboardUserService() returns error? {
    // Function to integrate with the service start pattern
    io:println("Dashboard User service started on port 9090");
}
