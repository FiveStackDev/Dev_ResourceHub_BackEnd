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