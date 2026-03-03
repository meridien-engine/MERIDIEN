# Project Status

**Last Updated:** March 2, 2026
**Current Phase:** Phase 2 — Join Requests & Invitations (active)

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

## Phase 2 — Join Requests & Invitations 🚧

**Goal:** Allow users to find and join businesses, and allow owners/admins to invite users by email.

### Backend

| Task | Status |
|---|---|
| Migration: `join_requests` table | ❌ |
| Migration: `invitations` table | ❌ |
| `GET /businesses/slug/:slug` — lookup by slug | ❌ |
| `POST /join-requests` — submit join request | ❌ |
| `GET /businesses/:id/join-requests` — pending list (admin+) | ❌ |
| `POST /businesses/:id/join-requests/:reqId/approve` | ❌ |
| `POST /businesses/:id/join-requests/:reqId/reject` | ❌ |
| `POST /businesses/:id/invitations` — send invite by email | ❌ |
| `GET /invitations/:token` — validate token (public) | ❌ |
| `POST /invitations/:token/accept` — accept invite | ❌ |

### Frontend

| Task | Status |
|---|---|
| `JoinRequestModel` + `InvitationModel` (Freezed) | ❌ |
| `JoinRequestRepository` + `InvitationRepository` | ❌ |
| Update `NoBusinessScreen` — add "Find & join" option | ❌ |
| `FindBusinessScreen` — search by slug, submit join request | ❌ |
| `PendingApprovalScreen` — after submitting join request | ❌ |
| `JoinRequestsScreen` — admin view, approve/reject with role picker | ❌ |
| `InviteUserScreen` — email + role picker | ❌ |
| `MembersScreen` — list members, change role, remove | ❌ |
| Invitation accept flow (token entry or deep link) | ❌ |
| Localization: EN + AR for all new strings | ❌ |

---

## Phase 3 — Branches 📋

**Goal:** Multi-store access control. Single-branch businesses get a silent main store; multi-branch get full branch management.

| Task | Status |
|---|---|
| Migration: `user_branch_access` table | ❌ |
| Auto-create main store on `POST /businesses` | ❌ |
| `POST/GET /businesses/:id/branches` | ❌ |
| `GET/PUT /branches/:id` | ❌ |
| `POST /branches/:id/users` — grant access | ❌ |
| `DELETE /branches/:id/users/:userId` — revoke | ❌ |
| Flutter: `BranchListScreen`, `CreateBranchScreen`, `BranchAccessScreen` | ❌ |
| POS: `BranchPickerScreen` (multi-branch only) | ❌ |

---

## Phase 4 — Branch Inventory 📋

**Goal:** Stock and product activation managed per store.

| Task | Status |
|---|---|
| Migration: `branch_inventory` table | ❌ |
| `GET /branches/:id/products` — with stock data | ❌ |
| `POST/PUT/DELETE /branches/:id/products/:productId` | ❌ |
| Update POS product lookup to use `branch_inventory` | ❌ |
| Flutter: `BranchInventoryScreen`, `ActivateProductScreen` | ❌ |

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

tables:
  users                    — global, no business_id
  businesses               — multi-business root
  business_categories      — predefined system list
  user_business_memberships — user ↔ business with role
  stores                   — physical locations per business
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
Backend (Go):       ~11,000 LOC · 45+ files
Frontend (Flutter): ~7,500 LOC · 40+ files (excluding generated)
API Endpoints:      ~38
Database Tables:    15
Migrations:         9
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
