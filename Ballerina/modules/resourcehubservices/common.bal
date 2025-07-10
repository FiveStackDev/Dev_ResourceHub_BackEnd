import ballerina/http;
import ballerina/jwt;
import ballerina/random;

// Helper function to extract and validate JWT token and return payload
function getValidatedPayload(http:Request req) returns jwt:Payload|error {
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
function hasRole(jwt:Payload payload, string requiredRole) returns boolean {
    anydata roleClaim = payload["role"];
    return roleClaim is string && roleClaim == requiredRole;
}

// Helper function to check if user has any of the allowed roles
function hasAnyRole(jwt:Payload payload, string[] allowedRoles) returns boolean {
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

// JWT issuer configuration
jwt:IssuerConfig jwtIssuerConfig = {
    username: "ballerina",
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        config: {
            keyFile: "auth/certificate.key"
        }
    },
    expTime: 3600
};

// JWT validator configuration
jwt:ValidatorConfig jwtValidatorConfig = {
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        certFile: "auth/certificate.crt"
    },
    clockSkew: 60
};

// Utility function to generate random lowercase password
function generateSimplePassword(int length) returns string|error {
    final string LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
    string[] chars = [];

    foreach int _ in 0 ..< length {
        int randomIndex = check random:createIntInRange(0, LOWERCASE.length());
        chars.push(LOWERCASE[randomIndex]);
    }

    return chars.reduce(function(string acc, string c) returns string => acc + c, "");
}