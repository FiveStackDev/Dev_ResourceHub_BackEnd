import ResourceHub.common;
import ResourceHub.database;

import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/sql;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}

service /user on database:mainListener {
    // Only admin, manager, and User can view user details
    resource function get details(http:Request req) returns User[]|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin", "User"])) {
            return error("Forbidden: You do not have permission to access this resource");
        }

        int orgId = check common:getOrgId(payload);

        stream<User, sql:Error?> resultStream =
            database:dbClient->query(`SELECT * FROM users WHERE org_id = ${orgId}`);
        User[] users = [];
        check resultStream.forEach(function(User user) {
            users.push(user);
        });
        return users;
    }

    // Only admin and manager can add users
    resource function post add(http:Request req, @http:Payload User user) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to add users");
        }

        int orgId = check common:getOrgId(payload);

        // Check if email already exists in the organization
        stream<record {|int count;|}, sql:Error?> emailCheckStream =
            database:dbClient->query(`SELECT COUNT(*) as count FROM users WHERE email = ${user.email}`);

        record {|int count;|}[] emailCheckResult = [];
        check emailCheckStream.forEach(function(record {|int count;|} result) {
            emailCheckResult.push(result);
        });

        if (emailCheckResult.length() > 0 && emailCheckResult[0].count > 0) {
            return {
                message: "Email already exists in a organization. Please use a different email address."
            };
        }

        // Generate a random password of length 8 
        string randomPassword = check common:generateSimplePassword(8);

        // Hash the random password using BCrypt
        string|error hashedPassword = common:hashPassword(randomPassword);
        if (hashedPassword is error) {
            io:println("Password hashing error: " + hashedPassword.message());
            return error("Failed to hash password");
        }

        sql:ExecutionResult result = check database:dbClient->execute(` 
            insert into 
            users (username,usertype,email,profile_picture_url,phone_number,password,bio,created_at,org_id) 
            values (${user.email},${user.usertype},${user.email},'https://img.freepik.com/free-vector/smiling-young-man-illustration_1308-174669.jpg?t=st=1746539771~exp=1746543371~hmac=66ec0b65bf0ae4d49922a69369cec4c0e3b3424613be723e0ca096a97d1039f1&w=740',NULL,${hashedPassword},${user.bio},NOW(),${orgId}) 
        `);
        if result.affectedRowCount != 0 {
            email:Message emailMsg = {
                to: [user.email],
                subject: "Welcome to ResourceHub - Account Created Successfully",
                body: string `Hello and Welcome to ResourceHub!

We're thrilled to have you join our platform! Your account has been successfully created, and you're now ready to access our comprehensive suite of resource management tools.

ACCOUNT DETAILS:
Email: ${user.email}
Temporary Password: ${randomPassword}

GETTING STARTED:
1. Visit our platform: https://fivestackdev-resourcehub.vercel.app/
2. Log in using your email and the temporary password above
3. You will be prompted to create a new secure password immediately after login
4. Complete your profile setup to get the most out of ResourceHub

IMPORTANT SECURITY REMINDER:
- This is a temporary password that must be changed upon first login
- Choose a strong, unique password that you don't use elsewhere
- Keep your login credentials secure and don't share them with others

WHAT'S NEXT?
Once you log in, you'll have access to:
- Resource management tools
- Team collaboration features
- Administrative dashboards
- And much more!

NEED SUPPORT?
If you have any questions or need assistance getting started, our support team is here to help. Contact us at resourcehub.contact.info@gmail.com

We're excited to see how ResourceHub will help streamline your resource management processes!

Best regards,
The ResourceHub Team
Your Digital Resource Management Solution`
            };
            var emailResult = common:emailClient->sendMessage(emailMsg);
            if emailResult is error {
                io:println("Error sending password email: ", emailResult.message());
            }
            return {
                message: "User added successfully. Temporary password sent via email."
            };
        } else {
            return {
                message: "Failed to add user."
            };
        }
    }

    // Only admin and manager can delete users
    resource function delete details/[int id](http:Request req) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to delete users");
        }

        int orgId = check common:getOrgId(payload);

        sql:ExecutionResult result = check database:dbClient->execute(` 
            DELETE FROM users WHERE user_id = ${id} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "User not found or you don't have permission to delete them"
            };
        }
        return {
            message: "User deleted successfully"
        };
    }

    // Only admin and manager can update users
    resource function PUT details/[int userid](http:Request req, @http:Payload User user) returns json|error {
        jwt:Payload payload = check common:getValidatedPayload(req);
        if (!common:hasAnyRole(payload, ["Admin", "SuperAdmin"])) {
            return error("Forbidden: You do not have permission to update users");
        }

        int orgId = check common:getOrgId(payload);

        // Check if email already exists in the organization (excluding current user)
        stream<record {|int count;|}, sql:Error?> emailCheckStream =
            database:dbClient->query(`SELECT COUNT(*) as count FROM users WHERE email = ${user.email} AND user_id != ${userid}`);

        record {|int count;|}[] emailCheckResult = [];
        check emailCheckStream.forEach(function(record {|int count;|} result) {
            emailCheckResult.push(result);
        });

        if (emailCheckResult.length() > 0 && emailCheckResult[0].count > 0) {
            return {
                message: "Email already exists in a organization. Please use a different email address."
            };
        }

        sql:ExecutionResult result = check database:dbClient->execute(` 
            UPDATE users set usertype = ${user.usertype},bio = ${user.bio} WHERE user_id = ${userid} AND org_id = ${orgId}
        `);
        if result.affectedRowCount == 0 {
            return {
                message: "User not found or you don't have permission to update them"
            };
        }
        return {
            message: "User updated successfully"
        };
    }
}

public function startUserManagementService() returns error? {
    io:println("User management service started on port 9090");
}
