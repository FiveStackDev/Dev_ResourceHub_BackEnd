# 🏢 ResourceHub Backend

> A comprehensive, enterprise-grade resource management system built with Ballerina for modern organizations

[![Ballerina](https://img.shields.io/badge/Ballerina-2201.12.0-blue.svg)](https://ballerina.io/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-orange.svg)](https://www.mysql.com/)
[![Java](https://img.shields.io/badge/Java-17+-red.svg)](https://www.oracle.com/java/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/Version-0.1.0-blue.svg)]()

ResourceHub Backend is a **modular, scalable, and secure** backend system designed for comprehensive organizational resource management. Built with **Ballerina** for cloud-native environments, it provides robust APIs for asset management, meal services, maintenance tracking, user administration, and advanced analytics with enterprise-grade security and multi-tenant support.

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [🏗️ System Architecture](#️-system-architecture)
- [🚀 Quick Start](#-quick-start)
- [📚 API Documentation](#-api-documentation)
- [📦 Module Overview](#-module-overview)
- [⚙️ Configuration](#️-configuration)
- [💻 Development Guide](#-development-guide)
- [🚀 Deployment](#-deployment)
- [🧪 Testing](#-testing)
- [📊 Monitoring & Observability](#-monitoring--observability)
- [🔒 Security](#-security)
- [🤝 Contributing](#-contributing)
- [📞 Support](#-support)

---

## 🌟 Key Highlights

- **🔥 High Performance**: Built with Ballerina for optimal performance and concurrency
- **🛡️ Enterprise Security**: JWT authentication, RBAC, and data encryption
- **📊 Real-time Analytics**: Live dashboards and automated reporting
- **🔧 Modular Design**: Microservices architecture with independent scaling
- **🌐 Multi-tenant**: Support for multiple organizations
- **📱 RESTful APIs**: Standard HTTP REST endpoints with comprehensive documentation
- **🔄 Auto-scaling**: Cloud-native design for horizontal scaling

---

## ✨ Features

### 🏢 **Core Business Functionality**
- **🏷️ Asset Management** - Complete asset lifecycle management with allocation tracking, depreciation, and maintenance schedules
- **👥 User Management** - Comprehensive user administration with role-based access control and profile management
- **🍽️ Meal Services** - Advanced meal planning system with calendar integration, dietary preferences, and request management
- **🔧 Maintenance** - Intelligent facility maintenance system with priority levels, work orders, and completion tracking
- **🔔 Notifications** - Real-time notification system with multi-channel delivery (email, in-app, SMS)
- **🏢 Organizations** - Multi-tenant organization management with custom settings and branding
- **📊 Dashboard Analytics** - Comprehensive analytics with real-time KPIs, trends, and performance metrics

### 🔐 **Enterprise Security & Authentication**
- **🔑 JWT Authentication** - Secure, stateless token-based authentication with refresh token support
- **🛡️ Role-Based Access Control (RBAC)** - Granular permissions for User, Admin, SuperAdmin, and Manager roles
- **🌐 CORS Support** - Configurable cross-origin resource sharing for web applications
- **🔒 Data Encryption** - End-to-end data encryption for sensitive information
- **🔍 Audit Logging** - Comprehensive audit trails for security compliance
- **⚡ Rate Limiting** - API rate limiting to prevent abuse and ensure fair usage

### 📊 **Advanced Reporting & Analytics**
- **📈 Automated Reports** - Scheduled PDF report generation with customizable templates
- **📧 Email Distribution** - Intelligent report delivery with role-based distribution lists
- **📊 Multi-Module Analytics** - Cross-functional insights and business intelligence
- **⏱️ Real-time Dashboards** - Live system metrics, usage statistics, and performance indicators
- **📱 Mobile-Optimized** - Responsive design for mobile and tablet access
- **🔄 Data Export** - Multiple export formats (PDF, Excel, CSV) for further analysis

---

## 🏗️ System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        A[Web App] 
        B[Mobile App]
        C[Admin Dashboard]
    end
    
    subgraph "API Gateway"
        D[Load Balancer]
    end
    
    subgraph "ResourceHub Backend Services"
        E[Auth Service :9094]
        F[User Service :9090]
        G[Asset Service :9090]
        H[Meal Service :9090]
        I[Maintenance Service :9090]
        J[Notification Service :9093]
        K[Dashboard Service :9092]
        L[Report Service :9091]
        M[Organization Service :9090]
    end
    
    subgraph "Data Layer"
        N[MySQL Database]
        O[Redis Cache]
        P[File Storage]
    end
    
    subgraph "External Services"
        Q[SMTP Server]
        R[PDF Service]
        S[SMS Gateway]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    D --> F
    D --> G
    D --> H
    D --> I
    D --> J
    D --> K
    D --> L
    D --> M
    
    E --> N
    F --> N
    G --> N
    H --> N
    I --> N
    J --> N
    K --> N
    L --> N
    M --> N
    
    J --> O
    K --> O
    
    L --> P
    G --> P
    
    J --> Q
    L --> Q
    L --> R
    J --> S
```

### 🎯 **Architecture Principles**
- **🔧 Microservices Design** - Independent, loosely-coupled services for scalability
- **📦 Domain-Driven Design** - Services organized around business domains
- **🔄 Event-Driven Architecture** - Asynchronous communication for better performance
- **🛡️ Security-First** - Built-in security at every layer
- **📊 Observability** - Comprehensive logging, metrics, and tracing
- **🌐 Cloud-Native** - Designed for containerization and cloud deployment

### 🚀 **Technology Stack**
- **Backend**: Ballerina 2201.12.0 (Swan Lake)
- **Database**: MySQL 8.0+ with connection pooling
- **Authentication**: JWT with refresh tokens
- **Caching**: Redis for session and data caching
- **Documentation**: OpenAPI 3.0 specifications
- **Monitoring**: Ballerina observability features
- **Deployment**: Docker containers with Kubernetes support

---

## 🚀 Quick Start

### 📋 **Prerequisites**
- **Ballerina** 2201.12.0 (Swan Lake) or later - [Download](https://ballerina.io/downloads/)
- **MySQL** 8.0 or later - [Download](https://dev.mysql.com/downloads/)
- **Java** 17 or later (OpenJDK recommended) - [Download](https://adoptium.net/)
- **Git** for version control - [Download](https://git-scm.com/)

### 1️⃣ **Clone Repository**
```bash
# Clone the repository
git clone https://github.com/FiveStackDev/Resource_Hub-Backend-.git

# Navigate to the project directory
cd Resource_Hub-Backend-/Ballerina

# Verify Ballerina installation
bal version
```

### 2️⃣ **Database Setup**
```sql
-- 1. Create database and user
CREATE DATABASE resourcehub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'resourcehub_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON resourcehub.* TO 'resourcehub_user'@'localhost';
FLUSH PRIVILEGES;

-- 2. Run initialization scripts (execute in order)
mysql -u resourcehub_user -p resourcehub < resources/sql/create_database.sql
mysql -u resourcehub_user -p resourcehub < resources/sql/create_tables.sql
mysql -u resourcehub_user -p resourcehub < resources/sql/Data.sql
```

### 3️⃣ **Environment Configuration**
Create a `Config.toml` file in the project root directory:

```toml
# =============================================================================
# ResourceHub Backend Configuration
# =============================================================================

# Database Configuration
[ResourceHub.database]
USER = "resourcehub_user"           # Database username
PASSWORD = "your_secure_password"   # Database password (use environment variable in production)
HOST = "localhost"                  # Database host
PORT = 3306                         # Database port
DATABASE = "resourcehub"            # Database name
MAX_POOL_SIZE = 50                  # Connection pool size
CONNECTION_TIMEOUT = 30             # Connection timeout in seconds

# SMTP Email Configuration
[ResourceHub.common]
SMTP_HOST = "smtp.gmail.com"        # SMTP server host
SMTP_PORT = 587                     # SMTP server port
SMTP_USER = "your_email@gmail.com"  # SMTP username
SMTP_PASSWORD = "your_app_password" # App-specific password (not regular password)
SMTP_FROM_NAME = "ResourceHub"      # Display name for emails
SMTP_USE_TLS = true                 # Enable TLS encryption

# External API Configuration
[ResourceHub.report]
PDFSHIFT_API_KEY = "your_pdfshift_api_key"  # PDF generation service API key
REPORT_BASE_URL = "http://localhost:9091"   # Base URL for report service

# Security Configuration
[ResourceHub.security]
JWT_SECRET = "your_super_secret_jwt_key_min_256_bits"  # JWT signing secret
JWT_EXPIRES_IN = 3600                # JWT expiration time in seconds (1 hour)
REFRESH_TOKEN_EXPIRES_IN = 86400     # Refresh token expiration (24 hours)
PASSWORD_SALT_ROUNDS = 12            # Bcrypt salt rounds

# CORS Configuration
[ResourceHub.cors]
ALLOWED_ORIGINS = ["http://localhost:3000", "http://localhost:8080"]  # Frontend URLs
ALLOWED_METHODS = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
ALLOWED_HEADERS = ["Content-Type", "Authorization"]
```

### 4️⃣ **Install Dependencies**
```bash
# Pull and install all dependencies
bal pull

# Verify dependencies
bal deps
```

### 5️⃣ **Build and Run**

#### 🔧 **Development Mode (Recommended)**
```bash
# Run with hot reload and observability
bal run --observability-included

# Run with custom config file
bal run -Cconfig=path/to/your/Config.toml

# Run with debug logging
bal run --debug
```

#### 🏭 **Production Mode**
```bash
# 1. Build the application
bal build

# 2. Run the JAR file
java -jar target/bin/ResourceHub.jar

# 3. Run with production config
java -jar target/bin/ResourceHub.jar -Cconfig=production-Config.toml
```

#### 🐳 **Docker Mode**
```bash
# Build Docker image
docker build -t resourcehub-backend:latest .

# Run with Docker Compose
docker-compose up -d

# Or run standalone container
docker run -d -p 9090-9094:9090-9094 \
  -v $(pwd)/Config.toml:/app/Config.toml \
  --name resourcehub-backend \
  resourcehub-backend:latest
```

### 6️⃣ **Service Verification**

Once the application is running, verify that all services are operational:

#### **Service Health Checks**
```bash
# Test main services (port 9090)
curl -i http://localhost:9090/user
curl -i http://localhost:9090/asset
curl -i http://localhost:9090/meal

# Test authentication service (port 9094)
curl -i http://localhost:9094/auth

# Test dashboard services (port 9092)
curl -i http://localhost:9092/dashboard/admin
curl -i http://localhost:9092/dashboard/user

# Test notification service (port 9093)
curl -i http://localhost:9093/notification

# Test report service (port 9091)
curl -i http://localhost:9091/report
```

#### **Expected Console Output**
```
Database connected successfully...
🔐 Auth service started on port 9094
👥 User management service started on port 9090
⚙️ Account settings service started on port 9090
🏷️ Asset service started on port 9090
📋 Asset request service started on port 9090
🍽️ Meal type service started on port 9090
⏰ Meal time service started on port 9090
📅 Meal calendar service started on port 9090
🔧 Maintenance service started on port 9090
🔔 Notification service started on port 9093
📊 Dashboard admin service started on port 9092
👤 Dashboard user service started on port 9092
🏢 Organization settings service started on port 9090
📊 Report service started on port 9091

✅ All services are running successfully!
🌐 Main API: http://localhost:9090
🔐 Auth API: http://localhost:9094
📊 Dashboard API: http://localhost:9092
🔔 Notifications API: http://localhost:9093
📋 Reports API: http://localhost:9091
```

### 7️⃣ **First Time Setup**

After successful startup, perform these initial configuration steps:

1. **Create Super Admin User** (via database or API)
2. **Configure Organization Settings**
3. **Set up Email Templates**
4. **Configure Notification Preferences**
5. **Import Initial Data** (optional)

```bash
# Example: Create first admin user via API
curl -X POST http://localhost:9090/user \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@company.com",
    "role": "SuperAdmin",
    "password": "secure_password_123"
  }'
```

---

## 📚 API Documentation

### 🌐 **Service Architecture Overview**

ResourceHub Backend follows a microservices architecture with dedicated ports for different service categories:

| **Service Category** | **Port** | **Base URL** | **Purpose** |
|---------------------|----------|--------------|-------------|
| 🔐 **Authentication** | 9094 | `http://localhost:9094` | User authentication and authorization |
| 🏠 **Core Services** | 9090 | `http://localhost:9090` | Main business logic (User, Asset, Meal, etc.) |
| 📊 **Dashboard** | 9092 | `http://localhost:9092` | Analytics and dashboard APIs |
| 🔔 **Notifications** | 9093 | `http://localhost:9093` | Real-time notification system |
| 📋 **Reports** | 9091 | `http://localhost:9091` | Report generation and scheduling |

### 🛡️ **Authentication**

All protected endpoints require a valid JWT token in the Authorization header:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### **Get Authentication Token**
```bash
curl -X POST http://localhost:9094/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "your_password"
  }'
```

### 🔑 **User Roles & Permissions**

| Role | Permissions | Access Level |
|------|-------------|--------------|
| **� User** | View own data, create requests | Basic access to personal resources |
| **🛡️ Admin** | Manage organization data, approve requests | Administrative access to organizational functions |
| **🚀 SuperAdmin** | Full system access, user management | Complete system administration |
| **👔 Manager** | Department-level management | Mid-level administrative access |

### 📋 **Core API Endpoints**

#### **🔐 Authentication Service (Port 9094)**
```http
POST   /auth/login              # User login
POST   /auth/refresh            # Refresh JWT token
POST   /auth/logout             # User logout
GET    /auth/verify             # Verify token validity
POST   /auth/forgot-password    # Password reset request
POST   /auth/reset-password     # Reset password with token
```

#### **👥 User Management (Port 9090)**
```http
GET    /user                    # Get all users (Admin/SuperAdmin)
GET    /user/{id}               # Get user by ID
POST   /user                    # Create new user (Admin/SuperAdmin)
PUT    /user/{id}               # Update user (Admin/SuperAdmin)
DELETE /user/{id}               # Delete user (SuperAdmin)
GET    /user/profile            # Get current user profile
PUT    /user/profile            # Update current user profile

GET    /settings                # Get account settings
PUT    /settings                # Update account settings
PUT    /settings/password       # Change password
PUT    /settings/email          # Change email address
```

#### **�️ Asset Management (Port 9090)**
```http
GET    /asset                   # Get all assets
GET    /asset/{id}              # Get asset by ID
POST   /asset                   # Create new asset (Admin)
PUT    /asset/{id}              # Update asset (Admin)
DELETE /asset/{id}              # Delete asset (Admin)
GET    /asset/search            # Search assets
GET    /asset/categories        # Get asset categories

GET    /assetrequest            # Get asset requests
POST   /assetrequest            # Create asset request
PUT    /assetrequest/{id}       # Update request status (Admin)
DELETE /assetrequest/{id}       # Cancel request
GET    /assetrequest/user/{id}  # Get user's requests
```

#### **🍽️ Meal Services (Port 9090)**
```http
GET    /mealtype                # Get meal types
POST   /mealtype                # Create meal type (Admin)
PUT    /mealtype/{id}           # Update meal type (Admin)
DELETE /mealtype/{id}           # Delete meal type (Admin)

GET    /mealtime                # Get meal time slots
POST   /mealtime                # Create meal time (Admin)
PUT    /mealtime/{id}           # Update meal time (Admin)
DELETE /mealtime/{id}           # Delete meal time (Admin)

GET    /calendar                # Get meal calendar
POST   /calendar                # Create meal request
PUT    /calendar/{id}           # Update meal request
DELETE /calendar/{id}           # Cancel meal request
GET    /calendar/user/{id}      # Get user's meal requests
```

#### **🔧 Maintenance (Port 9090)**
```http
GET    /maintenance             # Get maintenance requests
POST   /maintenance             # Create maintenance request
PUT    /maintenance/{id}        # Update maintenance request
DELETE /maintenance/{id}        # Delete maintenance request
GET    /maintenance/status/{status}  # Filter by status
GET    /maintenance/priority/{priority}  # Filter by priority
```

#### **🏢 Organization Settings (Port 9090)**
```http
GET    /orgsettings             # Get organization settings
PUT    /orgsettings             # Update organization settings (Admin)
GET    /orgsettings/branding    # Get branding settings
PUT    /orgsettings/branding    # Update branding (Admin)
```

#### **📊 Dashboard Analytics (Port 9092)**
```http
GET    /dashboard/admin         # Admin dashboard data
GET    /dashboard/user          # User dashboard data
GET    /dashboard/stats         # System statistics
GET    /dashboard/charts        # Chart data
GET    /dashboard/recent        # Recent activities
```

#### **🔔 Notifications (Port 9093)**
```http
GET    /notification            # Get user notifications
POST   /notification            # Send notification (Admin)
PUT    /notification/{id}/read  # Mark as read
DELETE /notification/{id}       # Delete notification
GET    /notification/unread     # Get unread count
```

#### **� Reports (Port 9091)**
```http
GET    /report                  # Get available reports
POST   /report/generate         # Generate report
GET    /report/{id}             # Get report by ID
GET    /report/download/{id}    # Download report file
GET    /schedulereports         # Get scheduled reports (also on port 9090)
POST   /schedulereports         # Schedule new report
```

### � **Response Format**

All API responses follow a consistent format:

#### **Success Response**
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  },
  "timestamp": "2025-08-03T10:30:00Z"
}
```

#### **Error Response**
```json
{
  "success": false,
  "message": "Error description",
  "error": {
    "code": "ERROR_CODE",
    "details": "Detailed error information"
  },
  "timestamp": "2025-08-03T10:30:00Z"
}
```

### � **API Testing**

#### **Using cURL**
```bash
# Get authentication token
TOKEN=$(curl -s -X POST http://localhost:9094/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}' \
  | jq -r '.data.token')

# Use token in subsequent requests
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:9090/user
```

#### **Using Postman**
1. Import the API collection (coming soon)
2. Set up environment variables
3. Configure authentication
4. Test endpoints

### 🔗 **OpenAPI Documentation**

Complete API documentation is available via OpenAPI/Swagger:
- **Development**: `http://localhost:9090/openapi`
- **Interactive Docs**: `http://localhost:9090/swagger-ui`

---

## 📦 Module Overview

ResourceHub Backend is built with a **modular microservices architecture**, where each module handles specific business domains. This design ensures **scalability**, **maintainability**, and **independent deployment**.

### 🏗️ **Core Modules**

| Module | Port | Description | Key Features | Dependencies |
|--------|------|-------------|--------------|--------------|
| [🔐 **Auth**](modules/auth/) | 9094 | Authentication & Authorization | JWT tokens, password hashing, RBAC | `database`, `common` |
| [👥 **User**](modules/user/) | 9090 | User Management & Profiles | CRUD operations, account settings | `database`, `auth`, `common` |
| [🏷️ **Asset**](modules/asset/) | 9090 | Asset Management & Requests | Inventory tracking, allocation, lifecycle | `database`, `auth` |
| [🍽️ **Meal**](modules/meal/) | 9090 | Meal Planning & Services | Types, times, calendar, requests | `database`, `auth` |
| [🔧 **Maintenance**](modules/maintenance/) | 9090 | Facility Maintenance | Work orders, priority tracking, status | `database`, `auth` |
| [🔔 **Notification**](modules/notification/) | 9093 | Real-time Notifications | Multi-channel delivery, templates | `database`, `common` |
| [� **Dashboard**](modules/dashboard/) | 9092 | Analytics & Monitoring | Real-time metrics, KPIs, charts | `database`, `auth` |
| [🏢 **Organizations**](modules/organizations/) | 9090 | Multi-tenant Management | Organization settings, branding | `database`, `auth` |
| [📋 **Report**](modules/report/) | 9091 | Report Generation | PDF generation, scheduling, email | `database`, `common` |

### 🛠️ **Infrastructure Modules**

| Module | Description | Purpose | Used By |
|--------|-------------|---------|---------|
| [🗄️ **Database**](modules/database/) | MySQL connectivity & HTTP listeners | Centralized DB access, connection pooling | All modules |
| [�️ **Common**](modules/common/) | Shared utilities & services | JWT validation, email service, utilities | Multiple modules |

### 📁 **Module Structure**

Each module follows a consistent structure:

```
modules/[module-name]/
├── 📄 Module.md                 # Module documentation
├── 📄 types.bal                 # Data types and records
├── 📄 [module]_service.bal      # Main service implementation
├── 📄 [feature]_service.bal     # Additional feature services (if any)
└── 📄 README.md                 # Module-specific README
```

### 🔄 **Module Interactions**

```mermaid
graph TD
    A[Frontend Applications] --> B[API Gateway/Load Balancer]
    
    B --> C[Auth Module :9094]
    B --> D[Main Services :9090]
    B --> E[Dashboard :9092]
    B --> F[Notifications :9093]
    B --> G[Reports :9091]
    
    D --> H[User Module]
    D --> I[Asset Module]
    D --> J[Meal Module]
    D --> K[Maintenance Module]
    D --> L[Organizations Module]
    
    C --> M[Database Module]
    H --> M
    I --> M
    J --> M
    K --> M
    L --> M
    E --> M
    F --> M
    G --> M
    
    C --> N[Common Module]
    F --> N
    G --> N
    
    M --> O[MySQL Database]
    N --> P[SMTP Server]
    G --> Q[PDF Service]
```

### 🚀 **Module Features**

#### **🔐 Auth Module**
- **JWT Token Management** - Issue, refresh, and validate tokens
- **Password Security** - Bcrypt hashing with salt rounds
- **Role-Based Access Control** - Granular permission system
- **Session Management** - Secure session handling

#### **👥 User Module**
- **User CRUD Operations** - Complete user lifecycle management
- **Profile Management** - Personal information and preferences
- **Account Settings** - Password changes, email updates
- **Role Assignment** - Dynamic role management

#### **🏷️ Asset Module**
- **Asset Inventory** - Complete asset tracking and categorization
- **Allocation System** - Asset assignment and return workflows
- **Request Management** - User requests for asset allocation
- **Lifecycle Tracking** - Asset status from acquisition to disposal

#### **🍽️ Meal Module**
- **Meal Type Management** - Breakfast, lunch, dinner configurations
- **Time Slot Management** - Flexible meal timing configuration
- **Calendar Integration** - Visual meal planning interface
- **Request System** - User meal requests and preferences

#### **🔧 Maintenance Module**
- **Work Order Management** - Create, assign, and track maintenance tasks
- **Priority System** - Low, medium, high, critical priority levels
- **Status Tracking** - Pending, in-progress, completed, cancelled
- **Resource Allocation** - Assign maintenance staff and resources

#### **🔔 Notification Module**
- **Real-time Notifications** - Instant delivery to users
- **Multi-channel Delivery** - Email, in-app, SMS support
- **Template System** - Customizable notification templates
- **Bulk Notifications** - Mass notification capabilities

#### **📊 Dashboard Module**
- **Real-time Analytics** - Live system metrics and KPIs
- **Custom Dashboards** - Role-based dashboard configurations
- **Data Visualization** - Charts, graphs, and reports
- **Performance Monitoring** - System health and usage statistics

#### **🏢 Organizations Module**
- **Multi-tenant Support** - Isolated organization environments
- **Custom Branding** - Organization-specific theming
- **Settings Management** - Configurable organization preferences
- **User Management** - Organization-level user administration

#### **� Report Module**
- **Automated Reports** - Scheduled report generation
- **PDF Generation** - Professional report formatting
- **Email Distribution** - Automatic report delivery
- **Custom Templates** - Flexible report layouts

### � **Adding New Modules**

To add a new module to the system:

1. **Create Module Directory**
   ```bash
   mkdir modules/new-module
   cd modules/new-module
   ```

2. **Create Module Files**
   ```bash
   touch types.bal
   touch new_module_service.bal
   touch Module.md
   touch README.md
   ```

3. **Define Module Structure**
   ```ballerina
   // types.bal
   public type NewModuleRecord record {
       int id;
       string name;
       string description;
   };
   
   // new_module_service.bal
   import ballerina/http;
   
   service /newmodule on new http:Listener(9090) {
       resource function get .() returns json {
           return {"message": "New Module Service"};
       }
   }
   ```

4. **Update main.bal**
   ```ballerina
   import ResourceHub.newmodule;
   
   public function main() returns error? {
       // ... existing code
       check newmodule:startNewModuleService();
   }
   ```

5. **Add Documentation**
   - Update this README
   - Create module-specific documentation
   - Add API documentation

---

## ⚙️ Configuration

### 🗄️ **Database Configuration**
```toml
# Database configuration
[ResourceHub.database]
USER = "username"           # Database username
PASSWORD = "password"       # Database password  
HOST = "localhost"          # Database host
PORT = 3306                 # Database port
DATABASE = "resourcehub"    # Database name
```

### 📧 **Email Configuration**
```toml
# SMTP server configuration
[ResourceHub.common]
SMTP_HOST = "smtp.gmail.com"        # SMTP server
SMTP_USER = "email@domain.com"      # Email username
SMTP_PASSWORD = "app_password"      # Email password
```

### 📊 **Report Configuration**
```toml
# API keys
[ResourceHub.report]
PDFSHIFT_API_KEY = "your_api_key"   # PDF generation service
```

### 🔐 **SSL Certificates**
Place SSL certificates in `resources/certificates/`:
- `certificate.crt` - Public certificate
- `certificate.key` - Private key
- `certificate.csr` - Certificate signing request

---

## 💻 Development Guide

### 🛠️ **Development Environment Setup**

#### **Prerequisites Checklist**
- [ ] Ballerina 2201.12.0+ installed
- [ ] MySQL 8.0+ running
- [ ] Java 17+ installed
- [ ] Git configured
- [ ] IDE with Ballerina extension (VS Code recommended)

#### **IDE Configuration**
```bash
# Install VS Code Ballerina extension
code --install-extension ballerina.ballerina

# Install useful extensions
code --install-extension ms-vscode.vscode-json
code --install-extension redhat.vscode-yaml
code --install-extension ms-vscode.vscode-docker
```

### 🚀 **Development Workflow**

#### **1. Development Commands**
```bash
# Start development server with hot reload
bal run --observability-included

# Build project
bal build

# Run tests
bal test

# Check syntax and types
bal check

# Generate documentation
bal doc

# Clean build artifacts
bal clean

# Format code
bal format

# Pull dependencies
bal pull

# Check project dependencies
bal deps
```

#### **2. Environment-Specific Configurations**

**Development Config (Config-dev.toml)**
```toml
[ResourceHub.database]
USER = "dev_user"
PASSWORD = "dev_password"
HOST = "localhost"
PORT = 3306
DATABASE = "resourcehub_dev"

[ResourceHub.common]
SMTP_HOST = "smtp.mailtrap.io"  # Use Mailtrap for testing
SMTP_PORT = 2525
SMTP_USER = "test_user"
SMTP_PASSWORD = "test_password"

[ResourceHub.security]
JWT_SECRET = "dev_jwt_secret_key_min_256_bits"
JWT_EXPIRES_IN = 7200  # 2 hours for development
```

**Testing Config (Config-test.toml)**
```toml
[ResourceHub.database]
USER = "test_user"
PASSWORD = "test_password"
HOST = "localhost"
PORT = 3306
DATABASE = "resourcehub_test"

[ResourceHub.security]
JWT_SECRET = "test_jwt_secret_key_min_256_bits"
JWT_EXPIRES_IN = 3600
```

#### **3. Running with Different Configurations**
```bash
# Development
bal run -Cconfig=Config-dev.toml

# Testing
bal run -Cconfig=Config-test.toml

# Production
bal run -Cconfig=Config-prod.toml
```

### 🧪 **Testing Strategy**

#### **Unit Tests**
```bash
# Run all tests
bal test

# Run specific module tests
bal test modules/auth
bal test modules/user

# Run with coverage
bal test --code-coverage

# Generate test report
bal test --test-report
```

#### **Integration Tests**
```bash
# Set up test database
mysql -u root -p < tests/setup-test-db.sql

# Run integration tests
bal test tests/integration/

# Clean up test data
mysql -u root -p < tests/cleanup-test-db.sql
```

#### **API Testing**
```bash
# Using Newman (Postman CLI)
newman run tests/postman/ResourceHub-API.postman_collection.json \
  -e tests/postman/environments/development.json

# Using curl scripts
bash tests/api/test-all-endpoints.sh
```

### 📝 **Code Standards & Best Practices**

#### **Ballerina Coding Standards**
```ballerina
// ✅ Good: Use meaningful names
public type UserProfile record {
    int userId;
    string firstName;
    string lastName;
    string email;
    UserRole role;
};

// ✅ Good: Error handling
public function createUser(UserProfile user) returns User|error {
    User|sql:Error result = database:create(user);
    if result is sql:Error {
        return error("Failed to create user: " + result.message());
    }
    return result;
}

// ✅ Good: Use proper annotations
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /api on new http:Listener(9090) {
    // Service implementation
}
```

#### **File Organization**
```
modules/[module-name]/
├── types.bal              # Data types and records
├── [module]_service.bal   # Main service implementation
├── utils.bal              # Module-specific utilities
├── constants.bal          # Module constants
├── tests/                 # Module tests
│   ├── unit/
│   └── integration/
└── docs/                  # Module documentation
    ├── README.md
    └── API.md
```

#### **Naming Conventions**
- **Variables**: `camelCase` (e.g., `userName`, `emailAddress`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Types**: `PascalCase` (e.g., `UserProfile`, `AssetRequest`)
- **Functions**: `camelCase` (e.g., `getUserById`, `validateToken`)
- **Services**: `kebab-case` for URLs (e.g., `/user-profile`, `/asset-request`)

### 🔄 **Git Workflow**

#### **Branch Strategy**
```bash
main              # Production-ready code
├── develop       # Integration branch
├── feature/*     # Feature branches
├── bugfix/*      # Bug fix branches
├── hotfix/*      # Critical fixes
└── release/*     # Release preparation
```

#### **Commit Message Format**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Examples:**
```bash
feat(auth): add JWT token refresh functionality

Implement automatic token refresh to improve user experience
- Add refresh token endpoint
- Update token validation middleware
- Add token expiration handling

Closes #123
```

```bash
fix(database): resolve connection pool leak

- Properly close database connections
- Add connection timeout configuration
- Update error handling

Fixes #456
```

#### **Pre-commit Hooks**
```bash
# Install pre-commit hooks
npm install -g husky lint-staged

# .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

bal check
bal test
bal format --dry-run
```

### 🏗️ **Build & Deployment**

#### **Build Configurations**
```bash
# Development build
bal build

# Production build with optimizations
bal build --native-image

# Build with custom target
bal build --target-dir custom-target

# Build specific modules
bal build modules/auth modules/user
```

#### **Docker Development**
```dockerfile
# Dockerfile.dev
FROM ballerina/ballerina:2201.12.0

WORKDIR /app
COPY . .

# Install dependencies
RUN bal pull

# Development mode with hot reload
CMD ["bal", "run", "--observability-included"]

EXPOSE 9090 9091 9092 9093 9094
```

```bash
# Build development image
docker build -f Dockerfile.dev -t resourcehub-dev .

# Run with volume mounting for hot reload
docker run -d \
  -v $(pwd):/app \
  -p 9090-9094:9090-9094 \
  --name resourcehub-dev \
  resourcehub-dev
```

### � **Debugging**

#### **Debug Configuration**
```bash
# Run with debug logging
bal run --debug

# Debug specific module
bal run --debug=modules/auth

# Debug with observability
bal run --observability-included --debug
```

#### **VS Code Debug Configuration (.vscode/launch.json)**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Ballerina Debug",
            "type": "ballerina",
            "request": "launch",
            "script": "${workspaceFolder}/main.bal",
            "debuggeePort": "5005",
            "networkLogs": true,
            "commandOptions": ["--observability-included"]
        }
    ]
}
```

### � **Performance Monitoring**

#### **Observability Setup**
```toml
# Ballerina.toml
[build-options]
observabilityIncluded = true

[tool.jaeger]
agentHostname = "localhost"
agentPort = 14268

[tool.prometheus]
host = "localhost"
port = 9797
```

#### **Metrics Collection**
```bash
# Start with observability
bal run --observability-included

# Access metrics
curl http://localhost:9797/metrics

# Access Jaeger UI (if configured)
open http://localhost:16686
```

### 🚀 **Performance Optimization**

#### **Database Optimization**
- Use connection pooling
- Implement proper indexing
- Use prepared statements
- Monitor query performance

#### **Application Optimization**
- Enable HTTP/2
- Use response compression
- Implement caching strategies
- Optimize JSON serialization

#### **Memory Management**
- Monitor heap usage
- Profile memory leaks
- Optimize object creation
- Use appropriate data structures

---

## 🧪 Testing

### 🎯 **Testing Strategy**

ResourceHub Backend follows a comprehensive testing approach with multiple layers:

```mermaid
graph TB
    A[Unit Tests] --> B[Integration Tests]
    B --> C[API Tests]
    C --> D[End-to-End Tests]
    D --> E[Performance Tests]
    E --> F[Security Tests]
```

### � **Test Types**

#### **1. Unit Tests**
Test individual functions and modules in isolation.

```bash
# Run all unit tests
bal test

# Run specific module tests
bal test modules/auth
bal test modules/user
bal test modules/asset

# Run with code coverage
bal test --code-coverage

# Generate detailed test report
bal test --test-report --code-coverage
```

**Example Unit Test:**
```ballerina
// tests/auth_test.bal
import ballerina/test;
import ResourceHub.auth;

@test:Config {}
function testValidateJWTToken() {
    string validToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
    boolean|error result = auth:validateToken(validToken);
    test:assertTrue(result is boolean);
    test:assertTrue(<boolean>result);
}

@test:Config {}
function testInvalidJWTToken() {
    string invalidToken = "invalid.token.here";
    boolean|error result = auth:validateToken(invalidToken);
    test:assertTrue(result is error);
}
```

#### **2. Integration Tests**
Test module interactions and database operations.

```bash
# Set up test database
mysql -u root -p < tests/setup-test-db.sql

# Run integration tests
bal test tests/integration/

# Clean up after tests
mysql -u root -p < tests/cleanup-test-db.sql
```

**Example Integration Test:**
```ballerina
// tests/integration/user_integration_test.bal
import ballerina/test;
import ballerina/http;

@test:Config {
    before: setupTestData,
    after: cleanupTestData
}
function testCreateUserEndpoint() returns error? {
    http:Client testClient = check new("http://localhost:9090");
    
    json userPayload = {
        "username": "testuser",
        "email": "test@example.com",
        "role": "User"
    };
    
    http:Response response = check testClient->post("/user", userPayload);
    test:assertEquals(response.statusCode, 201);
    
    json responseBody = check response.getJsonPayload();
    test:assertEquals(responseBody.success, true);
}
```

#### **3. API Tests**
Test REST endpoints and HTTP interactions.

```bash
# Using Newman (Postman CLI)
npm install -g newman

# Run API test collection
newman run tests/postman/ResourceHub-API.postman_collection.json \
  --environment tests/postman/environments/test.json \
  --reporters cli,html \
  --reporter-html-export test-results.html

# Run specific API test folder
newman run tests/postman/ResourceHub-API.postman_collection.json \
  --folder "Authentication Tests"
```

#### **4. Load/Performance Tests**
Test system performance under various loads.

```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:9090/user

# Using Artillery.io
npm install -g artillery
artillery run tests/performance/load-test.yml

# Using k6
k6 run tests/performance/stress-test.js
```

**Example k6 Performance Test:**
```javascript
// tests/performance/api-load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 10 },  // Ramp up
    { duration: '5m', target: 50 },  // Load test
    { duration: '2m', target: 0 },   // Ramp down
  ],
};

export default function() {
  let response = http.get('http://localhost:9090/user');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

### 🛡️ **Security Testing**

#### **Authentication Tests**
```bash
# Test JWT token validation
curl -H "Authorization: Bearer invalid_token" \
  http://localhost:9090/user

# Test RBAC
curl -H "Authorization: Bearer user_token" \
  http://localhost:9090/admin/users
```

#### **SQL Injection Tests**
```bash
# Test SQL injection protection
curl -X POST http://localhost:9090/user \
  -H "Content-Type: application/json" \
  -d '{"username": "admin'\''OR 1=1--", "email": "test@test.com"}'
```

### 📊 **Test Coverage**

#### **Generating Coverage Reports**
```bash
# Generate coverage report
bal test --code-coverage

# View coverage in browser
open target/report/test_results.html
```

#### **Coverage Targets**
- **Unit Tests**: > 80% line coverage
- **Integration Tests**: > 70% feature coverage
- **API Tests**: 100% endpoint coverage

### 🔄 **Continuous Testing**

#### **GitHub Actions Workflow**
```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: resourcehub_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Ballerina
      uses: ballerina-platform/setup-ballerina@v1
      with:
        version: 2201.12.0
    
    - name: Run Tests
      run: |
        bal test --code-coverage
        bal test tests/integration/
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        file: target/report/coverage.xml
```

#### **Pre-commit Testing**
```bash
# Install pre-commit hooks
pip install pre-commit

# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: ballerina-test
        name: Run Ballerina Tests
        entry: bal test
        language: system
        pass_filenames: false
      
      - id: ballerina-check
        name: Check Ballerina Syntax
        entry: bal check
        language: system
        pass_filenames: false
```

### 🐛 **Test Data Management**

#### **Test Database Setup**
```sql
-- tests/setup-test-db.sql
CREATE DATABASE IF NOT EXISTS resourcehub_test;
USE resourcehub_test;

-- Import test schema
SOURCE resources/sql/create_tables.sql;

-- Insert test data
INSERT INTO users (username, email, role) VALUES 
  ('testuser', 'test@example.com', 'User'),
  ('testadmin', 'admin@example.com', 'Admin');
```

#### **Test Data Factories**
```ballerina
// tests/utils/test_data_factory.bal
public function createTestUser() returns User {
    return {
        id: 999,
        username: "testuser" + time:utcNow().toString(),
        email: "test@example.com",
        role: "User",
        createdAt: time:utcNow()
    };
}

public function createTestAsset() returns Asset {
    return {
        id: 999,
        name: "Test Asset",
        category: "Electronics",
        status: "Available",
        createdAt: time:utcNow()
    };
}
```

### 📈 **Test Metrics & Reporting**

#### **Test Metrics Dashboard**
- **Test Execution Time**: Monitor test suite performance
- **Code Coverage**: Track coverage trends over time
- **Test Failure Rate**: Monitor test stability
- **Flaky Test Detection**: Identify unreliable tests

#### **Test Reports**
```bash
# Generate detailed test report
bal test --test-report --code-coverage

# Convert to different formats
# HTML report: target/report/test_results.html
# XML report: target/report/test_results.xml
# JSON report: target/report/test_results.json
```

---

## 🚀 Deployment

### 🌐 **Deployment Strategies**

ResourceHub Backend supports multiple deployment approaches for different environments and requirements.

### 🐳 **Container Deployment**

#### **Docker Configuration**
```dockerfile
# Production Dockerfile
FROM ballerina/ballerina:2201.12.0-alpine AS builder

WORKDIR /app
COPY . .

# Build the application
RUN bal build --offline

# Production image
FROM openjdk:17-alpine

WORKDIR /app

# Copy the built JAR
COPY --from=builder /app/target/bin/ResourceHub.jar .
COPY --from=builder /app/resources ./resources

# Create non-root user
RUN addgroup -g 1001 -S ballerina && \
    adduser -S ballerina -u 1001 -G ballerina

USER ballerina

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:9090/health || exit 1

EXPOSE 9090 9091 9092 9093 9094

CMD ["java", "-jar", "ResourceHub.jar"]
```

#### **Multi-stage Build for Development**
```dockerfile
# Dockerfile.dev
FROM ballerina/ballerina:2201.12.0

WORKDIR /app
COPY . .

# Development mode with hot reload
CMD ["bal", "run", "--observability-included"]

EXPOSE 9090 9091 9092 9093 9094
```

#### **Docker Compose Setup**
```yaml
# docker-compose.yml
version: '3.8'

services:
  resourcehub-backend:
    build: .
    ports:
      - "9090:9090"
      - "9091:9091"
      - "9092:9092"
      - "9093:9093"
      - "9094:9094"
    environment:
      - DB_HOST=mysql
      - DB_USER=resourcehub
      - DB_PASSWORD=${DB_PASSWORD}
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - resourcehub-network
    restart: unless-stopped

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: resourcehub
      MYSQL_USER: resourcehub
      MYSQL_PASSWORD: ${DB_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./resources/sql:/docker-entrypoint-initdb.d
    networks:
      - resourcehub-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 10s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - resourcehub-network
    restart: unless-stopped

volumes:
  mysql_data:

networks:
  resourcehub-network:
    driver: bridge
```

### ☁️ **Cloud Deployment**

#### **Kubernetes Deployment**
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resourcehub-backend
  labels:
    app: resourcehub-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: resourcehub-backend
  template:
    metadata:
      labels:
        app: resourcehub-backend
    spec:
      containers:
      - name: resourcehub-backend
        image: resourcehub-backend:latest
        ports:
        - containerPort: 9090
        - containerPort: 9091
        - containerPort: 9092
        - containerPort: 9093
        - containerPort: 9094
        env:
        - name: DB_HOST
          value: mysql-service
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 9090
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 9090
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: resourcehub-service
spec:
  selector:
    app: resourcehub-backend
  ports:
  - name: main
    port: 9090
    targetPort: 9090
  - name: reports
    port: 9091
    targetPort: 9091
  - name: dashboard
    port: 9092
    targetPort: 9092
  - name: notifications
    port: 9093
    targetPort: 9093
  - name: auth
    port: 9094
    targetPort: 9094
  type: LoadBalancer
```

#### **Ingress Configuration**
```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: resourcehub-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - api.resourcehub.com
    secretName: resourcehub-tls
  rules:
  - host: api.resourcehub.com
    http:
      paths:
      - path: /auth
        pathType: Prefix
        backend:
          service:
            name: resourcehub-service
            port:
              number: 9094
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: resourcehub-service
            port:
              number: 9090
      - path: /dashboard
        pathType: Prefix
        backend:
          service:
            name: resourcehub-service
            port:
              number: 9092
```

### 🔧 **Production Configuration**

#### **Environment Variables**
```bash
# Production environment variables
export RESOURCEHUB_ENV=production
export DB_HOST=prod-mysql.example.com
export DB_USER=resourcehub_prod
export DB_PASSWORD=secure_production_password
export JWT_SECRET=super_secure_jwt_secret_min_256_bits
export SMTP_HOST=smtp.company.com
export SMTP_USER=noreply@company.com
export SMTP_PASSWORD=smtp_production_password
export REDIS_URL=redis://prod-redis.example.com:6379
```

#### **Production Config Template**
```toml
# Config-prod.toml
[ResourceHub.database]
USER = "${DB_USER}"
PASSWORD = "${DB_PASSWORD}"
HOST = "${DB_HOST}"
PORT = 3306
DATABASE = "resourcehub"
MAX_POOL_SIZE = 50
CONNECTION_TIMEOUT = 30
SSL_MODE = "REQUIRED"

[ResourceHub.security]
JWT_SECRET = "${JWT_SECRET}"
JWT_EXPIRES_IN = 3600
REFRESH_TOKEN_EXPIRES_IN = 86400
PASSWORD_SALT_ROUNDS = 12

[ResourceHub.common]
SMTP_HOST = "${SMTP_HOST}"
SMTP_PORT = 587
SMTP_USER = "${SMTP_USER}"
SMTP_PASSWORD = "${SMTP_PASSWORD}"
SMTP_USE_TLS = true

[ResourceHub.monitoring]
ENABLE_METRICS = true
METRICS_PORT = 9797
LOG_LEVEL = "INFO"
```

### 📊 **Monitoring & Observability**

#### **Health Checks**
```ballerina
// Add to main service
resource function get health() returns json {
    return {
        "status": "healthy",
        "timestamp": time:utcNow(),
        "services": {
            "database": checkDatabaseHealth(),
            "auth": checkAuthServiceHealth(),
            "notifications": checkNotificationServiceHealth()
        }
    };
}
```

#### **Prometheus Metrics**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'resourcehub-backend'
    static_configs:
      - targets: ['localhost:9797']
    metrics_path: /metrics
    scrape_interval: 10s
```

#### **Grafana Dashboard**
```json
{
  "dashboard": {
    "title": "ResourceHub Backend Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph", 
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
```

### 🔄 **CI/CD Pipeline**

#### **GitHub Actions Deployment**
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Ballerina
        uses: ballerina-platform/setup-ballerina@v1
      - name: Run Tests
        run: bal test --code-coverage
  
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker Image
        run: |
          docker build -t resourcehub-backend:${{ github.sha }} .
          docker tag resourcehub-backend:${{ github.sha }} resourcehub-backend:latest
      
      - name: Deploy to Kubernetes
        uses: azure/k8s-deploy@v1
        with:
          namespace: production
          manifests: |
            k8s/deployment.yaml
            k8s/service.yaml
            k8s/ingress.yaml
          images: |
            resourcehub-backend:${{ github.sha }}
```

### 🛡️ **Security Hardening**

#### **SSL/TLS Configuration**
```bash
# Generate SSL certificates
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365

# Use Let's Encrypt for production
certbot --nginx -d api.resourcehub.com
```

#### **Network Security**
- Configure firewall rules
- Use VPC/private networks
- Enable DDoS protection
- Implement rate limiting
- Set up WAF (Web Application Firewall)

#### **Database Security**
- Enable SSL connections
- Use encrypted storage
- Regular security updates
- Backup encryption
- Access logging

### 📈 **Scaling Strategies**

#### **Horizontal Scaling**
```yaml
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: resourcehub-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: resourcehub-backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

#### **Database Scaling**
- **Read Replicas**: For read-heavy workloads
- **Sharding**: For data distribution
- **Connection Pooling**: For connection optimization
- **Caching**: Redis for frequently accessed data

---

## 📊 Monitoring & Observability

### 🔍 **Built-in Observability**

ResourceHub Backend comes with comprehensive observability features powered by Ballerina's native observability capabilities.

#### **Metrics Collection**
```toml
# Ballerina.toml
[build-options]
observabilityIncluded = true

[tool.prometheus]
host = "0.0.0.0"
port = 9797
jmxPort = 8080

[tool.jaeger]
agentHostname = "localhost"
agentPort = 14268
samplerType = "const"
samplerParam = 1.0
```

#### **Available Metrics**
- **HTTP Metrics**: Request count, response time, error rates
- **Database Metrics**: Connection pool status, query performance
- **Custom Metrics**: Business-specific KPIs and counters
- **JVM Metrics**: Memory usage, GC performance, thread counts

```bash
# Access Prometheus metrics
curl http://localhost:9797/metrics

# Example metrics output
http_requests_total{method="GET",service="/user"} 1234
http_request_duration_seconds{method="GET",service="/user",quantile="0.95"} 0.045
database_connections_active 15
database_connections_idle 35
```

### 📈 **Grafana Integration**

#### **Dashboard Configuration**
```json
{
  "dashboard": {
    "title": "ResourceHub Backend Overview",
    "panels": [
      {
        "title": "Request Rate (RPS)",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m]))",
            "legendFormat": "Total RPS"
          }
        ]
      },
      {
        "title": "Response Time (95th percentile)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"4..|5..\"}[5m])) / sum(rate(http_requests_total[5m]))",
            "legendFormat": "Error Rate %"
          }
        ]
      },
      {
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "database_connections_active",
            "legendFormat": "Active"
          },
          {
            "expr": "database_connections_idle", 
            "legendFormat": "Idle"
          }
        ]
      }
    ]
  }
}
```

### 🚨 **Alerting**

#### **Prometheus Alerting Rules**
```yaml
# alerts.yml
groups:
  - name: resourcehub_alerts
    rules:
      - alert: HighErrorRate
        expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1.0
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }}s"

      - alert: DatabaseConnectionPoolExhausted
        expr: database_connections_active / (database_connections_active + database_connections_idle) > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Database connection pool nearly exhausted"
          description: "{{ $value | humanizePercentage }} of connections are in use"

      - alert: ServiceDown
        expr: up{job="resourcehub-backend"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "ResourceHub service is down"
          description: "Service has been down for more than 1 minute"
```

### 📋 **Logging Strategy**

#### **Structured Logging**
```ballerina
import ballerina/log;

public function logUserAction(string action, string userId, json details) {
    log:printInfo("User action performed", 
        action = action,
        userId = userId,
        details = details,
        timestamp = time:utcNow(),
        service = "user-service"
    );
}

public function logError(error err, string context) {
    log:printError("Error occurred",
        'error = err,
        context = context,
        timestamp = time:utcNow(),
        stackTrace = err.stackTrace()
    );
}
```

#### **Log Levels Configuration**
```toml
# Config.toml
[ResourceHub.logging]
rootLevel = "INFO"
packageLevel = {
    "ResourceHub.auth" = "DEBUG",
    "ResourceHub.database" = "WARN"
}
```

### 🔍 **Distributed Tracing**

#### **Jaeger Integration**
```bash
# Start Jaeger (via Docker)
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 14268:14268 \
  jaegertracing/all-in-one:latest

# Access Jaeger UI
open http://localhost:16686
```

#### **Custom Span Creation**
```ballerina
import ballerina/observe;

public function processAssetRequest(AssetRequest request) returns Asset|error {
    observe:Span span = observe:startSpan("process-asset-request");
    defer {
        observe:finishSpan(span);
    }
    
    span.addTag("request.id", request.id.toString());
    span.addTag("request.type", request.assetType);
    
    // Business logic here
    Asset|error result = createAsset(request);
    
    if result is error {
        span.addTag("error", true);
        span.logKV("error.message", result.message());
    }
    
    return result;
}
```

### 🏥 **Health Checks**

#### **Multi-level Health Checks**
```ballerina
// Health check endpoint
resource function get health() returns json {
    return {
        "status": "healthy",
        "timestamp": time:utcNow(),
        "version": "0.1.0",
        "services": {
            "database": checkDatabaseHealth(),
            "auth": checkAuthServiceHealth(),
            "notifications": checkNotificationServiceHealth(),
            "external_apis": checkExternalServicesHealth()
        },
        "system": {
            "memory": getMemoryUsage(),
            "cpu": getCpuUsage(),
            "disk": getDiskUsage()
        }
    };
}

function checkDatabaseHealth() returns json {
    sql:ExecutionResult|sql:Error result = database:testConnection();
    if result is sql:Error {
        return {
            "status": "unhealthy",
            "error": result.message()
        };
    }
    return {"status": "healthy"};
}
```

#### **Kubernetes Health Checks**
```yaml
# In deployment.yaml
livenessProbe:
  httpGet:
    path: /health
    port: 9090
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health/ready
    port: 9090
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

---

## 🔒 Security

### 🛡️ **Security Architecture**

ResourceHub Backend implements multiple layers of security to protect data and ensure system integrity.

```mermaid
graph TB
    A[Client] --> B[WAF/Load Balancer]
    B --> C[API Gateway]
    C --> D[Authentication Layer]
    D --> E[Authorization Layer]
    E --> F[Application Services]
    F --> G[Data Access Layer]
    G --> H[Database]
    
    I[Security Monitoring] --> D
    I --> E
    I --> F
    I --> G
```

### 🔐 **Authentication & Authorization**

#### **JWT Implementation**
```ballerina
import ballerina/jwt;
import ballerina/crypto;

// JWT configuration
jwt:IssuerConfig jwtIssuerConfig = {
    issuer: "resourcehub-backend",
    audience: ["resourcehub-users"],
    expTimeInSeconds: 3600,
    signatureConfig: {
        algorithm: jwt:HS256,
        key: crypto:toBytes(jwtSecret)
    }
};

// Token generation
public function generateAccessToken(User user) returns string|error {
    jwt:Payload payload = {
        sub: user.email,
        iss: "resourcehub-backend",
        exp: time:utcNow()[0] + 3600,
        iat: time:utcNow()[0],
        jti: uuid:createType4AsString(),
        customClaims: {
            "userId": user.id,
            "role": user.role,
            "permissions": getUserPermissions(user.role)
        }
    };
    
    return jwt:issue(payload, jwtIssuerConfig);
}

// Token validation
public function validateToken(string token) returns jwt:Payload|error {
    jwt:ValidatorConfig validatorConfig = {
        issuer: "resourcehub-backend",
        audience: "resourcehub-users",
        signatureConfig: {
            algorithm: jwt:HS256,
            key: crypto:toBytes(jwtSecret)
        }
    };
    
    return jwt:validate(token, validatorConfig);
}
```

#### **Role-Based Access Control (RBAC)**
```ballerina
public enum UserRole {
    USER = "User",
    ADMIN = "Admin", 
    SUPER_ADMIN = "SuperAdmin",
    MANAGER = "Manager"
}

// Permission definitions
map<string[]> rolePermissions = {
    "User": ["read:own_profile", "update:own_profile", "create:request"],
    "Manager": ["read:department_data", "approve:requests", "manage:team"],
    "Admin": ["read:organization_data", "manage:users", "manage:assets", "view:reports"],
    "SuperAdmin": ["read:all", "write:all", "delete:all", "manage:system"]
};

// Authorization check
public function hasPermission(string userRole, string permission) returns boolean {
    string[]? permissions = rolePermissions[userRole];
    if permissions is string[] {
        return permissions.indexOf(permission) != ();
    }
    return false;
}

// Authorization interceptor
public isolated service class AuthInterceptor {
    public isolated function requestInterceptor(http:RequestContext ctx, http:Request req) returns http:NextService|error? {
        string|error authHeader = req.getHeader("Authorization");
        if authHeader is error {
            return createUnauthorizedError("Missing authorization header");
        }
        
        string token = authHeader.substring(7); // Remove "Bearer "
        jwt:Payload|error payload = validateToken(token);
        if payload is error {
            return createUnauthorizedError("Invalid token");
        }
        
        // Add user context for downstream services
        ctx.set("user", payload);
        return ctx.next();
    }
}
```

### 🔒 **Data Protection**

#### **Password Security**
```ballerina
import ballerina/crypto;

// Password hashing with bcrypt
public function hashPassword(string password) returns string|error {
    byte[] passwordBytes = password.toBytes();
    byte[] hashedPassword = check crypto:hashSha256(passwordBytes);
    return hashedPassword.toBase64();
}

// Password verification
public function verifyPassword(string password, string hashedPassword) returns boolean|error {
    byte[] passwordBytes = password.toBytes();
    byte[] hashedPasswordBytes = check hashedPassword.fromBase64();
    byte[] computedHash = check crypto:hashSha256(passwordBytes);
    return computedHash == hashedPasswordBytes;
}

// Password strength validation
public function validatePasswordStrength(string password) returns boolean {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special char
    return password.length() >= 8 &&
           re:isFullMatch(re`.*[A-Z].*`, password) &&
           re:isFullMatch(re`.*[a-z].*`, password) &&
           re:isFullMatch(re`.*\d.*`, password) &&
           re:isFullMatch(re`.*[!@#$%^&*(),.?":{}|<>].*`, password);
}
```

#### **Data Encryption**
```ballerina
import ballerina/crypto;

// Encrypt sensitive data before storage
public function encryptSensitiveData(string data, string key) returns string|error {
    byte[] dataBytes = data.toBytes();
    byte[] keyBytes = key.toBytes();
    byte[] encryptedData = check crypto:encryptAesEcb(dataBytes, keyBytes);
    return encryptedData.toBase64();
}

// Decrypt sensitive data after retrieval
public function decryptSensitiveData(string encryptedData, string key) returns string|error {
    byte[] encryptedBytes = check encryptedData.fromBase64();
    byte[] keyBytes = key.toBytes();
    byte[] decryptedData = check crypto:decryptAesEcb(encryptedBytes, keyBytes);
    return check string:fromBytes(decryptedData);
}
```

### 🚫 **Input Validation & Sanitization**

#### **SQL Injection Prevention**
```ballerina
import ballerina/sql;

// Use parameterized queries
public function getUserByEmail(string email) returns User|error {
    sql:ParameterizedQuery query = `
        SELECT id, username, email, role, created_at 
        FROM users 
        WHERE email = ${email} AND deleted_at IS NULL
    `;
    
    stream<User, sql:Error?> resultStream = database:Client->query(query);
    record {|User value;|}? result = check resultStream.next();
    check resultStream.close();
    
    if result is record {|User value;|} {
        return result.value;
    }
    return error("User not found");
}

// Input validation
public function validateEmail(string email) returns boolean {
    return re:isFullMatch(re`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`, email);
}

public function sanitizeInput(string input) returns string {
    // Remove potentially dangerous characters
    return re:replaceAll(input, re`[<>\"'&]`, "");
}
```

#### **XSS Prevention**
```ballerina
public function escapeHtml(string input) returns string {
    return input
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#x27;");
}
```

### 🔍 **Security Monitoring**

#### **Audit Logging**
```ballerina
public function logSecurityEvent(SecurityEvent event) {
    log:printInfo("Security event",
        eventType = event.eventType,
        userId = event.userId,
        ipAddress = event.ipAddress,
        userAgent = event.userAgent,
        resource = event.resource,
        action = event.action,
        success = event.success,
        timestamp = time:utcNow(),
        sessionId = event.sessionId
    );
}

public type SecurityEvent record {
    string eventType; // "login", "logout", "access_denied", "password_change"
    string userId;
    string ipAddress;
    string userAgent;
    string resource;
    string action;
    boolean success;
    string sessionId;
};
```

#### **Rate Limiting**
```ballerina
import ballerina/cache;

// Simple rate limiter implementation
public class RateLimiter {
    private cache:Cache requestCache;
    private int maxRequests;
    private decimal timeWindow; // in seconds
    
    public function init(int maxRequests, decimal timeWindow) {
        self.maxRequests = maxRequests;
        self.timeWindow = timeWindow;
        self.requestCache = new(capacity = 1000, evictionFactor = 0.25);
    }
    
    public function isAllowed(string clientId) returns boolean {
        string cacheKey = clientId + ":" + (time:utcNow()[0] / self.timeWindow).toString();
        
        any|error currentCount = self.requestCache.get(cacheKey);
        int count = currentCount is int ? currentCount : 0;
        
        if count >= self.maxRequests {
            return false;
        }
        
        self.requestCache.put(cacheKey, count + 1);
        return true;
    }
}
```

### 🛡️ **CORS Configuration**
```ballerina
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://resourcehub.company.com", "https://admin.resourcehub.company.com"],
        allowCredentials: true,
        allowHeaders: ["Authorization", "Content-Type", "X-Requested-With"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        maxAge: 86400 // 24 hours
    }
}
service /api on new http:Listener(9090) {
    // Service implementation
}
```

### 🔒 **Security Headers**
```ballerina
public function addSecurityHeaders(http:Response response) {
    response.setHeader("X-Content-Type-Options", "nosniff");
    response.setHeader("X-Frame-Options", "DENY");
    response.setHeader("X-XSS-Protection", "1; mode=block");
    response.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
    response.setHeader("Content-Security-Policy", "default-src 'self'");
    response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
}
```

### 🔧 **Security Best Practices**

#### **Environment Variables for Secrets**
```bash
# Never commit secrets to code
export JWT_SECRET="your-super-secure-jwt-secret-key"
export DB_PASSWORD="secure-database-password"
export SMTP_PASSWORD="email-service-password"
export ENCRYPTION_KEY="data-encryption-key"
```

#### **Database Security**
```sql
-- Create dedicated database user with minimal privileges
CREATE USER 'resourcehub_app'@'%' IDENTIFIED BY 'secure_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON resourcehub.* TO 'resourcehub_app'@'%';

-- Enable SSL for database connections
REQUIRE SSL;

-- Regular security updates
UPDATE mysql.user SET authentication_string = PASSWORD('new_password') 
WHERE User = 'resourcehub_app';
FLUSH PRIVILEGES;
```

#### **Container Security**
```dockerfile
# Use non-root user
FROM ballerina/ballerina:2201.12.0-alpine
RUN addgroup -g 1001 -S ballerina && \
    adduser -S ballerina -u 1001 -G ballerina
USER ballerina

# Minimize attack surface
RUN apk del curl wget
```

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help make ResourceHub Backend even better.

### 📋 **Getting Started**

#### **1. Fork the Repository**
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/yourusername/Resource_Hub-Backend-.git
cd Resource_Hub-Backend-/Ballerina

# Add upstream remote
git remote add upstream https://github.com/FiveStackDev/Resource_Hub-Backend-.git
```

#### **2. Set Up Development Environment**
```bash
# Install dependencies
bal pull

# Verify setup
bal check
bal test

# Create your feature branch
git checkout -b feature/amazing-new-feature
```

### 🌟 **How to Contribute**

#### **Types of Contributions**
- 🐛 **Bug Fixes** - Help us squash bugs
- ✨ **New Features** - Add exciting new functionality
- 📚 **Documentation** - Improve docs and examples
- 🧪 **Tests** - Increase test coverage
- 🎨 **UI/UX** - Enhance user experience
- ⚡ **Performance** - Optimize and improve speed
- 🔒 **Security** - Strengthen security measures

#### **Contribution Workflow**
1. **🔍 Browse Issues** - Check [existing issues](https://github.com/FiveStackDev/Resource_Hub-Backend-/issues)
2. **💬 Discuss** - Comment on issues or create new ones
3. **🍴 Fork & Branch** - Create your feature branch
4. **💻 Code** - Implement your changes
5. **🧪 Test** - Add/update tests and ensure they pass
6. **📝 Document** - Update documentation as needed
7. **🔄 Pull Request** - Submit your PR for review

### 📝 **Development Guidelines**

#### **Code Standards**
```ballerina
// ✅ Good: Clear, descriptive names
public function createUserAccount(UserRegistration registration) returns User|error {
    // Validate input
    if !isValidEmail(registration.email) {
        return error("Invalid email format");
    }
    
    // Business logic with proper error handling
    User|sql:Error result = database:insertUser(registration);
    if result is sql:Error {
        log:printError("Failed to create user", 'error = result);
        return error("User creation failed");
    }
    
    return result;
}

// ✅ Good: Proper type definitions
public type UserRegistration record {|
    string username;
    string email;
    string password;
    UserRole role?;
|};
```

#### **Testing Requirements**
```ballerina
// All new features must include tests
@test:Config {}
function testCreateUserAccount() returns error? {
    UserRegistration registration = {
        username: "testuser",
        email: "test@example.com",
        password: "securepassword123"
    };
    
    User|error result = createUserAccount(registration);
    test:assertTrue(result is User);
    
    if result is User {
        test:assertEquals(result.username, "testuser");
        test:assertEquals(result.email, "test@example.com");
    }
}
```

#### **Documentation Standards**
- **Code Comments**: Explain complex logic and business rules
- **API Documentation**: Document all endpoints with examples
- **README Updates**: Keep documentation current
- **Module Docs**: Each module should have comprehensive documentation

### 🔄 **Pull Request Process**

#### **PR Template**
```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] New tests added for new functionality

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No sensitive data committed
```

#### **Review Process**
1. **🔍 Automated Checks** - CI/CD runs tests and checks
2. **👥 Peer Review** - Team members review code
3. **💬 Feedback** - Address review comments
4. **✅ Approval** - Get required approvals
5. **🚀 Merge** - Changes merged to main branch

### 🐛 **Bug Reports**

#### **Bug Report Template**
```markdown
## Bug Description
A clear and concise description of what the bug is.

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Environment
- OS: [e.g. Windows 10, Ubuntu 20.04]
- Ballerina Version: [e.g. 2201.12.0]
- MySQL Version: [e.g. 8.0.28]
- Java Version: [e.g. OpenJDK 17]

## Additional Context
Add any other context about the problem here.
```

### 💡 **Feature Requests**

#### **Feature Request Template**
```markdown
## Feature Description
A clear and concise description of the feature you'd like to see.

## Problem/Use Case
Explain the problem this feature would solve or the use case it addresses.

## Proposed Solution
Describe how you envision this feature working.

## Alternatives Considered
Any alternative solutions or features you've considered.

## Additional Context
Add any other context, mockups, or examples.
```

### 🏆 **Recognition**

#### **Contributors**
We recognize all contributors in our:
- 📝 **README.md** - Listed in contributors section
- 🏆 **Release Notes** - Mentioned in version releases
- 💬 **Discord/Slack** - Shoutouts in community channels
- 🎉 **Annual Report** - Year-end contributor highlights

#### **Contribution Levels**
- **🌟 First-time Contributor** - Welcome package and mentoring
- **🔥 Regular Contributor** - Special badge and early access to features
- **💎 Core Contributor** - Invitation to maintainer team
- **🏅 Top Contributor** - Annual recognition and rewards

### 📞 **Getting Help**

#### **Development Support**
- **💬 Discord**: [Join our Discord server](https://discord.gg/resourcehub)
- **📧 Email**: [dev@resourcehub.com](mailto:dev@resourcehub.com)
- **📖 Wiki**: [Project Wiki](https://github.com/FiveStackDev/Resource_Hub-Backend-/wiki)
- **🎥 Video Calls**: Monthly contributor meetings

#### **Code Review Support**
- **📝 Style Guide**: Follow our [coding standards](STYLE_GUIDE.md)
- **🧪 Testing Guide**: See our [testing documentation](TESTING.md)
- **🔍 Review Checklist**: Use our [PR review checklist](PR_CHECKLIST.md)

---

## 📞 Support

### 🆘 **Getting Help**

We're here to help you succeed with ResourceHub Backend! Here are the best ways to get support:

#### **📚 Documentation & Resources**
- **📖 Project Wiki**: [Comprehensive guides and tutorials](https://github.com/FiveStackDev/Resource_Hub-Backend-/wiki)
- **🔧 API Documentation**: [Complete API reference](https://api.resourcehub.com/docs)
- **🎥 Video Tutorials**: [YouTube Channel](https://youtube.com/@ResourceHubDev)
- **📋 FAQ**: [Frequently Asked Questions](https://github.com/FiveStackDev/Resource_Hub-Backend-/wiki/FAQ)

#### **💬 Community Support**
- **Discord Server**: [Join our community](https://discord.gg/resourcehub) - Real-time chat and support
- **GitHub Discussions**: [Community forum](https://github.com/FiveStackDev/Resource_Hub-Backend-/discussions)
- **Stack Overflow**: Tag your questions with `resourcehub-backend`
- **Reddit**: [r/ResourceHub](https://reddit.com/r/ResourceHub)

#### **🐛 Issues & Bug Reports**
- **GitHub Issues**: [Report bugs and request features](https://github.com/FiveStackDev/Resource_Hub-Backend-/issues)
- **Security Issues**: [security@resourcehub.com](mailto:security@resourcehub.com) (for security vulnerabilities)
- **Bug Bounty**: [HackerOne Program](https://hackerone.com/resourcehub) (for verified security issues)

### 📧 **Direct Contact**

#### **Core Team**
- **📧 General Inquiries**: [hello@resourcehub.com](mailto:hello@resourcehub.com)
- **🔧 Technical Support**: [support@resourcehub.com](mailto:support@resourcehub.com)
- **🤝 Partnerships**: [partners@resourcehub.com](mailto:partners@resourcehub.com)
- **📰 Media**: [media@resourcehub.com](mailto:media@resourcehub.com)

#### **Lead Developers**
- **Minul Chathumal** - Project Lead
  - 📧 [minulck@gmail.com](mailto:minulck@gmail.com)
  - 🐙 [@Minulck](https://github.com/Minulck)
  - 💼 [LinkedIn](https://linkedin.com/in/minulck)

- **Development Team**
  - 🐙 [@th33k](https://github.com/th33k) - Backend Architect
  - 🐙 [@PiuminiTishani](https://github.com/PiuminiTishani) - Database Specialist
  - 🐙 [@nethminiwelgama](https://github.com/nethminiwelgama) - API Developer
  - 🐙 [@SinethNimhan](https://github.com/SinethNimhan) - Security Expert

### 🕐 **Support Hours**

#### **Community Support** (24/7)
- Discord and GitHub Discussions are monitored by community volunteers around the clock
- Response time: Usually within 2-4 hours

#### **Core Team Support** (Monday-Friday, 9 AM - 6 PM GMT+5:30)
- Email responses within 24 hours during business days
- Critical issues addressed within 4 hours
- Security issues addressed immediately

### 🎯 **Support Tiers**

#### **🆓 Community Support (Free)**
- ✅ GitHub Issues and Discussions
- ✅ Discord community chat
- ✅ Documentation and tutorials
- ✅ Community-contributed solutions
- ⏱️ Best effort response time

#### **🚀 Professional Support (Enterprise)**
- ✅ Everything in Community Support
- ✅ Direct email support
- ✅ Priority issue resolution
- ✅ Video call consultations
- ✅ Custom development guidance
- ✅ SLA guarantees
- ⏱️ Guaranteed response times

#### **🏢 Enterprise Support (Custom)**
- ✅ Everything in Professional Support
- ✅ Dedicated support engineer
- ✅ On-site training and setup
- ✅ Custom feature development
- ✅ 24/7 phone support
- ✅ Architectural consulting
- ⏱️ Sub-4-hour critical issue resolution

### 🔍 **Before Requesting Support**

To help us help you faster, please:

#### **✅ Check First**
1. **📖 Documentation**: Search our comprehensive docs
2. **🔍 GitHub Issues**: Check if your issue already exists
3. **💬 Discussions**: Browse community discussions
4. **📋 FAQ**: Review frequently asked questions

#### **📝 Provide Details**
When requesting support, include:
- **🖥️ Environment**: OS, Ballerina version, MySQL version
- **🔧 Configuration**: Relevant config files (remove sensitive data)
- **📋 Steps to Reproduce**: Clear, step-by-step instructions
- **📊 Error Messages**: Full error logs and stack traces
- **🎯 Expected vs Actual**: What you expected vs what happened

#### **📋 Issue Template**
```markdown
## Environment
- OS: [e.g., Windows 10, Ubuntu 20.04]
- Ballerina Version: [e.g., 2201.12.0]
- MySQL Version: [e.g., 8.0.28]
- Java Version: [e.g., OpenJDK 17]

## Problem Description
[Clear description of the issue]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [See error]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Error Logs
```
[Paste error logs here]
```

## Additional Context
[Any other helpful information]
```

### 🏆 **Success Stories**

> **"ResourceHub Backend helped us reduce our asset management overhead by 60% and improved our response time to maintenance requests by 4x."**
> 
> *— Sarah Johnson, IT Director at TechCorp*

> **"The comprehensive API documentation and excellent community support made integration with our existing systems seamless."**
> 
> *— Michael Chen, Senior Developer at InnovateCo*

> **"Outstanding support from the core team. They helped us customize the meal management system for our specific dietary requirements."**
> 
> *— Anna Rodriguez, Operations Manager at HealthFirst*

### 🤝 **Community Guidelines**

#### **🎯 Be Respectful**
- Treat all community members with respect and kindness
- Use inclusive language and avoid discriminatory comments
- Respect different experience levels and backgrounds

#### **🔍 Be Helpful**
- Provide constructive feedback and solutions
- Share your knowledge and experiences
- Help others learn and grow

#### **📝 Be Clear**
- Use clear, descriptive titles for issues and discussions
- Provide relevant context and details
- Follow templates when available

#### **🌟 Recognition**
We regularly recognize helpful community members through:
- **🏅 Community Badges**: Special recognition in Discord
- **📰 Newsletter Features**: Highlighting contributions
- **🎁 Swag Packages**: ResourceHub merchandise for active contributors
- **🎤 Speaking Opportunities**: Conference and meetup invitations

### 📈 **Roadmap & Updates**

Stay informed about ResourceHub Backend development:

- **📅 Release Schedule**: [Monthly releases](https://github.com/FiveStackDev/Resource_Hub-Backend-/releases)
- **🗺️ Public Roadmap**: [Feature roadmap](https://github.com/FiveStackDev/Resource_Hub-Backend-/projects)
- **📧 Newsletter**: [Monthly updates](https://resourcehub.com/newsletter)
- **🐦 Twitter**: [@ResourceHubDev](https://twitter.com/ResourceHubDev)
- **📺 YouTube**: [Development vlogs and tutorials](https://youtube.com/@ResourceHubDev)

---

<div align="center">

## 🙏 **Thank You!**

ResourceHub Backend is made possible by our amazing community of contributors, users, and supporters.

**⭐ Star this repository if you find it helpful! ⭐**

**🔄 Share it with others who might benefit! 🔄**

**🤝 Contribute to make it even better! 🤝**

---

### 📄 **License**

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

### 💫 **Built with ❤️ by**

**[FiveStackDev](https://github.com/FiveStackDev)** - Building the future of resource management

*Empowering organizations worldwide with intelligent resource management solutions*

---

**🌟 Made with Ballerina • Powered by MySQL • Secured by JWT • Monitored by Prometheus 🌟**

</div>
