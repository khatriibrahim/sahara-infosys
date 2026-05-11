# Sahara Infosys API Documentation

**© Ibrahim Khatri since 2014**

## Base URL
```
http://localhost:8000/api
```

## Authentication

All API endpoints (except login) require JWT authentication.

### Header
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

---

## Authentication Endpoints

### Login
**POST** `/auth/login`

Request:
```json
{
  "username": "admin",
  "password": "password123"
}
```

Response:
```json
{
  "status": "success",
  "token": "eyJhbGc...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@sahara.com",
    "role": "admin"
  }
}
```

---

## Customer Endpoints

### Get All Customers
**GET** `/customers`

Response:
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "9876543210",
      "address": "123 Main St",
      "city": "Mumbai",
      "status": "active",
      "created_at": "2026-05-11T10:00:00Z"
    }
  ]
}
```

### Get Customer by ID
**GET** `/customers/{id}`

### Create Customer
**POST** `/customers`

Request:
```json
{
  "name": "John Doe",
  "phone": "9876543210",
  "email": "john@example.com",
  "address": "123 Main St",
  "city": "Mumbai",
  "whatsapp_number": "9876543210"
}
```

### Update Customer
**PUT** `/customers/{id}`

Request:
```json
{
  "name": "John Updated",
  "phone": "9876543210"
}
```

---

## Repair Job Endpoints

### Get All Jobs
**GET** `/jobs`

### Get Job by ID
**GET** `/jobs/{id}`

### Create Job
**POST** `/jobs`

Request:
```json
{
  "customer_id": 1,
  "device_type": "Mobile Phone",
  "device_model": "iPhone 13",
  "issue_description": "Screen broken",
  "priority": "high",
  "estimated_cost": 5000
}
```

Response:
```json
{
  "status": "success",
  "message": "Repair job created successfully",
  "job_id": 1,
  "job_number": "JOB-20260511-ABC1"
}
```

### Update Job
**PUT** `/jobs/{id}`

Request:
```json
{
  "status": "completed",
  "actual_cost": 5000
}
```

---

## Inventory Endpoints

### Get All Items
**GET** `/inventory`

### Create Inventory Item
**POST** `/inventory`

Request:
```json
{
  "part_name": "iPhone Screen",
  "part_code": "IPHONE-SCREEN-001",
  "quantity": 10,
  "unit_price": 3000,
  "supplier": "Tech Supplies Inc"
}
```

---

## Invoice Endpoints

### Get All Invoices
**GET** `/invoices`

### Get Invoice by ID
**GET** `/invoices/{id}`

### Create Invoice
**POST** `/invoices`

Request:
```json
{
  "customer_id": 1,
  "job_id": 1,
  "subtotal": 5000,
  "tax": 900,
  "total_amount": 5900,
  "payment_method": "cash"
}
```

Response:
```json
{
  "status": "success",
  "message": "Invoice created successfully",
  "invoice_id": 1,
  "invoice_number": "INV-20260511-ABC1"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "error": "Name and phone are required"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid credentials"
}
```

### 404 Not Found
```json
{
  "error": "Customer not found"
}
```

### 500 Server Error
```json
{
  "error": "Failed to create customer"
}
```

---

## Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request parameters
- `401 Unauthorized` - Missing or invalid authentication
- `404 Not Found` - Resource not found
- `405 Method Not Allowed` - HTTP method not allowed
- `500 Internal Server Error` - Server error

---

## Rate Limiting

Currently no rate limiting is implemented. This will be added in future versions.

---

For more information, visit: https://github.com/khatriibrahim/sahara-infosys
