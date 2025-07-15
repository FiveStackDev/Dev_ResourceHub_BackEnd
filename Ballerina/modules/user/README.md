# 👥 User Module

> Complete user management and account settings for ResourceHub

## 📋 Overview

Manages user accounts, profiles, and settings with role-based access control and comprehensive user lifecycle management.

---

## 🔗 API Endpoints

### 👤 User Management Service
**Base URL:** `http://localhost:9090/user`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/details` | Get all users (admin view) | Admin, User, SuperAdmin |
| `POST` | `/add` | Create new user account | Admin, SuperAdmin |
| `PUT` | `/details/{userid}` | Update user information | Admin, SuperAdmin |
| `DELETE` | `/details/{id}` | Delete user account | Admin, SuperAdmin |

### ⚙️ Account Settings Service
**Base URL:** `http://localhost:9090/settings`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/details/{userid}` | Get user profile details | Admin, User, SuperAdmin |
| `PUT` | `/profile/{userid}` | Update user profile | Admin, User, SuperAdmin |
| `PUT` | `/email/{userid}` | Update email address | Admin, User, SuperAdmin |
| `PUT` | `/phone/{userid}` | Update phone number | Admin, User, SuperAdmin |
| `PUT` | `/password/{userid}` | Change password | Admin, User, SuperAdmin |
| `POST` | `/sendEmail` | Send verification email | Public |

---

## ✨ Key Features

- 🔄 **User CRUD Operations** - Complete user lifecycle management
- ⚙️ **Account Settings** - Profile and preference management
- � **Email Management** - Email updates with verification codes
- 📱 **Phone Management** - Phone number updates and verification
- 🔐 **Password Management** - Secure password change with validation
- 👥 **Role-Based Access** - Different access levels for user types
- � **Automated Notifications** - Email notifications for account creation
- 🆔 **User Profile Management** - Username, bio, and profile picture updates

---

## 📊 User Management Features

### 🔐 Account Creation
- **Automatic Password Generation** - 8-character random passwords
- **Email Notifications** - Welcome emails with temporary credentials
- **Default Profile Setup** - Standard profile picture and settings

### ⚙️ Profile Management
- **Profile Updates** - Username, bio, and profile picture
- **Email Verification** - Verification codes for email changes
- **Phone Updates** - Phone number management
- **Password Security** - Current password validation for changes

---

## 👤 User Types

- 🛡️ **Admin** - Full system access with user management
- 🚀 **SuperAdmin** - Highest level system administration  
- 👤 **User** - Standard access to own data and resources
