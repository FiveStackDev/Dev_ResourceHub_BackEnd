import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

public type Asset record {|
    int asset_id?;
    string asset_name;
    string category;
    int quantity;
    string condition_type;
    string location;
    boolean is_available?;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /asset on ln {
    // Only admin, manager, and User can view asset details
    resource function get details(http:Request req) returns Asset[]|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }
        stream<Asset, sql:Error?> resultStream = dbClient->query(`SELECT * FROM assets`);
        Asset[] assets = [];
        check resultStream.forEach(function(Asset asset) {
            assets.push(asset);
        });
        return assets;
    }

    // Only admin and manager can add assets
    resource function post add(http:Request req, @http:Payload Asset asset) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add assets");
        }
        sql:ExecutionResult result = check dbClient->execute(
            `insert into assets (asset_name, category, quantity, condition_type, location) 
              values (${asset.asset_name}, ${asset.category}, ${asset.quantity}, ${asset.condition_type}, ${asset.location})`
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
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update assets");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE assets 
            SET asset_name = ${asset.asset_name}, category = ${asset.category}, quantity = ${asset.quantity}, condition_type = ${asset.condition_type}, location = ${asset.location}, is_available = ${asset.is_available} 
            WHERE asset_id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Asset not found"
            };
        }
        return {
            message: "Asset updated successfully",
            asset: asset
        };
    }

    // Only admin and manager can delete assets
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);
        if (!hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete assets");
        }
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM assets WHERE asset_id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "asset not found"
            };
        }
        return {
            message: "asset deleted successfully"
        };
    }
}

public function startAssetService() returns error? {
    io:println("Assets service started on port 9090");
}
