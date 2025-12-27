# MERIDIEN API Documentation

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

---

## Health & Status

### Health Check
Get server health status.

**Endpoint:** `GET /health`  
**Authentication:** Not required

**Response:**
```json
{
  "status": "healthy",
  "service": "MERIDIEN API",
  "time": "2025-12-24T02:45:07Z"
}
```

---

## Authentication Endpoints

### Register User
Create a new user account.

**Endpoint:** `POST /api/v1/auth/register`  
**Authentication:** Not required

**Request Body:**
```json
{
  "tenant_slug": "demo",
  "email": "user@example.com",
  "password": "Password123",
  "first_name": "John",
  "last_name": "Doe",
  "role": "user"
}
```

**Field Validation:**
- `email`: Valid email format, required
- `password`: Minimum 8 characters, must contain uppercase, lowercase, and digit, required
- `first_name`: Minimum 2 characters, maximum 100, required
- `last_name`: Minimum 2 characters, maximum 100, required
- `role`: One of: `admin`, `manager`, `user`, `cashier` (default: `user`)

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "1f9a7ff8-246a-4672-ad34-55cd8f62af3c",
      "tenant_id": "bae1577c-1b95-4a0e-8eae-9a44654278b2",
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "user",
      "is_active": true
    }
  }
}
```

**Error Responses:**
```json
// 400 - Validation Error
{
  "success": false,
  "error": "password must contain at least one uppercase letter"
}

// 400 - User Already Exists
{
  "success": false,
  "error": "user with this email already exists"
}

// 400 - Tenant Limit Reached
{
  "success": false,
  "error": "tenant has reached maximum user limit"
}
```

---

### Login
Authenticate user and receive JWT token.

**Endpoint:** `POST /api/v1/auth/login`  
**Authentication:** Not required

**Request Body:**
```json
{
  "tenant_slug": "demo",
  "email": "user@example.com",
  "password": "Password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "1f9a7ff8-246a-4672-ad34-55cd8f62af3c",
      "tenant_id": "bae1577c-1b95-4a0e-8eae-9a44654278b2",
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "user",
      "is_active": true
    }
  }
}
```

**Error Responses:**
```json
// 401 - Invalid Credentials
{
  "success": false,
  "error": "invalid email or password"
}

// 401 - Account Disabled
{
  "success": false,
  "error": "account is disabled"
}
```

---

### Get Current User
Retrieve authenticated user's information.

**Endpoint:** `GET /api/v1/auth/me`  
**Authentication:** Required

**Request Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User retrieved successfully",
  "data": {
    "id": "1f9a7ff8-246a-4672-ad34-55cd8f62af3c",
    "tenant_id": "bae1577c-1b95-4a0e-8eae-9a44654278b2",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "user",
    "is_active": true
  }
}
```

**Error Responses:**
```json
// 401 - No Token
{
  "success": false,
  "error": "Authorization header is required"
}

// 401 - Invalid Token
{
  "success": false,
  "error": "Invalid or expired token"
}

// 404 - User Not Found
{
  "success": false,
  "error": "User not found"
}
```

---

### Logout
Logout current user (client-side token removal).

**Endpoint:** `POST /api/v1/auth/logout`  
**Authentication:** Required

**Request Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### Refresh Token
Generate a new JWT token from existing valid token.

**Endpoint:** `POST /api/v1/auth/refresh`  
**Authentication:** Not required (but requires valid token in header)

**Request Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "error": "Error message here"
}
```

### HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data or validation error
- `401 Unauthorized` - Authentication required or invalid credentials
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

---

## JWT Token

### Token Structure

JWT tokens contain the following claims:

```json
{
  "user_id": "1f9a7ff8-246a-4672-ad34-55cd8f62af3c",
  "tenant_id": "bae1577c-1b95-4a0e-8eae-9a44654278b2",
  "email": "user@example.com",
  "role": "user",
  "iss": "MERIDIEN",
  "exp": 1766623525,
  "nbf": 1766537125,
  "iat": 1766537125
}
```

### Token Expiration

Tokens expire after 24 hours (configurable in `.env` via `JWT_EXPIRATION_HOURS`).

---

## User Roles

Available roles and their permissions:

- **admin**: Full system access
- **manager**: Manage users, products, orders
- **user**: Standard user access
- **cashier**: POS operations only

---

## Testing with cURL

### Register a new user
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "tenant_slug": "demo",
    "email": "test@example.com",
    "password": "Test123456",
    "first_name": "Test",
    "last_name": "User",
    "role": "user"
  }'
```

### Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "tenant_slug": "demo",
    "email": "test@example.com",
    "password": "Test123456"
  }'
```

### Get current user (replace TOKEN with your JWT)
```bash
TOKEN="your_jwt_token_here"
curl -X GET http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## Rate Limiting

Currently not implemented. Will be added in future versions.

---

## Pagination

For endpoints that return lists (future implementation):

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "per_page": 20,
    "total_pages": 5
  }
}
```

---

## Coming Soon

- Customer Management (`/api/v1/customers`)
- Product Management (`/api/v1/products`)
- Order Management (`/api/v1/orders`)
- Reports & Analytics (`/api/v1/reports`)
