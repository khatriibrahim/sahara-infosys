# Sahara Infosys - Setup Guide

**© Ibrahim Khatri since 2014**

## Prerequisites

- PHP 8.0 or higher
- MySQL 5.7 or higher
- Apache/Nginx web server
- Node.js 14+ (optional, for frontend tools)
- Android Studio (for mobile development)

## Installation Steps

### 1. Clone Repository

```bash
git clone https://github.com/khatriibrahim/sahara-infosys.git
cd sahara-infosys
```

### 2. Configure Environment

```bash
cp backend/config/.env.example backend/config/.env
```

Edit `backend/config/.env` with your database credentials:

```env
DB_HOST=localhost
DB_NAME=sahara_infosys
DB_USER=root
DB_PASSWORD=your_password
```

### 3. Create Database

```bash
mysql -u root -p < backend/database/schema.sql
```

### 4. Insert Default Data

The schema.sql file automatically creates default roles and permissions.

### 5. Start Development Server

#### Using PHP Built-in Server
```bash
cd backend
php -S localhost:8000
```

#### Using Apache
1. Copy project to Apache document root (`/var/www/html/` on Linux or `C:\xampp\htdocs` on Windows)
2. Restart Apache service
3. Access at `http://localhost/sahara-infosys`

### 6. Access Admin Panel

```
http://localhost:8000/../admin-panel
```

Default credentials (create in database):
- **Username:** admin
- **Password:** admin@123

## Database Schema Overview

### Tables Created

1. **roles** - User roles (admin, manager, technician, etc.)
2. **users** - System users
3. **permissions** - Permission definitions
4. **role_permissions** - Role to permission mapping
5. **customers** - Customer information
6. **repair_jobs** - Repair job records
7. **inventory** - Spare parts inventory
8. **invoices** - Invoice records
9. **whatsapp_logs** - WhatsApp message logs

## API Testing

### Using cURL

#### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin@123"}'
```

#### Get Customers
```bash
curl -X GET http://localhost:8000/api/customers \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Create Customer
```bash
curl -X POST http://localhost:8000/api/customers \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","phone":"9876543210"}'
```

### Using Postman

1. Import the API collection (coming soon)
2. Set authorization token in Headers
3. Send requests

## File Structure

```
sahara-infosys/
├── backend/
│   ├── config/
│   │   ├── config.php
│   │   └── .env.example
│   ├── database/
│   │   └── schema.sql
│   ├── routes/
│   │   ├── auth.php
│   │   ├── customers.php
│   │   ├── jobs.php
│   │   ├── inventory.php
│   │   └── invoices.php
│   ├── public/
│   │   └── index.php
│   └── .htaccess
├── admin-panel/
│   ├── assets/
│   │   ├── css/
│   │   │   └── style.css
│   │   └── js/
│   │       └── app.js
│   └── index.php
├── android/
│   ├── app/
│   ├── build.gradle
│   └── proguard-rules.pro
├── docs/
│   └── API.md
├── README.md
├── SETUP.md
└── .gitignore
```

## Troubleshooting

### Database Connection Error

**Error:** "Database Connection Error"

**Solution:**
1. Check database credentials in `.env`
2. Ensure MySQL service is running
3. Verify database exists

### Permission Denied on Upload Directory

**Error:** "Permission denied"

**Solution:**
```bash
chmod -R 755 uploads/
chmod -R 755 temp/
```

### API Not Responding

**Solution:**
1. Check PHP version (PHP 8.0+ required)
2. Verify `.htaccess` is enabled (Apache)
3. Check PHP error logs

## Next Steps

1. Configure WhatsApp API credentials in `.env`
2. Set up email service for notifications
3. Create admin user account
4. Import customer data
5. Test all API endpoints
6. Deploy to production

## Support

For issues and questions:
- GitHub Issues: https://github.com/khatriibrahim/sahara-infosys/issues
- Documentation: https://github.com/khatriibrahim/sahara-infosys/wiki

---

**© 2014-2026 Ibrahim Khatri. All rights reserved.**
