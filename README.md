# Sahara Infosys - Smart Service Center Management System

**© Ibrahim Khatri since 2014**

## Overview

A comprehensive service center management solution designed to streamline operations for electronics and device repair businesses. Built with modern technologies for scalability, security, and ease of use.

## Features

✅ **Customer Management** - Track customer profiles and service history
✅ **Repair Job Tracking** - Manage repair requests from intake to completion
✅ **Inventory Management** - Monitor spare parts and stock levels
✅ **Billing System** - Generate and track invoices
✅ **Role-Based Access** - Secure permission management
✅ **Admin Dashboard** - Comprehensive management interface
✅ **WhatsApp Integration** - Automated customer notifications
✅ **Android Mobile App** - Field technician support

## Project Structure

```
sahara-infosys/
├── backend/                 # PHP/API Server
│   ├── config/             # Database & environment config
│   ├── routes/             # API endpoints
│   ├── controllers/        # Business logic
│   ├── models/             # Database models
│   ├── middleware/         # Authentication & validation
│   └── database/           # SQL migrations
├── admin-panel/            # Web Dashboard
│   ├── assets/             # CSS, JS, images
│   ├── pages/              # Dashboard views
│   ├── includes/           # Reusable components
│   └── index.php           # Entry point
├── android/                # Mobile Application
│   ├── app/                # Android source code
│   └── build.gradle        # Build configuration
└── docs/                   # Documentation
```

## Tech Stack

- **Backend:** PHP 8+ with PDO
- **Database:** MySQL/MariaDB
- **Frontend:** HTML5, CSS3, Bootstrap 5, JavaScript
- **Mobile:** Android (Kotlin/Java)
- **Authentication:** JWT (JSON Web Tokens)
- **API:** RESTful architecture

## Installation

### Prerequisites
- PHP 8.0+
- MySQL 5.7+
- Node.js 16+ (optional, for frontend build tools)
- Android Studio (for mobile development)

### Quick Start

1. **Clone Repository**
   ```bash
   git clone https://github.com/khatriibrahim/sahara-infosys.git
   cd sahara-infosys
   ```

2. **Configure Backend**
   ```bash
   cp backend/config/.env.example backend/config/.env
   # Edit .env with your database credentials
   ```

3. **Setup Database**
   ```bash
   mysql -u root -p < backend/database/schema.sql
   ```

4. **Start Development Server**
   ```bash
   php -S localhost:8000 -t backend/public
   ```

5. **Access Admin Panel**
   ```
   http://localhost/admin-panel
   ```

## API Documentation

All endpoints require JWT authentication. See `/docs/API.md` for detailed documentation.

### Core Endpoints
- `POST /api/auth/login` - User authentication
- `GET /api/customers` - List customers
- `POST /api/customers` - Create customer
- `GET /api/jobs` - List repair jobs
- `POST /api/jobs` - Create repair job
- `GET /api/inventory` - View inventory
- `POST /api/invoices` - Generate invoice

## License

Copyright © 2014-2026 Ibrahim Khatri. All rights reserved.

## Contact

**Sahara Infosys**
By: Ibrahim Khatri
Since: 2014

---

*Building reliable service management solutions since 2014.*
