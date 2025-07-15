# 🔐 Auth Module

> Secure authentication and authorization system for ResourceHub

## 📋 Overview

Handles user authentication, JWT token management, and role-based access control across all ResourceHub services.

---

## 🔗 API Endpoints

### 🔑 Authentication Service
**Base URL:** `http://localhost:9094/auth`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `POST` | `/login` | User login with credentials | Public |
| `POST` | `/forgot-password` | Request password reset | Public |
| `POST` | `/reset-password` | Reset password with token | Public |
| `POST` | `/change-password` | Change user password | Authenticated User |
| `POST` | `/refresh-token` | Refresh JWT token | Authenticated User |

---

## ✨ Key Features

- 🔐 **User Authentication** - Secure email/password login system
- 🎫 **JWT Token Management** - Generate, validate, and refresh tokens
- 🔄 **Password Reset** - Email-based password recovery
- 👥 **Role-Based Access** - Support for Admin, User, SuperAdmin roles
- 🛡️ **Session Management** - Secure token handling with expiration

---

## 📊 Security Features

- 🔒 **JWT Encryption** - Secure token generation with custom claims
- 👤 **Role Claims** - Embedded user roles in JWT tokens  
- ⏰ **Token Expiration** - Configurable token lifetime
- 📧 **Email Verification** - Password reset via email
- 🌐 **CORS Support** - Cross-origin resource sharing
