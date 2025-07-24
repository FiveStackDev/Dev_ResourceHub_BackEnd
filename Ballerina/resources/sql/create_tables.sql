-- Organizations Table
CREATE TABLE organizations (
    org_id INT PRIMARY KEY AUTO_INCREMENT,
    org_name VARCHAR(50),
    org_address VARCHAR(255),
    org_logo TEXT,
    org_email VARCHAR(50),
    org_about TEXT,
    org_website VARCHAR(255),
    org_phone VARCHAR(50),
    org_founded VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    org_id INT,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
);

-- Mealtimes Table
CREATE TABLE mealtimes (
    mealtime_id INT AUTO_INCREMENT PRIMARY KEY,
    mealtime_name VARCHAR(255) NOT NULL,
    mealtime_image_url TEXT,
    org_id INT,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
);

-- Mealtypes Table
CREATE TABLE mealtypes (
    mealtype_id INT AUTO_INCREMENT PRIMARY KEY,
    mealtype_name VARCHAR(255) NOT NULL,
    mealtype_image_url TEXT,
    org_id INT,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
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
    org_id INT,
    FOREIGN KEY (meal_time_id) REFERENCES mealtimes(mealtime_id) ON DELETE CASCADE,
    FOREIGN KEY (meal_type_id) REFERENCES mealtypes(mealtype_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
);

-- Assets Table
CREATE TABLE assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_name VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    quantity INT NOT NULL CHECK (quantity >= 0),
    condition_type VARCHAR(255),
    location VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE,
    org_id INT,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
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
    org_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE SET NULL,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
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
    org_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
);

CREATE TABLE notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                      -- recipient (individual user)
    type VARCHAR(50) NOT NULL,                 -- 'maintenance', 'asset_request', 'due_reminder', etc.
    reference_id INT,                          -- e.g., maintenance_id or requestedasset_id
    title VARCHAR(255),                        -- optional title (e.g., 'New Maintenance Request')
    message TEXT NOT NULL,                     -- full message to display
    is_read BOOLEAN DEFAULT FALSE,             -- unread tracker
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    org_id INT NOT NULL,                       -- which org this belongs to
    priority VARCHAR(10) NOT NULL DEFAULT 'General',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
);

-- Scheduled Reports Table
CREATE TABLE schedulereports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_name VARCHAR(255) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    org_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
);

CREATE TABLE mealtime_mealtype (
    mealtime_id INT,
    mealtype_id INT,
    PRIMARY KEY (mealtime_id, mealtype_id),
    FOREIGN KEY (mealtime_id) REFERENCES mealtimes(mealtime_id) ON DELETE CASCADE,
    FOREIGN KEY (mealtype_id) REFERENCES mealtypes(mealtype_id) ON DELETE CASCADE
);