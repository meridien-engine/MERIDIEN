# MERIDIEN

**Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine**

Enterprise SaaS platform for retail operations and inventory management. Built with Go (backend) and Flutter (cross-platform frontend).

[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)](https://golang.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B.svg)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-7+-DC382D.svg)](https://redis.io/)

---

## What It Does

MERIDIEN manages the full retail operations cycle across isolated business tenants:

- **Auth** — JWT login with workspace discovery, role-based access (owner / operator / collector)
- **Customers** — CRM with multi-level addresses, business profiles, credit limits
- **Products** — SKU/barcode catalog, hierarchical categories, inventory tracking, low-stock alerts
- **Orders** — 7-state lifecycle (draft → delivered), line items, payment tracking, shipping fees
- **Locations** — City/zone shipping configuration with fee management
- **Couriers** — Courier catalog, cash-on-delivery reconciliation reports

---

## Tech Stack

| Layer | Tech |
|---|---|
| Backend | Go 1.21+, Gin, GORM |
| Frontend | Flutter 3.24+, Riverpod, Dio, Freezed |
| Database | PostgreSQL 15+ with Row-Level Security |
| Cache | Redis 7+ (token blacklist, rate limiting) |
| Auth | JWT HS256, 24h expiry, JTI-based revocation |

---

## Quick Start

### Prerequisites
- Go 1.21+, Flutter 3.24+, PostgreSQL 15+
- Redis 7+ *(optional — app runs without it)*

### Backend

```bash
cd backend
./scripts/create-database.sh
./scripts/run-migrations.sh
./scripts/start-server.sh       # starts on :8080
```

**Environment** (`backend/configs/.env`):

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=meridien_dev

JWT_SECRET=change-this-in-production
JWT_EXPIRATION_HOURS=24

# Optional
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
```

### Frontend

```bash
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

### Demo credentials

Email: `admin@meridien.com` · Password: `Admin123`

The login screen uses workspace discovery — enter credentials, then select your workspace from the list.

---

## Architecture

```
Flutter (Web / Mobile / Desktop)
    ↓  REST API
Gin Router  ←── CORS, rate limiting (Redis, fail-open)
    ↓
Auth Middleware  ←── JWT validation + blacklist check (Redis, fail-open)
    ↓
Handlers → Services → Repositories
    ↓             ↓
    └─────────────┴── tenantTx() → SET LOCAL app.current_tenant
                                          ↓
                                   PostgreSQL (RLS enforced)
```

Every table carries `tenant_id`. Queries run inside transactions that set the RLS session variable, enforcing strict data isolation at the database level.

---

## Project Structure

```
backend/
├── cmd/server/          # Entry point
├── cmd/import_bosta/    # Bosta CSV import CLI
└── internal/
    ├── cache/           # Redis client, token blacklist
    ├── config/          # Config loading (env / .env file)
    ├── handlers/        # HTTP layer
    ├── services/        # Business logic
    ├── repositories/    # Data access — RLS-aware via tenantTx()
    ├── models/          # GORM entities
    ├── middleware/       # Auth, rate limit, tenant
    └── router/          # Route registration

frontend/
├── core/                # Theme, constants, role provider
├── data/                # Freezed models, repositories
├── features/
│   ├── auth/            # Login (workspace discovery), register
│   ├── customers/
│   ├── products/
│   ├── orders/
│   ├── locations/
│   └── couriers/
├── routes/              # Role-gated navigation
└── shared/              # Reusable widgets
```

---

## API

All responses follow a standard envelope:

```json
{ "success": true, "message": "...", "data": {} }
```

Paginated lists include a `meta` object: `{ "total", "page", "per_page", "total_pages" }`.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/login` | — | Workspace discovery or direct login |
| POST | `/api/v1/auth/logout` | JWT | Revoke token |
| POST | `/api/v1/auth/refresh` | JWT | Refresh JWT |
| CRUD | `/api/v1/customers` | JWT | Customer management |
| CRUD | `/api/v1/products` | JWT | Product catalog |
| CRUD | `/api/v1/orders` | JWT | Order management |
| POST | `/api/v1/orders/:id/{action}` | JWT + role | Status transitions |
| CRUD | `/api/v1/locations` | JWT | Shipping zones |
| GET | `/api/v1/reports/courier-reconciliation` | JWT + owner | Cash reconciliation |

Full reference: [backend/API-DOCUMENTATION.md](backend/API-DOCUMENTATION.md)

---

## Security

- bcrypt password hashing (cost 10)
- JWT HS256, 24h expiry, unique JTI per token
- Token revocation on logout via Redis (JTI blacklisted with TTL)
- Rate limiting on auth endpoints: 10 req/min per IP (Redis, fail-open)
- PostgreSQL RLS on all tenant tables (`FORCE ROW LEVEL SECURITY`)
- `SET LOCAL app.current_tenant` scoped to each transaction
- GORM prepared statements — no raw SQL
- Soft deletes on all entities

---

## Development

```bash
# Backend
cd backend
go build ./...                             # Verify build
go test ./...                              # Run tests
./scripts/run-migrations.sh               # Apply migrations

# RLS integration test (requires live DB)
export MERIDIEN_DB_DSN="user=postgres dbname=meridien_dev sslmode=disable"
go test ./internal/integration -run TestRLS_Enforcement -v

# Bosta CSV import
go run cmd/import_bosta/main.go --file pricing.csv --tenant <tenant-id>

# Frontend
cd frontend
flutter analyze
flutter build web
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Documentation

- [Project Status](PROJECT-STATUS.md) — Progress, roadmap, known gaps
- [Getting Started](GETTING-STARTED.md) — Detailed setup guide
- [API Documentation](backend/API-DOCUMENTATION.md) — Full endpoint reference
- [Development Rules](docs/DEVELOPMENT-RULES.md) — Coding standards
- [Brand Guidelines](docs/MERIDIEN-BRAND.md) — Visual identity

---

## License

Proprietary. Copyright © 2024-2025 MERIDIEN.

**Muhammad Ali** — [GitHub](https://github.com/mu7ammad-3li/) · [LinkedIn](https://linkedin.com/in/muhammad-3lii) · muhammad.3lii2@gmail.com
