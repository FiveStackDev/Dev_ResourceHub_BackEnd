import ballerina/io;
import ballerina/http;
import ballerina/sql;
import ballerina/jwt;
import ResourceHub.database;
import ResourceHub.common;

// Dashboard User Service to handle user dashboard data
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /dashboard/user on database:dashboardListener {

    // Only admin, manager, and User can view user dashboard stats
    resource function get stats/[int userId](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        // Query for meals today (assuming meal_request_date is a timestamp)
        record {|int meals_today;|} mealsTodayResult = check database:dbClient->queryRow(
            `SELECT COUNT(requestedmeal_id) AS meals_today 
             FROM requestedmeals 
             WHERE user_id = ${userId} 
             AND org_id = ${orgId}
             AND DATE(meal_request_date) = CURRENT_DATE`
        );
        int mealsToday = mealsTodayResult.meals_today;

        // Query for total assets borrowed by the user
        record {|int assets_count;|} assetsResult = check database:dbClient->queryRow(
            `SELECT COUNT(requestedasset_id) AS assets_count 
             FROM requestedassets
             WHERE user_id = ${userId}
             AND org_id = ${orgId}`
        );
        int assetsCount = assetsResult.assets_count;

        // Query for total maintenance requests by the user
        record {|int maintenance_count;|} maintenanceResult = check database:dbClient->queryRow(
            `SELECT COUNT(maintenance_id) AS maintenance_count 
             FROM maintenance 
             WHERE user_id = ${userId}
             AND org_id = ${orgId}`
        );
        int maintenanceCount = maintenanceResult.maintenance_count;

        // Query for monthly meal counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyMealStream = database:dbClient->query(
            `SELECT EXTRACT(MONTH FROM meal_request_date) AS month, COUNT(requestedmeal_id) AS count 
             FROM requestedmeals
             WHERE user_id = ${userId} 
             AND org_id = ${orgId}
             GROUP BY EXTRACT(MONTH FROM meal_request_date) 
             ORDER BY month`
        );
        int[] mealsMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyMealStream
            do {
                mealsMonthlyData[row.month - 1] = row.count;
            };

        // Query for monthly asset request counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyAssetStream = database:dbClient->query(
            `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(requestedasset_id) AS count 
             FROM requestedassets
             WHERE user_id = ${userId} 
             AND org_id = ${orgId}
             GROUP BY EXTRACT(MONTH FROM submitted_date) 
             ORDER BY month`
        );
        int[] assetsMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyAssetStream
            do {
                assetsMonthlyData[row.month - 1] = row.count;
            };

        // Query for monthly maintenance request counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyMaintenanceStream = database:dbClient->query(
            `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(maintenance_id) AS count 
             FROM maintenance 
             WHERE user_id = ${userId} 
             AND org_id = ${orgId}
             GROUP BY EXTRACT(MONTH FROM submitted_date) 
             ORDER BY month`
        );
        int[] maintenanceMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyMaintenanceStream
            do {
                maintenanceMonthlyData[row.month - 1] = row.count;
            };

        // Month labels for charts
        string[] monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        // Construct the JSON response with monthLabels
        return {
            "mealsToday": mealsToday,
            "assets": assetsCount,
            "maintenanceRequests": maintenanceCount,
            "mealsMonthlyData": mealsMonthlyData,
            "assetsMonthlyData": assetsMonthlyData,
            "maintenanceMonthlyData": maintenanceMonthlyData,
            "monthLabels": monthLabels
        };
    }

    // Get recent activities for a given user
    resource function get activities/[int userId](http:Request req) returns json[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access user activities");
        }

        int orgId = check common:getOrgId(payload);
        json[] activities = [];

        // Fetch the last meal request
        stream<record {|
            string requestedmeal_id;
            string meal_type_id;
            string meal_request_date;
        |}, sql:Error?> mealStream = database:dbClient->query(
            `SELECT requestedmeal_id, meal_type_id, meal_request_date 
             FROM requestedmeals 
             WHERE user_id = ${userId} 
             AND org_id = ${orgId}
             ORDER BY meal_request_date DESC 
             LIMIT 1`
        );
        check from var meal in mealStream
            do {
                activities.push({
                    "id": meal.requestedmeal_id,
                    "type": "meal",
                    "title": "Last Meal Request",
                    "description": "Your " + meal.meal_type_id + " request has been processed",
                    "timestamp": meal.meal_request_date
                });
            };

        // Fetch the last maintenance request
        stream<record {|
            string maintenance_id;
            string description;
            string submitted_date;
        |}, sql:Error?> maintenanceStream = database:dbClient->query(
            `SELECT  maintenance_id, description, submitted_date 
             FROM maintenance 
             WHERE user_id = ${userId} 
             AND org_id = ${orgId}
             ORDER BY submitted_date DESC 
             LIMIT 1`
        );
        check from var maintenance in maintenanceStream
            do {
                activities.push({
                    "id": maintenance.maintenance_id,
                    "type": "maintenance",
                    "title": "Last Maintenance notified",
                    "description": "Your maintenance request for " + maintenance.description + " has been processed",
                    "timestamp": maintenance.submitted_date
                });
            };

        // Fetch the last asset request
        stream<record {|
            string requestedasset_id;
            string asset_name;
            string submitted_date;
        |}, sql:Error?> assetStream = database:dbClient->query(
            `SELECT ar.requestedasset_id, a.asset_name, submitted_date 
             FROM requestedassets ar 
             join assets a on a.asset_id=ar.asset_id
             WHERE ar.user_id = ${userId} 
             AND ar.org_id = ${orgId}
             ORDER BY submitted_date DESC 
             LIMIT 1`
        );
        check from var asset in assetStream
            do {
                activities.push({
                    "id": asset.requestedasset_id,
                    "type": "asset",
                    "title": "Last Asset Request",
                    "description": asset.asset_name + " has been assigned to you",
                    "timestamp": asset.submitted_date
                });
            };

        return activities;
    }

    // Get quick actions available for the user
    resource function get quickactions(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access quick actions");
        }

        return {
            actions: [
                {
                    title: "Request Asset",
                    icon: "asset",
                    path: "/assets/request"
                },
                {
                    title: "Book Meal",
                    icon: "meal",
                    path: "/meals/book"
                },
                {
                    title: "Report Issue",
                    icon: "maintenance",
                    path: "/maintenance/report"
                }
            ]
        };
    }

    resource function options .() returns http:Ok {
        return {};
    }
}

public function startDashboardUserService() returns error? {
    // Function to integrate with the service start pattern
    io:println("Dashboard User service started on port 9092");
}