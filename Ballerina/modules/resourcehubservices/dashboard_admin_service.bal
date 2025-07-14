import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

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
service /dashboard/admin on ln {
    // Only admin can access dashboard admin endpoints
    resource function get stats(http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        // Existing counts
        record {|int user_count;|} userResult = check dbClient->queryRow(`SELECT COUNT(user_id) AS user_count FROM users`);
        int userCount = userResult.user_count;

        record {|int mealevents_count;|} mealResult = check dbClient->queryRow(`SELECT COUNT(requestedmeal_id) AS mealevents_count FROM requestedmeals`);
        int mealEventsCount = mealResult.mealevents_count;

        record {|int assetrequests_count;|} assetRequestsResult = check dbClient->queryRow(`SELECT COUNT(requestedasset_id) AS assetrequests_count FROM requestedassets`);
        int assetRequestsCount = assetRequestsResult.assetrequests_count;

        record {|int maintenance_count;|} maintenanceResult = check dbClient->queryRow(`SELECT COUNT(maintenance_id) AS maintenance_count FROM maintenance`);
        int maintenanceCount = maintenanceResult.maintenance_count;

        // Query to get user count by month
        stream<MonthlyUserData, sql:Error?> monthlyUserStream = dbClient->query(
        `SELECT EXTRACT(MONTH FROM created_at) AS month, COUNT(user_id) AS count 
         FROM users 
         GROUP BY EXTRACT(MONTH FROM created_at) 
         ORDER BY month`,
        MonthlyUserData
        );

        // Convert user stream to array
        MonthlyUserData[] monthlyUserData = [];
        check from MonthlyUserData row in monthlyUserStream
            do {
                monthlyUserData.push(row);
            };

        // Create an array for all 12 months for users, initialized with 0
        int[] monthlyUserCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyUserData {
            monthlyUserCounts[row.month - 1] = row.count;
        }

        // Query to get meal events count by month
        stream<MonthlyMealData, sql:Error?> monthlyMealStream = dbClient->query(
        `SELECT EXTRACT(MONTH FROM meal_request_date) AS month, COUNT(requestedmeal_id) AS count 
         FROM requestedmeals 
         GROUP BY EXTRACT(MONTH FROM meal_request_date) 
         ORDER BY month`,
        MonthlyMealData
        );

        // Convert meal stream to array
        MonthlyMealData[] monthlyMealData = [];
        check from MonthlyMealData row in monthlyMealStream
            do {
                monthlyMealData.push(row);
            };

        // Create an array for all 12 months for meal events, initialized with 0
        int[] monthlyMealCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyMealData {
            monthlyMealCounts[row.month - 1] = row.count;
        }

        // Query to get asset requests count by month
        stream<MonthlyAssetRequestData, sql:Error?> monthlyAssetRequestStream = dbClient->query(
        `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(requestedasset_id) AS count 
         FROM requestedassets
         GROUP BY EXTRACT(MONTH FROM submitted_date) 
         ORDER BY month`,
        MonthlyAssetRequestData
        );

        // Convert asset request stream to array
        MonthlyAssetRequestData[] monthlyAssetRequestData = [];
        check from MonthlyAssetRequestData row in monthlyAssetRequestStream
            do {
                monthlyAssetRequestData.push(row);
            };

        // Create an array for all 12 months for asset requests, initialized with 0
        int[] monthlyAssetRequestCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyAssetRequestData {
            monthlyAssetRequestCounts[row.month - 1] = row.count;
        }

        // Query to get maintenance count by month
        stream<MonthlyMaintenanceData, sql:Error?> monthlyMaintenanceStream = dbClient->query(
        `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(maintenance_id) AS count 
         FROM maintenance 
         GROUP BY EXTRACT(MONTH FROM submitted_date) 
         ORDER BY month`,
        MonthlyMaintenanceData
        );

        // Convert maintenance stream to array
        MonthlyMaintenanceData[] monthlyMaintenanceData = [];
        check from MonthlyMaintenanceData row in monthlyMaintenanceStream
            do {
                monthlyMaintenanceData.push(row);
            };

        // Create an array for all 12 months for maintenance, initialized with 0
        int[] monthlyMaintenanceCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyMaintenanceData {
            monthlyMaintenanceCounts[row.month - 1] = row.count;
        }

        // Construct the JSON response
        return [
            {
                "title": "Total Users",
                "value": userCount,
                "icon": "Users",
                "monthlyData": monthlyUserCounts
            },
            {
                "title": "Meals Served",
                "value": mealEventsCount,
                "icon": "Utensils",
                "monthlyData": monthlyMealCounts
            },
            {
                "title": "Resources",
                "value": assetRequestsCount,
                "icon": "Box",
                "monthlyData": monthlyAssetRequestCounts
            },
            {
                "title": "Services",
                "value": maintenanceCount,
                "icon": "Wrench",
                "monthlyData": monthlyMaintenanceCounts
            }
        ];
    }

    // Resource to get data for resource cards
    resource function get resources(http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        return [
            {
                title: "Food Supplies",
                total: 1250,
                highPriority: 45,
                progress: 75
            },
            {
                title: "Medical Kits",
                total: 358,
                highPriority: 20,
                progress: 60
            },
            {
                title: "Shelter Equipment",
                total: 523,
                highPriority: 32,
                progress: 85
            }
        ];
    }

    // Resource to get meal distribution data for pie chart
    resource function get mealdistribution(http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        // Query to get all meal types from mealtimes
        stream<MealTime, sql:Error?> mealTimeStream = dbClient->query(
        `SELECT mealtime_id, mealtime_name FROM mealtimes ORDER BY mealtime_id`,
        MealTime
        );

        // Convert meal time stream to array
        MealTime[] mealTimes = [];
        check from MealTime row in mealTimeStream
            do {
                mealTimes.push(row);
            };

        // Query to get meal event counts by day of week and meal type
        stream<MealDistributionData, sql:Error?> mealDistributionStream = dbClient->query(
        `SELECT DAYOFWEEK(meal_request_date) AS day_of_week, mealtimes.mealtime_name, COUNT(requestedmeal_id) AS count 
         FROM requestedmeals 
         JOIN mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
         GROUP BY DAYOFWEEK(meal_request_date), mealtimes.mealtime_name
         ORDER BY day_of_week, mealtimes.mealtime_name`,
        MealDistributionData
        );

        // Convert meal distribution stream to array
        MealDistributionData[] mealDistributionData = [];
        check from MealDistributionData row in mealDistributionStream
            do {
                mealDistributionData.push(row);
            };

        // Initialize a map to store data arrays for each meal type
        map<int[]> mealDataMap = {};
        foreach var meal in mealTimes {
            mealDataMap[meal.mealtime_name] = [0, 0, 0, 0, 0, 0, 0]; // 7 days: Sun, Mon, Tue, Wed, Thu, Fri, Sat
        }

        // Populate data arrays based on meal_name and day_of_week
        foreach var row in mealDistributionData {
            // DAYOFWEEK returns 1=Sunday, 2=Monday, ..., 7=Saturday
            // Map to array index: 1->0 (Sun), 2->1 (Mon), ..., 7->6 (Sat)
            int arrayIndex = row.day_of_week - 1;
            if (mealDataMap.hasKey(row.mealtime_name)) {
                int[]? dataArray = mealDataMap[row.mealtime_name];
                if (dataArray is int[]) {
                    dataArray[arrayIndex] = row.count;
                }
            }
        }

        // Define border colors for datasets (cycle through a predefined list)
        string[] borderColors = ["#4C51BF", "#38B2AC", "#ED8936", "#E53E3E", "#805AD5", "#319795", "#DD6B20"];
        json[] datasets = [];
        int colorIndex = 0;

        // Create datasets dynamically
        foreach var meal in mealTimes {
            string mealName = meal.mealtime_name;
            int[]? dataArray = mealDataMap[mealName];
            if (dataArray is int[]) {
                datasets.push({
                    "label": mealName,
                    "data": dataArray,
                    "borderColor": borderColors[colorIndex % borderColors.length()],
                    "tension": 0.4
                });
                colorIndex += 1;
            }
        }

        // Construct the JSON response
        return {
            "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            "datasets": datasets
        };
    }

    // Resource to get resource allocation data
    resource function get resourceallocation(http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        // Query to get total and allocated quantities by category
        stream<ResourceAllocationData, sql:Error?> allocationStream = dbClient->query(
        `SELECT 
            category,
            SUM(quantity) AS total
         FROM assets 
         GROUP BY category 
         ORDER BY category`,
        ResourceAllocationData
        );

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
                "category": row.category,
                "allocated": row.total,
                "total": row.total
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
