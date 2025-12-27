<div align="center">

# 🧭 MERIDIEN

### Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine

*Navigate Your Business to Success*

A comprehensive enterprise-grade SaaS platform for managing retail operations, inventory, and multi-tenant business intelligence. Built with Go and Flutter for maximum performance and cross-platform compatibility.

[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](#)
[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)](https://golang.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B.svg)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![Phase 1](https://img.shields.io/badge/Phase%201-MVP%20Complete%20(100%25)-success.svg)](#)

[Documentation](./docs/) · [Getting Started](./GETTING-STARTED.md) · [Project Status](./PROJECT-STATUS.md)

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Project Status](#-project-status)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Documentation](#-documentation)
- [Development](#-development)
- [API Reference](#-api-reference)
- [Testing](#-testing)
- [Roadmap](#-roadmap)
- [License](#-license)
- [Contact](#-contact)

---

## 🌟 Overview

**MERIDIEN** (Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine) is a sophisticated business management platform designed for modern retail enterprises. It provides comprehensive tools for inventory management, customer relationship management, sales tracking, and business analytics—all in a multi-tenant SaaS architecture designed to support 100+ concurrent businesses.

The name "MERIDIEN" evokes navigation and direction, symbolizing how the platform guides businesses toward success through data-driven insights and intelligent automation.

### Why MERIDIEN?

- **Multi-Tenant SaaS**: Complete data isolation per business with tenant-based architecture
- **Enterprise-Grade**: Built with security, scalability, and reliability as core principles
- **Modern Stack**: Leveraging Go's performance and Flutter's beautiful cross-platform UI
- **API-First Design**: RESTful APIs enable easy integration and extensibility
- **Production-Ready MVP**: Fully functional Phase 1 implementation with 26 API endpoints

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎯 Core Business Features (Implemented)
- ✅ **Multi-Tenant Architecture**: Isolated data and customization per business
- ✅ **Customer Management**: Complete CRM with multi-level addresses, business customers
- ✅ **Product Management**: SKU/barcode tracking, hierarchical categories, inventory control
- ✅ **Order Processing**: 7-state workflow from draft to delivery with payment tracking
- ✅ **Inventory Tracking**: Real-time stock levels with low-stock alerts
- ✅ **User Authentication**: JWT-based auth with refresh tokens and secure session management
- ✅ **Dashboard**: Quick actions and business overview
- ✅ **Internationalization**: Arabic & English with RTL support, Tajawal font

</td>
<td width="50%">

### 🔮 Enterprise Features (Planned - Phase 2)
- 🚧 **Multi-User & RBAC**: Role-based access control with granular permissions
- 🚧 **Advanced Analytics**: Revenue insights, performance metrics, custom reports
- 🚧 **Invoice Generation**: PDF generation with email delivery
- 🚧 **Automated Testing**: 80% backend, 70% frontend coverage
- 🚧 **DevOps Pipeline**: CI/CD, monitoring, automated backups
- 🚧 **Enhanced Security**: Redis caching, rate limiting, password reset
- �� **Audit Logging**: Complete activity tracking and compliance
- 🚧 **Data Export**: CSV/Excel/PDF report generation

</td>
</tr>
</table>

---

## 📊 Project Status

**Current Phase:** Phase 1 MVP - ✅ **COMPLETE** (100%)  
**Next Phase:** Phase 2 - Production Ready (Target: 35% by Month 4)  
**Last Updated:** December 27, 2025

### Implemented Modules

| Module | Status | Backend | Frontend | Features |
|--------|--------|---------|----------|----------|
| **Authentication** | ✅ Complete | 5 endpoints | Login, Register | JWT with refresh tokens |
| **Customer Management** | ✅ Complete | 6 endpoints | List, Detail, CRUD | Multi-level addresses, search |
| **Product Management** | ✅ Complete | 6 endpoints | List, Detail, CRUD | Categories, inventory, SKU |
| **Order Management** | ✅ Complete | 9 endpoints | List, Detail, Create | 7-state workflow, payments |
| **Dashboard** | ✅ Basic | - | Overview | Quick actions |
| **Internationalization** | ✅ Complete | - | AR/EN, RTL | 34 translations |

### Key Statistics

- **API Endpoints:** 26 RESTful endpoints
- **Database Tables:** 8 tables (all multi-tenant)
- **Frontend Screens:** 14 responsive screens
- **Backend Files:** 29 Go files
- **Frontend Files:** 28+ Dart files
- **Supported Languages:** English, Arabic (with RTL)
- **Test Coverage:** 0% automated (100% manual)

For detailed status tracking, see [PROJECT-STATUS.md](PROJECT-STATUS.md)

---

## 🏗️ Architecture

MERIDIEN follows clean architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Frontend                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Web UI  │  │ Mobile   │  │ Desktop  │  │  Tablet  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│         │            │             │             │          │
│         └────────────┴─────────────┴─────────────┘          │
│                       │ REST API                            │
└───────────────────────┼─────────────────────────────────────┘
                        │
┌───────────────────────┼─────────────────────────────────────┐
│                  Go Backend (Gin)                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              HTTP Handlers (API)                     │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │         Business Logic (Services)                    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │       Data Access Layer (Repositories)               │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │            Domain Models (GORM)                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                       │                                     │
└───────────────────────┼─────────────────────────────────────┘
                        │
┌───────────────────────┼─────────────────────────────────────┐
│              PostgreSQL Database                            │
│  • Multi-tenant with tenant_id on all tables                │
│  • UUID primary keys                                        │
│  • Soft deletes (deleted_at)                                │
│  • Automatic timestamps                                     │
└─────────────────────────────────────────────────────────────┘
```

### Clean Architecture Flow

```
HTTP Request → Handler → Service → Repository → Model → Database
                  ↓         ↓          ↓
             Validation  Business   Data Access
                         Logic      
```

### Multi-Tenancy Model

Every table includes `tenant_id` for complete data isolation:
- JWT tokens contain `tenant_id` claim
- All queries automatically filter by tenant
- Unique constraints include tenant_id
- Example: emails are unique per tenant

---

## 🛠 Tech Stack

<div align="center">

### Backend
![Go](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![Gin](https://img.shields.io/badge/Gin-HTTP%20Framework-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![GORM](https://img.shields.io/badge/GORM-ORM-00ADD8?style=for-the-badge)
![JWT](https://img.shields.io/badge/JWT-Auth-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white)

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-02569B?style=for-the-badge)
![Dio](https://img.shields.io/badge/Dio-HTTP%20Client-02569B?style=for-the-badge)

### Key Dependencies
- **Backend**: Viper (config), golang-jwt (auth), google/uuid, shopspring/decimal
- **Frontend**: Freezed (models), json_serializable, SharedPreferences, go_router

</div>

---

## 🚀 Quick Start

### Prerequisites

- **Go 1.21+** ([Download](https://golang.org/dl/))
- **Flutter 3.24+** ([Download](https://flutter.dev/docs/get-started/install))
- **PostgreSQL 15+** ([Download](https://www.postgresql.org/download/))
- **Git** ([Download](https://git-scm.com/downloads))

### 1. Clone Repository

```bash
git clone https://github.com/mu7ammad-3li/MERIDIEN.git
cd MERIDIEN
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
go mod download

# Create database
./scripts/create-database.sh

# Run migrations
./scripts/run-migrations.sh

# Start server (runs on port 8080)
./scripts/start-server.sh
```

Backend API will be available at: **http://localhost:8080**

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
flutter pub get

# Generate Freezed models
flutter pub run build_runner build --delete-conflicting-outputs

# Run app (web)
flutter run -d chrome

# Or run on mobile
flutter run

# Or run on desktop
flutter run -d macos  # or windows, linux
```

### 4. Test Login

Default demo tenant credentials:
- **Tenant Slug:** demo
- **Email:** admin@meridien.com
- **Password:** Admin123

For detailed setup instructions, see [GETTING-STARTED.md](GETTING-STARTED.md)

---

## 📁 Project Structure

```
MERIDIEN/
├── backend/                        # Go Backend
│   ├── config/                    # Configuration management
│   ├── handlers/                  # HTTP request handlers
│   ├── middleware/                # Auth, CORS, tenant middleware
│   ├── models/                    # GORM database models
│   ├── repositories/              # Data access layer
│   ├── routes/                    # API route definitions
│   ├── services/                  # Business logic layer
│   ├── utils/                     # Utility functions
│   ├── migrations/                # Database migrations
│   ├── scripts/                   # Deployment scripts
│   ├── main.go                    # Application entry point
│   ├── go.mod & go.sum           # Go dependencies
│   └── .env                       # Environment variables
│
├── frontend/                       # Flutter Frontend
│   ├── lib/
│   │   ├── core/                 # Constants, themes, utils
│   │   │   ├── constants/        # App-wide constants
│   │   │   ├── theme/           # Theme configuration
│   │   │   └── utils/           # Helper utilities
│   │   ├── data/                 # Data layer
│   │   │   ├── models/          # Freezed data models
│   │   │   └── repositories/    # API repositories
│   │   ├── features/             # Feature modules
│   │   │   ├── auth/            # Authentication
│   │   │   ├── customers/       # Customer management
│   │   │   ├── products/        # Product management
│   │   │   ├── orders/          # Order management
│   │   │   └── dashboard/       # Dashboard
│   │   ├── routes/               # Navigation & routing
│   │   ├── shared/               # Shared widgets
│   │   └── main.dart            # App entry point
│   ├── pubspec.yaml              # Flutter dependencies
│   └── analysis_options.yaml     # Dart linter config
│
├── docs/                          # Documentation
│   ├── MERIDIEN-BRAND.md         # Brand guidelines
│   ├── DEVELOPMENT-RULES.md      # Coding standards
│   ├── mvp-analysis.md           # MVP analysis
│   ├── guides/                   # Setup guides
│   │   ├── BACKEND-SETUP.md
│   │   └── FRONTEND-SETUP.md
│   └── completed/                # Module completion docs
│       ├── AUTHENTICATION-COMPLETE.md
│       ├── CUSTOMER-MODULE-COMPLETE.md
│       ├── PRODUCT-MODULE-COMPLETE.md
│       └── ORDER-MODULE-COMPLETE.md
│
├── CLAUDE.md                      # Claude Code guide
├── PROJECT-STATUS.md              # Current project status
├── GETTING-STARTED.md            # Quick start guide
├── IMPLEMENTATION-CHECKLIST.md   # Phase tracking
├── README.md                      # This file
└── .gitignore                     # Git ignore rules
```

---

## 📚 Documentation

### Quick Reference
- **[Getting Started](GETTING-STARTED.md)** - Quick start guide
- **[Project Status](PROJECT-STATUS.md)** - Current status, roadmap, metrics
- **[Implementation Checklist](IMPLEMENTATION-CHECKLIST.md)** - Phase tracking
- **[Claude Code Guide](CLAUDE.md)** - Development guide for Claude Code

### Core Documentation
- **[Brand Guidelines](docs/MERIDIEN-BRAND.md)** - Visual identity and branding
- **[Development Rules](docs/DEVELOPMENT-RULES.md)** - Coding standards and practices
- **[MVP Analysis](docs/mvp-analysis.md)** - Minimum viable product scope

### Technical Documentation
- **[API Documentation](backend/API-DOCUMENTATION.md)** - Complete API reference
- **[Backend Setup](docs/guides/BACKEND-SETUP.md)** - Detailed backend setup
- **[Frontend Setup](docs/guides/FRONTEND-SETUP.md)** - Detailed frontend setup

### Module Completion Documentation
- **[Authentication](docs/completed/AUTHENTICATION-COMPLETE.md)** - Auth module details
- **[Customers](docs/completed/CUSTOMER-MODULE-COMPLETE.md)** - Customer module details
- **[Products](docs/completed/PRODUCT-MODULE-COMPLETE.md)** - Product module details
- **[Orders (Backend)](docs/completed/ORDER-MODULE-COMPLETE.md)** - Order backend details
- **[Orders (Frontend)](docs/completed/ORDER_MODULE_COMPLETE.md)** - Order frontend details

---

## 💻 Development

### Common Commands

#### Backend Development
```bash
cd backend

# Start development server
./scripts/start-server.sh

# Run migrations
./scripts/run-migrations.sh

# Create new database
./scripts/create-database.sh

# Run backend directly
go run main.go

# Build for production
go build -o meridien main.go
```

#### Frontend Development
```bash
cd frontend

# Run on web
flutter run -d chrome

# Run on mobile/desktop
flutter run

# Generate Freezed models
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Build for production
flutter build web           # Web
flutter build apk           # Android
flutter build ios           # iOS
flutter build macos         # macOS
flutter build windows       # Windows
flutter build linux         # Linux
```

### Naming Conventions

#### Go (Backend)
- **Files:** `snake_case.go`
- **Packages:** lowercase, single word
- **Types/Structs:** `PascalCase`
- **Functions:** `PascalCase` (exported), `camelCase` (unexported)
- **Variables:** `camelCase`

#### Dart (Frontend)
- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables/Functions:** `camelCase`
- **Private members:** `_camelCase`

#### Database
- **Tables:** `snake_case`, plural (e.g., `customers`, `order_items`)
- **Columns:** `snake_case`
- **Primary keys:** `id` (UUID)
- **Foreign keys:** `{table}_id` (e.g., `tenant_id`, `customer_id`)

---

## 🔌 API Reference

### Standard Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Operation completed",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Error message",
  "message": "Detailed description"
}
```

**Paginated Response:**
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

### Key Endpoints

#### Authentication
```
POST   /api/v1/auth/register      - Register new tenant & user
POST   /api/v1/auth/login         - Login with credentials
GET    /api/v1/auth/me            - Get current user info
POST   /api/v1/auth/logout        - Logout user
POST   /api/v1/auth/refresh       - Refresh JWT token
```

#### Customers
```
GET    /api/v1/customers          - List customers (paginated, searchable)
POST   /api/v1/customers          - Create customer
GET    /api/v1/customers/:id      - Get customer by ID
PUT    /api/v1/customers/:id      - Update customer
DELETE /api/v1/customers/:id      - Soft delete customer
GET    /api/v1/customers/search   - Search customers
```

#### Products
```
GET    /api/v1/products           - List products (paginated, filterable)
POST   /api/v1/products           - Create product
GET    /api/v1/products/:id       - Get product by ID
PUT    /api/v1/products/:id       - Update product
DELETE /api/v1/products/:id       - Soft delete product
GET    /api/v1/products/categories - List categories
```

#### Orders
```
GET    /api/v1/orders             - List orders (paginated, filterable)
POST   /api/v1/orders             - Create order
GET    /api/v1/orders/:id         - Get order by ID
PUT    /api/v1/orders/:id         - Update order
DELETE /api/v1/orders/:id         - Soft delete order
POST   /api/v1/orders/:id/status  - Update order status
POST   /api/v1/orders/:id/payment - Record payment
GET    /api/v1/orders/:id/items   - Get order items
POST   /api/v1/orders/:id/return  - Return order
```

For complete API documentation, see [backend/API-DOCUMENTATION.md](backend/API-DOCUMENTATION.md)

---

## 🧪 Testing

### Backend Testing

```bash
cd backend

# Login test
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"tenant_slug":"demo","email":"admin@meridien.com","password":"Admin123"}' \
  | jq -r '.token')

# Test authenticated endpoint
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/v1/customers
```

### Frontend Testing

```bash
cd frontend

# Run unit tests
flutter test

# Run integration tests (when implemented)
flutter test integration_test
```

### Manual Testing

- **Health Check:** `curl http://localhost:8080/health`
- **API Testing:** Use Postman, Insomnia, or curl
- **Frontend Testing:** Browser DevTools, Flutter DevTools

---

## 🗺️ Roadmap

### Phase 1: MVP - ✅ Complete (100%)
- ✅ Authentication & authorization
- ✅ Customer management with CRM
- ✅ Product & inventory management
- ✅ Order processing with workflow
- ✅ Basic dashboard
- ✅ Internationalization (AR/EN)

### Phase 2: Production Ready - 🚧 In Progress (Target: 35%)
- 🚧 Multi-user support & RBAC
- 🚧 Automated testing (80% backend, 70% frontend)
- 🚧 Enhanced security (Redis, rate limiting)
- 🚧 DevOps pipeline (CI/CD, monitoring)
- 🚧 Reports & analytics module
- 🚧 Invoice generation (PDF)
- 🚧 Advanced filters & search
- 🚧 Notification system

### Phase 3: Advanced Features (Planned)
- 📋 Supplier management
- 📋 Purchase orders
- 📋 Advanced reporting & BI
- 📋 Mobile app optimization
- 📋 Barcode scanning
- 📋 Integration APIs (Shopify, WooCommerce)
- 📋 Multi-warehouse support
- 📋 Advanced inventory forecasting

### Phase 4: Enterprise & Scale (Future)
- 📋 Real-time collaboration
- 📋 Advanced permissions & workflows
- 📋 Data import/export automation
- 📋 Custom fields & forms
- 📋 White-label capabilities
- 📋 API marketplace
- 📋 Advanced integrations (accounting, shipping)

For detailed roadmap and progress tracking, see [PROJECT-STATUS.md](PROJECT-STATUS.md)

---

## 🔐 Security

MERIDIEN implements enterprise-grade security practices:

- **Password Hashing:** bcrypt with cost factor 10
- **JWT Authentication:** Short-lived tokens (24h) with refresh mechanism
- **Tenant Isolation:** All queries filtered by tenant_id
- **SQL Injection Prevention:** GORM prepared statements
- **Input Validation:** Comprehensive validation at handler level
- **Soft Deletes:** Data retention with deleted_at timestamps
- **CORS Configuration:** Environment-specific allowed origins
- **Environment Variables:** Sensitive config via .env files

---

## 🤝 Contributing

This is a proprietary project. If you have suggestions or find bugs, please contact the project maintainer.

### Development Workflow

1. Follow the coding standards in [docs/DEVELOPMENT-RULES.md](docs/DEVELOPMENT-RULES.md)
2. Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
3. Test thoroughly before committing
4. Update documentation as needed

---

## 📝 License

Copyright © 2024-2025 MERIDIEN. All rights reserved.

This project is proprietary software. Unauthorized copying, modification, or distribution is strictly prohibited.

---

## 📧 Contact

**Muhammad Ali**

- GitHub: [@mu7ammad-3li](https://github.com/mu7ammad-3li/)
- Email: muhammad.3lii2@gmail.com
- LinkedIn: [linkedin.com/in/muhammad-3lii](https://linkedin.com/in/muhammad-3lii)

**Project Link**: [https://github.com/mu7ammad-3li/MERIDIEN](https://github.com/mu7ammad-3li/MERIDIEN)

---

## 🙏 Acknowledgments

- [Go](https://golang.org/) - High-performance backend language
- [Gin](https://gin-gonic.com/) - Fast HTTP web framework for Go
- [Flutter](https://flutter.dev/) - Beautiful native applications from a single codebase
- [PostgreSQL](https://www.postgresql.org/) - Powerful open-source relational database
- [GORM](https://gorm.io/) - Fantastic ORM library for Go
- [Riverpod](https://riverpod.dev/) - Reactive state management for Flutter
- [Freezed](https://pub.dev/packages/freezed) - Code generation for immutable classes

---

<div align="center">

**Built with ❤️ by [Muhammad Ali](https://github.com/mu7ammad-3li/)**

*Navigate Your Business to Success*

[⬆ Back to Top](#-meridien)

</div>
