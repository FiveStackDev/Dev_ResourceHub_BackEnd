import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

type ForgotPassword record {
    string email;
};



@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /auth on ln {

    // Login resource - issues JWT token with role claim
    resource function post login(@http:Payload record {string email; string password;} credentials) returns json|error {

        sql:ParameterizedQuery query = `SELECT username, user_id, email, password, usertype, profile_picture_url FROM users WHERE email = ${credentials.email}`;
        record {|string username; int user_id; string email; string password; string usertype; string profile_picture_url;|}|sql:Error result = dbClient->queryRow(query);

        if (result is sql:Error) {
            if (result is sql:NoRowsError) {
                io:println("Invalid email: " + credentials.email);
                return error("Invalid email");
            } else {
                io:println("Database error: " + result.message());
                return error("Database error");
            }
        }

        if (result.password == credentials.password) {
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
                    "profile_picture": result.profile_picture_url
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

        jwt:Payload|error payload = check jwt:validate(token, jwtValidatorConfig);
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

        jwt:Payload|error payload = check jwt:validate(token, jwtValidatorConfig);
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
        string randomPassword = check generateSimplePassword(8);

        // Update password in database
        sql:ParameterizedQuery updateQuery = `UPDATE users SET password = ${randomPassword} WHERE email = ${password.email}`;
        sql:ExecutionResult updateResult = check dbClient->execute(updateQuery);

        if updateResult.affectedRowCount == 0 {
            return error("Failed to reset password", statusCode = 500);
        }

        // Send email with new password
        email:Message resetEmail = {
            to: [password.email],
            subject: "Your Account Password Reset",
            body: string `Your temporary password is: ${randomPassword}
                         Please change your password after logging in.
                         Login here: http://localhost:5173/login`
        };

        error? emailResult = emailClient->sendMessage(resetEmail);
        if emailResult is error {
            io:println("Error sending password email: ", emailResult.message());
            // Don't fail the request if email fails, but log it
        }

        return {
            message: "Password reset successful. Check your email for the temporary password."
        };
    }
}
