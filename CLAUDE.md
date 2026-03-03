# Claude Code Development Guide

Quick reference for AI-assisted development on MERIDIEN.

## Project Overview

**MERIDIEN** - Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine  
Multi-tenant SaaS for retail operations supporting 100+ concurrent businesses.

## Stack

**Backend:** Go 1.21+ · Gin · GORM · PostgreSQL 15+ · JWT  
**Frontend:** Flutter 3.24+ · Riverpod · Dio · Freezed  
**Architecture:** Clean architecture with multi-tenant isolation

## Architecture

### Backend (Clean Architecture)
```
HTTP → Handler → Service → Repository → Model → Database
```

### Frontend (Feature-First)
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
- Unique constraints include tenant_id

## Commands

### Backend
```bash
cd backend
./scripts/start-server.sh      # Start server
./scripts/run-migrations.sh    # Run migrations
./scripts/create-database.sh   # Create database
curl http://localhost:8080/health  # Test
```

### Frontend
```bash
cd frontend
flutter run -d chrome          # Run web
flutter pub run build_runner build --delete-conflicting-outputs  # Generate models
flutter analyze                # Lint
flutter build web              # Production build
```

## Code Standards

### Go Naming
- **Files:** `snake_case.go`
- **Packages:** lowercase
- **Types/Structs:** `PascalCase`
- **Functions:** `PascalCase` (exported), `camelCase` (unexported)
- **Variables:** `camelCase`

### Dart Naming
- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables/Functions:** `camelCase`
- **Private:** `_camelCase`

### Database
- **Tables:** `snake_case`, plural (`customers`, `order_items`)
- **Columns:** `snake_case`
- **Primary keys:** `id` (UUID)
- **Foreign keys:** `{table}_id` (`tenant_id`, `customer_id`)
- **Timestamps:** `created_at`, `updated_at`, `deleted_at`

## API Design

### Response Format
```json
{
  "success": true,
  "message": "Operation completed",
  "data": {...}
}
```

### Error Format
```json
{
  "success": false,
  "error": "Error message",
  "message": "Detailed description"
}
```

### Pagination
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

## Security

1. **Passwords:** bcrypt hash (cost 10)
2. **SQL:** GORM prepared statements only
3. **Input:** Validate all inputs
4. **JWT:** 24h expiry, include tenant_id
5. **Tenant Isolation:** Every query filters by tenant_id
6. **Soft Deletes:** Use `deleted_at`, never hard delete

## Project Status

**Phase 1 MVP:** ✅ Complete (100%)  
**Phase 2:** 🚧 In Progress (35%)

### Implemented (Phase 1)

**Authentication** ✅
- Backend: `/api/v1/auth/*` (register, login, refresh, me, logout)
- Frontend: Login & Register screens

**Customer Management** ✅
- Backend: `/api/v1/customers/*` (CRUD + search + filters)
- Frontend: List, Detail, Create/Edit screens
- Features: Multi-level addresses, business customers, financials

**Product Management** ✅
- Backend: `/api/v1/products/*` (CRUD + categories + inventory)
- Frontend: List, Detail, Create/Edit screens
- Features: SKU/barcode, categories, low stock alerts

**Order Management** ✅
- Backend: `/api/v1/orders/*` (CRUD + workflow + payments)
- Frontend: List, Detail, Create screens
- Features: 7-state workflow, auto order numbers, inventory integration

**Internationalization** ✅
- Arabic & English with RTL support
- 34+ translations

### Order Status Workflow
```
draft → pending → confirmed → processing → shipped → delivered
  ↓        ↓          ↓           ↓          ↓
  └────────┴──────────┴───────────┴──────────┴→ cancelled
```

### Next Phase (Phase 2)
1. Multi-user & RBAC
2. Automated testing (80% backend, 70% frontend)
3. Enhanced security (Redis, rate limiting)
4. CI/CD pipeline
5. Reports module
6. Invoice generation

## Key Statistics
- **API Endpoints:** 26
- **Database Tables:** 8 (multi-tenant)
- **Frontend Screens:** 14
- **Backend Files:** 29 Go files
- **Frontend Files:** 28+ Dart files
- **Test Coverage:** 0% automated, 100% manual

## Documentation

### Quick Reference
- [Getting Started](docs/GETTING-STARTED.md) - Setup guide
- [Project Status](docs/PROJECT-STATUS.md) - Current status
- [Architecture](docs/ARCHITECTURE.md) - Decisions and schema

### Core Docs
- [Brand Guidelines](docs/MERIDIEN-BRAND.md)
- [Development Rules](docs/DEVELOPMENT-RULES.md)
- [MVP Analysis](docs/mvp-analysis.md)

### Technical Docs
- [API Documentation](backend/API-DOCUMENTATION.md)
- [Backend Setup](docs/guides/BACKEND-SETUP.md)

### Module Completion
- [Authentication](docs/completed/AUTHENTICATION-COMPLETE.md)
- [Customers](docs/completed/CUSTOMER-MODULE-COMPLETE.md)
- [Products](docs/completed/PRODUCT-MODULE-COMPLETE.md)
- [Orders Backend](docs/completed/ORDER-MODULE-COMPLETE.md)
- [Orders Frontend](docs/completed/ORDER_MODULE_COMPLETE.md)

## Testing

### Backend
```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"tenant_slug":"demo","email":"admin@meridien.com","password":"Admin123"}' \
  | jq -r '.token')

# Use token
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/customers
```

### Frontend
Manual testing via browser and Flutter DevTools

## Important Notes

1. **Dio over Retrofit:** Frontend uses Dio (not Retrofit) for HTTP
2. **Freezed Required:** All Flutter models use Freezed
3. **Demo Tenant:** Default slug: `demo`, email: `admin@meridien.com`, password: `Admin123`
4. **Port 8080:** Backend default port
5. **UUID Primary Keys:** All tables use UUID

## Git Workflow

- Main branch: `main`
- Feature branches: `feature/{feature-name}`
- Bug fixes: `fix/{bug-description}`
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`

---

**Last Updated:** December 27, 2025  
**Version:** Phase 1 MVP Complete (100%)  
**Next:** Phase 2 - Production Ready
