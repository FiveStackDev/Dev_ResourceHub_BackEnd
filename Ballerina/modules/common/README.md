# 🛠️ Common Module

> Shared utilities and configurations for all ResourceHub modules

## 📋 Overview

Provides centralized authentication, authorization, email services, and utility functions shared across all ResourceHub modules.

---

## ✨ Key Features

- 🔐 **JWT Validation** - Centralized token validation and payload extraction
- 👥 **Role-Based Access Control** - Authorization functions for different user roles
- 📧 **Email Service Configuration** - Shared SMTP client setup
- 🔧 **Common Utilities** - Shared helper functions for all modules
- 🛡️ **Security Configuration** - Centralized security settings
- 🔑 **Password Generation** - Secure password creation utilities

---

## 🔧 Key Functions

### 🔐 Authentication Functions

#### `getValidatedPayload(http:Request req)`
**Returns:** `jwt:Payload|error`  
**Description:** Extracts and validates JWT token from request headers

#### `hasRole(jwt:Payload payload, string requiredRole)`
**Returns:** `boolean`  
**Description:** Check if user has a specific role

#### `hasAnyRole(jwt:Payload payload, string[] allowedRoles)`
**Returns:** `boolean`  
**Description:** Check if user has any of the specified roles

### 🔧 Utility Functions

#### `generateSimplePassword(int length)`
**Returns:** `string|error`  
**Description:** Generate a secure random password

---

## 👥 Supported Roles

- 🛡️ **Admin** - Administrative access to most functions
- 🚀 **SuperAdmin** - Highest level system control
- 👤 **User** - Standard user with limited permissions
- 📋 **Manager** - Enhanced user access with some admin capabilities

---

## ⚙️ Configuration

### 🔐 JWT Configuration
```ballerina
jwt:ValidatorConfig jwtValidatorConfig = {
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        certFile: "resources/certificates/certificate.crt"
    },
    clockSkew: 60
};
```

### 📧 Email Configuration
```ballerina
configurable string SMTP_HOST = ?;
configurable string SMTP_USER = ?;
configurable string SMTP_PASSWORD = ?;
```
