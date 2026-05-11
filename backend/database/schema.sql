-- Sahara Infosys - Database Schema
-- © Ibrahim Khatri since 2014
-- Smart Service Center Management System

CREATE DATABASE IF NOT EXISTS `sahara_infosys`;
USE `sahara_infosys`;

-- ============================================================================
-- USERS & ROLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) UNIQUE NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `users` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(100) UNIQUE NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `first_name` VARCHAR(100),
  `last_name` VARCHAR(100),
  `phone` VARCHAR(20),
  `role_id` INT NOT NULL,
  `status` ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `permissions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) UNIQUE NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` INT NOT NULL,
  `permission_id` INT NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`),
  FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- CUSTOMERS
-- ============================================================================

CREATE TABLE IF NOT EXISTS `customers` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100),
  `phone` VARCHAR(20) NOT NULL,
  `address` TEXT,
  `city` VARCHAR(50),
  `state` VARCHAR(50),
  `zip_code` VARCHAR(10),
  `whatsapp_number` VARCHAR(20),
  `customer_type` ENUM('individual', 'business') DEFAULT 'individual',
  `notes` TEXT,
  `status` ENUM('active', 'inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- REPAIR JOBS
-- ============================================================================

CREATE TABLE IF NOT EXISTS `repair_jobs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `job_number` VARCHAR(20) UNIQUE NOT NULL,
  `customer_id` INT NOT NULL,
  `device_type` VARCHAR(50),
  `device_model` VARCHAR(100),
  `device_serial` VARCHAR(100),
  `issue_description` TEXT NOT NULL,
  `assigned_to` INT,
  `status` ENUM('pending', 'in_progress', 'on_hold', 'completed', 'cancelled') DEFAULT 'pending',
  `priority` ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  `estimated_cost` DECIMAL(10, 2),
  `actual_cost` DECIMAL(10, 2),
  `start_date` DATETIME,
  `completion_date` DATETIME,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`),
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- INVENTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS `inventory_categories` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `inventory` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `part_name` VARCHAR(100) NOT NULL,
  `part_code` VARCHAR(50) UNIQUE NOT NULL,
  `category_id` INT,
  `quantity` INT DEFAULT 0,
  `min_quantity` INT DEFAULT 5,
  `unit_price` DECIMAL(10, 2),
  `supplier` VARCHAR(100),
  `last_restocked` DATETIME,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`category_id`) REFERENCES `inventory_categories`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `job_parts` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `job_id` INT NOT NULL,
  `part_id` INT NOT NULL,
  `quantity_used` INT,
  `added_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`job_id`) REFERENCES `repair_jobs`(`id`),
  FOREIGN KEY (`part_id`) REFERENCES `inventory`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- BILLING & INVOICES
-- ============================================================================

CREATE TABLE IF NOT EXISTS `invoices` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `invoice_number` VARCHAR(20) UNIQUE NOT NULL,
  `job_id` INT,
  `customer_id` INT NOT NULL,
  `subtotal` DECIMAL(10, 2),
  `tax` DECIMAL(10, 2),
  `discount` DECIMAL(10, 2),
  `total_amount` DECIMAL(10, 2),
  `payment_method` ENUM('cash', 'card', 'cheque', 'online', 'upi') DEFAULT 'cash',
  `payment_status` ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
  `due_date` DATE,
  `paid_date` DATETIME,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`job_id`) REFERENCES `repair_jobs`(`id`),
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `invoice_items` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `invoice_id` INT NOT NULL,
  `description` VARCHAR(255),
  `quantity` INT,
  `unit_price` DECIMAL(10, 2),
  `amount` DECIMAL(10, 2),
  FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- WHATSAPP & COMMUNICATION
-- ============================================================================

CREATE TABLE IF NOT EXISTS `whatsapp_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `job_id` INT,
  `phone_number` VARCHAR(20),
  `message` TEXT,
  `message_type` ENUM('status_update', 'invoice', 'reminder', 'custom') DEFAULT 'status_update',
  `sent_by` INT,
  `status` ENUM('pending', 'sent', 'delivered', 'failed') DEFAULT 'pending',
  `sent_at` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`),
  FOREIGN KEY (`job_id`) REFERENCES `repair_jobs`(`id`),
  FOREIGN KEY (`sent_by`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- INSERT DEFAULT ROLES
-- ============================================================================

INSERT INTO `roles` (`name`, `description`) VALUES
('admin', 'Administrator - Full system access'),
('manager', 'Manager - Can manage jobs and customers'),
('technician', 'Technician - Can view and update jobs'),
('customer_service', 'Customer Service - Handle customer queries'),
('accountant', 'Accountant - Manage invoices and payments');

-- ============================================================================
-- INSERT DEFAULT PERMISSIONS
-- ============================================================================

INSERT INTO `permissions` (`name`, `description`) VALUES
('view_dashboard', 'View dashboard'),
('manage_users', 'Create, edit, delete users'),
('manage_customers', 'Create, edit, delete customers'),
('manage_jobs', 'Create, edit, delete repair jobs'),
('manage_inventory', 'Manage inventory items'),
('manage_invoices', 'Create and manage invoices'),
('view_reports', 'View system reports'),
('export_data', 'Export data'),
('send_whatsapp', 'Send WhatsApp messages'),
('system_settings', 'Manage system settings');

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_user_email ON `users`(`email`);
CREATE INDEX idx_user_role ON `users`(`role_id`);
CREATE INDEX idx_customer_phone ON `customers`(`phone`);
CREATE INDEX idx_job_customer ON `repair_jobs`(`customer_id`);
CREATE INDEX idx_job_status ON `repair_jobs`(`status`);
CREATE INDEX idx_invoice_customer ON `invoices`(`customer_id`);
CREATE INDEX idx_whatsapp_customer ON `whatsapp_logs`(`customer_id`);
