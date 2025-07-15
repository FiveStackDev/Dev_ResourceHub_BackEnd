import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerina/jwt;
import ResourceHub.database;
import ResourceHub.common;
import ResourceHub.meal;

type MonthlyUserData record {|
    int month;
    int count;
|};

type MonthlyMealData record {|
    int month;
    int count;
|};

type MonthlyAssetRequestData record {|
    int month;
    int count;
|};

type MonthlyMaintenanceData record {|
    int month;
    int count;
|};

type MealDistributionData record {|
    int day_of_week;
    string mealtime_name;
    int count;
|};

type ResourceAllocationData record {|
    string category;
    decimal allocated;
    decimal total;
|};

// DashboardAdminService - RESTful service to provide data for admin dashboard
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /dashboard/admin on database:ln {
    // Only admin can access dashboard admin endpoints
    resource function get stats(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access admin dashboard");
        }

        // Get total counts for dashboard cards
        record {|int total_users;|} usersResult = check database:dbClient->queryRow(`SELECT COUNT(*) as total_users FROM users`);
        record {|int total_assets;|} assetsResult = check database:dbClient->queryRow(`SELECT COUNT(*) as total_assets FROM assets`);
        record {|int total_requests;|} requestsResult = check database:dbClient->queryRow(`SELECT COUNT(*) as total_requests FROM requestedassets`);
        record {|int total_maintenance;|} maintenanceResult = check database:dbClient->queryRow(`SELECT COUNT(*) as total_maintenance FROM maintenance`);

        return {
            total_users: usersResult.total_users,
            total_assets: assetsResult.total_assets,
            total_requests: requestsResult.total_requests,
            total_maintenance: maintenanceResult.total_maintenance
        };
    }

    // Resource to get data for resource cards
    resource function get resources(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access admin dashboard");
        }

        // Get monthly data for charts
        stream<record {|int month; int count;|}, sql:Error?> userStream = database:dbClient->query(`
            SELECT MONTH(created_at) as month, COUNT(*) as count 
            FROM users 
            WHERE YEAR(created_at) = YEAR(CURDATE())
            GROUP BY MONTH(created_at)
            ORDER BY month
        `);

        int[] userMonthlyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        check from var row in userStream
        do {
            userMonthlyData[row.month - 1] = row.count;
        };

        return {
            monthly_user_data: userMonthlyData
        };
    }

    // Resource to get meal distribution data for pie chart
    resource function get mealdistribution(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access admin dashboard");
        }

        // Query to get all meal types from mealtimes
        stream<meal:MealTime, sql:Error?> mealTimeStream = database:dbClient->query(`
            SELECT mealtime_id, mealtime_name, mealtime_image_url FROM mealtimes
        `);

        // Convert meal time stream to array
        meal:MealTime[] mealTimes = [];
        check from meal:MealTime row in mealTimeStream
        do {
            mealTimes.push(row);
        };

        return {
            meal_types: mealTimes
        };
    }

    // Resource to get resource allocation data
    resource function get resourceallocation(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access admin dashboard");
        }

        // Query to get total and allocated quantities by category
        stream<ResourceAllocationData, sql:Error?> allocationStream = database:dbClient->query(`
            SELECT 
                a.category, 
                COALESCE(SUM(ra.quantity), 0) as allocated,
                SUM(a.quantity) as total
            FROM assets a
            LEFT JOIN requestedassets ra ON a.asset_id = ra.asset_id AND ra.status = 'approved'
            GROUP BY a.category
        `);

        // Convert stream to array
        ResourceAllocationData[] allocationData = [];
        check from ResourceAllocationData row in allocationStream
        do {
            allocationData.push(row);
        };

        // Construct the JSON response
        json[] result = [];
        foreach var row in allocationData {
            result.push({
                category: row.category,
                allocated: row.allocated,
                total: row.total,
                percentage: row.total > 0.0d ? (row.allocated / row.total) * 100 : 0
            });
        }

        return result;
    }

    resource function options .() returns http:Ok {
        return http:OK;
    }
}

public function startDashboardAdminService() returns error? {
    // Function to integrate with the service start pattern
    io:println("Dashboard Admin service started on port 9090");
}
