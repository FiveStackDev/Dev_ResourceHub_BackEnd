import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerina/jwt;
import ballerina/websocket;
import ballerina/time;
import ballerina/task;
import ResourceHub.database;
import ResourceHub.common;

// Global WebSocket connection storage
map<ClientConnection> adminConnections = {};
map<websocket:Caller> activeCalls = {};

// Background task for real-time updates
task:JobId? updateTaskId = ();

// Utility function to broadcast message to all admin connections in an organization
function broadcastToOrgAdmins(string orgId, WebSocketMessage message) {
    foreach var [connectionId, connection] in adminConnections.entries() {
        if (connection.orgId == orgId) {
            websocket:Caller? caller = activeCalls[connectionId];
            if (caller is websocket:Caller) {
                var result = caller->writeMessage(message);
                if (result is websocket:Error) {
                    io:println("Error broadcasting to connection " + connectionId + ": " + result.message());
                    // Remove failed connection
                    _ = adminConnections.remove(connectionId);
                    _ = activeCalls.remove(connectionId);
                }
            }
        }
    }
}

// Function to get real-time stats for an organization
function getRealTimeStatsForOrg(string orgId) returns RealTimeStats|error {
    int orgIdInt = check int:fromString(orgId);
    
    // Get current counts
    record {|int user_count;|} userResult = check database:dbClient->queryRow(`SELECT COUNT(user_id) AS user_count FROM users WHERE org_id = ${orgIdInt}`);
    int userCount = userResult.user_count;

    record {|int mealevents_count;|} mealResult = check database:dbClient->queryRow(`SELECT COUNT(requestedmeal_id) AS mealevents_count FROM requestedmeals WHERE org_id = ${orgIdInt}`);
    int mealEventsCount = mealResult.mealevents_count;

    record {|int assetrequests_count;|} assetRequestsResult = check database:dbClient->queryRow(`SELECT COUNT(requestedasset_id) AS assetrequests_count FROM requestedassets WHERE org_id = ${orgIdInt}`);
    int assetRequestsCount = assetRequestsResult.assetrequests_count;

    record {|int maintenance_count;|} maintenanceResult = check database:dbClient->queryRow(`SELECT COUNT(maintenance_id) AS maintenance_count FROM maintenance WHERE org_id = ${orgIdInt}`);
    int maintenanceCount = maintenanceResult.maintenance_count;

    // Get monthly data (simplified for real-time updates)
    string[] monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    int[] monthlyUserCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    int[] monthlyMealCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    int[] monthlyAssetRequestCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    int[] monthlyMaintenanceCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    return {
        userCount,
        mealEventsCount,
        assetRequestsCount,
        maintenanceCount,
        monthlyUserCounts,
        monthlyMealCounts,
        monthlyAssetRequestCounts,
        monthlyMaintenanceCounts,
        monthLabels
    };
}

// Background task function to send periodic updates
function sendPeriodicUpdates() returns error? {
    foreach var [connectionId, connection] in adminConnections.entries() {
        RealTimeStats|error stats = getRealTimeStatsForOrg(connection.orgId);
        if (stats is RealTimeStats) {
            WebSocketMessage message = {
                event: "stats_update",
                data: stats,
                timestamp: time:utcNow()[0].toString()
            };
            
            websocket:Caller? caller = activeCalls[connectionId];
            if (caller is websocket:Caller) {
                var result = caller->writeMessage(message);
                if (result is websocket:Error) {
                    io:println("Error sending periodic update to connection " + connectionId + ": " + result.message());
                    // Remove failed connection
                    _ = adminConnections.remove(connectionId);
                    _ = activeCalls.remove(connectionId);
                }
            }
        }
    }
}

// WebSocket service for real-time admin dashboard
@websocket:ServiceConfig {
    subProtocols: ["admin-dashboard"],
    idleTimeout: 300
}
service /dashboard/admin/ws on new websocket:Listener(9095) {
    resource isolated function get .() returns websocket:Service|websocket:UpgradeError {
        return new AdminWebSocketService();
    }
}

// AdminWebSocketService class for handling WebSocket connections
service class AdminWebSocketService {
    *websocket:Service;
    
    remote function onOpen(websocket:Caller caller) returns websocket:Error? {
        io:println("WebSocket connection opened");
    }

    remote function onMessage(websocket:Caller caller, json message) returns websocket:Error? {
        json|error eventJson = message.event;
        if (eventJson is error || !(eventJson is string)) {
            json errorMessage = {
                event: "error",
                message: "Invalid message format - event field required",
                timestamp: time:utcNow()[0].toString()
            };
            check caller->writeMessage(errorMessage);
            return;
        }
        
        string event = <string>eventJson;
        
        if (event == "authenticate") {
            json|error tokenJson = message.token;
            if (tokenJson is error || !(tokenJson is string)) {
                json errorMessage = {
                    event: "error",
                    message: "Token not provided or invalid",
                    timestamp: time:utcNow()[0].toString()
                };
                check caller->writeMessage(errorMessage);
                return;
            }
            
            string token = <string>tokenJson;
            string|error authResult = authenticateWebSocketClient(caller, token);
            if (authResult is error) {
                json errorMessage = {
                    event: "error",
                    message: "Authentication failed: " + authResult.message(),
                    timestamp: time:utcNow()[0].toString()
                };
                check caller->writeMessage(errorMessage);
                check caller->close();
            } else {
                json successMessage = {
                    event: "authenticated",
                    message: "Successfully authenticated",
                    timestamp: time:utcNow()[0].toString()
                };
                check caller->writeMessage(successMessage);
                
                // Send initial stats
                RealTimeStats|error stats = getRealTimeStatsForOrg(authResult);
                if (stats is RealTimeStats) {
                    json statsMessage = {
                        event: "initial_stats",
                        data: stats,
                        timestamp: time:utcNow()[0].toString()
                    };
                    check caller->writeMessage(statsMessage);
                }
            }
        } else if (event == "ping") {
            json pongMessage = {
                event: "pong",
                timestamp: time:utcNow()[0].toString()
            };
            check caller->writeMessage(pongMessage);
        }
    }

    remote function onClose(websocket:Caller caller, int statusCode, string reason) returns websocket:Error? {
        io:println("WebSocket connection closed: " + reason);
        removeClientConnection(caller);
    }

    remote function onError(websocket:Caller caller, websocket:Error err) returns websocket:Error? {
        io:println("WebSocket error: " + err.message());
        removeClientConnection(caller);
    }
}

// Function to authenticate WebSocket client
function authenticateWebSocketClient(websocket:Caller caller, string token) returns string|error {
    jwt:Payload payload = check common:getValidatedPayload(createDummyRequest(token));
    
    // Validate user has admin role
    if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
        return error("Forbidden: You do not have permission to access this resource");
    }
    
    int orgIdInt = check common:getOrgId(payload);
    int userIdInt = check common:getUserId(payload);
    string orgId = orgIdInt.toString();
    string userId = userIdInt.toString();
    
    // Get role from payload
    anydata roleClaim = payload["role"];
    string[] roles = [];
    if (roleClaim is string) {
        roles.push(roleClaim);
    }
    
    // Generate connection ID
    string connectionId = userId + "_" + time:utcNow()[0].toString();
    
    // Store connection
    ClientConnection connection = {
        connectionId: connectionId,
        orgId: orgId,
        userId: userId,
        roles: roles
    };
    
    lock {
        adminConnections[connectionId] = connection;
        activeCalls[connectionId] = caller;
    }
    
    return orgId;
}

// Helper function to create a dummy request with Authorization header
function createDummyRequest(string token) returns http:Request {
    http:Request req = new;
    req.setHeader("Authorization", "Bearer " + token);
    return req;
}

// Function to remove client connection
function removeClientConnection(websocket:Caller caller) {
    lock {
        string? connectionToRemove = ();
        foreach var [connectionId, activeCaller] in activeCalls.entries() {
            if (activeCaller === caller) {
                connectionToRemove = connectionId;
                break;
            }
        }
        
        if (connectionToRemove is string) {
            _ = adminConnections.remove(connectionToRemove);
            _ = activeCalls.remove(connectionToRemove);
            io:println("Removed connection: " + connectionToRemove);
        }
    }
}

// Function to send notification to specific organization admins
public function sendNotificationToOrgAdmins(RealTimeNotification notification) {
    WebSocketMessage message = {
        event: "notification",
        data: notification,
        timestamp: time:utcNow()[0].toString()
    };
    
    broadcastToOrgAdmins(notification.orgId, message);
}

// DashboardAdminService - RESTful service to provide data for admin dashboard with real-time WebSocket support
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /dashboard/admin on database:dashboardListener {
    // Only admin can access dashboard admin endpoints
    resource function get stats(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        // Existing counts
        record {|int user_count;|} userResult = check database:dbClient->queryRow(`SELECT COUNT(user_id) AS user_count FROM users WHERE org_id = ${orgId}`);
        int userCount = userResult.user_count;

        record {|int mealevents_count;|} mealResult = check database:dbClient->queryRow(`SELECT COUNT(requestedmeal_id) AS mealevents_count FROM requestedmeals WHERE org_id = ${orgId}`);
        int mealEventsCount = mealResult.mealevents_count;

        record {|int assetrequests_count;|} assetRequestsResult = check database:dbClient->queryRow(`SELECT COUNT(requestedasset_id) AS assetrequests_count FROM requestedassets WHERE org_id = ${orgId}`);
        int assetRequestsCount = assetRequestsResult.assetrequests_count;

        record {|int maintenance_count;|} maintenanceResult = check database:dbClient->queryRow(`SELECT COUNT(maintenance_id) AS maintenance_count FROM maintenance WHERE org_id = ${orgId}`);
        int maintenanceCount = maintenanceResult.maintenance_count;

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
        int[] monthlyUserCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyUserData {
            monthlyUserCounts[row.month - 1] = row.count;
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
        int[] monthlyMealCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyMealData {
            monthlyMealCounts[row.month - 1] = row.count;
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
        int[] monthlyAssetRequestCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyAssetRequestData {
            monthlyAssetRequestCounts[row.month - 1] = row.count;
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
        int[] monthlyMaintenanceCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyMaintenanceData {
            monthlyMaintenanceCounts[row.month - 1] = row.count;
        }

        // Month labels for charts
        string[] monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
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
                "title": "Meals Served",
                "value": mealEventsCount,
                "icon": "Utensils",
                "monthlyData": monthlyMealCounts,
                "monthLabels": monthLabels
            },
            {
                "title": "Resources",
                "value": assetRequestsCount,
                "icon": "Box",
                "monthlyData": monthlyAssetRequestCounts,
                "monthLabels": monthLabels
            },
            {
                "title": "Services",
                "value": maintenanceCount,
                "icon": "Wrench",
                "monthlyData": monthlyMaintenanceCounts,
                "monthLabels": monthLabels
            }
        ];
    }

    // Resource to get data for resource cards
    resource function get resources(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
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
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
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

        // Query to get meal event counts by day of week and meal type
        stream<MealDistributionData, sql:Error?> mealDistributionStream = database:dbClient->query(
        `SELECT DAYOFWEEK(meal_request_date) AS day_of_week, mealtimes.mealtime_name, COUNT(requestedmeal_id) AS count 
         FROM requestedmeals 
         JOIN mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
         WHERE requestedmeals.org_id = ${orgId}
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
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        
        // Query to get total and allocated quantities by category
        stream<ResourceAllocationData, sql:Error?> allocationStream = database:dbClient->query(
        `SELECT 
            category,
            SUM(quantity) AS total
         FROM assets 
         WHERE org_id = ${orgId}
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

    // New endpoint to trigger real-time updates to all connected clients
    resource function post notify(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        string orgIdStr = orgId.toString();
        
        // Get current stats and broadcast to all connected clients
        RealTimeStats|error stats = getRealTimeStatsForOrg(orgIdStr);
        if (stats is RealTimeStats) {
            WebSocketMessage message = {
                event: "stats_update",
                data: stats,
                timestamp: time:utcNow()[0].toString()
            };
            broadcastToOrgAdmins(orgIdStr, message);
        }
        
        return {"message": "Real-time update sent", "status": "success"};
    }

    // New endpoint to send custom notifications
    resource function post notification(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        json requestBody = check req.getJsonPayload();
        string notificationType = check requestBody.'type;
        string title = check requestBody.title;
        string message = check requestBody.message;
        
        int orgId = check common:getOrgId(payload);
        string orgIdStr = orgId.toString();
        
        RealTimeNotification notification = {
            'type: notificationType,
            title: title,
            message: message,
            orgId: orgIdStr
        };
        
        sendNotificationToOrgAdmins(notification);
        
        return {"message": "Notification sent", "status": "success"};
    }

    // New endpoint to get WebSocket connection info
    resource function get connections(http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        
        int orgId = check common:getOrgId(payload);
        string orgIdStr = orgId.toString();
        
        json[] connections = [];
        foreach var [connectionId, connection] in adminConnections.entries() {
            if (connection.orgId == orgIdStr) {
                connections.push({
                    connectionId: connection.connectionId,
                    userId: connection.userId,
                    roles: connection.roles,
                    connected: activeCalls.hasKey(connectionId)
                });
            }
        }
        
        return {
            "totalConnections": connections.length(),
            "connections": connections
        };
    }

    resource function options .() returns http:Ok {
        return http:OK;
    }
}

// Job class for periodic updates
class PeriodicUpdateJob {
    *task:Job;
    
    public function execute() {
        error? result = sendPeriodicUpdates();
        if (result is error) {
            io:println("Error in periodic update: " + result.message());
        }
    }
}

public function startDashboardAdminService() returns error? {
    // Start periodic update task (every 30 seconds)
    task:JobId|error jobResult = task:scheduleJobRecurByFrequency(new PeriodicUpdateJob(), 30);
    if (jobResult is error) {
        io:println("Failed to schedule periodic updates: " + jobResult.message());
    } else {
        updateTaskId = jobResult;
        io:println("Real-time updates scheduled every 30 seconds");
    }
    
    // Function to integrate with the service start pattern
    io:println("Dashboard Admin service started on port 9092");
    io:println("WebSocket service started on port 9095");
}

// Function to stop the dashboard service and cleanup
public function stopDashboardAdminService() returns error? {
    task:JobId? taskId = updateTaskId;
    if (taskId is task:JobId) {
        check task:unscheduleJob(taskId);
        io:println("Real-time update task stopped");
    }
    
    // Close all WebSocket connections
    foreach var [connectionId, caller] in activeCalls.entries() {
        var result = caller->close();
        if (result is websocket:Error) {
            io:println("Error closing connection " + connectionId + ": " + result.message());
        }
    }
    
    // Clear connection maps
    adminConnections.removeAll();
    activeCalls.removeAll();
    
    io:println("Dashboard Admin service stopped");
}