import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;
import ResourceHub.database;
import ResourceHub.common;

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

        // Generate simple random password
        string randomPassword = check common:generateSimplePassword(8);

        // Hash the random password using BCrypt
        string|error hashedPassword = common:hashPassword(randomPassword);
        if (hashedPassword is error) {
            io:println("Password hashing error: " + hashedPassword.message());
            return error("Failed to hash password", statusCode = 500);
        }

        // Update password in database with hashed password
        sql:ParameterizedQuery updateQuery = `UPDATE users SET password = ${hashedPassword} WHERE email = ${password.email}`;
        sql:ExecutionResult updateResult = check database:dbClient->execute(updateQuery);

        if updateResult.affectedRowCount == 0 {
            return error("Failed to reset password", statusCode = 500);
        }

        // Send email with new password
        email:Message resetEmail = {
            to: [password.email],
            subject: "Your Account Password Reset",
            body: string `We received a request to reset the password associated with your account. If you made this request, you can reset your password by clicking the button below:

https://fivestackdev-resourcehub.vercel.app/

As part of the process, here is your temporary password: ${randomPassword}

Please use this temporary password to log in and remember to update it with a new secure password after logging in.

If you did not request a password reset, please ignore this email. Your password will remain unchanged.

If you have any questions or need further assistance, feel free to contact our support team.

Best regards,
ResourceHub
Support Team`
        };

        error? emailResult = common:emailClient->sendMessage(resetEmail);
        if emailResult is error {
            io:println("Error sending password email: ", emailResult.message());
            // Don't fail the request if email fails, but log it
        }

        return {
            message: "Password reset successful. Check your email for the temporary password."
        };
    }
}

public function startAuthService() returns error? {
    io:println("Auth service started on port 9094");
}