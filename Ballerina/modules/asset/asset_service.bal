import ResourceHub.common;
import ResourceHub.database;

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

service /asset on database:mainListener {
    // Only admin, manager, and User can view asset details
    resource function get details(http:Request req) returns Asset[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        stream<Asset, sql:Error?> resultStream = database:dbClient->query(`SELECT * FROM assets WHERE org_id = ${orgId}`);
        Asset[] assets = [];
        check resultStream.forEach(function(Asset asset) {
            assets.push(asset);
        });
        return assets;
    }

    // Only admin and manager can add assets
    resource function post add(http:Request req, @http:Payload Asset asset) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add assets");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(
            `insert into assets (asset_name, category, quantity, condition_type, location, org_id) 
              values (${asset.asset_name}, ${asset.category}, ${asset.quantity}, ${asset.condition_type}, ${asset.location}, ${orgId})`
        );
        if result.affectedRowCount == 0 {
            return {
                message: "Failed to add asset"
            };
        }
        return {
            message: "Asset added successfully",
            asset: asset
        };
    }

    // Only admin and manager can update assets
    resource function put details/[int id](http:Request req, @http:Payload Asset asset) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update assets");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE assets 
            SET asset_name = ${asset.asset_name}, category = ${asset.category}, quantity = ${asset.quantity}, condition_type = ${asset.condition_type}, location = ${asset.location}, is_available = ${asset.is_available} 
            WHERE asset_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Asset not found or you don't have permission to update it"
            };
        }
        return {
            message: "Asset updated successfully",
            asset: asset
        };
    }

    // Only admin and manager can delete assets
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete assets");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM assets WHERE asset_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Asset not found or you don't have permission to delete it"
            };
        }
        return {
            message: "Asset deleted successfully"
        };
    }
}

public function startAssetService() returns error? {
    io:println("Assets service started on port 9090");
}
