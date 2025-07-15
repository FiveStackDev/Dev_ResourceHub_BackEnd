# 📊 Dashboard Module

> Analytics and monitoring interfaces for ResourceHub administration and users

## 📋 Overview

Provides comprehensive dashboards with real-time analytics, statistics, and data visualization for both admin and user interfaces.

---

## 🔗 API Endpoints

### 🛡️ Admin Dashboard Service
**Base URL:** `http://localhost:9090/admin`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/stats` | Get comprehensive admin statistics | Admin, SuperAdmin |
| `GET` | `/resources` | Get resource utilization data | Admin, SuperAdmin |
| `GET` | `/mealdistribution` | Get meal distribution analytics | Admin, SuperAdmin |
| `GET` | `/resourceallocation` | Get asset allocation statistics | Admin, SuperAdmin |

### 👤 User Dashboard Service
**Base URL:** `http://localhost:9092/user`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/stats/{userId}` | Get user-specific statistics | User (own), Admin, SuperAdmin |
| `GET` | `/activities/{userId}` | Get user activity timeline | User (own), Admin, SuperAdmin |
| `GET` | `/quickactions` | Get available quick actions | Authenticated User |

---

## ✨ Key Features

- 📈 **Admin Dashboard** - System-wide statistics and analytics
- 👤 **User Dashboard** - Personalized data and activity tracking
- 📊 **Resource Monitoring** - Asset distribution and utilization
- 🔔 **Activity Tracking** - User actions and system events
- 📉 **Chart Data Generation** - Formatted data for visualizations
- ⚡ **Quick Actions** - Common functions for user convenience

---

## 📊 Dashboard Components

- 📋 **Statistics Cards** - Key performance indicators
- 📈 **Charts & Graphs** - Visual data representation  
- 📰 **Activity Feeds** - Real-time activity streams
- ⚡ **Quick Actions** - One-click operations
- 📦 **Resource Status** - Current system availability
