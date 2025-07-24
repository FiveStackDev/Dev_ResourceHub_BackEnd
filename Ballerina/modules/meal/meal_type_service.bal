import ResourceHub.common;
import ResourceHub.database;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

// CORS configuration for allowing specific cross-origin requests
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

// Service handling CRUD operations for meal types
service /mealtype on database:mainListener {
    // Only admin, manager, and User can view meal types
    resource function get details(http:Request req) returns MealType[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get all mealtypes for the organization
        stream<MealType, sql:Error?> resultStream =
            database:dbClient->query(`SELECT mealtype_id, mealtype_name, mealtype_image_url, org_id FROM mealtypes WHERE org_id = ${orgId}`);
        MealType[] mealtypes = [];
        check resultStream.forEach(function(MealType meal) {
            mealtypes.push(meal);
        });

        // For each mealtype, get associated mealtime_ids filtered by org_id
        foreach MealType mealtype in mealtypes {
            if (mealtype.mealtype_id is int) {
                stream<record {int mealtime_id;}, sql:Error?> mealtimeStream =
                    database:dbClient->query(`
                        SELECT mt.mealtime_id 
                        FROM mealtime_mealtype mt 
                        INNER JOIN mealtimes mtime ON mt.mealtime_id = mtime.mealtime_id 
                        WHERE mt.mealtype_id = ${mealtype.mealtype_id} AND mtime.org_id = ${orgId}
                    `);
                int[] mealtimeIds = [];
                check mealtimeStream.forEach(function(record {int mealtime_id;} mt) {
                    mealtimeIds.push(mt.mealtime_id);
                });
                mealtype.mealtime_ids = mealtimeIds;
            }
        }

        return mealtypes;
    }

    // Only admin and manager can add meal types
    resource function post add(http:Request req, @http:Payload MealType mealType) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add meal types");
        }

        int orgId = check common:getOrgId(payload);

        io:println("Received meal type data: " + mealType.toJsonString());

        // Step 1: Insert the new mealtype into the mealtypes table
        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO mealtypes (mealtype_name, mealtype_image_url, org_id)
            VALUES (${mealType.mealtype_name}, ${mealType.mealtype_image_url}, ${orgId})
        `);

        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            // Step 3: Insert each (mealtime_id, mealtype_id) into the mealtime_mealtype table
            int[]? mealtimeIds = mealType.mealtime_ids;
            if (mealtimeIds is int[]) {
                foreach int mealtimeId in mealtimeIds {
                    sql:ExecutionResult _ = check database:dbClient->execute(`
                        INSERT INTO mealtime_mealtype (mealtime_id, mealtype_id)
                        VALUES (${mealtimeId}, ${lastInsertId})
                    `);
                }
            }

            return {
                message: "Meal type added successfully",
                mealtype_id: lastInsertId,
                mealType: mealType
            };
        }
        return {
            message: "Failed to add meal type"
        };
    }

    // Only admin and manager can update meal types
    resource function put details/[int id](http:Request req, @http:Payload MealType mealType) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update meal types");
        }

        int orgId = check common:getOrgId(payload);

        // Step 1: Update the mealtype_name and mealtype_image_url
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE mealtypes SET mealtype_name = ${mealType.mealtype_name}, mealtype_image_url = ${mealType.mealtype_image_url}
            WHERE mealtype_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found or you don't have permission to update it"
            };
        }

        // Step 2: Delete all existing mealtime links from mealtime_mealtype for this mealtype
        sql:ExecutionResult _ = check database:dbClient->execute(`
            DELETE FROM mealtime_mealtype WHERE mealtype_id = ${id}
        `);

        // Step 3: Insert the new (mealtime_id, mealtype_id) pairs from the request
        int[]? mealtimeIds = mealType.mealtime_ids;
        if (mealtimeIds is int[]) {
            foreach int mealtimeId in mealtimeIds {
                sql:ExecutionResult _ = check database:dbClient->execute(`
                    INSERT INTO mealtime_mealtype (mealtime_id, mealtype_id)
                    VALUES (${mealtimeId}, ${id})
                `);
            }
        }

        return {
            message: "Meal type updated successfully",
            mealType: mealType
        };
    }

    // Only admin and manager can delete meal types
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete meal types");
        }

        int orgId = check common:getOrgId(payload);

        // First delete the relationships from the junction table
        sql:ExecutionResult _ = check database:dbClient->execute(`
            DELETE FROM mealtime_mealtype WHERE mealtype_id = ${id}
        `);

        // Then delete the mealtype itself
        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM mealtypes WHERE mealtype_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found or you don't have permission to delete it"
            };
        }
        return {
            message: "Meal type deleted successfully"
        };
    }

    // Handle preflight CORS requests
    resource function options .() returns http:Ok {
        return http:OK;
    }
}

// Log service start
public function startMealTypeService() returns error? {
    io:println("Meal Type service started on port 9090");
}
