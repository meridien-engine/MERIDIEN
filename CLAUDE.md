# MERIDIEN - Claude Code Development Guide

## Project Overview

**MERIDIEN** (Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine)
- **Tagline:** Navigate Your Business to Success
- **Purpose:** Multi-tenant business management SaaS for retail/inventory operations
- **Target:** 100+ concurrent businesses

## Technology Stack

### Backend (`backend/`)
- **Language:** Go 1.21+
- **Framework:** Gin (HTTP router)
- **Database:** PostgreSQL 15+ with GORM ORM
- **Auth:** JWT with refresh tokens (golang-jwt/jwt/v5)
- **Config:** Viper + godotenv
- **UUID:** google/uuid
- **Decimals:** shopspring/decimal

### Frontend (`frontend/`)
- **Framework:** Flutter 3.x (Web + Mobile)
- **State Management:** Riverpod (flutter_riverpod)
- **HTTP Client:** Dio (NOT Retrofit - migrated for stability)
- **Models:** Freezed + json_serializable
- **Storage:** SharedPreferences for JWT

## Architecture Patterns

### Backend - Clean Architecture
```
HTTP Request → Handler → Service → Repository → Model → Database
```

### Frontend - Feature-First Architecture
```
lib/
├── core/           # Constants, themes, utils
├── data/           # Models, repositories
├── features/       # Feature modules (auth, customers, products, orders)
├── routes/         # Navigation
└── shared/         # Shared widgets
```

### Multi-Tenancy
- Every table has `tenant_id` column
- JWT contains `tenant_id` claim
- All queries MUST filter by tenant_id
- Unique constraints include tenant_id (e.g., email unique per tenant)

## Common Commands

### Backend
```bash
# Start server
cd backend && ./scripts/start-server.sh

# Run migrations
cd backend && ./scripts/run-migrations.sh

# Create database
cd backend && ./scripts/create-database.sh

# Test API
curl http://localhost:8080/health
```

### Frontend
```bash
# Run development
cd frontend && flutter run -d chrome

# Generate models (Freezed)
cd frontend && flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
cd frontend && flutter analyze

# Build for production
cd frontend && flutter build web
```

## Code Standards

### Go Naming Conventions
- **Files:** `snake_case.go`
- **Packages:** lowercase, single word
- **Types/Structs:** `PascalCase`
- **Functions/Methods:** `PascalCase` (exported), `camelCase` (unexported)
- **Variables:** `camelCase`
- **Constants:** `PascalCase` or `SCREAMING_SNAKE_CASE`

### Flutter/Dart Naming Conventions
- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables/Functions:** `camelCase`
- **Constants:** `camelCase` or `SCREAMING_SNAKE_CASE`
- **Private:** prefix with `_`

### Database Conventions
- **Tables:** `snake_case`, plural (e.g., `customers`, `order_items`)
- **Columns:** `snake_case`
- **Primary keys:** `id` (UUID)
- **Foreign keys:** `{table}_id` (e.g., `tenant_id`, `customer_id`)
- **Timestamps:** `created_at`, `updated_at`, `deleted_at`

## API Design

### Standard Response Format
```json
{
  "success": true,
  "message": "Operation completed",
  "data": { ... }
}
```

### Error Response Format
```json
{
  "success": false,
  "error": "Error message",
  "message": "Detailed description"
}
```

### Paginated Response
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

### Endpoints Pattern
- `GET /api/v1/{resource}` - List with pagination
- `GET /api/v1/{resource}/:id` - Get by ID
- `POST /api/v1/{resource}` - Create
- `PUT /api/v1/{resource}/:id` - Update
- `DELETE /api/v1/{resource}/:id` - Soft delete

## Security Requirements

1. **Passwords:** Always hash with bcrypt (cost 10)
2. **SQL:** Use GORM prepared statements, NEVER raw SQL concatenation
3. **Input:** Validate all inputs at handler level
4. **JWT:** Short expiry (24h), include tenant_id in claims
5. **Tenant Isolation:** Every query MUST filter by tenant_id
6. **Soft Deletes:** Never hard delete, use `deleted_at`

## Project Status

**Current Phase:** Phase 1 MVP - ✅ **COMPLETE** (100%)  
**Next Phase:** Phase 2 - Production Ready (Target: 35% by Month 4)  
**Last Updated:** December 27, 2025

For detailed project status, roadmap, and metrics, see [PROJECT-STATUS.md](PROJECT-STATUS.md)

### Implemented Modules (Phase 1)

#### ✅ Authentication Module (Week 1)
- **Backend:** `/api/v1/auth/*` (register, login, me, logout, refresh)
- **Frontend:** Login & Register screens
- **Status:** Production-ready

#### ✅ Customer Management (Week 2)
- **Backend:** `/api/v1/customers/*` (CRUD + search + filters + pagination)
- **Frontend:** List, Detail, Create/Edit screens
- **Features:** Multi-level addresses, business customers, financial tracking
- **Status:** Production-ready

#### ✅ Product Management (Week 3)
- **Backend:** `/api/v1/products/*` (CRUD + categories + inventory)
- **Frontend:** List, Detail, Create/Edit screens
- **Features:** SKU/barcode, hierarchical categories, low stock alerts
- **Status:** Production-ready

#### ✅ Order Management (Week 4)
- **Backend:** `/api/v1/orders/*` (CRUD + status workflow + payments)
- **Frontend:** List, Detail, Create screens with payment recording
- **Features:** Auto order numbers, 7-state workflow, inventory integration
- **Status:** Production-ready

#### ✅ Dashboard (Basic)
- **Frontend:** Dashboard screen with quick actions
- **Status:** Basic implementation

### Order Status Workflow
```
draft → pending → confirmed → processing → shipped → delivered
  ↓        ↓          ↓           ↓          ↓
  └────────┴──────────┴───────────┴──────────┴→ cancelled
```

### Key Statistics
- **API Endpoints:** 26 endpoints
- **Database Tables:** 8 tables (multi-tenant)
- **Frontend Screens:** 14 screens
- **Backend Files:** 29 Go files
- **Frontend Files:** 28+ Dart files
- **Test Coverage:** 0% (automated), 100% (manual)

### Next Phase Priorities (Phase 2)
1. **Multi-User & RBAC** - Critical for production
2. **Automated Testing** - 80% backend, 70% frontend coverage
3. **Enhanced Security** - Redis, rate limiting, password reset
4. **DevOps Setup** - CI/CD, monitoring, backups
5. **Reports Module** - Analytics, charts, exports
6. **Invoice Generation** - PDF generation, email delivery

## Testing

### Backend API Testing
```bash
# Login and get token
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"tenant_slug":"demo","email":"admin@meridien.com","password":"Admin123"}' \
  | jq -r '.token')

# Use token for protected endpoints
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/customers
```

### Frontend Testing
- Manual testing via browser
- Unit tests planned for Production phase

## Documentation Structure

### Quick Reference
- **Project Status:** [PROJECT-STATUS.md](PROJECT-STATUS.md) - Current status, roadmap, metrics
- **Getting Started:** [GETTING-STARTED.md](GETTING-STARTED.md) - Quick start guide
- **Implementation Checklist:** [IMPLEMENTATION-CHECKLIST.md](IMPLEMENTATION-CHECKLIST.md) - Phase tracking

### Core Documentation
- **Brand Guidelines:** [docs/MERIDIEN-BRAND.md](docs/MERIDIEN-BRAND.md)
- **Development Rules:** [docs/DEVELOPMENT-RULES.md](docs/DEVELOPMENT-RULES.md)
- **MVP Analysis:** [docs/mvp-analysis.md](docs/mvp-analysis.md)

### Technical Documentation
- **API Documentation:** [backend/API-DOCUMENTATION.md](backend/API-DOCUMENTATION.md)
- **Backend Setup:** [docs/guides/BACKEND-SETUP.md](docs/guides/BACKEND-SETUP.md)

### Module Completion Docs
- **Authentication:** [docs/completed/AUTHENTICATION-COMPLETE.md](docs/completed/AUTHENTICATION-COMPLETE.md)
- **Customers:** [docs/completed/CUSTOMER-MODULE-COMPLETE.md](docs/completed/CUSTOMER-MODULE-COMPLETE.md)
- **Products:** [docs/completed/PRODUCT-MODULE-COMPLETE.md](docs/completed/PRODUCT-MODULE-COMPLETE.md)
- **Orders (Backend):** [docs/completed/ORDER-MODULE-COMPLETE.md](docs/completed/ORDER-MODULE-COMPLETE.md)
- **Orders (Frontend):** [docs/completed/ORDER_MODULE_COMPLETE.md](docs/completed/ORDER_MODULE_COMPLETE.md)
- **Flutter Setup:** [docs/completed/FLUTTER-SETUP-COMPLETE.md](docs/completed/FLUTTER-SETUP-COMPLETE.md)
- **Backend Setup:** [docs/completed/BACKEND-SETUP-COMPLETE.md](docs/completed/BACKEND-SETUP-COMPLETE.md)

## Important Notes

1. **Dio over Retrofit:** Frontend uses Dio direct implementation (not Retrofit) due to version compatibility issues
2. **Freezed Required:** All Flutter models use Freezed for immutability
3. **Demo Tenant:** Default tenant slug is "demo" with admin@meridien.com / Admin123
4. **Port 8080:** Backend runs on localhost:8080 by default
5. **UUID Primary Keys:** All tables use UUID, not auto-increment integers

## Git Workflow

- Main branch: `main`
- Feature branches: `feature/{feature-name}`
- Bug fixes: `fix/{bug-description}`
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`

---

*Last Updated: December 27, 2025*  
*Project Version: Phase 1 MVP Complete (100%)*  
*Next Milestone: Phase 2 - Production Ready*
