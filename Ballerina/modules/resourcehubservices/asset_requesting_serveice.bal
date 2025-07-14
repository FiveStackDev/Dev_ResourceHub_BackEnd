import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

public type AssetRequest record {|
    int requestedasset_id?;
    int user_id;
    int asset_id;
    string category?;
    string submitted_date;
    string handover_date;
    int remaining_days?;
    int quantity;
    string profile_picture_url?;
    string username?;
    string status?;
    boolean is_returning?;
    string asset_name?;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "DELETE", "OPTIONS", "PUT"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /assetrequest on ln {
    // Role-based access control: validate JWT and roles for secure endpoints
    // Example: Add 'http:Request req' as a parameter and check roles using a helper like getValidatedPayload(req) and hasAnyRole(...)
    // You should implement or import getValidatedPayload and hasAnyRole as in account_settings_service.bal

    // ...existing code...
    resource function get details(http:Request req) returns AssetRequest[]|error {
        // Validate JWT and check for allowed roles (admin, manager, user)
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.profile_picture_url,
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
        JOIN assets a ON ra.asset_id = a.asset_id;`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get details/[int userid](http:Request req) returns AssetRequest[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.profile_picture_url,
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
        where ra.user_id=${userid};`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function post add(http:Request req, @http:Payload AssetRequest assetrequest) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add asset requests");
        }
        io:println("Received Asset Request data :" + assetrequest.toJsonString());

        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO requestedassets (user_id, asset_id, submitted_date , handover_date, quantity,is_returning)
            VALUES (${assetrequest.user_id}, ${assetrequest.asset_id}, ${assetrequest.submitted_date}, ${assetrequest.handover_date}, ${assetrequest.quantity},${assetrequest.is_returning})
        `);

        if result.affectedRowCount == 0 {
            return error("Failed to add asset request");
        }

        return {
            message: "Asset request added successfully",
            assetrequest: assetrequest
        };
    }

    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete asset requests");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM requestedassets WHERE requestedasset_id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Asset request not found"
            };
        }
        return {
            message: "Asset request deleted successfully"
        };
    }

    resource function put details/[int id](http:Request req, @http:Payload AssetRequest assetrequest) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update asset requests");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE requestedassets 
            SET  handover_date = ${assetrequest.handover_date}, quantity = ${assetrequest.quantity} , status = ${assetrequest.status},is_returning = ${assetrequest.is_returning}
            WHERE requestedasset_id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Asset request not found"
            };
        }

        return {
            message: "Asset request updated successfully",
            assetrequest: assetrequest
        };
    }

    resource function get dueassets(http:Request req) returns AssetRequest[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access due assets");
        }
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`select u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity,
        ra.status
        FROM requestedassets  ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE  DATEDIFF(ra.handover_date, CURDATE()) < 0
        AND ra.is_returning = true
        AND ra.status = 'Accepted'
        ORDER BY remaining_days ASC;`
        );

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get dueassets/[int userid](http:Request req) returns AssetRequest[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access due assets");
        }
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`SELECT 
        u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE DATEDIFF(ra.handover_date, CURDATE()) < 0 AND ra.user_id = ${userid}
        AND ra.is_returning = true
        AND ra.status = 'Accepted'
        ORDER BY remaining_days ASC;`
        );

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }
}

public function AssetRequestService() {
    io:println("Asset request service work on port :9090");
}
