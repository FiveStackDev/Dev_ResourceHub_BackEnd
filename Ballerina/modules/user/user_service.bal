import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerina/jwt;
import ResourceHub.database;
import ResourceHub.common;

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
        stream<record {| int count; |}, sql:Error?> emailCheckStream = 
            database:dbClient->query(`SELECT COUNT(*) as count FROM users WHERE email = ${user.email}`);
        
        record {| int count; |}[] emailCheckResult = [];
        check emailCheckStream.forEach(function(record {| int count; |} result) {
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
                subject: "Your Account Login Password", 
                body: string `Hello,

Welcome to ResourceHub - we're thrilled to have you join our platform!

An account has been created for you, and you're now one step away from accessing a powerful suite of tools and resources designed to make your experience smooth and productive.

Here are your temporary login credentials:

Temporary Password: ${randomPassword}

To begin using your account, please follow these steps:

Click the link below to log in to your account:
https://fivestackdev-resourcehub.vercel.app/

Use your temporary password to log in.

Once logged in, you will be prompted to create a new secure password. This is a mandatory step to protect your account.

⚠ Important: For your security, we recommend choosing a strong password that you do not use elsewhere.

If you were not expecting this account or believe this message was sent in error, you can safely ignore it—no action will be taken.

Should you need help or have any questions, feel free to contact our support team. We're here to help!

Best regards,
The ResourceHub Team` 
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
        stream<record {| int count; |}, sql:Error?> emailCheckStream = 
            database:dbClient->query(`SELECT COUNT(*) as count FROM users WHERE email = ${user.email} AND user_id != ${userid}`);

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