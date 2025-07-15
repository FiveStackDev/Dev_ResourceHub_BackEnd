# 🏢 Asset Module

> Comprehensive asset management and request system for ResourceHub

## 📋 Overview

The Asset module provides complete asset lifecycle management through two integrated services:
- **Asset Management Service** - Inventory and asset operations
- **Asset Request Service** - User requests and allocation tracking

---

## 🔗 API Endpoints

### 📦 Asset Service
**Base URL:** `http://localhost:9090/asset`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/details` | Retrieve all asset details | Admin, User, SuperAdmin |
| `POST` | `/add` | Add new asset to inventory | Admin, SuperAdmin |
| `PUT` | `/details/{id}` | Update existing asset | Admin, SuperAdmin |
| `DELETE` | `/details/{id}` | Remove asset from inventory | Admin, SuperAdmin |

### 📋 Asset Request Service  
**Base URL:** `http://localhost:9090/assetrequest`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/details` | Get all asset requests | Admin, SuperAdmin |
| `GET` | `/details/{userid}` | Get user-specific requests | Admin, User, SuperAdmin |
| `POST` | `/add` | Submit new asset request | Admin, User, SuperAdmin |
| `PUT` | `/details/{id}` | Update request status | Admin, SuperAdmin |
| `DELETE` | `/details/{id}` | Delete asset request | Admin, User, SuperAdmin |
| `GET` | `/dueassets` | Get all overdue assets | Admin, User, SuperAdmin |
| `GET` | `/dueassets/{userid}` | Get user-specific overdue assets | Admin, User, SuperAdmin |

---

## ✨ Key Features

- 🔄 **Asset CRUD Operations** - Complete asset lifecycle management
- 📋 **Request Management** - Handle user allocation requests  
- 📊 **Inventory Tracking** - Monitor asset distribution and availability
- ⏰ **Due Asset Monitoring** - Track overdue assets requiring return
- 🔐 **Role-Based Access** - Secure permissions for different user types
- ⏰ **Status & Deadline Tracking** - Real-time request and return monitoring

---

## 📊 Data Models

### 🏷️ Asset
```typescript
{
  asset_id: number,           // Unique identifier
  asset_name: string,         // Asset name
  category: string,           // Asset category  
  quantity: number,           // Available quantity
  condition_type: string,     // Asset condition
  location: string,           // Physical location
  is_available: boolean       // Availability status
}
```

### 📝 AssetRequest
```typescript
{
  requestedasset_id: number,  // Request ID
  user_id: number,            // Requesting user
  asset_id: number,           // Requested asset
  submitted_date: string,     // Submission date
  handover_date: string,      // Expected handover
  quantity: number,           // Requested quantity
  status: string,             // Request status
  is_returning: boolean       // Return flag
}
```
