import ballerina/email;
import ballerina/http;
import ballerina/jwt;
import ballerina/sql;
import ResourceHub.database;
import ResourceHub.common;
import ballerina/io;

// CORS configuration for client access
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /settings on database:mainListener {

    // Fetch user profile details by user ID - accessible by user themselves or admin
    resource function get details/[int userid](http:Request req) returns Profile[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        stream<Profile, sql:Error?> resultStream = database:dbClient->query(`
            SELECT username, profile_picture_url, bio, usertype, email, phone_number 
            FROM users WHERE user_id = ${userid} AND org_id = ${orgId}
        `);

        Profile[] profiles = [];
        check resultStream.forEach(function(Profile profile) {
            profiles.push(profile);
        });

        return profiles;
    }

    // Update username, profile picture, and bio - user can update own profile, admin can update any
    resource function put profile/[int userid](http:Request req, @http:Payload Profile profile) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update profiles");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE users SET username = ${profile.username}, 
                           profile_picture_url = ${profile.profile_picture_url}, 
                           bio = ${profile.bio ?: ""}
            WHERE user_id = ${userid} AND org_id = ${orgId}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Profile updated successfully"};
        } else {
            return error("Failed to update profile");
        }
    }

    // Update email address - user can update own email, admin can update any
    resource function put email/[int userid](http:Request req, @http:Payload Email email) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update email");
        }

               int orgId = check common:getOrgId(payload);
        
        // Check if email already exists in the organization (excluding current user)
        stream<record {| int count; |}, sql:Error?> emailCheckStream = 
            database:dbClient->query(`SELECT COUNT(*) as count FROM users WHERE email = ${email.email} AND user_id != ${userid}`);

        record {| int count; |}[] emailCheckResult = [];
        check emailCheckStream.forEach(function(record {| int count; |} result) {
            emailCheckResult.push(result);
        });

        if (emailCheckResult.length() > 0 && emailCheckResult[0].count > 0) {
            return {
                message: "Email already exists in a organization. Please use a different email address."
            };
        }

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE users SET email = ${email.email} WHERE user_id = ${userid} AND org_id = ${orgId}
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
            subject: "🔐 Your Verification Code",
            body: string `🔐 Your Verification Code: ${email.code ?: "!!error!!"}

Please enter this code within the next few minutes to complete the verification process. This helps us ensure the security of your account and provide you with the best experience.

If you did not request this verification code, you can safely ignore this email. Your account will remain unchanged and no action will be taken.

Need help? Our support team is here for you. Feel free to contact us at resourcehub.contact.info@gmail.com  if you have any questions or concerns.

Thanks for choosing ResourceHub. We're excited to have you on board!`
        };

        error? emailResult = common:emailClient->sendMessage(resetEmail);
        if emailResult is error {
            return error("Error sending Code to email");
        }

        return {
            message: "Code sent successfully. Check your email for the Verification Code."
        };
    }

    // Update phone number - user can update own phone, admin can update any
    resource function put phone/[int userid](http:Request req, @http:Payload Phone phone) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update phone");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE users SET phone_number = ${phone.phone_number} WHERE user_id = ${userid} AND org_id = ${orgId}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Phone number updated successfully"};
        } else {
            return error("Failed to update phone number");
        }
    }

    // Update password after validating current password - user can update own password, admin can update any
    resource function put password/[int userid](http:Request req, @http:Payload Password password) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!common:hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update password");
        }

        int orgId = check common:getOrgId(payload);

        // Verify current password using BCrypt
        record {|string password;|}|sql:Error currentPasswordResult = database:dbClient->queryRow(`
            SELECT password FROM users WHERE user_id = ${userid} AND org_id = ${orgId}
        `);

        if currentPasswordResult is sql:Error {
            return error("User not found");
        }

        // Verify the current password using BCrypt
        boolean|error passwordMatches = common:verifyPassword(password.current_password, currentPasswordResult.password);
        if (passwordMatches is error) {
            io:println("Password verification error: " + passwordMatches.message());
            return error("Password verification failed");
        }

        if (!passwordMatches) {
            return error("Current password is incorrect");
        }

        // Hash the new password using BCrypt
        string|error hashedNewPassword = common:hashPassword(password.new_password);
        if (hashedNewPassword is error) {
            io:println("Password hashing error: " + hashedNewPassword.message());
            return error("Failed to hash new password");
        }

        // Update to new hashed password
        sql:ExecutionResult result = check database:dbClient->execute(`
            UPDATE users SET password = ${hashedNewPassword} WHERE user_id = ${userid} AND org_id = ${orgId}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Password updated successfully"};
        } else {
            return error("Failed to update password");
        }
    }
}

public function startAccountSettingsService() returns error? {
    io:println("Account settings service started on port 9090");
}