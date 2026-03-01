# Project Status

**Last Updated:** March 1, 2026
**Current Phase:** Phase 2 — Production Ready

---

## Phase 2 Progress

| Area | Status |
|------|--------|
| Multi-tenant isolation (RLS + tenantTx) | ✅ Complete |
| RBAC (owner / operator / collector) | ✅ Complete |
| Workspace discovery login | ✅ Complete |
| Location & courier management | ✅ Complete |
| Courier cash reconciliation report | ✅ Complete |
| Redis token blacklist (real logout) | ✅ Complete |
| Redis rate limiting (auth endpoints) | ✅ Complete |
| Automated testing (80% backend target) | ❌ Pending |
| CI/CD pipeline (GitHub Actions) | ❌ Pending |
| Invoice generation (PDF) | ❌ Pending |
| Advanced reporting & analytics | ❌ Pending |
| Password reset flow | ❌ Pending |
| Email verification | ❌ Pending |

---

## Phase 1 — Complete ✅

### Authentication
- JWT HS256, 24h expiry, JTI per token, bcrypt passwords
- Workspace discovery: email/password → list of matching tenants
- Endpoints: `POST /auth/register`, `/auth/login`, `/auth/refresh`, `GET /auth/me`, `POST /auth/logout`

### Customer Management
- Full CRUD with multi-level addresses, business profiles (company, tax ID), credit limits
- Search and filters (name, email, status, city)
- Endpoints: `/api/v1/customers/*`

### Product Management
- SKU/barcode, hierarchical categories, inventory with low-stock alerts
- Multi-level pricing (cost, selling, discount)
- Endpoints: `/api/v1/products/*`

### Order Management
- 7-state workflow: `draft → pending → confirmed → processing → shipped → delivered` (+ `cancelled`)
- Auto-generated order numbers (`ORD-YYYYMMDD-XXXX`)
- Line items with product snapshots, payment tracking, shipping fees, inventory deduction on ship
- Endpoints: `/api/v1/orders/*` (11 endpoints)

### Internationalization
- Arabic and English with RTL layout, Tajawal font, 34+ translations

---

## Phase 2 — In Progress

### Completed

**Multi-Tenant & RBAC**
- Per-transaction `SET LOCAL app.current_tenant` in all repositories via `tenantTx()`
- PostgreSQL RLS policies on all tenant tables (migration `000006_enable_rls`)
- RBAC roles enforced at handler level; owner bypasses all role checks
- 14/14 RBAC unit tests passing

**Location & Courier Management**
- Full CRUD for city/zone/shipping_fee (`/api/v1/locations`)
- Courier catalog per tenant
- Cash reconciliation report: `GET /api/v1/reports/courier-reconciliation` (owner-only)

**Redis Security**
- Token blacklist: JTI stored in Redis with TTL on logout; checked in `RequireAuth`
- Rate limiting: fixed-window, 10 req/min per IP on auth endpoints
- Fail-open: if Redis is unavailable, app runs normally without these protections
- New packages: `internal/cache/` (redis.go, token_blacklist.go), `internal/middleware/rate_limit.go`

### Pending

**Automated Testing**
- Current: 14 RBAC unit tests; 1 RLS integration test
- Target: 80% backend coverage, 70% frontend widget tests

**DevOps**
- Docker Compose (partial)
- CI/CD via GitHub Actions
- Monitoring (Prometheus / Grafana)
- Automated backups

**Invoice Generation**
- PDF generation with customizable templates
- Email delivery

**Advanced Reporting**
- Revenue analytics, product performance, customer insights
- CSV / Excel export

**Auth Enhancements**
- Password reset flow
- Email verification

---

## Database Schema

```
tenants        — multi-tenant root
users          — authentication, roles
customers      — CRM with addresses
categories     — hierarchical product categories
products       — inventory with SKU/barcode
orders         — order lifecycle, logistics fields, optimistic locking
order_items    — line items with product snapshots
payments       — payment tracking
audit_logs     — immutable trail for status and price changes
couriers       — tenant courier catalog
locations      — cities/zones with shipping fees
```

All tables: `id (UUID)`, `tenant_id`, `created_at`, `updated_at`, `deleted_at`

---

## Code Metrics

```
Backend (Go):       ~9,500 LOC · 37+ files
Frontend (Flutter): ~6,000 LOC · 28+ files (excluding generated)
API Endpoints:      32
Database Tables:    11
Migrations:         6
Unit Tests:         14 RBAC + 1 RLS integration
```

---

## Known Gaps

| Gap | Priority |
|-----|----------|
| Automated test coverage (currently ~5%) | Critical |
| CI/CD pipeline | Critical |
| Password reset & email verification | High |
| Invoice generation | High |
| Advanced reporting dashboard | High |
| Product image uploads | Medium |
| Real-time notifications | Low |

---

## Phase 3 — Planned

- Advanced inventory (batch tracking, serial numbers)
- Supplier and purchase order management
- Business intelligence dashboards
- Real-time notifications (WebSocket)
- Mobile app optimization
- Integration APIs (Shopify, WooCommerce)
- Multi-warehouse support

---

## Resources

- [Getting Started](GETTING-STARTED.md)
- [API Documentation](backend/API-DOCUMENTATION.md)
- [Development Rules](docs/DEVELOPMENT-RULES.md)
- [Implementation Checklist](IMPLEMENTATION-CHECKLIST.md)
