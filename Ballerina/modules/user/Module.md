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
| `GET` | `/details` | Get all users (admin view) | Admin, SuperAdmin |
| `GET` | `/details/{id}` | Get specific user details | Admin, User (own), SuperAdmin |
| `POST` | `/add` | Create new user account | Admin, SuperAdmin |
| `PUT` | `/details/{id}` | Update user information | Admin, User (own), SuperAdmin |
| `DELETE` | `/details/{id}` | Delete user account | Admin, SuperAdmin |

### ⚙️ Account Settings Service
**Base URL:** `http://localhost:9090/account`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/profile` | Get user profile | Authenticated User |
| `PUT` | `/profile` | Update user profile | Authenticated User |
| `PUT` | `/password` | Change password | Authenticated User |
| `PUT` | `/email` | Update email address | Authenticated User |
| `PUT` | `/phone` | Update phone number | Authenticated User |
| `POST` | `/upload-avatar` | Upload profile picture | Authenticated User |

---

## ✨ Key Features

- 🔄 **User CRUD Operations** - Complete user lifecycle management
- ⚙️ **Account Settings** - Profile and preference management
- 🖼️ **Avatar Upload** - Profile picture management
- 👥 **Role-Based Access** - Different access levels for user types
- 🔍 **User Search** - Search and filter functionality

---

## 👤 User Types

- 🛡️ **Admin** - Full system access with user management
- 🚀 **SuperAdmin** - Highest level system administration  
- 👤 **User** - Standard access to own data and resources
