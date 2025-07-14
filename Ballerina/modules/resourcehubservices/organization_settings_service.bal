import ballerina/email;
import ballerina/http;
import ballerina/jwt;
import ballerina/sql;

// Profile data structure for user settings
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
service /orgsettings on ln {

    // Fetch user profile details by user ID - accessible by user themselves or admin
    resource function get details/[int orgid](http:Request req) returns OrgProfile[]|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        stream<OrgProfile, sql:Error?> resultStream = dbClient->query(`
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

    // Update username, profile picture, and bio - user can update own profile, admin can update any
    resource function put profile/[int orgid](http:Request req, @http:Payload OrgProfile profile) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update this profile");
        }

        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE organizations SET 
            org_name = ${profile.org_name}, 
            org_logo = ${profile.org_logo}, 
            org_address = ${profile.org_address} 
            WHERE org_id = ${orgid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Profile updated successfully"};
        } else {
            return error("Failed to update profile");
        }
    }

    // Update email address - user can update own email, admin can update any
    resource function put email/[int orgid](http:Request req, @http:Payload Email email) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update this email");
        }

        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE organizations SET 
                org_email = ${email.email} 
            WHERE org_id = ${orgid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Email updated successfully"};
        } else {
            return error("Failed to update email");
        }
    }

    // Send verification email with code - open endpoint (no auth required)
    resource function post sendEmail(@http:Payload Email email) returns json|error {
        email:Message resetEmail = {
            to: [email.email],
            subject: "Verify Your Email Address to Complete the Update",
            body: string `Your verification code is: ${email.code ?: "!!error!!"}

Enter this code in the app to verify your email address.

If you didn’t request this, you can safely ignore this message.
`
        };

        error? emailResult = emailClient->sendMessage(resetEmail);
        if emailResult is error {
            return error("Error sending Code to email");
        }

        return {
            message: "Code sent successfully. Check your email for the Verification Code."
        };
    }

}
