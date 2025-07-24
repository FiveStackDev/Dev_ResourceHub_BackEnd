import ResourceHub.common;
import ResourceHub.database;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

// CORS configuration for cross-origin requests
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

// MealTime service with CRUD operations
service /mealtime on database:mainListener {
    // Only admin, manager, and User can view mealtime details
    resource function get details(http:Request req) returns MealTime[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        // Get all mealtimes for the organization
        stream<MealTime, sql:Error?> resultStream =
            database:dbClient->query(`SELECT mealtime_id, mealtime_name, mealtime_image_url, org_id FROM mealtimes WHERE org_id = ${orgId}`);
        MealTime[] mealtimes = [];
        check resultStream.forEach(function(MealTime meal) {
            mealtimes.push(meal);
        });

        // For each mealtime, get associated mealtype_ids filtered by org_id
        foreach MealTime mealtime in mealtimes {
            if (mealtime.mealtime_id is int) {
                stream<record {int mealtype_id;}, sql:Error?> mealtypeStream =
                    database:dbClient->query(`
                        SELECT mt.mealtype_id 
                        FROM mealtime_mealtype mt 
                        INNER JOIN mealtypes mtype ON mt.mealtype_id = mtype.mealtype_id 
                        WHERE mt.mealtime_id = ${mealtime.mealtime_id} AND mtype.org_id = ${orgId}
                    `);
                int[] mealtypeIds = [];
                check mealtypeStream.forEach(function(record {int mealtype_id;} mt) {
                    mealtypeIds.push(mt.mealtype_id);
                });
                mealtime.mealtype_ids = mealtypeIds;
            }
        }

        return mealtimes;
    }

    // Only admin and manager can add mealtime records
    resource function post add(http:Request req, @http:Payload MealTime mealTime) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add mealtime records");
        }

        int orgId = check common:getOrgId(payload);

        io:println("Received meal time data: " + mealTime.toJsonString());

        // Step 1: Insert the new mealtime into the mealtimes table
        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO mealtimes (mealtime_name, mealtime_image_url, org_id)
            VALUES (${mealTime.mealtime_name}, ${mealTime.mealtime_image_url}, ${orgId})
        `);

        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            // Step 3: Insert each (mealtime_id, mealtype_id) into the mealtime_mealtype table
            int[]? mealtypeIds = mealTime.mealtype_ids;
            if (mealtypeIds is int[]) {
                foreach int mealtypeId in mealtypeIds {
                    sql:ExecutionResult _ = check database:dbClient->execute(`
                        INSERT INTO mealtime_mealtype (mealtime_id, mealtype_id)
                        VALUES (${lastInsertId}, ${mealtypeId})
                    `);
                }
            }

            return {
                message: "Meal time added successfully",
                mealtime_id: lastInsertId,
                mealTime: mealTime
            };
        }
        return {
            message: "Failed to add meal time"
        };
    }

    // Only admin and manager can update mealtime records
    resource function put details/[int id](http:Request req, @http:Payload MealTime mealTime) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update mealtime records");
        }

        int orgId = check common:getOrgId(payload);

        // Step 1: Update the mealtime_name and mealtime_image_url
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE mealtimes SET mealtime_name = ${mealTime.mealtime_name}, mealtime_image_url = ${mealTime.mealtime_image_url}
            WHERE mealtime_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found or you don't have permission to update it"
            };
        }

        // Step 2: Delete all existing mealtype links from mealtime_mealtype for this mealtime
        sql:ExecutionResult _ = check database:dbClient->execute(`
            DELETE FROM mealtime_mealtype WHERE mealtime_id = ${id}
        `);

        // Step 3: Insert the new (mealtime_id, mealtype_id) pairs from the request
        int[]? mealtypeIds = mealTime.mealtype_ids;
        if (mealtypeIds is int[]) {
            foreach int mealtypeId in mealtypeIds {
                sql:ExecutionResult _ = check database:dbClient->execute(`
                    INSERT INTO mealtime_mealtype (mealtime_id, mealtype_id)
                    VALUES (${id}, ${mealtypeId})
                `);
            }
        }

        return {
            message: "Meal time updated successfully",
            mealTime: mealTime
        };
    }

    // Only admin and manager can delete mealtime records
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete mealtime records");
        }

        int orgId = check common:getOrgId(payload);

        // First delete the relationships from the junction table
        sql:ExecutionResult _ = check database:dbClient->execute(`
            DELETE FROM mealtime_mealtype WHERE mealtime_id = ${id}
        `);

        // Then delete the mealtime itself
        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM mealtimes WHERE mealtime_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found or you don't have permission to delete it"
            };
        }
        return {
            message: "Meal time deleted successfully"
        };
    }

    // Handle preflight CORS requests
    resource function options .() returns http:Ok {
        return http:OK;
    }
}

// Logs service start on port 9090
public function startMealTimeService() returns error? {
    io:println("Meal Time service started on port 9090");
}
