# Project Status

**Last Updated:** February 28, 2026  
**Current Phase:** Phase 1 MVP Complete → Phase 2 Production Ready (65%)

## Quick Stats

| Metric | Value |
|--------|-------|
| Phase 1 MVP | ✅ 100% |
| Production Ready | 🚧 65% |
| API Endpoints | 32 |
| Database Tables | 11 |
| Frontend Screens | 14 |
| Test Coverage | 0% (manual only) |

## Phase 1 - Complete ✅

### Authentication
- JWT-based auth with refresh tokens
- bcrypt password hashing
- User profile management
- **Endpoints:** `/api/v1/auth/*` (register, login, refresh, me, logout)

### Customer Management
- Full CRUD with multi-level addresses
- Business customer support (company, tax ID)
- Financial tracking (credit limit, balance)
- Search and filters (name, email, status, city)
- **Endpoints:** `/api/v1/customers/*`

### Product Management
- SKU/barcode tracking
- Hierarchical categories
- Inventory management with low stock alerts
- Multi-level pricing (cost, selling, discount)
- **Endpoints:** `/api/v1/products/*`

-### Order Management
- 7-state workflow: draft → pending → confirmed → processing → shipped → delivered (+ cancelled)
- Auto-generated order numbers (ORD-YYYYMMDD-XXXX)
- Line items with product snapshots
- Payment tracking (cash, card, bank transfer, check)
- Inventory integration (stock deduction on shipping)
- Return/reject functionality
- **Endpoints:** `/api/v1/orders/*` (11 endpoints)

### Internationalization
- Arabic and English support
- RTL layout
- Tajawal font
- 34+ translations

## Phase 2 - In Progress (42%)

### Critical (Blocking Production)

**Multi-Tenant & RBAC** ✅ (90% complete)
- Tenant isolation: request + per-transaction tenant context (middleware + SET LOCAL in repositories)
- RBAC roles: operator, collector, owner with endpoint enforcement (role bypass for owner)
- Unit tests: 14/14 RBAC tests passing (middleware, auth, handlers)
- Courier reconciliation report: GET `/api/v1/reports/courier-reconciliation` (owner-only)
- Locations CRUD: Full city/zone/shipping_fee management endpoints
- PostgreSQL RLS policies applied (see migration `000006_enable_rls`) for tenant-scoped tables (defense-in-depth)
- **Next:** monitor and extend policies if new tenant-scoped tables are added
- **Priority:** Critical | **Complexity:** Medium

**Automated Testing** ❌
- Backend unit tests (target: 80%)
- Frontend widget tests (target: 70%)
- Integration tests
- **Priority:** Critical | **Complexity:** High

**DevOps Pipeline** 🚧 25%
- Docker Compose (partial)
- CI/CD (GitHub Actions)
- Monitoring (Prometheus/Grafana)
- Automated backups
- **Priority:** Critical | **Complexity:** Medium

**Enhanced Security** ❌
- Redis for refresh tokens
- Rate limiting
- Password reset flow
- Email verification
- **Priority:** Critical | **Complexity:** Medium

### High Priority

**Invoice Generation** ❌
- PDF generation
- Customizable templates
- Email delivery
- **Priority:** High | **Complexity:** High

**Advanced Reporting** ❌
- Revenue analytics
- Product performance
- Customer insights
- CSV/Excel export
- **Priority:** High | **Complexity:** High

## Phase 3 - Planned

- Advanced inventory (batch tracking, serial numbers)
- Supplier management
- Purchase orders
- Business intelligence dashboards
- Real-time notifications (WebSocket)
- Mobile app optimization
- Integration APIs (Shopify, WooCommerce)
- Multi-warehouse support

## Architecture

### Backend (Go)
```
Gin Router → Handlers → Services → Repositories → GORM → PostgreSQL
```

**Clean separation:** HTTP → Business Logic → Data Access

### Frontend (Flutter)
```
Features/
├── auth/          ✅ Complete
├── customers/     ✅ Complete
├── products/      ✅ Complete
├── orders/        ✅ Complete
├── dashboard/     ✅ Basic
├── reports/       ❌ Planned
└── invoices/      ❌ Planned
```

**State:** Riverpod | **HTTP:** Dio | **Models:** Freezed

### Multi-Tenancy
- Every table has `tenant_id` column
- JWT contains `tenant_id` claim
- All queries filter by tenant
- Unique constraints include tenant_id

## Database Schema

```sql
tenants           -- Multi-tenant root
users             -- Authentication
customers         -- CRM with addresses
categories        -- Hierarchical product categories
products          -- Inventory with SKU
orders            -- Order lifecycle (now includes logistics fields, optimistic locking)
order_items       -- Line items with snapshots
payments          -- Payment tracking
audit_logs        -- Immutable audit trail for status/price changes
couriers          -- Tenant couriers catalog
locations         -- Cities/zones and shipping fees
```

All tables include: `id`, `tenant_id`, `created_at`, `updated_at`, `deleted_at`

## Current Gaps

### Critical
1. **Automated testing** - RBAC tests added (14 tests passing); backend unit coverage needs expansion to 80%
2. **RLS policies** - middleware + per-transaction tenant variable complete; RLS policies applied and verified against `meridien_dev` using migration `000006_enable_rls`
3. **Production deployment** - CI/CD (GitHub Actions), monitoring (Prometheus), automated backups still required
4. **Redis integration** - Refresh token caching and rate limiting not yet implemented

### Important
5. **Limited reporting** - Basic logistics reconciliation done; analytics/exports still needed
6. **No file uploads** - No product images or document storage
7. **No invoice generation** - PDF invoice templates not yet implemented
8. **Basic dashboard** - No charts or KPIs

## Next Actions

### This Week (Current Sprint - COMPLETE) ✅
✅ Completed:
1. ✅ Wire `TenantMiddleware` into router (per-transaction SET LOCAL)
2. ✅ Email-based workspace discovery on login (DiscoverTenants, returns tenant list)
3. ✅ RBAC roles (OPERATOR, COLLECTOR, OWNER) with handler enforcement and owner bypass
4. ✅ Unit tests for RBAC behavior (14 tests passing)
5. ✅ Courier reconciliation report endpoint (`GET /api/v1/reports/courier-reconciliation`)
   - Query: SUM(orders.delivered) - SUM(orders.collected) per courier
   - Response: Cash reconciliation showing amount stuck with each courier
6. ✅ Locations CRUD endpoints (POST, GET, PUT, DELETE):
   - City/zone/shipping_fee management
   - Pagination support with tenant filtering
   - Decimal precision for shipping fees
7. ✅ PostgreSQL RLS policies applied for tenant-scoped tables (migration `000006_enable_rls`)
8. ✅ RLS integration test added (`backend/internal/integration/rls_test.go`) — skips when DB DSN is not configured

### Next 2 Weeks (Phase 2 Continuation)
7. Redis for token management and rate limiting middleware
8. Enhanced backend error handling and validation

### Next Month (Phase 2 Sprint 2)
10. Reports module (revenue, analytics)
11. Invoice generation (PDF)
12. Automated testing expansion (target 80% backend, 70% frontend)

## Code Metrics

```
Backend (Go):        ~9,500 LOC in 35 files (added location_* + report_* + courier_*)
Frontend (Flutter):  ~6,000 LOC in 28+ files (excluding generated)
Database:            11 tables, 5 migrations
API Endpoints:       32 total (CRUD: customers, products, orders, locations; reports, auth)
Unit Tests:          14/14 RBAC tests passing; expanding coverage
```

## Resources

- [Getting Started](GETTING-STARTED.md)
- [API Documentation](backend/API-DOCUMENTATION.md)
- [Development Rules](docs/DEVELOPMENT-RULES.md)
- [Implementation Checklist](IMPLEMENTATION-CHECKLIST.md)

---

**Next Review:** March 7, 2026 (RLS policies + Redis implementation)
