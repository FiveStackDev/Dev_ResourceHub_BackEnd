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

service /dashboard/user on database:ln {

    // Only admin, manager, and User can view user dashboard stats
    resource function get stats/[int userId](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access user dashboard");
        }

        // Query for meals today (assuming meal_request_date is a timestamp)
        record {|int meals_today;|} mealsTodayResult = check database:dbClient->queryRow(`
            SELECT COUNT(*) as meals_today 
            FROM requestedmeals 
            WHERE user_id = ${userId} AND DATE(meal_request_date) = CURDATE()
        `);
        int mealsToday = mealsTodayResult.meals_today;

        // Query for total assets borrowed by the user
        record {|int assets_count;|} assetsResult = check database:dbClient->queryRow(`
            SELECT COUNT(*) as assets_count 
            FROM requestedassets 
            WHERE user_id = ${userId} AND status = 'approved'
        `);
        int assetsCount = assetsResult.assets_count;

        // Query for total maintenance requests by the user
        record {|int maintenance_count;|} maintenanceResult = check database:dbClient->queryRow(`
            SELECT COUNT(*) as maintenance_count 
            FROM maintenance 
            WHERE user_id = ${userId}
        `);
        int maintenanceCount = maintenanceResult.maintenance_count;

        // Query for monthly meal counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyMealStream = database:dbClient->query(`
            SELECT MONTH(meal_request_date) as month, COUNT(*) as count 
            FROM requestedmeals 
            WHERE user_id = ${userId} AND YEAR(meal_request_date) = YEAR(CURDATE())
            GROUP BY MONTH(meal_request_date)
            ORDER BY month
        `);
        int[] mealsMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyMealStream
        do {
            mealsMonthlyData[row.month - 1] = row.count;
        };

        // Query for monthly asset request counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyAssetStream = database:dbClient->query(`
            SELECT MONTH(submitted_date) as month, COUNT(*) as count 
            FROM requestedassets 
            WHERE user_id = ${userId} AND YEAR(submitted_date) = YEAR(CURDATE())
            GROUP BY MONTH(submitted_date)
            ORDER BY month
        `);
        int[] assetsMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyAssetStream
        do {
            assetsMonthlyData[row.month - 1] = row.count;
        };

        // Query for monthly maintenance request counts
        stream<record {|int month; int count;|}, sql:Error?> monthlyMaintenanceStream = database:dbClient->query(`
            SELECT MONTH(submitted_date) as month, COUNT(*) as count 
            FROM maintenance 
            WHERE user_id = ${userId} AND YEAR(submitted_date) = YEAR(CURDATE())
            GROUP BY MONTH(submitted_date)
            ORDER BY month
        `);
        int[] maintenanceMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in monthlyMaintenanceStream
        do {
            maintenanceMonthlyData[row.month - 1] = row.count;
        };

        // Construct the JSON response
        return {
            meals_today: mealsToday,
            assets_count: assetsCount,
            maintenance_count: maintenanceCount,
            meals_monthly_data: mealsMonthlyData,
            assets_monthly_data: assetsMonthlyData,
            maintenance_monthly_data: maintenanceMonthlyData
        };
    }

    // Get recent activities for a given user
    resource function get activities/[int userId](http:Request req) returns json[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin","User","SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access user activities");
        }

        json[] activities = [];

        // Fetch the last meal request
        stream<record {|
            string meal_request_date;
        |}, sql:Error?> mealStream = database:dbClient->query(`
            SELECT meal_request_date 
            FROM requestedmeals 
            WHERE user_id = ${userId} 
            ORDER BY meal_request_date DESC 
            LIMIT 1
        `);
        check from var meal in mealStream
        do {
            activities.push({
                "type": "meal",
                "date": meal.meal_request_date,
                "description": "Meal requested"
            });
        };

        // Fetch the last maintenance request
        stream<record {|
            string submitted_date;
        |}, sql:Error?> maintenanceStream = database:dbClient->query(`
            SELECT submitted_date 
            FROM maintenance 
            WHERE user_id = ${userId} 
            ORDER BY submitted_date DESC 
            LIMIT 1
        `);
        check from var maintenance in maintenanceStream
        do {
            activities.push({
                "type": "maintenance",
                "date": maintenance.submitted_date,
                "description": "Maintenance request submitted"
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
    io:println("Dashboard User service started on port 9090");
}
