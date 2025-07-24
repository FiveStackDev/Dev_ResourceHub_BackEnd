import ResourceHub.common;
import ResourceHub.database;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;
import ballerina/time;

// DashboardAdminService - RESTful service to provide data for admin dashboard
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /dashboard/admin on database:dashboardListener {
    // STAT CARD OPERATIONS
    // Only admin can access dashboard admin endpoints
    resource function get stats(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Optimized query to get all counts in a single database call
        record {|
            int user_count;
            int mealevents_count;
            int assetrequests_count;
            int maintenance_count;
        |} statsCounts = check database:dbClient->queryRow(`
            SELECT
                (SELECT COUNT(user_id) FROM users WHERE org_id = ${orgId}) AS user_count,
                (SELECT COUNT(requestedmeal_id) FROM requestedmeals WHERE org_id = ${orgId} AND DATE(meal_request_date) = CURDATE()) AS mealevents_count,
                (SELECT COUNT(requestedasset_id) FROM requestedassets WHERE org_id = ${orgId} AND DATE(submitted_date) = CURDATE()) AS assetrequests_count,
                (SELECT COUNT(maintenance_id) FROM maintenance WHERE org_id = ${orgId} AND DATE(submitted_date) = CURDATE()) AS maintenance_count
        `);

        int userCount = statsCounts.user_count;
        int mealEventsCount = statsCounts.mealevents_count;
        int assetRequestsCount = statsCounts.assetrequests_count;
        int maintenanceCount = statsCounts.maintenance_count;

        // Month labels for charts
        time:Civil civilTime = time:utcToCivil(time:utcNow());
        int currentMonth = civilTime.month;
        string[] allMonthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

        int startMonthIndex = (currentMonth - 1 - 11 + 12) % 12;
        string[] monthLabels = [];
        foreach int i in 0 ... 11 {
            monthLabels.push(allMonthLabels[(startMonthIndex + i) % 12]);
        }

        // EACH STATCARD POPUP OPERATIONS
        // Query to get user count by month
        stream<MonthlyUserData, sql:Error?> monthlyUserStream = database:dbClient->query(
        `SELECT EXTRACT(MONTH FROM created_at) AS month, COUNT(user_id) AS count 
         FROM users 
         WHERE org_id = ${orgId}
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
        int[] monthlyUserCountsAll = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyUserData {
            monthlyUserCountsAll[row.month - 1] = row.count;
        }
        int[] monthlyUserCounts = [];
        foreach int i in 0 ... 11 {
            monthlyUserCounts.push(monthlyUserCountsAll[(startMonthIndex + i) % 12]);
        }

        // Query to get meal events count by month
        stream<MonthlyMealData, sql:Error?> monthlyMealStream = database:dbClient->query(
        `SELECT EXTRACT(MONTH FROM meal_request_date) AS month, COUNT(requestedmeal_id) AS count 
         FROM requestedmeals 
         WHERE org_id = ${orgId}
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
        int[] monthlyMealCountsAll = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyMealData {
            monthlyMealCountsAll[row.month - 1] = row.count;
        }
        int[] monthlyMealCounts = [];
        foreach int i in 0 ... 11 {
            monthlyMealCounts.push(monthlyMealCountsAll[(startMonthIndex + i) % 12]);
        }

        // Query to get asset requests count by month
        stream<MonthlyAssetRequestData, sql:Error?> monthlyAssetRequestStream = database:dbClient->query(
        `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(requestedasset_id) AS count 
         FROM requestedassets
         WHERE org_id = ${orgId}
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
        int[] monthlyAssetRequestCountsAll = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyAssetRequestData {
            monthlyAssetRequestCountsAll[row.month - 1] = row.count;
        }
        int[] monthlyAssetRequestCounts = [];
        foreach int i in 0 ... 11 {
            monthlyAssetRequestCounts.push(monthlyAssetRequestCountsAll[(startMonthIndex + i) % 12]);
        }

        // Query to get maintenance count by month
        stream<MonthlyMaintenanceData, sql:Error?> monthlyMaintenanceStream = database:dbClient->query(
        `SELECT EXTRACT(MONTH FROM submitted_date) AS month, COUNT(maintenance_id) AS count 
         FROM maintenance 
         WHERE org_id = ${orgId}
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
        int[] monthlyMaintenanceCountsAll = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyMaintenanceData {
            monthlyMaintenanceCountsAll[row.month - 1] = row.count;
        }
        int[] monthlyMaintenanceCounts = [];
        foreach int i in 0 ... 11 {
            monthlyMaintenanceCounts.push(monthlyMaintenanceCountsAll[(startMonthIndex + i) % 12]);
        }

        // Construct the JSON response with monthLabels
        return [
            {
                "title": "Total Users",
                "value": userCount,
                "icon": "Users",
                "monthlyData": monthlyUserCounts,
                "monthLabels": monthLabels
            },
            {
                "title": "Today's Meals",
                "value": mealEventsCount,
                "icon": "Utensils",
                "monthlyData": monthlyMealCounts,
                "monthLabels": monthLabels
            },
            {
                "title": "Today's Resources",
                "value": assetRequestsCount,
                "icon": "Box",
                "monthlyData": monthlyAssetRequestCounts,
                "monthLabels": monthLabels
            },
            {
                "title": "Today's Services",
                "value": maintenanceCount,
                "icon": "Wrench",
                "monthlyData": monthlyMaintenanceCounts,
                "monthLabels": monthLabels
            }
        ];
    }

    // MEAL DASHBOARD OPERATIONS
    // Resource to get meal distribution data for line chart
    resource function get mealdistribution(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get date from query param, default to today if not provided
        map<string[]> queryParams = req.getQueryParams();
        string date = "";
        if queryParams.hasKey("date") {
            string[]? dateArrOpt = queryParams["date"];
            if dateArrOpt is string[] && dateArrOpt.length() > 0 {
                date = dateArrOpt[0];
            }
        }
        if date == "" {
            time:Civil civilNow = time:utcToCivil(time:utcNow());
            date = string `${civilNow.year}-${civilNow.month < 10 ? "0" : ""}${civilNow.month}-${civilNow.day < 10 ? "0" : ""}${civilNow.day}`;
        }

        // Query to get all meal types from mealtimes
        stream<MealTime, sql:Error?> mealTimeStream = database:dbClient->query(
        `SELECT mealtime_id, mealtime_name FROM mealtimes WHERE org_id = ${orgId} ORDER BY mealtime_id`,
        MealTime
        );

        // Convert meal time stream to array
        MealTime[] mealTimes = [];
        check from MealTime row in mealTimeStream
            do {
                mealTimes.push(row);
            };

        // Prepare 8 days: past 6 days from selected date, selected date, next day
        time:Civil civilDate = check time:civilFromString(date + "T00:00:00.000Z");
        time:Utc baseUtc = check time:utcFromCivil(civilDate);
        int secondsInDay = 86400;
        time:Utc startUtc = time:utcAddSeconds(baseUtc, <time:Seconds>(-6 * secondsInDay));

        // Build 8 consecutive dates (YYYY-MM-DD) and day labels
        string[] dateKeys = [];
        string[] dayLabels = [];
        foreach int i in 0 ... 7 {
            time:Utc dUtc = time:utcAddSeconds(startUtc, <time:Seconds>(i * secondsInDay));
            time:Civil dCivil = time:utcToCivil(dUtc);
            string dateKey = string `${dCivil.year}-${dCivil.month < 10 ? "0" : ""}${dCivil.month}-${dCivil.day < 10 ? "0" : ""}${dCivil.day}`;
            dateKeys.push(dateKey);
            
            string dayLabel = "";
            match dCivil.dayOfWeek {
                time:SUNDAY => { dayLabel = i == 6 ? "Sun (Selected)" : i == 7 ? "Sun (Next Day)" : "Sun"; }
                time:MONDAY => { dayLabel = i == 6 ? "Mon (Selected)" : i == 7 ? "Mon (Next Day)" : "Mon"; }
                time:TUESDAY => { dayLabel = i == 6 ? "Tue (Selected)" : i == 7 ? "Tue (Next Day)" : "Tue"; }
                time:WEDNESDAY => { dayLabel = i == 6 ? "Wed (Selected)" : i == 7 ? "Wed (Next Day)" : "Wed"; }
                time:THURSDAY => { dayLabel = i == 6 ? "Thu (Selected)" : i == 7 ? "Thu (Next Day)" : "Thu"; }
                time:FRIDAY => { dayLabel = i == 6 ? "Fri (Selected)" : i == 7 ? "Fri (Next Day)" : "Fri"; }
                time:SATURDAY => { dayLabel = i == 6 ? "Sat (Selected)" : i == 7 ? "Sat (Next Day)" : "Sat"; }
            }
            dayLabels.push(dayLabel);
        }

        // Query to get meal event counts by date and meal type for 8 days based on selected date
        stream<MealDistributionData, sql:Error?> mealDistributionStream = database:dbClient->query(
        `SELECT DATE(meal_request_date) AS meal_date, DAYOFWEEK(meal_request_date) AS day_of_week, mealtimes.mealtime_name, COUNT(requestedmeal_id) AS count 
         FROM requestedmeals 
         JOIN mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
         WHERE requestedmeals.org_id = ${orgId} AND DATE(meal_request_date) BETWEEN DATE_SUB(STR_TO_DATE(${date}, '%Y-%m-%d'), INTERVAL 6 DAY) AND DATE_ADD(STR_TO_DATE(${date}, '%Y-%m-%d'), INTERVAL 1 DAY)
         GROUP BY meal_date, DAYOFWEEK(meal_request_date), mealtimes.mealtime_name
         ORDER BY meal_date, mealtimes.mealtime_name`,
        MealDistributionData
        );

        // Convert meal distribution stream to array
        MealDistributionData[] mealDistributionData = [];
        check from MealDistributionData row in mealDistributionStream
            do {
                mealDistributionData.push(row);
            };

        // Initialize a map to store data arrays for each meal type (8 days)
        map<int[]> mealDataMap = {};
        foreach var meal in mealTimes {
            mealDataMap[meal.mealtime_name] = [0, 0, 0, 0, 0, 0, 0, 0];
        }

        // Populate data arrays based on meal_name and meal_date
        foreach var row in mealDistributionData {
            string mealDate = row.meal_date;
            string mealName = row.mealtime_name;
            int count = row.count;
            int? idxOpt = dateKeys.indexOf(mealDate);
            if idxOpt is int {
                int idx = idxOpt;
                if mealDataMap.hasKey(mealName) {
                    int[]? dataArray = mealDataMap[mealName];
                    if (dataArray is int[]) {
                        dataArray[idx] = count;
                    }
                }
            }
        }

        json[] datasets = [];
        string[] borderColors = ["#4C51BF", "#38B2AC", "#ED8936", "#E53E3E", "#805AD5", "#319795", "#DD6B20"];
        int colorIndex = 0;

        foreach var meal in mealTimes {
            string mealName = meal.mealtime_name;
            int[]? dataArr = mealDataMap[mealName];
            if (dataArr is int[]) {
                datasets.push({
                    "label": mealName,
                    "data": dataArr,
                    "borderColor": borderColors[colorIndex % borderColors.length()],
                    "tension": 0.4
                });
                colorIndex += 1;
            }
        }

        // Construct the JSON response
        return {
            "labels": dayLabels,
            "datasets": datasets
        };
    }

    // PIE CHART OPERATIONS
    // Resource to get resource allocation data for a selected date (available assets)
    resource function get resourceallocation(http:Request req) returns json|error {
        // Simplified error handling for debugging
        do {
            jwt:Payload payload = check common:getValidatedPayload(req);
            if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
                return error("Forbidden: You do not have permission to access this resource");
            }

            int orgId = check common:getOrgId(payload);

            // Very simple query to test database connectivity
            stream<record {|string category; int allocated;|}, sql:Error?> allocationStream = database:dbClient->query(
            `SELECT 
                category,
                CAST(SUM(quantity) AS SIGNED) AS allocated
             FROM assets
             WHERE org_id = ${orgId}
             GROUP BY category
             ORDER BY category`,
            typeof ({category: "", allocated: 0})
            );

            // Convert stream to array with error handling
            json[] result = [];
            error? streamError = from var row in allocationStream
                do {
                    result.push({
                        "category": row.category,
                        "allocated": row.allocated
                    });
                };
            
            if streamError is error {
                return error("Database query failed: " + streamError.message());
            }

            return result;
        } on fail var e {
            return error("Resource allocation endpoint failed: " + e.message());
        }
    }

    // Get top 3 most requested assets data for a selected date
    resource function get mostrequestedasset(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get date from query param, default to today if not provided
        map<string[]> queryParams = req.getQueryParams();
        string date = "";
        if queryParams.hasKey("date") {
            string[]? dateArrOpt = queryParams["date"];
            if dateArrOpt is string[] && dateArrOpt.length() > 0 {
                date = dateArrOpt[0];
            }
        }
        if date == "" {
            time:Civil civilNow = time:utcToCivil(time:utcNow());
            date = string `${civilNow.year}-${civilNow.month < 10 ? "0" : ""}${civilNow.month}-${civilNow.day < 10 ? "0" : ""}${civilNow.day}`;
        }

        // Query to get the top 3 most requested assets for the selected date
        stream<record {|string asset_name; string category; int request_count;|}, sql:Error?> mostRequestedStream = database:dbClient->query(
            `SELECT a.asset_name, a.category, COUNT(ra.requestedasset_id) AS request_count
             FROM assets a
             LEFT JOIN requestedassets ra 
               ON a.asset_id = ra.asset_id 
               AND ra.org_id = ${orgId}
               AND DATE(ra.submitted_date) = ${date}
             WHERE a.org_id = ${orgId}
             GROUP BY a.asset_id, a.asset_name, a.category
             HAVING request_count > 0
             ORDER BY request_count DESC
             LIMIT 3`,
            typeof ({asset_name: "", category: "", request_count: 0})
        );

        // Get the results
        record {|string asset_name; string category; int request_count;|}[] topAssets = [];
        check from var row in mostRequestedStream
            do {
                topAssets.push(row);
            };

        if topAssets.length() == 0 {
            return [];
        }

        return topAssets;
    }

    // NEW: Meal type distribution for a selected date (pie chart)
    resource function get mealtypedist(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get date from query param, default to today if not provided

        map<string[]> queryParams = req.getQueryParams();
        string date = "";
        if queryParams.hasKey("date") {
            string[]? dateArrOpt = queryParams["date"];
            if dateArrOpt is string[] && dateArrOpt.length() > 0 {
                date = dateArrOpt[0];
            }
        }
        if date == "" {
            time:Civil civilNow = time:utcToCivil(time:utcNow());
            date = string `${civilNow.year}-${civilNow.month < 10 ? "0" : ""}${civilNow.month}-${civilNow.day < 10 ? "0" : ""}${civilNow.day}`;
        }

        // Query to get meal type distribution for the selected date
        stream<record {|string mealtype; int count;|}, sql:Error?> mealTypeStream = database:dbClient->query(
            `SELECT mealtypes.mealtype_name AS mealtype, 
                    COUNT(requestedmeals.requestedmeal_id) AS count
             FROM mealtypes
             LEFT JOIN requestedmeals 
               ON requestedmeals.meal_type_id = mealtypes.mealtype_id
               AND requestedmeals.org_id = ${orgId}
               AND DATE(requestedmeals.meal_request_date) = ${date}
             WHERE mealtypes.org_id = ${orgId}
             GROUP BY mealtypes.mealtype_name
             ORDER BY mealtypes.mealtype_name`,
            typeof ({mealtype: "", count: 0})
        );

        // Convert stream to array
        json[] result = [];
        check from var row in mealTypeStream
            do {
                result.push({
                    "mealtype": row.mealtype,
                    "count": row.count
                });
            };

        return {
            "date": date,
            "data": result
        };
    }

    // NEW: Get top 3 most requested meal types for a selected date
    resource function get mostrequestedmealtypes(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get date from query param, default to today if not provided
        map<string[]> queryParams = req.getQueryParams();
        string date = "";
        if queryParams.hasKey("date") {
            string[]? dateArrOpt = queryParams["date"];
            if dateArrOpt is string[] && dateArrOpt.length() > 0 {
                date = dateArrOpt[0];
            }
        }
        if date == "" {
            time:Civil civilNow = time:utcToCivil(time:utcNow());
            date = string `${civilNow.year}-${civilNow.month < 10 ? "0" : ""}${civilNow.month}-${civilNow.day < 10 ? "0" : ""}${civilNow.day}`;
        }

        // Query to get top 3 most requested meal types for the selected date
        stream<record {|string mealtype; int count;|}, sql:Error?> topMealTypesStream = database:dbClient->query(
            `SELECT mealtypes.mealtype_name AS mealtype, 
                    COUNT(requestedmeals.requestedmeal_id) AS count
             FROM mealtypes
             LEFT JOIN requestedmeals 
               ON requestedmeals.meal_type_id = mealtypes.mealtype_id
               AND requestedmeals.org_id = ${orgId}
               AND DATE(requestedmeals.meal_request_date) = ${date}
             WHERE mealtypes.org_id = ${orgId}
             GROUP BY mealtypes.mealtype_name
             HAVING count > 0
             ORDER BY count DESC
             LIMIT 3`,
            typeof ({mealtype: "", count: 0})
        );

        // Convert stream to array
        json[] result = [];
        check from var row in topMealTypesStream
            do {
                result.push({
                    "mealtype": row.mealtype,
                    "count": row.count
                });
            };

        // If no meal types found, return empty array with message
        if result.length() == 0 {
            return {
                "date": date,
                "data": [],
                "message": "No meal requests found for this date"
            };
        }

        return {
            "date": date,
            "data": result
        };
    }

    // NEW: Asset distribution data for line chart based on selected date
    resource function get assetdistribution(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get date from query param, default to today if not provided
        map<string[]> queryParams = req.getQueryParams();
        string date = "";
        if queryParams.hasKey("date") {
            string[]? dateArrOpt = queryParams["date"];
            if dateArrOpt is string[] && dateArrOpt.length() > 0 {
                date = dateArrOpt[0];
            }
        }
        if date == "" {
            time:Civil civilNow = time:utcToCivil(time:utcNow());
            date = string `${civilNow.year}-${civilNow.month < 10 ? "0" : ""}${civilNow.month}-${civilNow.day < 10 ? "0" : ""}${civilNow.day}`;
        }

        // Prepare 8 days: past 6 days from selected date, selected date, next day
        time:Civil civilDate = check time:civilFromString(date + "T00:00:00.000Z");
        time:Utc baseUtc = check time:utcFromCivil(civilDate);
        int secondsInDay = 86400;
        time:Utc startUtc = time:utcAddSeconds(baseUtc, <time:Seconds>(-6 * secondsInDay));

        // Build 8 consecutive dates (YYYY-MM-DD) and day labels
        string[] dateKeys = [];
        string[] dayLabels = [];
        foreach int i in 0 ... 7 {
            time:Utc dUtc = time:utcAddSeconds(startUtc, <time:Seconds>(i * secondsInDay));
            time:Civil dCivil = time:utcToCivil(dUtc);
            string dateKey = string `${dCivil.year}-${dCivil.month < 10 ? "0" : ""}${dCivil.month}-${dCivil.day < 10 ? "0" : ""}${dCivil.day}`;
            dateKeys.push(dateKey);
            
            string dayLabel = "";
            match dCivil.dayOfWeek {
                time:SUNDAY => { dayLabel = i == 6 ? "Sun (Selected)" : i == 7 ? "Sun (Next Day)" : "Sun"; }
                time:MONDAY => { dayLabel = i == 6 ? "Mon (Selected)" : i == 7 ? "Mon (Next Day)" : "Mon"; }
                time:TUESDAY => { dayLabel = i == 6 ? "Tue (Selected)" : i == 7 ? "Tue (Next Day)" : "Tue"; }
                time:WEDNESDAY => { dayLabel = i == 6 ? "Wed (Selected)" : i == 7 ? "Wed (Next Day)" : "Wed"; }
                time:THURSDAY => { dayLabel = i == 6 ? "Thu (Selected)" : i == 7 ? "Thu (Next Day)" : "Thu"; }
                time:FRIDAY => { dayLabel = i == 6 ? "Fri (Selected)" : i == 7 ? "Fri (Next Day)" : "Fri"; }
                time:SATURDAY => { dayLabel = i == 6 ? "Sat (Selected)" : i == 7 ? "Sat (Next Day)" : "Sat"; }
            }
            dayLabels.push(dayLabel);
        }

        // Query to get distinct asset categories
        stream<record {|string category;|}, sql:Error?> categoryStream = database:dbClient->query(
            `SELECT DISTINCT a.category
             FROM assets a
             WHERE a.org_id = ${orgId}
             ORDER BY a.category`,
            typeof ({category: ""})
        );

        // Convert category stream to array
        string[] categories = [];
        check from var row in categoryStream
            do {
                categories.push(row.category);
            };

        // Query to get asset request counts by date and category for 8 days
        stream<record {|string request_date; string category; int count;|}, sql:Error?> assetDistributionStream = database:dbClient->query(
            `SELECT DATE(ra.submitted_date) AS request_date, a.category, COUNT(ra.requestedasset_id) AS count 
             FROM requestedassets ra
             JOIN assets a ON ra.asset_id = a.asset_id
             WHERE ra.org_id = ${orgId} AND DATE(ra.submitted_date) BETWEEN DATE_SUB(STR_TO_DATE(${date}, '%Y-%m-%d'), INTERVAL 6 DAY) AND DATE_ADD(STR_TO_DATE(${date}, '%Y-%m-%d'), INTERVAL 1 DAY)
             GROUP BY request_date, a.category
             ORDER BY request_date, a.category`,
            typeof ({request_date: "", category: "", count: 0})
        );

        // Convert asset distribution stream to array
        record {|string request_date; string category; int count;|}[] assetDistributionData = [];
        check from var row in assetDistributionStream
            do {
                assetDistributionData.push(row);
            };

        // Initialize a map to store data arrays for each category (8 days)
        map<int[]> assetDataMap = {};
        foreach var category in categories {
            assetDataMap[category] = [0, 0, 0, 0, 0, 0, 0, 0];
        }

        // Populate data arrays based on category and request_date
        foreach var row in assetDistributionData {
            string requestDate = row.request_date;
            string category = row.category;
            int count = row.count;
            int? idxOpt = dateKeys.indexOf(requestDate);
            if idxOpt is int {
                int[]? dataArr = assetDataMap[category];
                if (dataArr is int[]) {
                    dataArr[idxOpt] = count;
                }
            }
        }

        json[] datasets = [];
        string[] borderColors = ["#4C51BF", "#38B2AC", "#ED8936", "#E53E3E", "#805AD5", "#319795", "#DD6B20"];
        int colorIndex = 0;

        foreach var category in categories {
            int[]? dataArr = assetDataMap[category];
            if (dataArr is int[]) {
                datasets.push({
                    "label": category,
                    "data": dataArr,
                    "borderColor": borderColors[colorIndex % borderColors.length()],
                    "tension": 0.4
                });
                colorIndex += 1;
            }
        }

        // Construct the JSON response
        return {
            "labels": dayLabels,
            "datasets": datasets
        };
    }

    // NEW: Services distribution data for line chart based on selected date
    resource function get servicesdistribution(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get date from query param, default to today if not provided
        map<string[]> queryParams = req.getQueryParams();
        string date = "";
        if queryParams.hasKey("date") {
            string[]? dateArrOpt = queryParams["date"];
            if dateArrOpt is string[] && dateArrOpt.length() > 0 {
                date = dateArrOpt[0];
            }
        }
        if date == "" {
            time:Civil civilNow = time:utcToCivil(time:utcNow());
            date = string `${civilNow.year}-${civilNow.month < 10 ? "0" : ""}${civilNow.month}-${civilNow.day < 10 ? "0" : ""}${civilNow.day}`;
        }

        // Prepare 8 days: past 6 days from selected date, selected date, next day
        time:Civil civilDate = check time:civilFromString(date + "T00:00:00.000Z");
        time:Utc baseUtc = check time:utcFromCivil(civilDate);
        int secondsInDay = 86400;
        time:Utc startUtc = time:utcAddSeconds(baseUtc, <time:Seconds>(-6 * secondsInDay));

        // Build 8 consecutive dates (YYYY-MM-DD) and day labels
        string[] dateKeys = [];
        string[] dayLabels = [];
        foreach int i in 0 ... 7 {
            time:Utc dUtc = time:utcAddSeconds(startUtc, <time:Seconds>(i * secondsInDay));
            time:Civil dCivil = time:utcToCivil(dUtc);
            string dateKey = string `${dCivil.year}-${dCivil.month < 10 ? "0" : ""}${dCivil.month}-${dCivil.day < 10 ? "0" : ""}${dCivil.day}`;
            dateKeys.push(dateKey);
            
            string dayLabel = "";
            match dCivil.dayOfWeek {
                time:SUNDAY => { dayLabel = i == 6 ? "Sun (Selected)" : i == 7 ? "Sun (Next Day)" : "Sun"; }
                time:MONDAY => { dayLabel = i == 6 ? "Mon (Selected)" : i == 7 ? "Mon (Next Day)" : "Mon"; }
                time:TUESDAY => { dayLabel = i == 6 ? "Tue (Selected)" : i == 7 ? "Tue (Next Day)" : "Tue"; }
                time:WEDNESDAY => { dayLabel = i == 6 ? "Wed (Selected)" : i == 7 ? "Wed (Next Day)" : "Wed"; }
                time:THURSDAY => { dayLabel = i == 6 ? "Thu (Selected)" : i == 7 ? "Thu (Next Day)" : "Thu"; }
                time:FRIDAY => { dayLabel = i == 6 ? "Fri (Selected)" : i == 7 ? "Fri (Next Day)" : "Fri"; }
                time:SATURDAY => { dayLabel = i == 6 ? "Sat (Selected)" : i == 7 ? "Sat (Next Day)" : "Sat"; }
            }
            dayLabels.push(dayLabel);
        }

        // Query to get maintenance request counts by date for 8 days, categorized by priority/type
        stream<record {|string request_date; string priority; int count;|}, sql:Error?> serviceDistributionStream = database:dbClient->query(
            `SELECT DATE(submitted_date) AS request_date, priority_level AS priority, COUNT(maintenance_id) AS count 
             FROM maintenance 
             WHERE org_id = ${orgId} AND DATE(submitted_date) BETWEEN DATE_SUB(STR_TO_DATE(${date}, '%Y-%m-%d'), INTERVAL 6 DAY) AND DATE_ADD(STR_TO_DATE(${date}, '%Y-%m-%d'), INTERVAL 1 DAY)
             GROUP BY request_date, priority_level
             ORDER BY request_date, priority_level`,
            typeof ({request_date: "", priority: "", count: 0})
        );

        // Convert service distribution stream to array
        record {|string request_date; string priority; int count;|}[] serviceDistributionData = [];
        check from var row in serviceDistributionStream
            do {
                serviceDistributionData.push(row);
            };

        // Get unique priorities
        string[] priorities = ["Low", "Medium", "High", "Critical"];

        // Initialize a map to store data arrays for each priority (8 days)
        map<int[]> serviceDataMap = {};
        foreach var priority in priorities {
            serviceDataMap[priority] = [0, 0, 0, 0, 0, 0, 0, 0];
        }

        // Populate data arrays based on priority and request_date
        foreach var row in serviceDistributionData {
            string requestDate = row.request_date;
            string priority = row.priority;
            int count = row.count;
            int? idxOpt = dateKeys.indexOf(requestDate);
            if idxOpt is int {
                int[]? dataArr = serviceDataMap[priority];
                if (dataArr is int[]) {
                    dataArr[idxOpt] = count;
                }
            }
        }

        json[] datasets = [];
        string[] borderColors = ["#10B981", "#F59E0B", "#EF4444", "#7C3AED"]; // Green, Yellow, Red, Purple
        int colorIndex = 0;

        foreach var priority in priorities {
            int[]? dataArr = serviceDataMap[priority];
            if (dataArr is int[]) {
                datasets.push({
                    "label": priority + " Priority",
                    "data": dataArr,
                    "borderColor": borderColors[colorIndex % borderColors.length()],
                    "tension": 0.4
                });
                colorIndex += 1;
            }
        }

        // Construct the JSON response
        return {
            "labels": dayLabels,
            "datasets": datasets
        };
    }

    resource function options .() returns http:Ok {
        return http:OK;
    }
}

public function startDashboardAdminService() returns error? {
    // Function to integrate with the service start pattern
    io:println("Dashboard Admin service started on port 9092");
}
