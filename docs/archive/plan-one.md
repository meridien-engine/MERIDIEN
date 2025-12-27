# Business Management System - Project Structure & Implementation Plan

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Frontend Structure (Flutter)](#frontend-structure-flutter)
4. [Backend Structure (Go)](#backend-structure-go)
5. [Database Schema](#database-schema)
6. [API Design](#api-design)
7. [Deployment Strategy](#deployment-strategy)
8. [Development Workflow](#development-workflow)

---

## Project Overview

### Objective
Develop a comprehensive Business Management System targeting the Middle Eastern retail market, supporting both direct retail and dropshipping models. The application manages customers, products, orders, revenue, CRM, and integrates with regional shipping services (Posta, DHL, Aramex).

### Target Platforms
- Web (Primary)
- Mobile (Future)
- Desktop (Future)

---

## Technology Stack

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **HTTP Client:** dio
- **Local Storage:** Hive
- **UI Widgets:** Standard Flutter widgets
- **Code Generation:** Freezed, json_serializable

### Backend
- **Language:** Go (Golang)
- **Web Framework:** Gin-Gonic
- **Database:** PostgreSQL
- **ORM:** GORM
- **Authentication:** JWT
- **Environment Variables:** godotenv
- **Logging:** logrus
- **API Documentation:** swaggo/gin-swagger
- **Password Hashing:** bcrypt

### DevOps & Deployment
- **Version Control:** Git (GitHub)
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Hosting:** Cloud Provider (AWS/GCP/Azure) or VPS

---

## Frontend Structure (Flutter)

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp setup, theme, routing
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── validation_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failure.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── interceptors.dart
│   │   └── dio_config.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── extensions.dart
│   │   └── helpers.dart
│   └── themes/
│       ├── app_theme.dart
│       └── colors.dart
├── shared/
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   └── empty_state_widget.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── customer.dart
│   │   ├── product.dart
│   │   ├── order.dart
│   │   ├── order_item.dart
│   │   ├── shipping_info.dart
│   │   └── revenue_summary.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── api_provider.dart
│   │   └── theme_provider.dart
│   └── services/
│       ├── auth_service.dart
│       ├── customer_service.dart
│       ├── product_service.dart
│       ├── order_service.dart
│       ├── shipping_service.dart
│       └── revenue_service.dart
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   └── forgot_password_page.dart
│   │   │   ├── widgets/
│   │   │   │   └── auth_form.dart
│   │   │   └── providers/
│   │   │       └── auth_controller.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── user_entity.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── auth_remote_data_source.dart
│   │       ├── models/
│   │       │   └── user_model.dart
│   │       └── repositories/
│   │           └── auth_repository_impl.dart
│   ├── customers/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── customer_list_page.dart
│   │   │   │   ├── customer_detail_page.dart
│   │   │   │   └── customer_form_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── customer_card.dart
│   │   │   │   └── customer_address_input.dart
│   │   │   └── providers/
│   │   │       ├── customer_list_controller.dart
│   │   │       ├── customer_detail_controller.dart
│   │   │       └── customer_form_controller.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── customer_entity.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── customer_remote_data_source.dart
│   │       ├── models/
│   │       │   └── customer_model.dart
│   │       └── repositories/
│   │           └── customer_repository_impl.dart
│   ├── products/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── product_list_page.dart
│   │   │   │   ├── product_detail_page.dart
│   │   │   │   └── product_form_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── product_card.dart
│   │   │   │   └── product_price_display.dart
│   │   │   └── providers/
│   │   │       ├── product_list_controller.dart
│   │   │       ├── product_detail_controller.dart
│   │   │       └── product_form_controller.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── product_entity.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── product_remote_data_source.dart
│   │       ├── models/
│   │       │   └── product_model.dart
│   │       └── repositories/
│   │           └── product_repository_impl.dart
│   ├── orders/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── order_list_page.dart
│   │   │   │   ├── order_detail_page.dart
│   │   │   │   └── order_creation_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── order_item_widget.dart
│   │   │   │   └── order_status_badge.dart
│   │   │   └── providers/
│   │   │       ├── order_list_controller.dart
│   │   │       ├── order_detail_controller.dart
│   │   │       └── order_creation_controller.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── order_entity.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── order_remote_data_source.dart
│   │       ├── models/
│   │       │   └── order_model.dart
│   │       └── repositories/
│   │           └── order_repository_impl.dart
│   ├── revenue/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── revenue_dashboard_page.dart
│   │   │   │   └── revenue_report_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── revenue_summary_card.dart
│   │   │   │   └── chart_widget.dart
│   │   │   └── providers/
│   │   │       ├── revenue_dashboard_controller.dart
│   │   │       └── revenue_report_controller.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── revenue_summary_entity.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── revenue_remote_data_source.dart
│   │       ├── models/
│   │       │   └── revenue_summary_model.dart
│   │       └── repositories/
│   │           └── revenue_repository_impl.dart
│   └── shipping/
│       ├── presentation/
│       │   ├── pages/
│       │   │   ├── shipping_list_page.dart
│       │   │   └── shipping_detail_page.dart
│       │   ├── widgets/
│       │   │   ├── shipping_tracking_widget.dart
│       │   │   └── carrier_selector.dart
│       │   └── providers/
│       │       ├── shipping_list_controller.dart
│       │       └── shipping_detail_controller.dart
│       ├── domain/
│       │   └── entities/
│       │       └── shipping_entity.dart
│       └── data/
│           ├── datasources/
│           │   └── shipping_remote_data_source.dart
│           ├── models/
│           │   └── shipping_model.dart
│           └── repositories/
│               └── shipping_repository_impl.dart
├── routes/
│   └── app_router.dart
└── l10n/
    ├── app_en.arb
    └── app_ar.arb
```

### Key Frontend Libraries
- `riverpod`: State management
- `dio`: HTTP requests
- `freezed`: Immutable data classes
- `json_annotation` / `json_serializable`: JSON serialization
- `flutter_hooks`: Lifecycle management
- `go_router`: Navigation
- `l10n`: Localization

---

## Backend Structure (Go)

```
business-management-backend/
├── cmd/
│   └── server/
│       └── main.go               # Entry point
├── internal/
│   ├── config/
│   │   └── config.go             # Configuration loading
│   ├── database/
│   │   └── database.go           # Database connection setup
│   ├── handlers/
│   │   ├── auth_handler.go
│   │   ├── customer_handler.go
│   │   ├── product_handler.go
│   │   ├── order_handler.go
│   │   ├── revenue_handler.go
│   │   └── shipping_handler.go
│   ├── middleware/
│   │   ├── auth.go
│   │   ├── cors.go
│   │   └── logger.go
│   ├── models/
│   │   ├── customer.go
│   │   ├── product.go
│   │   ├── order.go
│   │   ├── order_item.go
│   │   ├── supplier.go
│   │   ├── category.go
│   │   ├── shipping_info.go
│   │   ├── shipping_tracking_update.go
│   │   └── revenue_summary.go
│   ├── repositories/
│   │   ├── customer_repository.go
│   │   ├── product_repository.go
│   │   ├── order_repository.go
│   │   ├── shipping_repository.go
│   │   └── revenue_repository.go
│   ├── services/
│   │   ├── customer_service.go
│   │   ├── product_service.go
│   │   ├── order_service.go
│   │   ├── shipping_service.go
│   │   └── revenue_service.go
│   ├── utils/
│   │   ├── jwt.go
│   │   ├── hash.go
│   │   ├── validators.go
│   │   └── helpers.go
│   └── router/
│       └── router.go
├── docs/
│   └── swagger/                  # Generated Swagger docs
├── scripts/
│   ├── migrate.sh
│   └── setup_db.sh
├── .env.example
├── .gitignore
├── Dockerfile
├── docker-compose.yml
├── go.mod
├── go.sum
└── README.md
```

### Key Backend Libraries
- `github.com/gin-gonic/gin`: Web framework
- `gorm.io/gorm`: ORM
- `gorm.io/driver/postgres`: PostgreSQL driver
- `github.com/golang-jwt/jwt`: JWT handling
- `github.com/joho/godotenv`: Environment variables
- `github.com/sirupsen/logrus`: Logging
- `github.com/swaggo/gin-swagger`: API documentation
- `golang.org/x/crypto/bcrypt`: Password hashing

---

## Database Schema

### Core Tables

#### `customers`
```sql
id (PK, INT, Auto-Increment)
name (VARCHAR)
address (TEXT)
government (VARCHAR) -- Governorate/Region
city (VARCHAR)
landmark_near (TEXT) -- Optional
phone_number (VARCHAR) -- Optional
email (VARCHAR) -- Optional
notes (TEXT) -- CRM notes
customer_rank (ENUM: 'Regular', 'VIP', 'Platinum') -- Optional
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

#### `suppliers`
```sql
id (PK, INT, Auto-Increment)
name (VARCHAR)
contact_info (TEXT) -- JSON or separate fields
address (TEXT)
payment_terms (TEXT) -- Optional
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

#### `categories`
```sql
id (PK, INT, Auto-Increment)
name (VARCHAR)
description (TEXT) -- Optional
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

#### `products`
```sql
id (PK, INT, Auto-Increment)
name (VARCHAR)
description (TEXT) -- Optional
price (DECIMAL)
discount_price (DECIMAL) -- Optional
product_cost (DECIMAL) -- Cost to business
product_revenue (DECIMAL) -- Calculated: price - cost (or based on discount_price)
category_id (FK, INT, References categories.id)
supplier_id (FK, INT, References suppliers.id, Optional for dropshipping)
sku (VARCHAR) -- Optional
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

#### `orders`
```sql
id (PK, INT, Auto-Increment)
customer_id (FK, INT, References customers.id)
order_date (TIMESTAMP)
status (ENUM: 'Pending Payment', 'Confirmed', 'Awaiting Fulfillment', 'Shipped', 'Out for Delivery', 'Delivered', 'Returned', 'Cancelled')
total_amount (DECIMAL) -- Gross amount
total_discount (DECIMAL) -- Total discount applied
shipping_cost (DECIMAL) -- Cost charged to customer
net_revenue (DECIMAL) -- Calculated: total_amount - total_discount + shipping_cost - (sum of product costs for items in order)
payment_method (ENUM: 'Credit Card', 'Cash on Delivery', 'Bank Transfer', etc.) -- Optional
payment_status (ENUM: 'Pending', 'Paid', 'Failed', 'Refunded') -- Optional
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

#### `order_items`
```sql
id (PK, INT, Auto-Increment)
order_id (FK, INT, References orders.id)
product_id (FK, INT, References products.id)
quantity (INT)
unit_price (DECIMAL) -- Price at time of order (captures price/discount_price)
total_price (DECIMAL) -- Calculated: quantity * unit_price
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

#### `shipping_info`
```sql
id (PK, INT, Auto-Increment)
order_id (FK, INT, References orders.id)
carrier_name (ENUM: 'Posta', 'DHL', 'Aramex', 'Other') -- Or VARCHAR if flexibility needed
tracking_number (VARCHAR)
shipping_label_url (TEXT) -- URL or path to label file
recipient_name (VARCHAR)
recipient_address (TEXT)
recipient_phone (VARCHAR)
shipping_cost_to_customer (DECIMAL) -- Cost charged to customer
shipping_cost_to_business (DECIMAL) -- Cost paid to carrier -- Optional, for profit calc
estimated_delivery_date (DATE) -- Optional
actual_delivery_date (DATE) -- Optional
current_status_from_carrier (TEXT) -- Raw status from API
last_tracked_update (TIMESTAMP) -- Last time status was fetched from carrier API
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

#### `shipping_tracking_updates`
```sql
id (PK, INT, Auto-Increment)
shipping_info_id (FK, INT, References shipping_info.id)
event_timestamp (TIMESTAMP) -- Time reported by carrier
event_description (TEXT)
location (TEXT) -- Location of the event
status_code (VARCHAR) -- Carrier-specific code -- Optional
created_at (TIMESTAMP) -- Time this update was recorded in our system
```

#### `revenue_summary` (Aggregated Data, Updated Periodically)
```sql
id (PK, INT, Auto-Increment)
date_range_start (DATE) -- e.g., 2023-10-01
date_range_end (DATE) -- e.g., 2023-10-31 (for monthly)
total_orders_count (INT)
total_gross_revenue (DECIMAL)
total_discount_given (DECIMAL)
total_net_revenue (DECIMAL)
total_shipping_revenue (DECIMAL)
total_product_costs (DECIMAL)
calculated_profit (DECIMAL) -- total_net_revenue - total_product_costs
summary_period_type (ENUM: 'Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly')
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

---

## API Design

### Base URL
`/api/v1`

### Example Endpoints

#### Authentication
- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/refresh`

#### Customers
- `GET /customers` (with pagination/filtering)
- `GET /customers/:id`
- `POST /customers`
- `PUT /customers/:id`
- `DELETE /customers/:id`

#### Products
- `GET /products` (with pagination/filtering)
- `GET /products/:id`
- `POST /products`
- `PUT /products/:id`
- `DELETE /products/:id`

#### Orders
- `GET /orders` (with pagination/filtering)
- `GET /orders/:id`
- `POST /orders`
- `PUT /orders/:id` (for status updates)
- `GET /orders/:id/shipping`

#### Revenue
- `GET /reports/revenue-summary?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD`

#### Shipping
- `GET /shipping-info/:id`
- `GET /shipping-info/:id/tracking-updates`

### Response Format
```json
{
  "success": true,
  "message": "Request successful",
  "data": {},
  "error": null
}
```

---

## Deployment Strategy

### Backend
1.  **Build:** Compile Go application (`CGO_ENABLED=0 GOOS=linux go build -o bin/server cmd/server/main.go`).
2.  **Dockerize:** Multi-stage Dockerfile.
3.  **Push:** Push image to container registry.
4.  **Deploy:** Deploy to cloud (ECS, Cloud Run, Kubernetes) or VPS with Docker Compose.
5.  **Proxy:** Nginx for SSL termination.

### Frontend (Web)
1.  Build Flutter web app (`flutter build web`).
2.  Host `build/web` on static hosting (S3 + CloudFront, Netlify, Vercel) or serve via Nginx.

---

## Development Workflow

### Initial Setup
1.  Clone repositories.
2.  Set up `.env` files.
3.  Run database migrations.
4.  Start backend and frontend in development mode.

### Feature Development
1.  Define models in backend.
2.  Create API endpoints and handlers.
3.  Implement frontend screens using Riverpod state management.
4.  Write unit and integration tests.
5.  Run API tests against backend.
6.  Perform end-to-end testing.

### CI/CD Pipeline
1.  Run linters and static analysis.
2.  Execute unit/integration tests.
3.  Build Docker images.
4.  Push images to registry.
5.  Deploy to staging/production environment.
