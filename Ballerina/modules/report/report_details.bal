import ResourceHub.asset;
import ResourceHub.common;
import ResourceHub.database;
import ResourceHub.maintenance;
import ResourceHub.meal;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /schedulereports on database:mainListener {
    resource function post addscedulereport(http:Request req, @http:Payload ScheduleReport schedulereport) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add schedule reports");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            insert into schedulereports (user_id,report_name,frequency,org_id)
            values(${schedulereport.user_id},${schedulereport.report_name},${schedulereport.frequency},${orgId})
        `);
        if result.affectedRowCount == 0 {
            return {message: "Failed to add schedule event"};
        }
        return {message: "schedule event added successfully"};
    }
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /schedulereports on database:reportListener {
    resource function get weeklyassetrequestdetails/[int orgId]() returns asset:AssetRequest[]|error {
        stream<asset:AssetRequest, sql:Error?> resultstream = database:dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        ra.status,
        ra.is_returning,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE ra.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
        AND ra.org_id = ${orgId};`);

        asset:AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(asset:AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get biweeklyassetrequestdetails/[int orgId]() returns asset:AssetRequest[]|error {
        stream<asset:AssetRequest, sql:Error?> resultstream = database:dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        ra.status,
        ra.is_returning,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE ra.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 14 DAY) AND CURDATE()
        AND ra.org_id = ${orgId};`);

        asset:AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(asset:AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get monthlyassetrequestdetails/[int orgId]() returns asset:AssetRequest[]|error {
        stream<asset:AssetRequest, sql:Error?> resultstream = database:dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        ra.status,
        ra.is_returning,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE ra.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE()
        AND ra.org_id = ${orgId};`);

        asset:AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(asset:AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get weeklymealdetails/[int orgId]() returns meal:MealEvent[]|error {
        stream<meal:MealEvent, sql:Error?> resultStream =
            database:dbClient->query(`SELECT requestedmeals.requestedmeal_id, mealtime_id,mealtimes.mealtime_name , mealtype_id,mealtypes.mealtype_name , username,users.user_id, submitted_date, meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE requestedmeals.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
            AND requestedmeals.org_id = ${orgId};`);
        meal:MealEvent[] events = [];
        check resultStream.forEach(function(meal:MealEvent event) {
            events.push(event);
        });
        return events;
    }

    resource function get biweeklymealdetails/[int orgId]() returns meal:MealEvent[]|error {
        stream<meal:MealEvent, sql:Error?> resultStream =
            database:dbClient->query(`SELECT requestedmeals.requestedmeal_id, mealtime_id,mealtimes.mealtime_name , mealtype_id,mealtypes.mealtype_name , username,users.user_id, submitted_date, meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE requestedmeals.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 14 DAY) AND CURDATE()
            AND requestedmeals.org_id = ${orgId};`);
        meal:MealEvent[] events = [];
        check resultStream.forEach(function(meal:MealEvent event) {
            events.push(event);
        });
        return events;
    }

    resource function get monthlymealdetails/[int orgId]() returns meal:MealEvent[]|error {
        stream<meal:MealEvent, sql:Error?> resultStream =
            database:dbClient->query(`SELECT requestedmeals.requestedmeal_id, mealtime_id,mealtimes.mealtime_name , mealtype_id,mealtypes.mealtype_name , username,users.user_id, submitted_date, meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE requestedmeals.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE()
            AND requestedmeals.org_id = ${orgId};`);
        meal:MealEvent[] events = [];
        check resultStream.forEach(function(meal:MealEvent event) {
            events.push(event);
        });
        return events;
    }

    resource function get weeklymaintenancedetails/[int orgId]() returns maintenance:Maintenance[]|error {
        stream<maintenance:Maintenance, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
                m.maintenance_id,
                m.user_id,
                m.name,
                m.description,
                m.priority_level as priorityLevel,
                m.status,
                m.submitted_date,
                u.profile_picture_url as profilePicture,
                u.username
            FROM maintenance m
            JOIN users u ON m.user_id = u.user_id
            WHERE m.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
            AND m.org_id = ${orgId};
        `);
        maintenance:Maintenance[] maintenances = [];
        check resultStream.forEach(function(maintenance:Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }

    resource function get biweeklymaintenancedetails/[int orgId]() returns maintenance:Maintenance[]|error {
        stream<maintenance:Maintenance, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
                m.maintenance_id,
                m.user_id,
                m.name,
                m.description,
                m.priority_level as priorityLevel,
                m.status,
                m.submitted_date,
                u.profile_picture_url as profilePicture,
                u.username
            FROM maintenance m
            JOIN users u ON m.user_id = u.user_id
            WHERE m.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 14 DAY) AND CURDATE()
            AND m.org_id = ${orgId};
        `);
        maintenance:Maintenance[] maintenances = [];
        check resultStream.forEach(function(maintenance:Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }

    resource function get monthlymaintenancedetails/[int orgId]() returns maintenance:Maintenance[]|error {
        stream<maintenance:Maintenance, sql:Error?> resultStream =
            database:dbClient->query(`SELECT 
                m.maintenance_id,
                m.user_id,
                m.name,
                m.description,
                m.priority_level as priorityLevel,
                m.status,
                m.submitted_date,
                u.profile_picture_url as profilePicture,
                u.username
            FROM maintenance m
            JOIN users u ON m.user_id = u.user_id
            WHERE m.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE()
            AND m.org_id = ${orgId};
        `);
        maintenance:Maintenance[] maintenances = [];
        check resultStream.forEach(function(maintenance:Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }
}

public function startReportDetailsService() returns error? {
    io:println("Report details service started on port 9091");
}
