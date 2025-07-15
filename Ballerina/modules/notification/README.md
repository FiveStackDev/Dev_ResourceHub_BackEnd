# 🔔 Notification Module

> Real-time notification and alert system for ResourceHub

## 📋 Overview

Manages system notifications, alerts, and real-time updates with focus on maintenance request notifications and system-wide announcements.

---

## 🔗 API Endpoints

### 🔔 Notification Service
**Base URL:** `http://localhost:9093/notification`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/details` | Retrieve all pending notifications | Admin, User, SuperAdmin |
| `POST` | `/add` | Add custom notification | Admin, SuperAdmin |

---

## ✨ Key Features

- 🔄 **Real-time Notifications** - Live updates for pending maintenance requests
- 🚨 **Alert Management** - System-wide announcements and alerts
- 👥 **User-Specific Notifications** - Personalized notification delivery
- 🔧 **Maintenance Integration** - Automatic notifications for maintenance requests
- 🛡️ **Role-Based Access** - Different notification levels for user types
- 📊 **Status Tracking** - Monitor notification delivery and status

---

## 📊 Notification Features

### 🔧 Maintenance Notifications
- **Pending Requests** - Automatic notifications for pending maintenance
- **User Integration** - Links to user profiles and maintenance details
- **Priority Levels** - Different notification urgency levels
- **Status Updates** - Real-time status change notifications

### 🚨 System Alerts
- **Custom Notifications** - Admin-created system announcements
- **Broadcast Messages** - Organization-wide communications
- **Alert Categories** - Different types of system notifications

---

## 📊 Data Model

### 🔔 Notification Structure
- **Maintenance ID** - Link to maintenance request
- **User Information** - User ID, username, and profile picture
- **Content Details** - Name, description, and priority level
- **Timestamps** - Submission dates and status tracking
- **Status Information** - Current notification status

---

## 🔧 Technical Details

- **Port:** 9093 (Dedicated notification listener)
- **Database Integration** - Direct connection to maintenance and user data
- **CORS Support** - Cross-origin requests for web clients
- **JWT Authentication** - Secure access control
- **Real-time Updates** - Live notification delivery system
