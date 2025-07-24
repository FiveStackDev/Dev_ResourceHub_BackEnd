import ResourceHub.common;
import ResourceHub.database;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "DELETE", "OPTIONS", "PUT"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /assetrequest on database:mainListener {

    resource function get details(http:Request req) returns AssetRequest[]|error {
        // Validate JWT and check for allowed roles (admin, manager, user)
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        stream<AssetRequest, sql:Error?> resultstream = database:dbClient->query
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
        ra.quantity,
        ra.org_id
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE ra.org_id = ${orgId};`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get details/[int userid](http:Request req) returns AssetRequest[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        stream<AssetRequest, sql:Error?> resultstream = database:dbClient->query
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
        ra.quantity,
        ra.org_id
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE ra.user_id = ${userid} AND ra.org_id = ${orgId};`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function post add(http:Request req, @http:Payload AssetRequest assetrequest) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add asset requests");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO requestedassets (user_id, asset_id, submitted_date, handover_date, quantity, status, is_returning, org_id)
            VALUES (${assetrequest.user_id}, ${assetrequest.asset_id}, ${assetrequest.submitted_date}, 
                    ${assetrequest.handover_date}, ${assetrequest.quantity}, 'Pending', false, ${orgId})
        `);

        if result.affectedRowCount == 0 {
            return {message: "Failed to add asset request"};
        }
        return {message: "Asset request added successfully"};
    }

    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete asset requests");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM requestedassets WHERE requestedasset_id = ${id} AND org_id = ${orgId}
        `);

        if result.affectedRowCount == 0 {
            return {message: "Asset request not found or you don't have permission to delete it"};
        }
        return {message: "Asset request deleted successfully"};
    }

    resource function put details/[int id](http:Request req, @http:Payload AssetRequest assetrequest) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin", "User"])) {
            return error("Forbidden: You do not have permission to update asset requests");
        }

        int orgId = check common:getOrgId(payload);

        // Get current request details to check if status is changing to "Accepted"
        stream<record {|int asset_id; string status; int quantity;|}, sql:Error?> currentRequestStream =
            database:dbClient->query(`
                SELECT asset_id, status, quantity 
                FROM requestedassets 
                WHERE requestedasset_id = ${id} AND org_id = ${orgId}
            `);

        record {|int asset_id; string status; int quantity;|}? currentRequest = ();
        check currentRequestStream.forEach(function(record {|int asset_id; string status; int quantity;|} requestData) {
            currentRequest = requestData;
        });

        if currentRequest is () {
            return {message: "Asset request not found or you don't have permission to update it"};
        }

        record {|int asset_id; string status; int quantity;|} currentReq = <record {|int asset_id; string status; int quantity;|}>currentRequest;

        // Check if status is changing from non-Accepted to Accepted or from Accepted to non-Accepted
        string newStatus = assetrequest.status ?: "Pending";
        boolean isApproving = currentReq.status != "Accepted" && newStatus == "Accepted";
        boolean isReturning = currentReq.status == "Accepted" && newStatus != "Accepted";

        // If approving, check and reduce asset quantity
        if isApproving {
            // Check current available quantity in assets table
            stream<record {|int quantity;|}, sql:Error?> assetQuantityStream =
                database:dbClient->query(`
                    SELECT quantity 
                    FROM assets 
                    WHERE asset_id = ${currentReq.asset_id} AND org_id = ${orgId}
                `);

            record {|int quantity;|}? assetQuantity = ();
            check assetQuantityStream.forEach(function(record {|int quantity;|} asset) {
                assetQuantity = asset;
            });

            if assetQuantity is () {
                return error("Asset not found");
            }

            record {|int quantity;|} assetQty = <record {|int quantity;|}>assetQuantity;

            // Check if there's enough quantity
            if assetQty.quantity < currentReq.quantity {
                return error("Not enough quantity available. Available: " + assetQty.quantity.toString() + ", Requested: " + currentReq.quantity.toString() + ". Error Code: INSUFFICIENT_QUANTITY_3819");
            }

            // Try to reduce the asset quantity
            do {
                sql:ExecutionResult quantityResult = check database:dbClient->execute(`
                    UPDATE assets 
                    SET quantity = quantity - ${currentReq.quantity}
                    WHERE asset_id = ${currentReq.asset_id} AND org_id = ${orgId}
                `);

                if quantityResult.affectedRowCount == 0 {
                    return error("Failed to update asset quantity");
                }
            } on fail var e {
                // Handle constraint violation or other database errors
                string errorMessage = e.message();
                if errorMessage.includes("chk_quantity_nonnegative") || errorMessage.includes("3819") {
                    return error("Not enough quantity available. Database constraint violated. Error Code: CONSTRAINT_VIOLATION_3819");
                }
                return error("Database error occurred while updating quantity: " + errorMessage);
            }
        }

        // If returning (status changed from Accepted to something else), increase the asset quantity back
        if isReturning {
            do {
                sql:ExecutionResult quantityResult = check database:dbClient->execute(`
                    UPDATE assets 
                    SET quantity = quantity + ${currentReq.quantity}
                    WHERE asset_id = ${currentReq.asset_id} AND org_id = ${orgId}
                `);

                if quantityResult.affectedRowCount == 0 {
                    return error("Failed to update asset quantity during return");
                }
            } on fail var e {
                return error("Database error occurred while returning quantity: " + e.message());
            }
        }

        // Update the asset request
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE requestedassets 
            SET status = ${newStatus}, 
            is_returning = ${assetrequest.is_returning ?: false},
            quantity = ${assetrequest.quantity},
            handover_date = ${assetrequest.handover_date}
            WHERE requestedasset_id = ${id} AND org_id = ${orgId}
        `);

        if result.affectedRowCount == 0 {
            return {message: "Asset request not found or you don't have permission to update it"};
        }
        return {message: "Asset request updated successfully"};
    }

    resource function get dueassets(http:Request req) returns AssetRequest[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access due assets");
        }

        int orgId = check common:getOrgId(payload);

        stream<AssetRequest, sql:Error?> resultstream = database:dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date,
        ra.handover_date,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity,
        ra.status,
        ra.is_returning,
        ra.org_id
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE DATEDIFF(ra.handover_date, CURDATE()) < 0
        AND ra.is_returning = true
        AND ra.status = 'Accepted'
        AND ra.org_id = ${orgId}
        ORDER BY remaining_days ASC;`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get dueassets/[int userid](http:Request req) returns AssetRequest[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access due assets");
        }

        int orgId = check common:getOrgId(payload);

        stream<AssetRequest, sql:Error?> resultstream = database:dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date,
        ra.handover_date,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity,
        ra.status,
        ra.is_returning,
        ra.org_id
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE DATEDIFF(ra.handover_date, CURDATE()) < 0 
        AND ra.user_id = ${userid}
        AND ra.is_returning = true
        AND ra.status = 'Accepted'
        AND ra.org_id = ${orgId}
        ORDER BY remaining_days ASC;`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }
}

public function startAssetRequestService() returns error? {
    io:println("Asset request service started on port 9090");
}
