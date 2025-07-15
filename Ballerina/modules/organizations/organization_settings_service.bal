import ballerina/email;
import ballerina/http;
import ballerina/jwt;
import ballerina/sql;
import ResourceHub.database;
import ResourceHub.common;
import ResourceHub.user;
import ballerina/io;

// Profile data structure for organization settings
public type OrgProfile record {|
    string org_name;
    string org_logo;
    string? org_address = ();
    string? org_email = ();
|};

// CORS configuration for client access
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /orgsettings on database:mainListener {

    // Fetch organization profile details by organization ID - accessible by admin or authorized users
    resource function get details/[int orgid](http:Request req) returns OrgProfile[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        stream<OrgProfile, sql:Error?> resultStream = database:dbClient->query(`
            SELECT org_name,
            org_email,
            org_logo,
            org_address
            FROM organizations
            WHERE org_id = ${orgid}`);

        OrgProfile[] profiles = [];
        check resultStream.forEach(function(OrgProfile profile) {
            profiles.push(profile);
        });

        return profiles;
    }

    // Update organization profile - admin or authorized users can update organization details
    resource function put profile/[int orgid](http:Request req, @http:Payload OrgProfile profile) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update organization profile");
        }

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE organizations 
            SET org_name = ${profile.org_name}, 
                org_logo = ${profile.org_logo}, 
                org_address = ${profile.org_address ?: ""}, 
                org_email = ${profile.org_email ?: ""}
            WHERE org_id = ${orgid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Organization profile updated successfully"};
        } else {
            return error("Failed to update organization profile or organization not found");
        }
    }

    // Update organization email address - admin or authorized users can update organization email
    resource function put email/[int orgid](http:Request req, @http:Payload user:Email email) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update organization email");
        }

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE organizations SET org_email = ${email.email} WHERE org_id = ${orgid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Organization email updated successfully"};
        } else {
            return error("Failed to update organization email or organization not found");
        }
    }

    // Send verification email with code - open endpoint (no auth required)
    resource function post sendEmail(@http:Payload user:Email email) returns json|error {
        email:Message resetEmail = {
            to: [email.email],
            subject: "🔐 Your Organization Verification Code",
            body: string `🔐 Your Verification Code: ${email.code ?: "!!error!!"}

Enter this code in the app to verify your email address.

If you didn't request this, you can safely ignore this message.`
        };

        error? emailResult = common:emailClient->sendMessage(resetEmail);
        if emailResult is error {
            return error("Error sending Code to email");
        }

        return {
            message: "Code sent successfully. Check your email for the Verification Code."
        };
    }
}

public function startOrganizationSettingsService() returns error? {
    io:println("Organization settings service started on port 9090");
}
