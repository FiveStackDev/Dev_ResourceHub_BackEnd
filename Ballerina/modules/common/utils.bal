import ballerina/http;
import ballerina/jwt;
import ballerina/random;
import ballerina/crypto;
import ballerina/regex;

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

// Utility function to generate random lowercase password
public function generateSimplePassword(int length) returns string|error {
    final string LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
    string[] chars = [];

    foreach int _ in 0 ..< length {
        int randomIndex = check random:createIntInRange(0, LOWERCASE.length());
        chars.push(LOWERCASE[randomIndex]);
    }

    return chars.reduce(function(string acc, string c) returns string => acc + c, "");
}

// Generate a random salt for password hashing
public function generateSalt() returns string|error {
    final string CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    string[] saltChars = [];
    
    foreach int _ in 0 ..< 16 { // 16 character salt
        int randomIndex = check random:createIntInRange(0, CHARS.length());
        saltChars.push(CHARS[randomIndex]);
    }
    
    return saltChars.reduce(function(string acc, string c) returns string => acc + c, "");
}

// Hash password with salt using SHA-256
public function hashPassword(string password) returns string|error {
    string salt = check generateSalt();
    string saltedPassword = password + salt;
    byte[] passwordBytes = saltedPassword.toBytes();
    byte[] hashedBytes = crypto:hashSha256(passwordBytes);
    string hashedPassword = hashedBytes.toBase16();
    
    // Return salt:hash format for storage
    return salt + ":" + hashedPassword;
}

// Verify password against stored hash
public function verifyPassword(string password, string storedHash) returns boolean|error {
    // Split stored hash to get salt and hash
    string[] parts = regex:split(storedHash, ":");
    if parts.length() != 2 {
        return false; // Invalid hash format
    }
    
    string salt = parts[0];
    string expectedHash = parts[1];
    
    // Hash the provided password with the same salt
    string saltedPassword = password + salt;
    byte[] passwordBytes = saltedPassword.toBytes();
    byte[] hashedBytes = crypto:hashSha256(passwordBytes);
    string actualHash = hashedBytes.toBase16();
    
    // Compare hashes (constant-time comparison would be better in production)
    return actualHash == expectedHash;
}
