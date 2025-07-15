# 🔧 Maintenance Module

> Comprehensive maintenance request management for ResourceHub facilities

## 📋 Overview

Manages maintenance tickets with priority levels, status tracking, and notification capabilities for efficient facility management.

---

## 🔗 API Endpoints

### 🛠️ Maintenance Management Service
**Base URL:** `http://localhost:9090/maintenance`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/details` | Get all maintenance requests | Admin, User, SuperAdmin |
| `POST` | `/add` | Submit new maintenance request | Admin, User, SuperAdmin |
| `PUT` | `/details/{id}` | Update request status | Admin, SuperAdmin |
| `DELETE` | `/details/{id}` | Delete maintenance request | Admin, SuperAdmin |
| `GET` | `/notification` | Get maintenance notifications | Admin, User, SuperAdmin |
| `POST` | `/addnotification` | Create maintenance notification | Admin, SuperAdmin |

---

## ✨ Key Features

- 🔄 **Request CRUD Operations** - Complete maintenance ticket lifecycle
- 🏷️ **Priority Management** - Low, Medium, High, Critical levels
- 📊 **Status Tracking** - Pending, In Progress, Completed, Cancelled
- 🔔 **Notification System** - Alerts for updates and deadlines
- 👥 **User Integration** - Link requests to user profiles
- ⏰ **Timeline Tracking** - Monitor submission and completion dates

---

## 🏷️ Priority Levels

| Level | Description |
|-------|-------------|
| 🔴 **Critical** | Immediate attention (safety/security) |
| 🟠 **High** | Urgent resolution needed |
| 🟡 **Medium** | Standard priority |
| 🟢 **Low** | Non-urgent issues |

---

## 📊 Status Workflow

1. **⏳ Pending** - Request submitted, awaiting assignment
2. **🔄 In Progress** - Work has begun on the request  
3. **✅ Completed** - Maintenance work finished
4. **❌ Cancelled** - Request cancelled or no longer needed
