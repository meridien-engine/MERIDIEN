# MERIDIEN — Architecture

**Version:** Phase 2 (active)
**Last updated:** March 2, 2026

---

## System Overview

MERIDIEN is a multi-business SaaS platform for retail operations. Users are global (not tied to any business). After login, a user selects which business to operate in and receives a scoped JWT that gates all subsequent API calls to that business's data.

```
Flutter (Web / Mobile / Desktop)
    ↓  REST API
Gin Router  ←── CORS, rate limiting (Redis, fail-open)
    ↓
Auth Middleware  ←── JWT validation (type check) + JTI blacklist (Redis, fail-open)
    ↓
Handlers → Services → Repositories
    ↓
businessTx() → SET LOCAL app.current_business = <business_id>
    ↓
PostgreSQL (RLS enforced per-transaction)
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Go 1.21+, Gin, GORM |
| Frontend | Flutter 3.24+, Riverpod, Dio, Freezed |
| Database | PostgreSQL 15+ with Row-Level Security |
| Cache | Redis 7+ (token blacklist, rate limiting — fail-open) |
| Auth | JWT HS256, 24h expiry, JTI revocation |

---

## Multi-Business Model

### Core Principle

Users are global entities. A user may own or be a member of multiple businesses. Business context is established after login via a separate token exchange.

### Key Decisions (locked)

| Decision | Choice |
|---|---|
| Role granularity | Per-business |
| Auth context | Session-scoped token (`POST /auth/use-business/:id`) |
| Product strategy | Shared business catalog + branch-level inventory |
| Join request approval | Owner + Admin |
| Online orders | Business-scoped (no branch required) |
| Online fulfillment | Manual branch selection; hard block if stock insufficient |
| Business type | User picks at creation: `single_branch` or `multi_branch` |
| New branch access | Owner auto-added; owner assigns admin access to others |
| POS branch selection | Single branch → straight to terminal; multiple → picker first |
| Slug | Set at creation; immutable after |
| Product import | Activate from catalog (creates `branch_inventory` row, qty = 0) |
| Plans | Field only — no enforcement now |
| Business switching | Dedicated switch-business screen |
| Invitations | Owner/admin invite by email; users can also self-submit join requests |
| Business categories | Predefined system list (seeded) |
| Fulfillment stock guard | Hard block |
| Stock transfers | Out of scope for now |

---

## Role Set

| Role | Scope | Capabilities |
|---|---|---|
| `owner` | Business | Everything; immutable; auto-assigned at business creation |
| `admin` | Business | Approve joins, invite users, assign branch access, manage all data |
| `manager` | Branch | Manage products/orders/inventory for assigned branches |
| `cashier` | Branch | POS only on assigned branches |
| `viewer` | Branch | Read-only; reports |

---

## Authentication Flow

```
1. POST /auth/register        → creates user only (no business attached)
2. POST /auth/login           → returns generic JWT { user_id, email, type="generic" }
3. GET  /auth/businesses      → list businesses the user is a member of (requires generic JWT)
         ↓ user picks one, or creates/joins
4. POST /auth/use-business/:id
                              → validates active membership
                              → returns scoped JWT { user_id, business_id, role, type="scoped" }
5. All subsequent API calls   → use scoped JWT (RequireAuth rejects generic tokens)
6. Switch business            → repeat from step 4
```

### JWT Token Types

| Field | Generic Token | Scoped Token |
|---|---|---|
| `type` | `"generic"` | `"scoped"` |
| `user_id` | ✅ | ✅ |
| `business_id` | ❌ | ✅ |
| `role` | ❌ | ✅ |
| `jti` | ✅ (unique) | ✅ (unique) |
| Used for | Login + business selection | All business API calls |

### Middleware

- `RequireGenericAuth` — accepts only `type="generic"` tokens (used on `/auth/businesses`, `/auth/use-business/:id`)
- `RequireAuth` — accepts only `type="scoped"` tokens (used on all business-scoped routes)
- `RequireRole(roles...)` — checks role from scoped JWT claims

---

## Database Schema

```sql
-- ── Users (global, decoupled from businesses) ────────────────────────
users (
  id UUID PK,
  email VARCHAR UNIQUE,
  first_name, last_name, phone,
  password_hash,
  created_at, updated_at, deleted_at
)

-- ── Business categories (predefined system list) ─────────────────────
business_categories (
  id UUID PK,
  name VARCHAR,         -- e.g. "Retail"
  name_ar VARCHAR,      -- e.g. "تجزئة"
  slug VARCHAR UNIQUE   -- e.g. "retail"
)

-- ── Businesses ───────────────────────────────────────────────────────
businesses (
  id UUID PK,
  name VARCHAR NOT NULL,
  slug VARCHAR UNIQUE NOT NULL,          -- immutable after creation
  owner_id UUID → users(id),
  category_id UUID → business_categories(id),
  business_type VARCHAR CHECK IN ('single_branch','multi_branch'),
  contact_phone, contact_email, logo_url,
  plan VARCHAR DEFAULT 'free',           -- label only, no enforcement
  status VARCHAR DEFAULT 'active' CHECK IN ('active','suspended','trial'),
  created_at, updated_at, deleted_at
)

-- ── Memberships (users ↔ businesses) ────────────────────────────────
user_business_memberships (
  id UUID PK,
  user_id UUID → users(id),
  business_id UUID → businesses(id),
  role VARCHAR CHECK IN ('owner','admin','manager','cashier','viewer'),
  status VARCHAR DEFAULT 'active' CHECK IN ('active','suspended'),
  invited_by UUID → users(id),           -- NULL if self-joined via join request
  created_at, updated_at,
  UNIQUE(user_id, business_id)
)

-- ── Join requests (user-initiated) ──────────────────────────────────
join_requests (
  id UUID PK,
  user_id UUID → users(id),
  business_id UUID → businesses(id),
  message TEXT,
  role VARCHAR,
  status VARCHAR DEFAULT 'pending' CHECK IN ('pending','approved','rejected'),
  reviewed_by UUID → users(id),
  reviewed_at TIMESTAMPTZ,
  created_at
)

-- ── Invitations (owner/admin-initiated) ─────────────────────────────
invitations (
  id UUID PK,
  business_id UUID → businesses(id),
  email VARCHAR NOT NULL,
  role VARCHAR NOT NULL,
  token VARCHAR UNIQUE NOT NULL,         -- secure random token
  invited_by UUID → users(id),
  status VARCHAR DEFAULT 'pending' CHECK IN ('pending','accepted','expired'),
  expires_at TIMESTAMPTZ,
  created_at
)

-- ── Stores ──────────────────────────────────────────────────────────
stores (
  id UUID PK,
  business_id UUID → businesses(id),
  name VARCHAR NOT NULL,
  address VARCHAR,
  city VARCHAR,
  phone VARCHAR,
  is_main BOOLEAN DEFAULT false,
  status VARCHAR DEFAULT 'active' CHECK IN ('active','inactive'),
  created_at, updated_at, deleted_at
)

-- ── Branch access (which stores a user can operate) ─────────────────
user_branch_access (
  id UUID PK,
  user_id UUID → users(id),
  branch_id UUID → stores(id),
  granted_by UUID → users(id),
  created_at,
  UNIQUE(user_id, branch_id)
)

-- ── Product catalog (business-level) ────────────────────────────────
product_categories (
  id UUID PK,
  business_id UUID,
  name VARCHAR,
  created_at, updated_at, deleted_at
)

products (
  id UUID PK,
  business_id UUID → businesses(id),
  name, sku, barcode, description,
  category_id → product_categories(id),
  base_price, cost_price,
  track_inventory BOOLEAN,
  status VARCHAR,
  created_at, updated_at, deleted_at
)

-- ── Branch inventory (store-level stock & activation) ───────────────
branch_inventory (
  id UUID PK,
  branch_id UUID → stores(id),
  product_id UUID → products(id),
  is_active BOOLEAN DEFAULT true,
  stock_quantity INT DEFAULT 0,
  price_override DECIMAL(15,2),          -- NULL = use base_price
  low_stock_threshold INT DEFAULT 5,
  created_at, updated_at,
  UNIQUE(branch_id, product_id)
)

-- ── Orders ──────────────────────────────────────────────────────────
orders (
  id UUID PK,
  business_id UUID → businesses(id),
  branch_id UUID → stores(id),          -- NULL for online orders
  fulfillment_branch_id UUID → stores(id),  -- set when shipping online order
  order_type VARCHAR CHECK IN ('online','pos'),
  customer_id UUID → customers(id),     -- nullable (POS walk-in)
  customer_name VARCHAR,                -- POS walk-in name
  ... order fields, status, totals ...
)

-- ── POS sessions (store-level) ──────────────────────────────────────
pos_sessions (
  id UUID PK,
  business_id UUID → businesses(id),
  branch_id UUID → stores(id),
  ... session fields ...
)

-- ── Supporting tables ────────────────────────────────────────────────
customers, order_items, payments, audit_logs, couriers, locations
-- All carry business_id; RLS enforced via SET LOCAL app.current_business
```

### RLS Pattern

Every repository wraps writes and reads in a transaction that sets the business context:

```go
func (r *Repo) businessTx(ctx context.Context, businessID string, fn func(*gorm.DB) error) error {
    return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        tx.Exec("SET LOCAL app.current_business = ?", businessID)
        return fn(tx)
    })
}
```

PostgreSQL RLS policies use `current_setting('app.current_business')` to enforce row-level isolation.

---

## API Design

### Response Envelope

```json
{ "success": true, "message": "...", "data": {} }
```

### Error Envelope

```json
{ "success": false, "error": "...", "message": "..." }
```

### Paginated Response

```json
{
  "success": true,
  "data": [...],
  "meta": { "total": 100, "page": 1, "per_page": 20, "total_pages": 5 }
}
```

### Endpoint Conventions

```
GET    /api/v1/{resource}       — list with pagination
GET    /api/v1/{resource}/:id   — get by ID
POST   /api/v1/{resource}       — create
PUT    /api/v1/{resource}/:id   — update
DELETE /api/v1/{resource}/:id   — soft delete
```

---

## Backend Structure

```
backend/
├── cmd/server/           # Entry point + dependency injection
└── internal/
    ├── cache/            # Redis client (redis.go, token_blacklist.go)
    ├── config/           # Env config (DB, JWT, Redis)
    ├── handlers/         # HTTP layer — thin, delegates to services
    ├── services/         # Business logic
    ├── repositories/     # Data access — all RLS-aware via businessTx()
    ├── models/           # GORM entities
    ├── middleware/        # auth_middleware, business_middleware, rate_limit
    └── router/           # Route registration (Setup func)
```

`router.Setup` signature (current):
```go
func Setup(
    authHandler      *handlers.AuthHandler,
    customerHandler  *handlers.CustomerHandler,
    productHandler   *handlers.ProductHandler,
    orderHandler     *handlers.OrderHandler,
    locationHandler  *handlers.LocationHandler,
    courierHandler   *handlers.CourierHandler,
    posHandler       *handlers.POSHandler,
    reportHandler    *handlers.ReportHandler,
    businessHandler  *handlers.BusinessHandler,
    storeHandler     *handlers.StoreHandler,
    rateLimiter      gin.HandlerFunc,
) *gin.Engine
```

---

## Frontend Structure

```
frontend/lib/
├── core/               # Theme, constants, localization, role provider
├── data/
│   ├── models/         # Freezed models (all DTOs)
│   ├── repositories/   # Dio-based HTTP repositories
│   ├── providers/      # Riverpod: DIO, storage, repository providers
│   └── services/       # StorageService (token + business persistence)
├── features/
│   ├── auth/           # Login, register, business selector, no-business
│   ├── business/       # Create business screen
│   ├── customers/
│   ├── products/
│   ├── orders/
│   ├── stores/         # Store management screen
│   ├── locations/
│   ├── couriers/
│   ├── pos/            # POS session + checkout
│   └── dashboard/
├── routes/             # GoRouter with redirect logic
└── shared/             # Reusable widgets
```

### State Management

- **Auth state machine** (Riverpod `StateNotifier`):
  `initial → loading → authenticated(user, businesses, selectedBusiness) → selectingBusiness(user, businesses) → noBusiness(user) → unauthenticated → error`
- **Feature providers**: plain `StateNotifier` classes per feature (products, orders, stores, POS, etc.)
- **Models**: all Freezed + `json_serializable`

### Storage (StorageService)

| Key | Value |
|---|---|
| `generic_token` | JWT from `/auth/login` |
| `scoped_token` | JWT from `/auth/use-business/:id` |
| `business_id` | Selected business UUID |
| `role` | User role in selected business |

---

## Security

| Concern | Implementation |
|---|---|
| Passwords | bcrypt, cost 10 |
| JWT | HS256, 24h expiry, unique JTI per token |
| Token revocation | JTI stored in Redis with TTL on logout |
| Rate limiting | Fixed-window, 10 req/min per IP on auth endpoints |
| Data isolation | PostgreSQL RLS + `SET LOCAL app.current_business` per transaction |
| SQL injection | GORM prepared statements only — no raw SQL |
| Soft deletes | `deleted_at` on all entities — no hard deletes |
| Redis dependency | Fail-open — app runs normally if Redis is unavailable |

---

## Implementation Roadmap

| Phase | Scope | Status |
|---|---|---|
| Phase 1 | Identity & Business Core + Stores management | ✅ Complete |
| Phase 2 | Join Requests & Invitations | 🚧 Active |
| Phase 3 | Branches (store access management) | 📋 Planned |
| Phase 4 | Branch Inventory (per-store stock) | 📋 Planned |
| Phase 5 | Online Order Fulfillment (branch stock guard) | 📋 Planned |

See [TODO.md](TODO.md) for detailed task breakdowns per phase.
