# MERIDIEN — Todo / Backlog

---

## Implementation Status

### ✅ Phase 1 — Identity & Business Core + Stores (COMPLETE)

| Area | Status |
|---|---|
| Migration 000008 — `tenants→businesses`, `business_id` across 9 tables | ✅ |
| `user_business_memberships`, `business_categories` (seeded) | ✅ |
| Two-token JWT (generic → scoped), `/auth/use-business/:id` | ✅ |
| `POST /businesses`, `GET /businesses/:id`, `GET /business-categories` | ✅ |
| Flutter: `BusinessSelectorScreen`, `NoBusinessScreen`, `CreateBusinessScreen` | ✅ |
| Redis: token blacklist + rate limiting (fail-open) | ✅ |
| Migration 000009 — `stores` table with RLS | ✅ |
| Backend: `Store` model, `StoreRepository`, `StoreService`, `StoreHandler` | ✅ |
| API: `GET/POST /stores`, `GET/PUT/DELETE /stores/:id` | ✅ |
| Flutter: `StoreModel` (Freezed), `StoreRepository`, `StoreNotifier` | ✅ |
| Flutter: `StoreManagementScreen` — list, create, edit, delete, active toggle | ✅ |
| Router: `/stores` route + Dashboard quick-action card (indigo) | ✅ |
| Localization: EN + AR for all store strings | ✅ |

---

### ✅ Phase 2 — Join Requests & Invitations (COMPLETE)

| Area | Status |
|---|---|
| Migration 000010 — `role`/`reviewed_by`/`reviewed_at` on `join_requests`, `status` on `invitations` | ✅ |
| `GET /businesses/slug/:slug` — lookup business for join request | ✅ |
| `POST /join-requests`, `GET /join-requests` | ✅ |
| `GET/POST /businesses/:id/join-requests` (list, approve, reject) | ✅ |
| `POST /businesses/:id/invitations`, `GET /businesses/:id/invitations` | ✅ |
| `GET /invitations/:token`, `POST /invitations/:token/accept` | ✅ |
| `GET/PATCH/DELETE /businesses/:id/members` | ✅ |
| Flutter: `JoinRequestModel`, `InvitationModel`, `MemberModel` (Freezed) | ✅ |
| Flutter: `MembershipRepository` (Dio, 13 endpoints) | ✅ |
| Flutter: `MembershipNotifier` + `MembershipState` (Riverpod) | ✅ |
| Flutter: `FindBusinessScreen`, `MyJoinRequestsScreen` | ✅ |
| Flutter: `JoinRequestsScreen` (admin approve/reject) | ✅ |
| Flutter: `MembersScreen` (list, change role, remove) | ✅ |
| Flutter: `InviteUserScreen`, `AcceptInvitationScreen` | ✅ |
| Localization: EN + AR for all membership strings | ✅ |

---

---

### ✅ Phase 3 — Branches (COMPLETE)

> **Goal:** Multi-branch support. Single-branch businesses get a silent main branch; multi-branch get full branch management.

#### Backend

- [x] Migration 000011 — `branches` table (RLS, business_id scoped) + `user_branch_access` (no RLS)
- [x] `Branch` + `UserBranchAccess` models (`backend/internal/models/branch.go`)
- [x] `BranchRepository` — CRUD + access management
- [x] `BranchService` — business logic, main-branch delete guard
- [x] `BranchHandler` — 8 HTTP endpoints
- [x] Auto-create "Main Branch" (is_main=true) on `POST /businesses`
- [x] `POST /businesses/:id/branches` — create branch (admin+)
- [x] `GET /businesses/:id/branches` — list branches
- [x] `GET /branches/:id` — get branch details
- [x] `PUT /branches/:id` — update branch (admin+)
- [x] `DELETE /branches/:id` — delete branch, owner only, rejects main branch
- [x] `POST /branches/:id/users` — grant user access (admin+)
- [x] `DELETE /branches/:id/users/:userId` — revoke access (owner only)
- [x] `GET /branches/:id/users` — list users with access (admin+)

#### Frontend

- [x] `BranchModel`, `CreateBranchRequest`, `UpdateBranchRequest`, `BranchUserModel` (Freezed)
- [x] `BranchRepository` (Dio, all 8 endpoints)
- [x] `BranchNotifier` / `branchProvider` (Riverpod)
- [x] `BranchManagementScreen` — list, create, edit, delete, main badge
- [x] `BranchAccessScreen` — grant/revoke user access per branch
- [x] Router: `/branches`, `/branches/:id/access`
- [x] Dashboard: "Branches" quick-action card (deepOrange, account_tree_rounded)
- [x] Localization: EN + AR for all branch strings (20 keys)
- [ ] POS: `BranchPickerScreen` — shown before POS if multi-branch (Phase 4)

---

### ✅ Product Module Fixes (COMPLETE)

| Area | Status |
|---|---|
| Migration 000012 — replace `UNIQUE(business_id, sku/barcode/slug)` with partial indexes that exclude empty strings | ✅ |
| `product_service.go` — slug now gets UUID suffix to guarantee uniqueness across Arabic/non-ASCII names | ✅ |
| Product list screen — switched from `GridView` (card) to `ListView` (tile), no image dependency | ✅ |
| Seed script — 100 Arabic hardware products across 8 categories (hand tools, power tools, electrical, plumbing, etc.) | ✅ |
| Dashboard — removed "Stores" quick-action card (superseded by Branches) | ✅ |

---

### 📋 Phase 4 — Branch Inventory

> **Goal:** Products are business-level; stock & activation are branch-level.

#### Backend

- [ ] `branch_inventory` table migration
  - Fields: `id`, `branch_id`, `product_id`, `is_active`, `stock_quantity`, `price_override`, `low_stock_threshold`, UNIQUE(branch_id, product_id)
- [ ] `GET /branches/:id/products` — list with inventory data
- [ ] `POST /branches/:id/products/:productId` — activate product at branch
- [ ] `PUT /branches/:id/products/:productId` — update stock / price override
- [ ] `DELETE /branches/:id/products/:productId` — deactivate at branch
- [ ] Update `GET /products/lookup?q=` to use `branch_inventory` (POS product search)

#### Frontend

- [ ] `BranchInventoryModel` (Freezed) + `BranchInventoryRepository`
- [ ] `BranchInventoryScreen` — list products at branch, stock levels, active toggle
- [ ] `ActivateProductScreen` — pick from business catalog to activate at branch
- [ ] POS: update product lookup to pass `branch_id`
- [ ] Localization: EN + AR

---

### 📋 Phase 5 — Online Order Fulfillment

> **Goal:** Online orders can be fulfilled from any branch with sufficient stock.

#### Backend

- [ ] Add `fulfillment_branch_id` column to `orders`
- [ ] `POST /orders/:id/fulfill { branch_id }` — assign fulfillment branch
  - Hard block if branch stock < order quantity
  - Deduct stock from `branch_inventory` on fulfill
- [ ] Update order status flow: `confirmed → processing` requires fulfillment branch set

#### Frontend

- [ ] `FulfillmentBranchPicker` — shown when moving order to shipped/processing
- [ ] Show fulfillment branch on order detail screen
- [ ] Localization: EN + AR

---

## Tests

### ✅ Written & Passing

| File | Tests |
|---|---|
| `backend/internal/auth/roles_test.go` | All 7 role constants correct, all distinct, owner ≠ admin |
| `backend/internal/utils/jwt_test.go` | Generic token valid, scoped token valid, wrong secret rejected, unique JTI, refresh preserves type |
| `backend/internal/middleware/auth_middleware_test.go` | RequireRole — allowed/denied/owner-bypass, all new roles (admin/manager/cashier/viewer), missing context → 403, RequireAuth/RequireGenericAuth reject missing header |
| `backend/internal/handlers/membership_handler_test.go` | Join request RBAC (admin+), invitation RBAC (admin+), member list (admin+), remove member (owner-only), owner bypasses all |
| `backend/internal/handlers/order_handler_test.go` | Operator can ship, collector cannot ship, owner bypasses all |

### 📋 Tests Still To Write

#### Backend — Unit

- [ ] `utils/jwt_test.go` — expired token returns error
- [ ] `utils/jwt_test.go` — tampered token (modified payload) returns error
- [ ] `services/membership_service_test.go` — `SubmitJoinRequest` rejects duplicate pending request (mock repos)
- [ ] `services/membership_service_test.go` — `ApproveJoinRequest` rejects wrong business ID
- [ ] `services/membership_service_test.go` — `AcceptInvitation` rejects expired token
- [ ] `services/membership_service_test.go` — `RemoveMember` rejects when target is owner
- [ ] `services/membership_service_test.go` — `UpdateMemberRole` rejects when target is owner

#### Backend — Integration (requires DB)

- [ ] `integration/rls_test.go` — update from `tenant_id` → `business_id` / `app.current_business`
- [ ] `integration/auth_flow_test.go` — full two-step login: register → login (generic JWT) → use-business (scoped JWT) → access protected route
- [ ] `integration/membership_test.go` — submit join request → approve → user appears in member list
- [ ] `integration/invitation_test.go` — send invitation → validate token → accept → user appears in member list
- [ ] `integration/membership_test.go` — remove owner returns 400/403

#### Frontend — Unit

- [ ] `membership_provider_test.dart` — `loadMyJoinRequests` sets state correctly on success and error
- [ ] `membership_provider_test.dart` — `submitJoinRequest` sets successMessage on success
- [ ] `membership_repository_test.dart` — `lookupBySlug` returns BusinessModel on 200, throws on 404

#### Frontend — Widget

- [ ] `find_business_screen_test.dart` — search field renders, shows result card after lookup
- [ ] `members_screen_test.dart` — shows member list, owner row has no remove button
- [ ] `join_requests_screen_test.dart` — pending requests show Approve/Reject buttons, reviewed ones don't
- [ ] `accept_invitation_screen_test.dart` — invalid token shows error body, valid token shows invitation card

---

## Tech Debt

### Localization Refactor
**Priority:** Low | **Effort:** Medium

Replace the current three-part system (getter + EN map + AR map) with a single
combined-map + `context.t('key')` extension. Adding a new string goes from touching
3 places to 1.

```dart
const _translations = {
  'openSession': {'en': 'Open Session', 'ar': 'فتح الجلسة'},
};
extension Loc on BuildContext {
  String t(String key) {
    final lang = Localizations.localeOf(this).languageCode;
    return _translations[key]?[lang] ?? _translations[key]?['en'] ?? key;
  }
}
```

**Files affected:** `app_localizations.dart`, every screen using `context.loc.xxx`

---

## Major Feature: Multi-Business Architecture Overhaul

**Priority:** High | **Effort:** Very Large | **Status:** 🟢 Architecture finalized — ready to plan

---

### Architecture Decisions (all locked)

| Decision | Choice |
|---|---|
| Role granularity | Per-business |
| Auth context | Session-scoped token (`/auth/use-business/:id`) |
| Product strategy | Shared business catalog + branch inventory |
| Join request approval | Owner + Admin |
| Online orders | Business-scoped (no branch) |
| Online fulfillment | Manual branch selection, hard block if insufficient stock |
| Business type | User picks: single-branch or multi-branch at creation |
| New branch access | Only owner auto-added; owner assigns admin access |
| POS branch selection | Single branch → straight to terminal; multiple → picker first |
| Slug | Set at creation, immutable after |
| Product import | Activate from catalog (create branch_inventory row, qty = 0) |
| Plans | Field only — no enforcement now |
| Business switching | Dedicated switch-business screen |
| Invitations | Owner/admin can invite by email (in addition to user-initiated join requests) |
| Business categories | Predefined system list |
| Fulfillment stock guard | Hard block |
| Stock transfers | Out of scope for now |

---

### Role Set

| Role | Scope | Capabilities |
|---|---|---|
| `owner` | Business | Everything; immutable; auto-assigned at creation |
| `admin` | Business | Approve joins, invite users, assign branch access, manage all data |
| `manager` | Branch | Manage products/orders/inventory for assigned branches |
| `cashier` | Branch | POS only on assigned branches |
| `viewer` | Branch | Read-only; reports |

---

### Complete Target Schema

```sql
-- ── Users (decoupled from businesses) ──────────────────────────────
users (
  id UUID PK,
  email VARCHAR UNIQUE,
  first_name, last_name, phone,
  password_hash,
  created_at, updated_at, deleted_at
  -- NO tenant_id
)

-- ── Business categories (predefined system list) ───────────────────
business_categories (
  id UUID PK,
  name VARCHAR,         -- e.g. "Retail"
  name_ar VARCHAR,      -- e.g. "تجزئة"
  slug VARCHAR UNIQUE   -- e.g. "retail"
)

-- ── Businesses (formerly tenants) ──────────────────────────────────
businesses (
  id UUID PK,
  name VARCHAR NOT NULL,
  slug VARCHAR UNIQUE NOT NULL,   -- immutable after creation
  owner_id UUID → users(id),
  category_id UUID → business_categories(id),
  business_type VARCHAR CHECK IN ('single_branch','multi_branch'),
  contact_phone VARCHAR,
  contact_email VARCHAR,
  logo_url VARCHAR,
  plan VARCHAR DEFAULT 'free',    -- label only, no enforcement
  status VARCHAR DEFAULT 'active' CHECK IN ('active','suspended','trial'),
  created_at, updated_at, deleted_at
)

-- ── Memberships (users ↔ businesses) ───────────────────────────────
user_business_memberships (
  id UUID PK,
  user_id UUID → users(id),
  business_id UUID → businesses(id),
  role VARCHAR CHECK IN ('owner','admin','manager','cashier','viewer'),
  status VARCHAR DEFAULT 'active' CHECK IN ('active','suspended'),
  invited_by UUID → users(id),  -- NULL if self-joined via request
  created_at, updated_at,
  UNIQUE(user_id, business_id)
)

-- ── Join requests (user-initiated) ─────────────────────────────────
join_requests (
  id UUID PK,
  user_id UUID → users(id),
  business_id UUID → businesses(id),
  message TEXT,                   -- optional note from requester
  role VARCHAR,                   -- role assigned on approval
  status VARCHAR DEFAULT 'pending' CHECK IN ('pending','approved','rejected'),
  reviewed_by UUID → users(id),
  reviewed_at TIMESTAMPTZ,
  created_at
)

-- ── Invitations (owner/admin-initiated via email) ──────────────────
invitations (
  id UUID PK,
  business_id UUID → businesses(id),
  email VARCHAR NOT NULL,
  role VARCHAR NOT NULL,
  token VARCHAR UNIQUE NOT NULL,  -- secure random token for invite link
  invited_by UUID → users(id),
  status VARCHAR DEFAULT 'pending' CHECK IN ('pending','accepted','expired'),
  expires_at TIMESTAMPTZ,
  created_at
)

-- ── Branches ───────────────────────────────────────────────────────
branches (
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

-- ── Branch access (which branches a user can use) ──────────────────
user_branch_access (
  id UUID PK,
  user_id UUID → users(id),
  branch_id UUID → branches(id),
  granted_by UUID → users(id),
  created_at,
  UNIQUE(user_id, branch_id)
)

-- ── Product catalog (business-level) ───────────────────────────────
product_categories (
  id UUID PK,
  business_id UUID → businesses(id),
  name VARCHAR,
  created_at, updated_at, deleted_at
)

products (
  id UUID PK,
  business_id UUID → businesses(id),   -- was tenant_id
  name, sku, barcode, description,
  category_id → product_categories(id),
  base_price, cost_price,
  track_inventory BOOLEAN,
  status VARCHAR,
  weight, weight_unit,
  created_at, updated_at, deleted_at
)

-- ── Branch inventory (branch-level stock & activation) ─────────────
branch_inventory (
  id UUID PK,
  branch_id UUID → branches(id),
  product_id UUID → products(id),
  is_active BOOLEAN DEFAULT true,     -- branch carries this product
  stock_quantity INT DEFAULT 0,
  price_override DECIMAL(15,2),       -- NULL = use base_price
  low_stock_threshold INT DEFAULT 5,
  created_at, updated_at,
  UNIQUE(branch_id, product_id)
)

-- ── Orders (online = business-level, POS = branch-level) ───────────
orders (
  ... existing fields ...
  business_id UUID → businesses(id),  -- was tenant_id
  branch_id UUID → branches(id),      -- NULL for online orders
  fulfillment_branch_id UUID → branches(id),  -- set when shipping online order
  order_type VARCHAR CHECK IN ('online','pos'),
  customer_name VARCHAR               -- for POS walk-in
)

-- ── POS sessions (branch-level) ────────────────────────────────────
pos_sessions (
  ... existing fields ...
  business_id UUID → businesses(id),
  branch_id UUID → branches(id)       -- was missing
)
```

---

### Auth Flow (new)

```
1. POST /auth/register   → creates user only (no business)
2. POST /auth/login      → returns generic JWT { user_id, exp }
3. GET  /auth/businesses → list businesses user is member of
        ↓ user picks one (or creates/joins)
4. POST /auth/use-business/:id
                         → validates active membership
                         → returns scoped JWT { user_id, business_id, role, exp }
5. All subsequent API calls use the scoped JWT
6. Switch business → repeat step 4
```

---

### New API Endpoints Required

```
-- Business
POST   /businesses                              create (becomes owner)
GET    /businesses/:id                          get details
PUT    /businesses/:id                          update (owner/admin)
GET    /businesses/slug/:slug                   lookup for join request

-- Membership management
GET    /businesses/:id/members                  list (admin+)
PATCH  /businesses/:id/members/:userId          change role / suspend
DELETE /businesses/:id/members/:userId          remove

-- Join requests
POST   /join-requests                           submit { slug }
GET    /businesses/:id/join-requests            pending list (admin+)
POST   /businesses/:id/join-requests/:id/approve { role }
POST   /businesses/:id/join-requests/:id/reject

-- Invitations
POST   /businesses/:id/invitations              send invite { email, role }
GET    /invitations/:token                      validate token (public)
POST   /invitations/:token/accept               accept (authenticated user)

-- Branches
POST   /businesses/:id/branches                 create
GET    /businesses/:id/branches                 list
GET    /branches/:id                            get
PUT    /branches/:id                            update
POST   /branches/:id/users                      grant user access { userId }
DELETE /branches/:id/users/:userId              revoke access

-- Branch inventory
GET    /branches/:id/products                   list (with inventory)
POST   /branches/:id/products/:productId        activate product at branch
PUT    /branches/:id/products/:productId        update stock / price_override
DELETE /branches/:id/products/:productId        deactivate at branch

-- Business categories (system)
GET    /business-categories                     predefined list

-- Online order fulfillment
POST   /orders/:id/fulfill { branch_id }        assign fulfillment branch
```

---

### Frontend Screens Required

```
Auth flow
  LoginScreen          → unchanged
  RegisterScreen       → unchanged (no business creation)
  BusinessSelectorScreen → after login if multiple businesses
  NoBusinessScreen     → join or create if zero businesses
  SwitchBusinessScreen → from any authenticated screen

Business
  CreateBusinessScreen → name, slug, category, type, contact
  BusinessSettingsScreen → update details (not slug)

Membership
  MembersScreen        → list, change role, remove
  JoinRequestsScreen   → pending approvals (admin+)
  InviteUserScreen     → send invite by email
  PendingApprovalScreen → shown to user after submitting join request

Branches
  BranchListScreen     → list all branches
  CreateBranchScreen   → add new branch
  BranchDetailScreen   → edit, manage access
  BranchAccessScreen   → assign/revoke users for a branch

Branch Inventory
  BranchInventoryScreen → list products at branch, activate/deactivate
  ActivateProductScreen → pick from business catalog to activate at branch

POS
  BranchPickerScreen   → shown before POS gate if multiple branches
  (existing screens updated with branch context)

Online orders
  FulfillmentBranchPicker → shown when shipping an online order
```

---

### Implementation Phases

#### Phase 1 — Identity & Business Core
- Drop `tenant_id` from `users`
- Rename `tenants` → `businesses`, add new columns
- Create `business_categories` (seed predefined list)
- Create `user_business_memberships`, `join_requests`, `invitations`
- New auth flow: generic JWT → `/auth/use-business` → scoped JWT
- `POST /businesses` (create), `GET /auth/businesses`
- Frontend: Register (no business), Login → selector, NoBusinessScreen, CreateBusinessScreen

#### Phase 2 — Join Requests & Invitations
- Join request endpoints + approval flow
- Email invitation system
- Frontend: JoinRequestsScreen, InviteUserScreen, PendingApprovalScreen

#### Phase 3 — Branches
- `branches` table + `user_branch_access`
- Branch CRUD endpoints
- Branch access assignment endpoints
- Auto-create main branch on business creation
- Frontend: BranchListScreen, CreateBranchScreen, BranchAccessScreen

#### Phase 4 — Branch Inventory
- `branch_inventory` table
- Migrate products (tenant_id → business_id)
- Branch inventory endpoints
- POS product lookup updated to use branch_inventory
- Frontend: BranchInventoryScreen, ActivateProductScreen
- POS: BranchPickerScreen

#### Phase 5 — Online Order Fulfillment
- Add `fulfillment_branch_id` to orders
- Fulfillment branch picker on ship action
- Hard block if branch stock insufficient
- Stock deduction from fulfillment branch

---

### What Changes in Existing Modules

| Module | Change |
|---|---|
| Users | Remove `tenant_id` |
| Auth | Generic JWT first, scoped after business selection |
| Customers | `tenant_id` → `business_id` |
| Products | `tenant_id` → `business_id`; add branch_inventory layer |
| Orders | `tenant_id` → `business_id`; add `branch_id`, `fulfillment_branch_id` |
| POS | Add `branch_id` to sessions; product lookup uses branch_inventory |
| RLS | Rename `app.current_tenant` → `app.current_business` throughout |

---
