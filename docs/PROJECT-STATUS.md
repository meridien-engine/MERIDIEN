# Project Status

**Last Updated:** March 3, 2026
**Current Phase:** Phase 4 — Branch Inventory (next)

---

## Phase 1 — Complete ✅

### Identity & Business Core

| Area | Detail |
|---|---|
| Multi-business model | `tenants` → `businesses`; `tenant_id` → `business_id` across all tables |
| Global users | Users decoupled from businesses; membership via `user_business_memberships` |
| Business categories | Predefined system list (`business_categories`), seeded |
| Two-token JWT auth | `generic` token on login → `scoped` token after business selection |
| Auth endpoints | `POST /auth/register`, `/auth/login`, `GET /auth/businesses`, `POST /auth/use-business/:id`, `POST /auth/logout` |
| Business endpoints | `POST /businesses`, `GET /businesses/:id`, `GET /business-categories` |
| Business middleware | Sets `app.current_business` for RLS per request |
| Redis token blacklist | JTI revoked on logout; checked in `RequireAuth` |
| Redis rate limiting | 10 req/min per IP on auth endpoints; fail-open |
| Flutter auth flow | Login → business selector → scoped session |
| Flutter screens | `BusinessSelectorScreen`, `NoBusinessScreen`, `CreateBusinessScreen` |
| Flutter models | `BusinessModel`, `BusinessCategoryModel`, `GenericAuthResponse`, `ScopedAuthResponse` (Freezed) |

### Stores Management

| Area | Detail |
|---|---|
| Migration 000009 | `stores` table with RLS (`business_id` scoped) |
| Backend | `Store` model, `StoreRepository`, `StoreService`, `StoreHandler` |
| API | `GET/POST /stores`, `GET/PUT/DELETE /stores/:id` |
| Flutter model | `StoreModel`, `CreateStoreRequest`, `UpdateStoreRequest` (Freezed) |
| Flutter repo | `StoreRepository` with Dio |
| Flutter state | `StoreNotifier` / `storeProvider` |
| Flutter screen | `StoreManagementScreen` — list, create, edit, delete, active toggle |
| Router | `/stores` route |
| Dashboard | "Stores" quick-action card (indigo, storefront icon) |
| Localization | EN + AR for all store strings |

### Previously Completed (pre-refactor)

| Module | Status |
|---|---|
| Customer management (CRUD, search, addresses, financials) | ✅ |
| Product management (SKU/barcode, categories, inventory) | ✅ |
| Order management (7-state workflow, line items, payments) | ✅ |
| Location & courier management | ✅ |
| Courier cash reconciliation report | ✅ |
| POS module (sessions, checkout, product lookup) | ✅ |
| Internationalization (EN + AR, RTL, 34+ strings) | ✅ |

---

## Phase 2 — Join Requests & Invitations ✅

**Goal:** Allow users to find and join businesses, and allow owners/admins to invite users by email.

### Backend

| Task | Status |
|---|---|
| Migration: `join_requests` table | ✅ |
| Migration: `invitations` table | ✅ |
| `GET /businesses/slug/:slug` — lookup by slug | ✅ |
| `POST /join-requests` — submit join request | ✅ |
| `GET /businesses/:id/join-requests` — pending list (admin+) | ✅ |
| `POST /businesses/:id/join-requests/:reqId/approve` | ✅ |
| `POST /businesses/:id/join-requests/:reqId/reject` | ✅ |
| `POST /businesses/:id/invitations` — send invite by email | ✅ |
| `GET /invitations/:token` — validate token (public) | ✅ |
| `POST /invitations/:token/accept` — accept invite | ✅ |

### Frontend

| Task | Status |
|---|---|
| `JoinRequestModel` + `InvitationModel` (Freezed) | ✅ |
| `JoinRequestRepository` + `InvitationRepository` | ✅ |
| `FindBusinessScreen` — search by slug, submit join request | ✅ |
| `MyJoinRequestsScreen` — user's own requests | ✅ |
| `JoinRequestsScreen` — admin approve/reject | ✅ |
| `InviteUserScreen` — email + role picker | ✅ |
| `MembersScreen` — list members, change role, remove | ✅ |
| `AcceptInvitationScreen` — accept via token | ✅ |
| Localization: EN + AR for all membership strings | ✅ |

---

## Phase 3 — Branches ✅

**Goal:** Multi-branch support. Single-branch businesses get a silent main branch; multi-branch get full branch management.

### Backend

| Task | Status |
|---|---|
| Migration 000011 — `branches` table (RLS) + `user_branch_access` | ✅ |
| `Branch` + `UserBranchAccess` models | ✅ |
| `BranchRepository`, `BranchService`, `BranchHandler` | ✅ |
| Auto-create "Main Branch" on `POST /businesses` | ✅ |
| `POST/GET /businesses/:id/branches` | ✅ |
| `GET/PUT/DELETE /branches/:id` | ✅ |
| `GET/POST /branches/:id/users`, `DELETE /branches/:id/users/:userId` | ✅ |

### Frontend

| Task | Status |
|---|---|
| `BranchModel`, `CreateBranchRequest`, `UpdateBranchRequest`, `BranchUserModel` (Freezed) | ✅ |
| `BranchRepository` (Dio) | ✅ |
| `BranchNotifier` / `branchProvider` (Riverpod) | ✅ |
| `BranchManagementScreen` — list, create, edit, delete, main badge | ✅ |
| `BranchAccessScreen` — grant/revoke user access | ✅ |
| Router: `/branches`, `/branches/:id/access` | ✅ |
| Dashboard: "Branches" card (deepOrange) | ✅ |
| Localization: EN + AR (20 keys) | ✅ |
| POS: `BranchPickerScreen` (multi-branch) | 📋 Phase 4 |

### Product Module Fixes

| Task | Status |
|---|---|
| Migration 000012 — partial unique indexes for SKU/barcode (allow empty) | ✅ |
| `product_service.go` — UUID suffix on slug for non-ASCII name uniqueness | ✅ |
| Product list — `ListView` tiles (was `GridView` cards), image-free | ✅ |
| Dashboard — removed redundant "Stores" card | ✅ |
| Seed script — 100 Arabic hardware products (8 categories) | ✅ |

---

## Phase 4 — Branch Inventory 📋 (Next)

**Goal:** Stock and product activation managed per branch.

| Task | Status |
|---|---|
| Migration: `branch_inventory` table | ❌ |
| `GET /branches/:id/products` — with stock data | ❌ |
| `POST/PUT/DELETE /branches/:id/products/:productId` | ❌ |
| Update POS product lookup to use `branch_inventory` | ❌ |
| Flutter: `BranchInventoryScreen`, `ActivateProductScreen` | ❌ |
| POS: `BranchPickerScreen` | ❌ |

---

## Phase 5 — Online Order Fulfillment 📋

**Goal:** Online orders fulfilled from a specific store with stock guard.

| Task | Status |
|---|---|
| Add `fulfillment_branch_id` to orders | ❌ |
| `POST /orders/:id/fulfill { branch_id }` | ❌ |
| Hard block if branch stock insufficient | ❌ |
| Stock deduction from fulfillment branch | ❌ |
| Flutter: `FulfillmentBranchPicker` | ❌ |

---

## Database Schema (current)

```
migrations applied:
  000001 — initial schema (users, customers, products, orders, etc.)
  000002 — order items + payments
  000003 — locations + couriers
  000004 — audit logs
  000005 — product categories
  000006 — enable RLS
  000007 — POS sessions; order_type, customer_name; nullable customer_id
  000008 — tenants→businesses; business_id across 9 tables; user_business_memberships; business_categories
  000009 — stores table with RLS
  000010 — join_requests + invitations; role/reviewed_by/reviewed_at columns
  000011 — branches table (RLS) + user_branch_access
  000012 — partial unique indexes for products (sku, barcode, slug) — allows empty values

tables:
  users                    — global, no business_id
  businesses               — multi-business root
  business_categories      — predefined system list
  user_business_memberships — user ↔ business with role
  join_requests            — user-initiated business join requests
  invitations              — owner/admin email invitations
  stores                   — physical locations per business (legacy, superseded by branches in UI)
  branches                 — business branches with RLS
  user_branch_access       — user ↔ branch access grants
  customers                — CRM, business_id scoped
  product_categories       — business_id scoped
  products                 — business catalog, business_id scoped
  orders                   — online + POS, business_id scoped
  order_items              — line items
  payments                 — payment tracking
  pos_sessions             — POS session lifecycle
  couriers                 — business courier catalog
  locations                — city/zone shipping config
  audit_logs               — immutable change trail
```

All tables (except `users`, `business_categories`): `id (UUID)`, `business_id`, `created_at`, `updated_at`, `deleted_at`

---

## Code Metrics (approximate)

```
Backend (Go):       ~13,500 LOC · 55+ files
Frontend (Flutter): ~9,500 LOC · 55+ files (excluding generated)
API Endpoints:      ~50
Database Tables:    19
Migrations:         12
Automated Tests:    14 RBAC unit tests + 1 RLS integration test
```

---

## Known Gaps

| Gap | Priority |
|---|---|
| Automated test coverage (~5%) | Critical |
| CI/CD pipeline | Critical |
| Password reset & email verification | High |
| Invoice generation (PDF) | High |
| Advanced reporting & analytics | High |
| Product image uploads | Medium |
| Real-time notifications | Low |

---

## Resources

- [Architecture](ARCHITECTURE.md) — decisions, schema, auth flow, roadmap
- [Todo / Backlog](../TODO.md) — detailed phase task breakdowns
- [Getting Started](GETTING-STARTED.md) — setup guide
- [API Documentation](api/API-DOCUMENTATION.md) — endpoint reference
- [Development Rules](DEVELOPMENT-RULES.md) — coding standards
