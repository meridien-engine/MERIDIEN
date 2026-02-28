# MERIDIEN

**Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine**

Enterprise SaaS platform for retail operations and inventory management. Built with Go (backend) and Flutter (cross-platform frontend).

[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)](https://golang.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B.svg)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)

## Status

**Phase 1 MVP:** ✅ Complete (100%)  
**Current Focus:** Phase 2 - Production Ready (35%)

### Implemented
- Multi-tenant architecture with JWT auth
- Customer management (CRM, addresses, financials)
- Product catalog (SKU, categories, inventory)
- Order processing (7-state workflow, payments)
- Internationalization (AR/EN, RTL support)

### Key Metrics
- 26 RESTful API endpoints
- 8 multi-tenant database tables
- 14 responsive Flutter screens
- Zero test coverage (manual testing only)

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

### Test Credentials
- Tenant: `demo`
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
Repository Layer
    ↓
GORM Models
    ↓
PostgreSQL (Multi-tenant)
```

**Multi-Tenancy:** Every table includes `tenant_id`. All queries filtered by tenant. JWT contains tenant context.

## Project Structure

```
backend/
├── handlers/          # HTTP layer
├── services/          # Business logic
├── repositories/      # Data access
├── models/            # GORM entities
├── middleware/        # Auth, CORS, tenant
└── migrations/        # Database migrations

frontend/
├── core/              # Theme, constants, utils
├── data/              # Models, repositories
├── features/          # Feature modules (auth, customers, products, orders)
├── routes/            # Navigation
└── shared/            # Shared widgets
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
- `POST /api/v1/auth/login` - JWT authentication
- `GET /api/v1/customers` - List with pagination
- `GET /api/v1/products` - Filter by category, stock
- `POST /api/v1/orders` - Create with line items
- `POST /api/v1/orders/:id/ship` - Update status, deduct inventory

Full API docs: [backend/API-DOCUMENTATION.md](backend/API-DOCUMENTATION.md)

## Development

### Backend Commands
```bash
make dev          # Start with hot reload
make test         # Run tests
make migrate-up   # Run migrations
make build        # Production build
```

### Frontend Commands
```bash
flutter run                    # Development
flutter test                   # Run tests
flutter build web             # Production web build
flutter pub run build_runner build --delete-conflicting-outputs  # Generate models
```

### Integration tests (RLS)

Run the RLS enforcement integration test locally to verify database row-level security behavior.

- Requirements: a running Postgres instance with the project migrations applied (see `./scripts/run-migrations.sh`). The test will skip if it cannot connect using the configured DSN.
- Configure a DSN via `MERIDIEN_DB_DSN` (optional). Example DSN:

```bash
export MERIDIEN_DB_DSN="user=postgres dbname=meridien_dev sslmode=disable"
```

- Run the single integration test (skips when DB access/auth fails):

```bash
cd backend
go test ./internal/integration -run TestRLS_Enforcement -v
```

- Notes:
    - The test inserts temporary tenants and orders inside a transaction and uses `SET LOCAL app.current_tenant` to verify access.
    - If your Postgres user requires a password, set the DSN accordingly (for example, `user=postgres password=secret dbname=meridien_dev sslmode=disable`).
    - The test cleans up via transaction rollback so it is safe to run against a dev database.


### Conventions

**Go:** snake_case files, PascalCase exports, camelCase unexported  
**Dart:** snake_case files, PascalCase classes, camelCase variables  
**Database:** snake_case tables/columns, plural tables, UUID primary keys

## Roadmap

### Phase 2 (In Progress - 35%)
- [ ] RBAC and multi-user support
- [ ] Automated testing (80% backend, 70% frontend)
- [ ] Enhanced security (Redis, rate limiting)
- [ ] CI/CD pipeline
- [ ] Invoice generation (PDF)
- [ ] Advanced reporting

### Phase 3 (Planned)
- [ ] Advanced inventory (batch tracking, serial numbers)
- [ ] Supplier and purchase order management
- [ ] Business intelligence dashboards
- [ ] Mobile app optimization
- [ ] Integration APIs (Shopify, WooCommerce)

## Documentation

- [Getting Started](GETTING-STARTED.md) - Setup guide
- [Project Status](PROJECT-STATUS.md) - Detailed status and metrics
- [Development Rules](docs/DEVELOPMENT-RULES.md) - Coding standards
- [API Documentation](backend/API-DOCUMENTATION.md) - Complete API reference
- [Brand Guidelines](docs/MERIDIEN-BRAND.md) - Visual identity

## Security

- bcrypt password hashing (cost 10)
- JWT with 24h expiry and refresh tokens
- Strict tenant isolation on all queries
- GORM prepared statements (SQL injection prevention)
- Input validation at handler level
- Soft deletes for data retention

## License

Proprietary. Copyright © 2024-2025 MERIDIEN.

## Contact

**Muhammad Ali**  
[GitHub](https://github.com/mu7ammad-3li/) · [LinkedIn](https://linkedin.com/in/muhammad-3lii) · muhammad.3lii2@gmail.com
