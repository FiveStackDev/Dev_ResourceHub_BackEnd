import ResourceHub.common;
import ResourceHub.database;
import ResourceHub.user;

import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

// JWT configuration is now in jwt_utils.bal to avoid duplication

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /auth on database:authListener {

    // Login resource - issues JWT token with role claim
    resource function post login(@http:Payload Credentials credentials) returns json|error {

        sql:ParameterizedQuery query = `SELECT u.username, u.user_id, u.email, u.password, u.usertype, u.profile_picture_url, u.org_id, o.org_logo 
                                       FROM users u 
                                       LEFT JOIN organizations o ON u.org_id = o.org_id 
                                       WHERE u.email = ${credentials.email}`;
        UserAuthData|sql:Error result = database:dbClient->queryRow(query);

        if (result is sql:Error) {
            if (result is sql:NoRowsError) {
                io:println("Invalid email: " + credentials.email);
                return error("Invalid email");
            } else {
                io:println("Database error: " + result.message());
                return error("Database error");
            }
        }

        // Verify password using BCrypt
        boolean|error passwordMatches = common:verifyPassword(credentials.password, result.password);
        if (passwordMatches is error) {
            io:println("Password verification error: " + passwordMatches.message());
            return error("Password verification failed");
        }

        if (passwordMatches) {
            // Create a new mutable IssuerConfig
            jwt:IssuerConfig config = {
                username: credentials.email,
                issuer: jwtIssuerConfig.issuer,
                audience: jwtIssuerConfig.audience,
                signatureConfig: jwtIssuerConfig.signatureConfig,
                expTime: jwtIssuerConfig.expTime,
                customClaims: {
                    "role": result.usertype,
                    "username": result.username,
                    "id": result.user_id,
                    "email": result.email,
                    "profile_picture": result.profile_picture_url,
                    "org_id": result.org_id,
                    "org_logo": result.org_logo ?: ""
                }
            };

            string token = check jwt:issue(config);

            return {
                token: token
            };
        } else {
            io:println("Invalid password for user: " + credentials.email);
            return error("Invalid password");
        }
    }

    // Protected resource - requires valid JWT token with any role
    resource function get protected(http:Request req) returns string|error {
        io:println("Accessing protected resource");

        string|error authHeader = req.getHeader("Authorization");
        if (authHeader is error) {
            io:println("Authorization header not found");
            return error("Authorization header not found");
        }

        string token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;

        jwt:Payload|error payload = check jwt:validate(token, common:jwtValidatorConfig);
        if (payload is jwt:Payload) {
            io:println("Protected data accessed successfully by user: " + <string>payload["username"]);
            return "Protected data accessed successfully";
        } else {
            io:println("Unauthorized access attempt");
            return error("Unauthorized");
        }
    }

    // Admin-only resource - requires JWT with role "admin"
    resource function get adminResource(http:Request req) returns string|error {
        string|error authHeader = req.getHeader("Authorization");
        if (authHeader is error) {
            io:println("Authorization header not found");
            return error("Authorization header not found");
        }

        string token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;

        jwt:Payload|error payload = check jwt:validate(token, common:jwtValidatorConfig);
        if (payload is jwt:Payload) {
            anydata roleClaim = payload["role"];
            if (roleClaim is string && roleClaim == "admin") {
                io:println("Admin resource accessed by: " + <string>payload["username"]);
                return "Welcome Admin! This is a restricted resource.";
            } else {
                io:println("Forbidden: User role is not admin");
                return error("Forbidden: You do not have permission to access this resource");
            }
        } else {
            io:println("Unauthorized access attempt");
            return error("Unauthorized");
        }
    }

    // Password reset resource
    resource function post resetpassword(@http:Payload ForgotPassword password) returns json|error {
        // Validate email format (basic check)
        if !password.email.includes("@") || !password.email.includes(".") {
            return error("Invalid email format", statusCode = 400);
        }

        // First check if the user exists in the database
        sql:ParameterizedQuery checkUserQuery = `SELECT user_id, email FROM users WHERE email = ${password.email}`;
        stream<record {|int user_id; string email;|}, sql:Error?> userStream = database:dbClient->query(checkUserQuery);

        record {|int user_id; string email;|}? userRecord = ();
        check userStream.forEach(function(record {|int user_id; string email;|} user) {
            userRecord = user;
        });

        // If user doesn't exist, return error
        if userRecord is () {
            return error("No account found with this email address. Please check your email or register for a new account.", statusCode = 404);
        }

        // Generate simple random password
        string randomPassword = check common:generateSimplePassword(8);

        // Hash the random password using BCrypt
        string|error hashedPassword = common:hashPassword(randomPassword);
        if (hashedPassword is error) {
            io:println("Password hashing error: " + hashedPassword.message());
            return error("Failed to hash password", statusCode = 500);
        }

        // Update password in database with hashed password for the existing user
        sql:ParameterizedQuery updateQuery = `UPDATE users SET password = ${hashedPassword} WHERE email = ${password.email}`;
        sql:ExecutionResult updateResult = check database:dbClient->execute(updateQuery);

        if updateResult.affectedRowCount == 0 {
            return error("Failed to reset password", statusCode = 500);
        }

        // Send email with new password only after confirming user exists and password is updated
        email:Message resetEmail = {
            to: [password.email],
            subject: "Password Reset - ResourceHub Account",
            body: string `Hello,

We received a request to reset the password for your ResourceHub account. If you made this request, please follow the instructions below to regain access to your account.

TEMPORARY LOGIN CREDENTIALS:
Email: ${password.email}
Temporary Password: ${randomPassword}

NEXT STEPS:
1. Visit our login page: https://fivestackdev-resourcehub.vercel.app/
2. Log in using your email and the temporary password above
3. Once logged in, you will be prompted to create a new secure password
4. Choose a strong password that you don't use elsewhere

IMPORTANT SECURITY NOTICE:
- This temporary password will expire after your first successful login
- For your security, please update your password immediately after logging in
- If you did not request this password reset, please ignore this email - your account remains secure

NEED HELP?
If you experience any issues or have questions, our support team is here to help. Contact us at resourcehub.contact.info@gmail.com

Thank you for using ResourceHub. We're committed to keeping your account secure and providing you with the best experience possible.

Best regards,
The ResourceHub Team
Your Digital Resource Management Solution`
        };

        error? emailResult = common:emailClient->sendMessage(resetEmail);
        if emailResult is error {
            io:println("Error sending password email: ", emailResult.message());
            return error("Password was reset but failed to send email notification. Please contact support.", statusCode = 500);
        }

        return {
            message: "Password reset successful. Check your email for the temporary password."
        };
    }

    // Send verification code for forgot password - checks if user exists first
    resource function post sendForgotPasswordCode(@http:Payload user:Email email) returns json|error {
        // Validate email format (basic check)
        if !email.email.includes("@") || !email.email.includes(".") {
            return error("Invalid email format", statusCode = 400);
        }

        // Check if the user exists in the database
        sql:ParameterizedQuery checkUserQuery = `SELECT user_id, email FROM users WHERE email = ${email.email}`;
        stream<record {|int user_id; string email;|}, sql:Error?> userStream = database:dbClient->query(checkUserQuery);

        record {|int user_id; string email;|}? userRecord = ();
        check userStream.forEach(function(record {|int user_id; string email;|} user) {
            userRecord = user;
        });

        // If user doesn't exist, return error
        if userRecord is () {
            return error("No account found with this email address. Please check your email or register for a new account.", statusCode = 404);
        }

        // User exists, send verification code
        email:Message verificationEmail = {
            to: [email.email],
            subject: "Password Reset Verification Code - ResourceHub",
            body: string `Hello,

We received a request to reset the password for your ResourceHub account. To proceed with the password reset, please verify your identity by entering the verification code below.

VERIFICATION CODE: ${email.code ?: "ERROR - Contact Support"}

INSTRUCTIONS:
1. Enter this verification code in the password reset form within the next few minutes
2. This code is valid for a limited time for security purposes
3. After verification, you will receive a new temporary password via email

SECURITY NOTE:
If you did not request this password reset, you can safely ignore this email. No changes will be made to your account, and your information remains secure.

NEED ASSISTANCE?
Our support team is ready to help if you encounter any issues. Contact us at resourcehub.contact.info@gmail.com with any questions or concerns.

Thank you for choosing ResourceHub. We appreciate your trust in our platform and are committed to providing you with excellent service.

Best regards,
The ResourceHub Team
Your Digital Resource Management Solution`
        };

        error? emailResult = common:emailClient->sendMessage(verificationEmail);
        if emailResult is error {
            return error("Failed to send verification code. Please try again later.", statusCode = 500);
        }

        return {
            message: "Verification code sent successfully. Check your email for the code."
        };
    }
}

public function startAuthService() returns error? {
    io:println("Auth service started on port 9094");
}
