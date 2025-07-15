# 🗄️ Database Module

> Centralized database connectivity and configuration for ResourceHub

## 📋 Overview

Manages MySQL database connections, HTTP listeners, and provides shared database client instances for all ResourceHub services.

---

## ⚙️ Configuration

### 🗄️ Database Connection
**Type:** MySQL Database

| Parameter | Description |
|-----------|-------------|
| `HOST` | Database server hostname |
| `PORT` | Database server port |
| `USER` | Database username |
| `PASSWORD` | Database password |
| `DATABASE` | Database name |

### 🌐 HTTP Listeners
- **Primary Listener:** Port 9090 (Main services)
- **Report Listener:** Port 9091 (Report services)

---

## ✨ Key Features

- 🔗 **MySQL Connection Management** - Centralized database connectivity
- 🌐 **HTTP Listener Configuration** - Multi-port service setup
- 🔄 **Connection Pooling** - Efficient database connection management
- ⚙️ **Environment Configuration** - Configurable database parameters
- ✅ **Connection Validation** - Database connectivity verification

---

## 🏗️ Key Components

- **`dbClient`** - Shared MySQL client instance
- **`ln`** - Primary HTTP listener (port 9090)  
- **`report`** - Report HTTP listener (port 9091)

---

## 🔧 Functions

### `connectDatabase()`
**Returns:** `error?`  
**Description:** Establishes and validates MySQL database connection

---

## 📊 Database Schema

| Table | Description |
|-------|-------------|
| `users` | User account information |
| `assets` | Asset inventory and details |
| `requestedassets` | Asset allocation requests |
| `mealtypes` | Meal type definitions |
| `maintenance_requests` | Maintenance tickets |
| `organizations` | Organization settings |
