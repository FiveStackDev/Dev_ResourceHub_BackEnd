import ballerina/crypto;
import ballerina/http;
import ballerina/jwt;
import ballerina/random;

// JWT validator configuration - defined here to avoid circular imports
public jwt:ValidatorConfig jwtValidatorConfig = {
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        certFile: "resources/certificates/certificate.crt"
    },
    clockSkew: 60
};

// Helper function to extract and validate JWT token and return payload
public function getValidatedPayload(http:Request req) returns jwt:Payload|error {
    string|error authHeader = req.getHeader("Authorization");
    if (authHeader is error) {
        return error("Authorization header not found");
    }

    string token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
    jwt:Payload|error payload = jwt:validate(token, jwtValidatorConfig);
    if (payload is error) {
        return error("Invalid or expired token");
    }
    return payload;
}

// Helper function to check role from JWT payload
public function hasRole(jwt:Payload payload, string requiredRole) returns boolean {
    anydata roleClaim = payload["role"];
    return roleClaim is string && roleClaim == requiredRole;
}

// Helper function to check if user has any of the allowed roles
public function hasAnyRole(jwt:Payload payload, string[] allowedRoles) returns boolean {
    anydata roleClaim = payload["role"];
    if roleClaim is string {
        foreach string role in allowedRoles {
            if roleClaim == role {
                return true;
            }
        }
    }
    return false;
}

// Helper function to extract user_id from JWT payload
public function getUserId(jwt:Payload payload) returns int|error {
    anydata userIdClaim = payload["id"];
    if userIdClaim is int {
        return userIdClaim;
    }
    return error("User ID not found in token");
}

// Helper function to extract org_id from JWT payload
public function getOrgId(jwt:Payload payload) returns int|error {
    anydata orgIdClaim = payload["org_id"];
    if orgIdClaim is int {
        return orgIdClaim;
    }
    return error("Organization ID not found in token");
}

// Helper function to extract both user_id and org_id from JWT payload
public function getUserAndOrgId(jwt:Payload payload) returns [int, int]|error {
    int userId = check getUserId(payload);
    int orgId = check getOrgId(payload);
    return [userId, orgId];
}

// Utility function to generate random lowercase password
public function generateSimplePassword(int length) returns string|error {
    final string CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
    string[] chars = [];

    foreach int _ in 0 ..< length {
        int randomIndex = check random:createIntInRange(0, CHARACTERS.length());
        chars.push(CHARACTERS[randomIndex]);
    }

    return chars.reduce(function(string acc, string c) returns string => acc + c, "");
}

// Utility function to hash password using BCrypt
public function hashPassword(string password) returns string|error {
    string|crypto:Error hashedPassword = crypto:hashBcrypt(password);
    if (hashedPassword is crypto:Error) {
        return error("Failed to hash password: " + hashedPassword.message());
    }
    return hashedPassword;
}

// Utility function to verify password using BCrypt
public function verifyPassword(string password, string hashedPassword) returns boolean|error {
    boolean|crypto:Error isValid = crypto:verifyBcrypt(password, hashedPassword);
    if (isValid is crypto:Error) {
        return error("Failed to verify password: " + isValid.message());
    }
    return isValid;
}

// Utility function to hash password with custom work factor
public function hashPasswordWithWorkFactor(string password, int workFactor) returns string|error {
    if (workFactor < 4 || workFactor > 31) {
        return error("Work factor must be between 4 and 31");
    }
    
    string|crypto:Error hashedPassword = crypto:hashBcrypt(password, workFactor);
    if (hashedPassword is crypto:Error) {
        return error("Failed to hash password: " + hashedPassword.message());
    }
    return hashedPassword;
}
