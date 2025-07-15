import ballerina/jwt;

// JWT issuer configuration
public jwt:IssuerConfig jwtIssuerConfig = {
    username: "ballerina",
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        config: {
            keyFile: "resources/certificates/certificate.key"
        }
    },
    expTime: 3600
};

// JWT validator configuration
public jwt:ValidatorConfig jwtValidatorConfig = {
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        certFile: "resources/certificates/certificate.crt"
    },
    clockSkew: 60
};
