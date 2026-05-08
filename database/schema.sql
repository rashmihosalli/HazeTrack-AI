-- database/schema.sql
CREATE DATABASE IF NOT EXISTS hazetrack2;
USE hazetrack2;

-- Roles Table
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(200),
    permissions JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Users Table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    username VARCHAR(80) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    INDEX idx_email (email),
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Surveillance Sessions Table
CREATE TABLE surveillance_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    session_id VARCHAR(36) UNIQUE NOT NULL,
    operator_id INT,
    source_type VARCHAR(20) NOT NULL,
    source VARCHAR(255) NOT NULL,
    camera_name VARCHAR(100),
    location VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    fps INT DEFAULT 30,
    resolution VARCHAR(20) DEFAULT '1920x1080',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    total_frames INT DEFAULT 0,
    total_detections INT DEFAULT 0,
    FOREIGN KEY (operator_id) REFERENCES users(id),
    INDEX idx_session_id (session_id),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vehicles Table
CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    track_id INT NOT NULL,
    session_id INT NOT NULL,
    vehicle_type VARCHAR(20) NOT NULL,
    confidence FLOAT DEFAULT 0.0,
    first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_tracked BOOLEAN DEFAULT TRUE,
    frame_count INT DEFAULT 0,
    FOREIGN KEY (session_id) REFERENCES surveillance_sessions(id),
    INDEX idx_track_id (track_id),
    INDEX idx_vehicle_type (vehicle_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Number Plates Table
CREATE TABLE number_plates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    plate_text VARCHAR(20) NOT NULL,
    confidence FLOAT DEFAULT 0.0,
    is_validated BOOLEAN DEFAULT FALSE,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    INDEX idx_plate_text (plate_text),
    INDEX idx_vehicle_id (vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Detections Table
CREATE TABLE detections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    plate_id INT,
    session_id INT NOT NULL,
    operator_id INT,
    frame_number INT NOT NULL,
    bbox_x INT,
    bbox_y INT,
    bbox_width INT,
    bbox_height INT,
    confidence FLOAT DEFAULT 0.0,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (plate_id) REFERENCES number_plates(id),
    FOREIGN KEY (session_id) REFERENCES surveillance_sessions(id),
    FOREIGN KEY (operator_id) REFERENCES users(id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_detected_at (detected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Snapshots Table
CREATE TABLE snapshots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    detection_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    image_type VARCHAR(20) DEFAULT 'detection',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (detection_id) REFERENCES detections(id) ON DELETE CASCADE,
    INDEX idx_detection_id (detection_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Activity Logs Table
CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id INT,
    details JSON,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- System Settings Table
CREATE TABLE system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    key VARCHAR(100) UNIQUE NOT NULL,
    value VARCHAR(500),
    data_type VARCHAR(20) DEFAULT 'string',
    description VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_key (key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
