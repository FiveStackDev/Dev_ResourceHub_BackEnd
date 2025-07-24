import ResourceHub.common;
import ResourceHub.database;
import ResourceHub.user;

import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

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

        int userOrgId = check common:getOrgId(payload);

        // Ensure users can only access their own organization's data
        if (orgid != userOrgId) {
            return error("Forbidden: You can only access your own organization's details");
        }

        stream<OrgProfile, sql:Error?> resultStream = database:dbClient->query(`
            SELECT org_name,
            org_email,
            org_logo,
            org_address,
            org_about,
            org_website,
            org_phone,
            org_founded
            FROM organizations
            WHERE org_id = ${orgid}`);

        OrgProfile[] profiles = [];
        check resultStream.forEach(function(OrgProfile profile) {
            profiles.push(profile);
        });

        return profiles;
    }

    // Create a new organization - admin or authorized users can create organizations
    resource function post register(@http:Payload Register register) returns json|error {

        // Check if email already exists in the system (no user_id yet, so just check for any user with this email)
        stream<record {|int count;|}, sql:Error?> emailCheckStream =
            database:dbClient->query(`SELECT COUNT(*) as count FROM users WHERE email = ${register.email}`);

        record {|int count;|}[] emailCheckResult = [];
        check emailCheckStream.forEach(function(record {|int count;|} result) {
            emailCheckResult.push(result);
        });

        if (emailCheckResult.length() > 0 && emailCheckResult[0].count > 0) {
            return {
                message: "Email already exists in a organization. Please use a different email address."
            };
        }

        // Step 1: Create the organization first
        sql:ExecutionResult result = check database:dbClient->execute(`
            INSERT INTO organizations (org_name, org_email, org_about, org_website, org_phone, org_founded, created_at, updated_at)
            VALUES (${register.org_name}, ${register.email}, ${register.org_about ?: ""}, 
                    ${register.org_website ?: ""}, ${register.org_phone ?: ""}, ${register.org_founded ?: ""}, NOW(), NOW())
        `);

        // Step 2: Get the newly created organization ID
        int|string? orgId = result.lastInsertId;
        if (orgId is () || orgId is string) {
            return error("Failed to get organization ID after creation");
        }

        // Step 3: Hash the password
        string|error hashedPassword = common:hashPassword(register.password);
        if (hashedPassword is error) {
            io:println("Password hashing error: " + hashedPassword.message());
            return error("Failed to hash password");
        }

        // Step 4: Create the SuperAdmin user for this organization
        sql:ExecutionResult result2 = check database:dbClient->execute(`
            INSERT INTO 
            users (username,usertype,email,profile_picture_url,phone_number,password,bio,created_at,org_id) 
            VALUES (${register.username},'SuperAdmin',${register.email},'https://img.freepik.com/free-vector/smiling-young-man-illustration_1308-174669.jpg?t=st=1746539771~exp=1746543371~hmac=66ec0b65bf0ae4d49922a69369cec4c0e3b3424613be723e0ca096a97d1039f1&w=740',NULL,${hashedPassword},'Organization Owner',NOW(),${orgId}) 
        `);

        if result.affectedRowCount > 0 && result2.affectedRowCount > 0 {
            return {message: "Organization created successfully", orgId: orgId};
        } else {
            return error("Failed to create organization");
        }
    }

    // Update organization profile - admin or authorized users can update organization details
    resource function put profile/[int orgid](http:Request req, @http:Payload OrgProfile profile) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update organization profile");
        }

        int userOrgId = check common:getOrgId(payload);

        // Ensure users can only update their own organization's data
        if (orgid != userOrgId) {
            return error("Forbidden: You can only update your own organization's profile");
        }

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE organizations 
            SET org_name = ${profile.org_name}, 
                org_logo = ${profile.org_logo}, 
                org_address = ${profile.org_address ?: ""},
                org_about = ${profile.org_about ?: ""},
                org_website = ${profile.org_website ?: ""},
                org_phone = ${profile.org_phone ?: ""},
                org_founded = ${profile.org_founded ?: ""},
                updated_at = NOW()
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

        int userOrgId = check common:getOrgId(payload);

        // Ensure users can only update their own organization's data
        if (orgid != userOrgId) {
            return error("Forbidden: You can only update your own organization's email");
        }

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE organizations SET org_email = ${email.email}, updated_at = NOW() WHERE org_id = ${orgid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Organization email updated successfully"};
        } else {
            return error("Failed to update organization email or organization not found");
        }
    }

    // Delete organization - ONLY SuperAdmin can delete organization (WARNING: This will delete ALL organization data)
    resource function delete organization/[int orgid](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow SuperAdmin to delete organization
        if (!common:hasAnyRole(payload, ["SuperAdmin"])) {
            return error("Forbidden: Only SuperAdmin can delete an organization");
        }

        int userOrgId = check common:getOrgId(payload);

        // Ensure SuperAdmin can only delete their own organization
        if (orgid != userOrgId) {
            return error("Forbidden: You can only delete your own organization");
        }

        // Check if organization exists before attempting deletion
        stream<record {|int count;|}, sql:Error?> orgCheckStream =
            database:dbClient->query(`SELECT COUNT(*) as count FROM organizations WHERE org_id = ${orgid}`);

        record {|int count;|}[] orgCheckResult = [];
        check orgCheckStream.forEach(function(record {|int count;|} result) {
            orgCheckResult.push(result);
        });

        if (orgCheckResult.length() == 0 || orgCheckResult[0].count == 0) {
            return error("Organization not found");
        }

        // WARNING: This will CASCADE DELETE all related data:
        // - All users in the organization
        // - All assets, meal times, meal types
        // - All requests (meals, assets, maintenance)
        // - All notifications and reports
        // This action is IRREVERSIBLE
        sql:ExecutionResult result = check database:dbClient->execute(`
            DELETE FROM organizations WHERE org_id = ${orgid}
        `);

        if result.affectedRowCount > 0 {
            return {
                message: "Organization and all associated data deleted successfully",
                warning: "This action is irreversible. All users, assets, requests, and data have been permanently removed."
            };
        } else {
            return error("Failed to delete organization");
        }
    }

    // Send verification email with code - open endpoint (no auth required)
    resource function post sendEmail(@http:Payload user:Email email) returns json|error {
        email:Message resetEmail = {
            to: [email.email],
            subject: "Organization Email Verification - ResourceHub",
            body: string `Hello,

Thank you for using ResourceHub for your organization's resource management needs. We need to verify this email address to ensure secure access to your organization's account.

VERIFICATION CODE: ${email.code ?: "ERROR - Contact Support"}

INSTRUCTIONS:
1. Enter this verification code in the application to verify your organization's email
2. This code is valid for a limited time for security purposes
3. Complete the verification to continue managing your organization's settings

SECURITY NOTICE:
This verification helps protect your organization's data and ensures only authorized personnel can make changes to your account settings.

If you did not request this verification code, please ignore this email. Your organization's account will remain unchanged and secure.

NEED ASSISTANCE?
Our support team is available to help with any questions or concerns. Contact us at resourcehub.contact.info@gmail.com

Thank you for trusting ResourceHub with your organization's resource management needs.

Best regards,
The ResourceHub Team
Your Digital Resource Management Solution`
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
