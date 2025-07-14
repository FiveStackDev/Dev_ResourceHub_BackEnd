# Resource Hub – Backend

The **Resource Hub Backend** is a Ballerina-based API service that manages organizational resources including meals, assets, maintenance requests, and user management. It serves as the backend for the Resource Hub application and provides secure, role-based functionality for both Admins and Users.

---

## Features

* **Authentication & Authorization**

  * JWT-based user login and access control for Admin/User roles
* **Meal Management**

  * APIs for managing meal types, meal times, and user meal requests
* **Asset Management**

  * Asset request, tracking, and CRUD operations by Admins
* **Maintenance Management**

  * Submit and manage maintenance tasks with priority and status tracking
* **User Management**

  * User profile management and admin-level user control
* **Dashboard Analytics**

  * Data endpoints for both Admin and User dashboards
* **Email Notifications**

  * SMTP-based notifications (e.g., password reset, updates)
* **Reporting Support**

  * API-level hooks for PDF or CSV report generation

---

## Tech Stack

* **Language:** Ballerina
* **Runtime:** Ballerina HTTP module
* **Database:** MySQL
* **Config Management:** Ballerina `Config.toml`
* **Email:** SMTP (via `smtpconnect.bal`)
* **Testing:** Ballerina built-in test framework
* **Docs:** OpenAPI (auto-generated if enabled)

---

## Project Structure

```
/resource_hub_backend/Ballerina
├── Ballerina.toml
├── main.bal
├── Config.toml
└── modules/
    └── resourcehubservices/
        ├── assetrequestingservice.bal
        ├── assetservice.bal
        ├── calanderservice.bal
        ├── dashboardadminservice.bal
        ├── dashboarduserservice.bal
        ├── dbconnect.bal
        ├── emailservice.bal
        ├── login.bal
        ├── maintenanceservice.bal
        ├── mealtimeservice.bal
        ├── mealtypeservice.bal
        ├── profilesettingsservice.bal
        ├── smtpconnect.bal
        └── userservice.bal
```

---

## Setup and Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/FiveStackDev/Resource_Hub-ballerina.git
   cd Resource_Hub-ballerina/Ballerina
   ```

2. **Configure the application**

   * Create or edit the `Config.toml` file inside the root directory with the following content:

   ```toml
   [ResourceHub.resourcehubservices]

   # Database configuration
   USER = "your_database_user"
   PASSWORD = "your_database_password"
   HOST = "localhost"
   PORT = "3306"  # MySQL default port
   DATABASE = "your_database_name"

   # SMTP server configuration
   SMTP_HOST = "your_smtp_host"
   SMTP_PORT = "587"
   SMTP_USER = "your_smtp_username"
   SMTP_PASSWORD = "your_smtp_password"

   # API keys
   PDFSHIFT_API_KEY = "your_pdfshift_api_key"
   ```

3. **Set up the database**

   * add this ti the Ballerina.toml file

     ```bash
     [[platform.java11.dependency]]
      groupId = "mysql"
      artifactId = "mysql-connector-java"
      version = "8.0.26"
     ```

---

## Running the Project

Run the application using Ballerina:

```bash
bal run
```

The service will be available at:
`http://localhost:9090`

---

---

## Building for Production

```bash
bal build
```

---

## Testing

```bash
bal test
```

---

## Database Schema

Database Schema
The following SQL schema defines the structure of the MySQL database used by the Resource Hub backend:

```sql
-- Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    profile_picture_url TEXT,
    usertype VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    password TEXT NOT NULL,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Mealtimes Table
CREATE TABLE mealtimes (
    mealtime_id INT AUTO_INCREMENT PRIMARY KEY,
    mealtime_name VARCHAR(255) NOT NULL,
    mealtime_image_url TEXT
);

-- Mealtypes Table
CREATE TABLE mealtypes (
    mealtype_id INT AUTO_INCREMENT PRIMARY KEY,
    mealtype_name VARCHAR(255) NOT NULL,
    mealtype_image_url TEXT
);

-- Requested Meals Table
CREATE TABLE requestedmeals (
    requestedmeal_id INT AUTO_INCREMENT PRIMARY KEY,
    meal_time_id INT NOT NULL,
    meal_type_id INT NOT NULL,
    user_id INT NOT NULL,
    submitted_date DATE NOT NULL,
    meal_request_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    notes TEXT,
    FOREIGN KEY (meal_time_id) REFERENCES mealtimes(mealtime_id) ON DELETE CASCADE,
    FOREIGN KEY (meal_type_id) REFERENCES mealtypes(mealtype_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Assets Table
CREATE TABLE assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_name VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    quantity INT NOT NULL,
    condition_type VARCHAR(255),
    location VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE
);

-- Requested Assets Table
CREATE TABLE requestedassets (
    requestedasset_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    asset_id INT,
    submitted_date DATE,
    handover_date DATE,
    quantity INT,
    status VARCHAR(20) DEFAULT 'Pending',
    is_returning BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE SET NULL
);

-- Maintenance Requests Table
CREATE TABLE maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100),
    description TEXT NOT NULL,
    priority_level VARCHAR(50),
    status VARCHAR(50) DEFAULT 'Pending',
    submitted_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Notification Table (many-to-many between user and maintenance)
CREATE TABLE notification (
    user_id INT,
    maintenance_id INT,
    PRIMARY KEY (user_id, maintenance_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (maintenance_id) REFERENCES maintenance(maintenance_id) ON DELETE CASCADE
);
```
The following diagram illustrates the database schema used in Resource Hub:

![Untitled](https://github.com/user-attachments/assets/f71de8a6-d12e-4eb2-8cc2-5219e9e6f07b)


---

