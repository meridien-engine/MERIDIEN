# MERIDIEN

**Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine**

Enterprise SaaS platform for retail operations and inventory management. Built with Go (backend) and Flutter (cross-platform frontend).

[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)](https://golang.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B.svg)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)

## Status

**Phase 1 MVP:** ✅ Complete (100%)
**Current Focus:** Phase 2 - Production Ready (55%)

### Implemented
- Multi-tenant architecture with JWT auth and workspace discovery login
- Customer management (CRM, addresses, financials)
- Product catalog (SKU, categories, inventory)
- Order processing (7-state workflow, payments, shipping fees)
- Location management (city/zone shipping zones)
- Courier management and cash reconciliation reports
- Row-level security (RLS) enforcement on all tenant tables
- Role-based UI guards (owner / operator / collector)
- Internationalization (AR/EN, RTL support)

### Key Metrics
- 33 RESTful API endpoints
- 8+ multi-tenant database tables
- 17 Flutter screens
- RLS enforced at database level via PostgreSQL policies

## Tech Stack

**Backend:** Go 1.21+ · Gin · GORM · PostgreSQL 15+ · JWT
**Frontend:** Flutter 3.24+ · Riverpod · Dio · Freezed
**Architecture:** Clean architecture with tenant isolation

## Quick Start

### Prerequisites
- Go 1.21+
- Flutter 3.24+
- PostgreSQL 15+

### Backend

```bash
cd backend

# Setup database
./scripts/create-database.sh
./scripts/run-migrations.sh

# Start server (localhost:8080)
./scripts/start-server.sh
```

### Frontend

```bash
cd frontend

# Install and generate models
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run web
flutter run -d chrome
```

### Login

The login screen uses a **workspace discovery** flow — no need to know your tenant slug upfront:

1. Enter your email and password
2. Choose your workspace from the list
3. You're in

**Demo credentials:**
- Email: `admin@meridien.com`
- Password: `Admin123`

## Architecture

```
Flutter (Web/Mobile/Desktop)
    ↓ REST API
Gin HTTP Handlers
    ↓
Business Services
    ↓
Repository Layer  ←── tenantTx() sets RLS session variable
    ↓
GORM Models
    ↓
PostgreSQL (RLS-enforced, multi-tenant)
```

**Multi-Tenancy:** Every table includes `tenant_id`. All queries are wrapped in a transaction that sets `SET LOCAL app.current_tenant` to satisfy PostgreSQL RLS policies. JWT carries the tenant context.

## Project Structure

```
backend/
├── cmd/
│   ├── server/          # Main server entry point
│   └── import_bosta/    # Bosta CSV import CLI
├── handlers/            # HTTP layer
├── services/            # Business logic
├── repositories/        # Data access (RLS-aware via tenantTx)
├── models/              # GORM entities
├── middleware/          # Auth, CORS, tenant
└── migrations/          # Database migrations

frontend/
├── core/                # Theme, constants, providers (role_provider)
├── data/                # Models, repositories
├── features/
│   ├── auth/            # Login (workspace discovery), register
│   ├── customers/       # Customer management
│   ├── products/        # Product catalog
│   ├── orders/          # Order processing
│   ├── locations/       # City/zone shipping configuration
│   └── couriers/        # Courier management + reconciliation
├── routes/              # Navigation (role-gated routes)
└── shared/              # Shared widgets
```

## API

**Standard Response:**
```json
{
  "success": true,
  "message": "Operation completed",
  "data": {...}
}
```

**Endpoints:**
- `POST /api/v1/auth/login` — workspace discovery or direct JWT login
- `GET /api/v1/customers` — list with pagination and filters
- `GET /api/v1/products` — filter by category, stock level
- `POST /api/v1/orders` — create with line items and shipping fee
- `POST /api/v1/orders/:id/ship` — advance status, deduct inventory
- `GET /api/v1/locations` — city/zone shipping configuration
- `GET /api/v1/reports/courier-reconciliation` — cash reconciliation per courier

Full API docs: [backend/API-DOCUMENTATION.md](backend/API-DOCUMENTATION.md)

## Development

### Backend Commands
```bash
cd backend
go run cmd/server/main.go     # Start server
./scripts/run-migrations.sh   # Apply migrations
go build ./...                # Verify build
```

### Frontend Commands
```bash
flutter run -d chrome                                                    # Development
flutter build web                                                        # Production build
flutter pub run build_runner build --delete-conflicting-outputs          # Regenerate models
flutter analyze                                                          # Lint
```

### Integration Tests (RLS)

Verify database row-level security enforcement:

```bash
export MERIDIEN_DB_DSN="user=postgres dbname=meridien_dev sslmode=disable"
cd backend
go test ./internal/integration -run TestRLS_Enforcement -v
```

The test inserts temporary data inside a transaction with `SET LOCAL app.current_tenant` and verifies isolation. Skipped automatically if `MERIDIEN_DB_DSN` is not set.

### Bosta CSV Import

Seed locations and couriers from a Bosta pricing export:

```bash
cd backend
go run cmd/import_bosta/main.go --file pricing.csv --tenant <tenant-id>
```

### Conventions

**Go:** snake_case files · PascalCase exports · camelCase unexported
**Dart:** snake_case files · PascalCase classes · camelCase variables
**Database:** snake_case tables/columns · plural tables · UUID primary keys

## Roadmap

### Phase 2 (In Progress — 55%)
- [x] Location and courier management
- [x] RLS enforcement at database level
- [x] Workspace discovery login flow
- [x] Role-based UI guards
- [ ] Full RBAC (backend enforcement)
- [ ] Automated testing (target: 80% backend, 70% frontend)
- [ ] Redis session cache and rate limiting
- [ ] Invoice generation (PDF)
- [ ] Advanced reporting dashboard

### Phase 3 (Planned)
- [ ] Advanced inventory (batch tracking, serial numbers)
- [ ] Supplier and purchase order management
- [ ] Business intelligence dashboards
- [ ] Mobile app optimization
- [ ] Integration APIs (Shopify, WooCommerce)

## Security

- bcrypt password hashing (cost 10)
- JWT with 24h expiry and refresh tokens
- PostgreSQL RLS policies on all tenant tables (`FORCE ROW LEVEL SECURITY`)
- `SET LOCAL app.current_tenant` scoped to each transaction
- GORM prepared statements (SQL injection prevention)
- Input validation at handler level
- Soft deletes for data retention

## Documentation

- [Getting Started](GETTING-STARTED.md) — Setup guide
- [Project Status](PROJECT-STATUS.md) — Detailed status and metrics
- [Development Rules](docs/DEVELOPMENT-RULES.md) — Coding standards
- [API Documentation](backend/API-DOCUMENTATION.md) — Complete API reference
- [Brand Guidelines](docs/MERIDIEN-BRAND.md) — Visual identity

## License

Proprietary. Copyright © 2024-2025 MERIDIEN.

## Contact

**Muhammad Ali**
[GitHub](https://github.com/mu7ammad-3li/) · [LinkedIn](https://linkedin.com/in/muhammad-3lii) · muhammad.3lii2@gmail.com
