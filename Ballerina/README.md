# 🏢 ResourceHub Backend

> Comprehensive resource management system built with Ballerina

[![Ballerina](https://img.shields.io/badge/Ballerina-2201.8.x-blue.svg)](https://ballerina.io/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-orange.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modular backend system for managing organizational resources including assets, meals, maintenance, users, and reporting with role-based access control and comprehensive analytics.

---

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [API Documentation](#-api-documentation)
- [Modules](#-modules)
- [Configuration](#-configuration)
- [Development](#-development)
- [Deployment](#-deployment)
- [Contributing](#-contributing)

---

## ✨ Features

### 🏢 **Core Functionality**
- **Asset Management** - Complete asset lifecycle and allocation tracking
- **User Management** - Role-based user accounts and authentication
- **Meal Services** - Comprehensive meal planning and request system
- **Maintenance** - Facility maintenance request and tracking system
- **Notifications** - Real-time notification system for pending requests
- **Organizations** - Multi-tenant organization management
- **Dashboard Analytics** - Real-time system monitoring and reporting

### 🔐 **Security & Authentication**
- **JWT Authentication** - Secure token-based authentication
- **Role-Based Access Control** - Admin, SuperAdmin, User, Manager roles
- **CORS Support** - Cross-origin resource sharing configuration
- **Data Privacy** - Secure data handling and user privacy protection

### 📊 **Reporting & Analytics**
- **Automated Reports** - Scheduled PDF report generation
- **Email Distribution** - Automatic report delivery
- **Multi-Module Analytics** - Comprehensive system insights
- **Real-time Dashboards** - Live system metrics and KPIs

---

## 🏗️ Architecture

```mermaid
graph TB
    A[Frontend Applications] --> B[ResourceHub Backend]
    B --> C[Authentication Module]
    B --> D[Asset Module]
    B --> E[User Module]
    B --> F[Meal Module]
    B --> G[Maintenance Module]
    B --> H[Dashboard Module]
    B --> I[Notification Module]
    B --> J[Report Module]
    B --> K[Organization Module]
    B --> L[Common Module]
    
    C --> M[Database Module]
    D --> M
    E --> M
    F --> M
    G --> M
    H --> M
    I --> M
    J --> M
    K --> M
    L --> M
    
    M --> N[MySQL Database]
    J --> O[Report Service :9091]
    H --> P[Dashboard Service :9092]
    I --> Q[Notification Service :9093]
    C --> R[Auth Service :9094]
    M --> S[Main Services :9090]
```

### 📦 **Modular Design**
- **Independent Modules** - Each feature as a separate module
- **Shared Dependencies** - Common utilities and database access
- **Scalable Architecture** - Easy to extend and maintain
- **RESTful APIs** - Standard HTTP REST endpoints

---

## 🚀 Quick Start

### Prerequisites
- **Ballerina** 2201.8.x or later
- **MySQL** 8.0 or later
- **Java** 17 or later

### 1. Clone Repository
```bash
git clone https://github.com/FiveStackDev/Resource_Hub-Backend-.git
cd Resource_Hub-Backend-/Ballerina
```

### 2. Database Setup
```sql
-- Create database
CREATE DATABASE resourcehub;

-- Run SQL scripts
mysql -u username -p resourcehub < resources/sql/create_tables.sql
mysql -u username -p resourcehub < resources/sql/add_accounts.sql
mysql -u username -p resourcehub < resources/sql/add_assets.sql
```

### 3. Configuration
Create `Config.toml` file:
```toml
[resourcehub]
USER = "your_db_user"
PASSWORD = "your_db_password"
HOST = "localhost"
PORT = 3306
DATABASE = "resourcehub"

SMTP_HOST = "smtp.gmail.com"
SMTP_USER = "your_email@gmail.com"
SMTP_PASSWORD = "your_app_password"

PDFSHIFT_API_KEY = "your_pdfshift_api_key"
```

### 4. Run the Application
```bash
bal run
```

The services will be available at:
- **Main Services:** `http://localhost:9090`
- **Report Services:** `http://localhost:9091`
- **Dashboard Services:** `http://localhost:9092`
- **Notification Services:** `http://localhost:9093`
- **Auth Services:** `http://localhost:9094`

---

## 📚 API Documentation

### 🌐 **Service Endpoints**

| Service | Base URL | Port | Description |
|---------|----------|------|-------------|
| 🔐 Authentication | `/auth` | 9094 | User login and token management |
| 👥 User Management | `/user` | 9090 | User CRUD operations |
| 🏢 Asset Management | `/asset` | 9090 | Asset inventory and tracking |
| 📋 Asset Requests | `/assetrequest` | 9090 | Asset allocation requests |
| 🍽️ Meal Types | `/mealtype` | 9090 | Meal type management |
| ⏰ Meal Times | `/mealtime` | 9090 | Meal time slots |
| 📅 Meal Calendar | `/calendar` | 9090 | Meal planning and requests |
| 🔧 Maintenance | `/maintenance` | 9090 | Maintenance request system |
| � Notifications | `/notification` | 9093 | Real-time notification system |
| �📊 Admin Dashboard | `/admin` | 9092 | Administrative analytics |
| 👤 User Dashboard | `/user` | 9092 | User-specific dashboard |
| 🏢 Organizations | `/orgsettings` | 9090 | Organization management |
| 📊 Reports | `/report` | 9091 | Report generation |
| 📋 Report Data | `/schedulereports` | 9091 | Report data endpoints |

### 🔐 **Authentication**
All protected endpoints require JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### 👥 **User Roles**
- **👤 User** - Basic access to own data and resources
- **🛡️ Admin** - Administrative access to most system functions
- **🚀 SuperAdmin** - Full system access and configuration

---

## 📦 Modules

| Module | Description | Key Features |
|--------|-------------|--------------|
| [🏢 Asset](modules/asset/Module.md) | Asset management and requests | CRUD operations, allocation tracking |
| [🔐 Auth](modules/auth/Module.md) | Authentication and authorization | JWT tokens, role-based access |
| [👥 User](modules/user/Module.md) | User management and profiles | Account management, settings |
| [🍽️ Meal](modules/meal/Module.md) | Meal planning and services | Calendar, types, time slots |
| [🔧 Maintenance](modules/maintenance/Module.md) | Maintenance request system | Priority levels, status tracking |
| [� Notification](modules/notification/Module.md) | Real-time notifications | Pending request alerts, system notifications |
| [�📊 Dashboard](modules/dashboard/Module.md) | Analytics and monitoring | Real-time stats, visualizations |
| [🏢 Organizations](modules/organizations/Module.md) | Organization settings | Multi-tenant management |
| [📊 Report](modules/report/Module.md) | Report generation | Automated PDF reports |
| [🗄️ Database](modules/database/Module.md) | Database connectivity | MySQL client, HTTP listeners |
| [🛠️ Common](modules/common/Module.md) | Shared utilities | JWT validation, email service |

---

## ⚙️ Configuration

### 🗄️ **Database Configuration**
```toml
[resourcehub]
USER = "username"           # Database username
PASSWORD = "password"       # Database password  
HOST = "localhost"          # Database host
PORT = 3306                 # Database port
DATABASE = "resourcehub"    # Database name
```

### 📧 **Email Configuration**
```toml
SMTP_HOST = "smtp.gmail.com"        # SMTP server
SMTP_USER = "email@domain.com"      # Email username
SMTP_PASSWORD = "app_password"      # Email password
```

### 📊 **Report Configuration**
```toml
PDFSHIFT_API_KEY = "your_api_key"   # PDF generation service
```

### 🔐 **SSL Certificates**
Place SSL certificates in `resources/certificates/`:
- `certificate.crt` - Public certificate
- `certificate.key` - Private key
- `certificate.csr` - Certificate signing request

---

## 💻 Development

### 🛠️ **Build Commands**
```bash
# Build the project
bal build

# Run with hot reload
bal run --observability-included

# Generate documentation
bal doc

# Run tests
bal test
```

### 📁 **Project Structure**
```
ResourceHub-Backend/
├── 📄 Ballerina.toml          # Project configuration
├── 📄 Config.toml             # Runtime configuration
├── 📄 Dependencies.toml       # Dependency management
├── 📄 main.bal               # Application entry point
├── 📁 modules/               # Feature modules
│   ├── 📁 asset/            # Asset management
│   ├── 📁 auth/             # Authentication
│   ├── 📁 user/             # User management
│   ├── 📁 meal/             # Meal services
│   ├── 📁 maintenance/      # Maintenance system
│   ├── 📁 notification/     # Notification system
│   ├── 📁 dashboard/        # Analytics dashboard
│   ├── 📁 organizations/    # Organization management
│   ├── 📁 report/           # Report generation
│   ├── 📁 database/         # Database connectivity
│   └── 📁 common/           # Shared utilities
├── 📁 resources/            # Static resources
│   ├── 📁 certificates/     # SSL certificates
│   └── 📁 sql/             # Database scripts
└── 📁 target/              # Build artifacts
```

### 🔄 **Adding New Features**
1. Create new module in `modules/` directory
2. Define service endpoints and data models
3. Implement business logic
4. Add authentication and authorization
5. Update main.bal to include new service
6. Write comprehensive tests
7. Update documentation

---

## 🚀 Deployment

### 🐳 **Docker Deployment**
```dockerfile
FROM ballerina/ballerina:2201.8.0

COPY . /app
WORKDIR /app

RUN bal build
CMD ["bal", "run", "target/bin/ResourceHub.jar"]

EXPOSE 9090 9091 9092 9093 9094
```

### ☁️ **Production Setup**
1. **Environment Variables**
   ```bash
   export RESOURCEHUB_USER="prod_user"
   export RESOURCEHUB_PASSWORD="secure_password"
   export RESOURCEHUB_HOST="db.production.com"
   ```

2. **SSL Configuration**
   - Use production SSL certificates
   - Configure HTTPS listeners
   - Enable security headers

3. **Database**
   - Use production MySQL instance
   - Configure connection pooling
   - Set up database backups

4. **Monitoring**
   - Enable Ballerina observability
   - Configure logging levels
   - Set up health checks

---

## 🤝 Contributing

### 📋 **Guidelines**
1. **Fork** the repository
2. **Create** a feature branch
3. **Follow** coding standards
4. **Write** comprehensive tests
5. **Update** documentation
6. **Submit** a pull request

### 📝 **Coding Standards**
- Follow Ballerina best practices
- Use meaningful variable names
- Write comprehensive comments
- Include error handling
- Maintain consistent formatting

### 🧪 **Testing**
```bash
# Run all tests
bal test

# Run specific module tests
bal test modules/asset

# Generate test coverage
bal test --code-coverage
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

**FiveStackDev** - Development Team
- GitHub: [@FiveStackDev](https://github.com/FiveStackDev)

### Core Contributors

- **Minul Chathumal** - [@Minulck](https://github.com/Minulck)
- **Theekshana Udara** - [@th33k](https://github.com/th33k)
- **Piumini Tishani** - [@PiuminiTishani](https://github.com/PiuminiTishani)
- **Nethminiwelgama** - [@nethminiwelgama](https://github.com/nethminiwelgama)
- **Sineth Nimhan** - [@SinethNimhan](https://github.com/SinethNimhan)

---

## 📞 Support

For support and questions:
- 📧 **Email**: minulck@gmail.com
- 📚 **Documentation**: [Project Wiki](https://github.com/FiveStackDev/Resource_Hub-Backend-/wiki)
- 🐛 **Issues**: [GitHub Issues](https://github.com/FiveStackDev/Resource_Hub-Backend-/issues)

---

<div align="center">

**⭐ Star this repo if you find it helpful! ⭐**

Made with ❤️ by FiveStackDev

</div>
