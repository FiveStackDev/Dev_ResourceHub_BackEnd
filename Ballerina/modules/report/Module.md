# 📊 Report Module

> Automated report generation and scheduling system for ResourceHub analytics

## 📋 Overview

Generates comprehensive reports across all system modules with automated PDF creation, email distribution, and flexible scheduling.

---

## 🔗 API Endpoints

### 📈 Report Generation Service  
**Base URL:** `http://localhost:9091/report`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 📊 Report Type |
|-----------|-------------|----------------|----------------|
| `GET` | `/generateWeeklyMeal` | Generate weekly meal report | Meal Events |
| `GET` | `/generateBiweeklyMeal` | Generate biweekly meal report | Meal Events |
| `GET` | `/generateMonthlyMeal` | Generate monthly meal report | Meal Events |
| `GET` | `/generateWeeklyAsset` | Generate weekly asset report | Asset Requests |
| `GET` | `/generateBiweeklyAsset` | Generate biweekly asset report | Asset Requests |
| `GET` | `/generateMonthlyAsset` | Generate monthly asset report | Asset Requests |
| `GET` | `/generateWeeklyMaintenance` | Generate weekly maintenance report | Maintenance Requests |
| `GET` | `/generateBiweeklyMaintenance` | Generate biweekly maintenance report | Maintenance Requests |
| `GET` | `/generateMonthlyMaintenance` | Generate monthly maintenance report | Maintenance Requests |

### 📋 Report Data Service
**Base URL:** `http://localhost:9091/schedulereports`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 📊 Data Scope |
|-----------|-------------|----------------|---------------|
| `POST` | `/addscedulereport` | Schedule automatic report generation | Schedule Config |
| `GET` | `/weeklyassetrequestdetails` | Get weekly asset request data | Asset Data |
| `GET` | `/weeklymealdetails` | Get weekly meal event data | Meal Data |
| `GET` | `/weeklymaintenancedetails` | Get weekly maintenance data | Maintenance Data |

---

## ✨ Key Features

- 🤖 **Automated Generation** - Scheduled reports with configurable frequencies
- 📧 **Email Distribution** - Automatic delivery to stakeholders
- 📄 **PDF Creation** - Professional formatted reports
- ⏰ **Task Scheduling** - Periodic generation and distribution
- 📊 **Multi-Module Coverage** - Reports across assets, meals, maintenance
- 📅 **Flexible Scheduling** - Weekly, biweekly, monthly options

---

## 📊 Report Types

### 📦 Asset Reports
- Asset request summaries and usage analytics
- Allocation statistics and trends

### 🍽️ Meal Reports  
- Meal event summaries and participation analytics
- Dietary trends and service metrics

### 🔧 Maintenance Reports
- Request summaries and priority analysis
- Completion metrics and resource allocation

---

## 🔧 Configuration

- **PDFSHIFT API** - External PDF generation service
- **Email Settings** - SMTP configuration for delivery
- **Schedule Config** - Customizable reporting frequencies
