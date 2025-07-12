import ballerina/http;
import ballerina/sql;
import ballerina/jwt;
public type ScheduleReport record{|
    int user_id;
    string report_name;
    string frequency;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /schedulereports on ln{
        resource function post addscedulereport(http:Request req,@http:Payload ScheduleReport schedulereport) returns json | error{
         jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin"])) {
            return error("Forbidden: You do not have permission to add maintenance requests");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            insert into schedulereports (user_id,report_name,frequency)
            values(${schedulereport.user_id},${schedulereport.report_name},${schedulereport.frequency})
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
service /schedulereports on report {
    resource function get weeklyassetrequestdetails() returns AssetRequest[]|error {
 
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
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
        WHERE ra.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE();`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get biweeklyassetrequestdetails() returns AssetRequest[]|error {
    
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
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
        WHERE ra.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 14 DAY) AND CURDATE();`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }
     resource function get monthlyassetrequestdetails() returns AssetRequest[]|error {
    
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
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
        WHERE ra.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE();`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }


     resource function get weeklymealevents() returns MealEvent[]|error {
        stream<MealEvent, sql:Error?> resultStream = 
            dbClient->query(`SELECT 
            requestedmeals.requestedmeal_id, 
            mealtime_id,mealtimes.mealtime_name , 
            mealtype_id,mealtypes.mealtype_name , 
            username,users.user_id, 
            submitted_date, 
            meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE meal_request_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()`); 
        MealEvent[] events = []; 
        check resultStream.forEach(function(MealEvent event) { 
            events.push(event); 
        }); 
        return events; 
    } 
         resource function get biweeklymealevents() returns MealEvent[]|error {
       
        stream<MealEvent, sql:Error?> resultStream = 
            dbClient->query(`SELECT 
            requestedmeals.requestedmeal_id, 
            mealtime_id,mealtimes.mealtime_name , 
            mealtype_id,mealtypes.mealtype_name , 
            username,users.user_id, submitted_date, 
            meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE meal_request_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 14 DAY) AND CURDATE()`); 
        MealEvent[] events = []; 
        check resultStream.forEach(function(MealEvent event) { 
            events.push(event); 
        }); 
        return events; 
    } 
         resource function get monthlymealevents() returns MealEvent[]|error {

        stream<MealEvent, sql:Error?> resultStream = 
            dbClient->query(`SELECT 
            requestedmeals.requestedmeal_id, 
            mealtime_id,mealtimes.mealtime_name , 
            mealtype_id,mealtypes.mealtype_name , 
            username,users.user_id, 
            submitted_date, 
            meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id
            WHERE meal_request_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE()`); 
        MealEvent[] events = []; 
        check resultStream.forEach(function(MealEvent event) { 
            events.push(event); 
        }); 
        return events; 
    } 



    resource function get weeklymaintenancedetails() returns Maintenance[]|error {

        stream<Maintenance, sql:Error?> resultStream =
            dbClient->query(`SELECT 
                u.username AS username,
                m.name AS name,
                m.description,
                m.priority_level AS priorityLevel,
                m.status,
                m.submitted_date,
                m.maintenance_id ,
                u.user_id as user_id
                FROM maintenance m
                JOIN users u ON m.user_id = u.user_id
                WHERE m.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE();
        `);
        Maintenance[] maintenances = [];
        check resultStream.forEach(function(Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }
    resource function get biweeklymaintenancedetails() returns Maintenance[]|error {
 
        stream<Maintenance, sql:Error?> resultStream =
            dbClient->query(`SELECT 
                u.username AS username,
                m.name AS name,
                m.description,
                m.priority_level AS priorityLevel,
                m.status,
                m.submitted_date,
                m.maintenance_id ,
                u.user_id as user_id
                FROM maintenance m
                JOIN users u ON m.user_id = u.user_id
                WHERE m.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 14 DAY) AND CURDATE();
        `);
        Maintenance[] maintenances = [];
        check resultStream.forEach(function(Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }
    resource function get monthlymaintenancedetails() returns Maintenance[]|error {

        stream<Maintenance, sql:Error?> resultStream =
            dbClient->query(`SELECT 
                u.username AS username,
                m.name AS name,
                m.description,
                m.priority_level AS priorityLevel,
                m.status,
                m.submitted_date,
                m.maintenance_id ,
                u.user_id as user_id
                FROM maintenance m
                JOIN users u ON m.user_id = u.user_id
                WHERE m.submitted_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE();
        `);
        Maintenance[] maintenances = [];
        check resultStream.forEach(function(Maintenance maintenance) {
            maintenances.push(maintenance);
        });
        return maintenances;
    }

}