import ballerina/email;
import ballerina/http;
import ballerina/jwt;
import ballerina/sql;

// Profile data structure for user settings
public type Profile record {|
    string username;
    string profile_picture_url;
    string? bio = ();
    string? usertype = ();
    string? email = ();
    string? phone_number = ();
|};

// Structure to carry email and verification code
public type Email record {|
    string email;
    int? code = ();
|};

// Structure for phone number update
public type Phone record {|
    string phone_number;
|};

// Structure for password update request
public type Password record {|
    string current_password;
    string new_password;
|};

// CORS configuration for client access
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /settings on ln {

    // Fetch user profile details by user ID - accessible by user themselves or admin
    resource function get details/[int userid](http:Request req) returns Profile[]|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        stream<Profile, sql:Error?> resultStream = dbClient->query(`
            SELECT username,
            email,
            phone_number,
            profile_picture_url,
            usertype,
            bio
            FROM users
            WHERE user_id = ${userid}`);

        Profile[] profiles = [];
        check resultStream.forEach(function(Profile profile) {
            profiles.push(profile);
        });

        return profiles;
    }

    // Update username, profile picture, and bio - user can update own profile, admin can update any
    resource function put profile/[int userid](http:Request req, @http:Payload Profile profile) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update this profile");
        }

        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
            username = ${profile.username}, 
            profile_picture_url = ${profile.profile_picture_url}, 
            bio = ${profile.bio} 
            WHERE user_id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Profile updated successfully"};
        } else {
            return error("Failed to update profile");
        }
    }

    // Update email address - user can update own email, admin can update any
    resource function put email/[int userid](http:Request req, @http:Payload Email email) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update this email");
        }

        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
                email = ${email.email} 
            WHERE user_id = ${userid}
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
            body: string `Thank you for signing up with ResourceHub! To complete your Changes and secure your account, please verify your email address by entering the code below in the app

🔐 Your Verification Code: ${email.code ?: "!!error!!"}

Please enter this code within the next few minutes to complete the verification process. This helps us ensure the security of your account and provide you with the best experience.

If you did not request this verification code, you can safely ignore this email. Your account will remain unchanged and no action will be taken.

Need help? Our support team is here for you. Feel free to contact us at resourcehub.contact.info@gmail.com  if you have any questions or concerns.

Thanks for choosing ResourceHub. We're excited to have you on board!`
        };

        error? emailResult = emailClient->sendMessage(resetEmail);
        if emailResult is error {
            return error("Error sending Code to email");
        }

        return {
            message: "Code sent successfully. Check your email for the Verification Code."
        };
    }

    // Update phone number - user can update own phone, admin can update any
    resource function put phone/[int userid](http:Request req, @http:Payload Phone phone) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update this phone number");
        }

        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
                phone_number = ${phone.phone_number} 
            WHERE user_id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Phone number updated successfully"};
        } else {
            return error("Failed to update phone number");
        }
    }

    // Update password after validating current password - user can update own password, admin can update any
    resource function put password/[int userid](http:Request req, @http:Payload Password password) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only allow users with specific roles (e.g., admin, manager)
        if (!hasAnyRole(payload, ["Admin", "User", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update this password");
        }

        // Fetch the current password for validation
        stream<record {|string password;|}, sql:Error?> result = dbClient->query(`
            SELECT password FROM users WHERE user_id = ${userid}
        `);

        string? storedPassword = null;
        check result.forEach(function(record {|string password;|} rec) {
            storedPassword = rec.password;
        });

        if storedPassword != password.current_password {
            return error("Current password is incorrect");
        }

        if password.current_password == password.new_password {
            return error("New password cannot be the same as the current password");
        }

        // Update password in database
        sql:ExecutionResult updateResult = check dbClient->execute(`
            UPDATE users SET 
                password = ${password.new_password} 
            WHERE user_id = ${userid}
        `);

        if updateResult.affectedRowCount > 0 {
            return {message: "Password updated successfully"};
        } else {
            return error("Failed to update password");
        }
    }
}
