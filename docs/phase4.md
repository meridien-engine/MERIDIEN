# Phase 4 — Branch Inventory Implementation Plan

## Context
Products are currently business-level only (no per-branch stock). Phase 4 adds a `branch_inventory` layer so each branch tracks which products it carries, how many are in stock, and optionally overrides the base price. The POS product lookup also needs to scope results to the active branch instead of searching all business products.

---

## Backend

### 1. Migration — `000013_add_branch_inventory`

**File:** `backend/migrations/000013_add_branch_inventory.up.sql`

```sql
BEGIN;

CREATE TABLE IF NOT EXISTS branch_inventory (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id         UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id           UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  product_id          UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  is_active           BOOLEAN NOT NULL DEFAULT true,
  stock_quantity      INT NOT NULL DEFAULT 0,
  price_override      DECIMAL(15,2),
  low_stock_threshold INT NOT NULL DEFAULT 5,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(branch_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_branch_inv_business_id ON branch_inventory(business_id);
CREATE INDEX IF NOT EXISTS idx_branch_inv_branch_id   ON branch_inventory(branch_id);
CREATE INDEX IF NOT EXISTS idx_branch_inv_product_id  ON branch_inventory(product_id);

CREATE TRIGGER update_branch_inventory_updated_at
  BEFORE UPDATE ON branch_inventory
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE branch_inventory ENABLE ROW LEVEL SECURITY;
CREATE POLICY business_isolation ON branch_inventory
  USING (business_id = current_setting('app.current_business')::uuid);
ALTER TABLE branch_inventory FORCE ROW LEVEL SECURITY;

COMMIT;
```

**Down:** `000013_add_branch_inventory.down.sql`
```sql
BEGIN;
DROP TABLE IF EXISTS branch_inventory;
COMMIT;
```

> Note: No `deleted_at` on this table — deactivate via `is_active=false`, hard-delete the row on DELETE endpoint.

---

### 2. Model — `backend/internal/models/branch_inventory.go`

```go
type BranchInventory struct {
    ID                 uuid.UUID       // BaseModel-style but no deleted_at
    BusinessID         uuid.UUID
    BranchID           uuid.UUID
    ProductID          uuid.UUID
    IsActive           bool            `default:true`
    StockQuantity      int             `default:0`
    PriceOverride      *decimal.Decimal  // nil = use product.base_price
    LowStockThreshold  int             `default:5`
    CreatedAt / UpdatedAt time.Time

    // Preloaded relationships (json output only)
    Product *Product
    Branch  *Branch
}

TableName() → "branch_inventory"
BeforeCreate() → set UUID if nil
```

---

### 3. Repository — `backend/internal/repositories/branch_inventory_repository.go`

Methods (all use `businessTx` for RLS):

| Method | Signature |
|---|---|
| `Create` | `(inv *models.BranchInventory) error` |
| `FindByBranchAndProduct` | `(branchID, productID, businessID uuid.UUID) (*models.BranchInventory, error)` |
| `FindByID` | `(id, businessID uuid.UUID) (*models.BranchInventory, error)` |
| `Update` | `(inv *models.BranchInventory) error` |
| `Delete` | `(branchID, productID, businessID uuid.UUID) error` — hard delete |
| `FindByBranch` | `(branchID, businessID uuid.UUID, page, limit int) ([]BranchInventory, int64, error)` — Preload("Product") |
| `LookupForPOS` | `(query, businessID, branchID uuid.UUID) (*BranchInventory, error)` — match barcode/SKU, is_active=true, Preload("Product") |

---

### 4. Service — `backend/internal/services/branch_inventory_service.go`

```go
type BranchInventoryService struct {
    invRepo    *repositories.BranchInventoryRepository
    branchRepo *repositories.BranchRepository
    productRepo *repositories.ProductRepository
}

func NewBranchInventoryService(inv, branch, product repos) *BranchInventoryService

// Request types
type ActivateProductRequest struct {
    StockQuantity      int             `json:"stock_quantity"`
    PriceOverride      *string         `json:"price_override"`
    LowStockThreshold  *int            `json:"low_stock_threshold"`
}

type UpdateInventoryRequest struct {
    IsActive           *bool           `json:"is_active"`
    StockQuantity      *int            `json:"stock_quantity"`
    PriceOverride      *string         `json:"price_override"`
    LowStockThreshold  *int            `json:"low_stock_threshold"`
}
```

Business logic:
- `ActivateProduct(businessID, branchID, productID, req)` — verify branch belongs to business, verify product belongs to business, check no duplicate, create inventory row
- `UpdateInventory(businessID, branchID, productID, req)` — find row, apply partial updates
- `DeactivateProduct(businessID, branchID, productID)` — hard delete the inventory row
- `ListByBranch(businessID, branchID, page, limit)` — verify branch ownership, list with products
- `LookupForPOS(query, businessID, branchID)` — delegate to repo, return inventory+product

---

### 5. Handler — `backend/internal/handlers/branch_inventory_handler.go`

```go
type BranchInventoryHandler struct {
    service *services.BranchInventoryService
}
```

Endpoints:

| Method | Path | Handler | RBAC |
|---|---|---|---|
| GET | `/branches/:id/products` | `List` | any member |
| POST | `/branches/:id/products/:productId` | `Activate` | admin+ |
| PUT | `/branches/:id/products/:productId` | `Update` | admin+ |
| DELETE | `/branches/:id/products/:productId` | `Deactivate` | admin+ |

Each handler:
1. Parse `:id` as branchID, `:productId` as productID
2. `GetBusinessID(c)` from middleware
3. Call service
4. Return standard `utils.SuccessResponse` / `utils.ErrorResponse`

---

### 6. POS Lookup Update

**File:** `backend/internal/handlers/pos_handler.go` and `backend/internal/services/pos_service.go`

Update `LookupProduct` to accept optional `branch_id` query param:
- If `branch_id` provided → delegate to `BranchInventoryService.LookupForPOS(query, businessID, branchID)` → returns product from active inventory
- If no `branch_id` → keep existing business-wide product lookup (backwards compat)

The handler calls the existing `posService.LookupProduct` unchanged when no branch_id, and calls `branchInventoryService.LookupForPOS` when branch_id is present. This means `BranchInventoryHandler` needs a `LookupProduct` method **or** `POSHandler` gets the branch inventory service injected.

**Simpler approach**: inject `branchInventoryService` into `POSHandler` and add the branch_id branch inside `LookupProduct`.

---

### 7. Router — `backend/internal/router/router.go`

Add to `Setup()` signature: `branchInventoryHandler *handlers.BranchInventoryHandler`

Register inside `protected` group:
```go
branches.GET("/:id/products", branchInventoryHandler.List)
branches.POST("/:id/products/:productId",
    authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner),
    branchInventoryHandler.Activate)
branches.PUT("/:id/products/:productId",
    authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner),
    branchInventoryHandler.Update)
branches.DELETE("/:id/products/:productId",
    authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner),
    branchInventoryHandler.Deactivate)
```

---

### 8. DI Wiring — `backend/cmd/server/main.go`

```go
branchInventoryRepo := repositories.NewBranchInventoryRepository(database.DB)
branchInventoryService := services.NewBranchInventoryService(branchInventoryRepo, branchRepo, productRepo)
branchInventoryHandler := handlers.NewBranchInventoryHandler(branchInventoryService)
// Inject into posHandler too (for branch-scoped lookup)
posService := services.NewPOSService(posSessionRepo, orderRepo, productRepo, paymentRepo, orderService, branchInventoryService)
// Pass branchInventoryHandler to router.Setup(...)
```

---

## Frontend

### 9. Model — `frontend/lib/data/models/branch_inventory_model.dart`

Freezed models:
- `BranchInventoryModel` — all fields + `ProductModel? product`, getters `isLowStock`, `effectivePrice`
- `ActivateProductRequest` — `stockQuantity`, `priceOverride?`, `lowStockThreshold?`
- `UpdateInventoryRequest` — all optional fields

Run `flutter pub run build_runner build --delete-conflicting-outputs` after.

---

### 10. API Endpoints — `frontend/lib/core/constants/api_endpoints.dart`

Add:
```dart
static String branchProducts(String branchId) => '/branches/$branchId/products';
static String branchProductById(String branchId, String productId) =>
    '/branches/$branchId/products/$productId';
```

Also update `productLookup` to accept optional `branchId` param (or keep as-is and pass `branch_id` as query param from repository level).

---

### 11. Repository — `frontend/lib/data/repositories/branch_inventory_repository.dart`

Dio-based, methods: `listByBranch(branchId)`, `activate(branchId, productId, req)`, `update(branchId, productId, req)`, `deactivate(branchId, productId)`.

---

### 12. Repository Provider — `frontend/lib/data/providers/repository_providers.dart`

Add:
```dart
final branchInventoryRepositoryProvider = Provider<BranchInventoryRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BranchInventoryRepository(dio);
});
```

---

### 13. Provider — `frontend/lib/features/branches/providers/branch_inventory_provider.dart`

Plain-Dart `StateNotifier<BranchInventoryState>`:
- `BranchInventoryState` — `items`, `isLoading`, `error`
- Methods: `loadInventory(branchId)`, `activate(branchId, productId, req)`, `update(branchId, productId, req)`, `deactivate(branchId, productId)`
- `branchInventoryProvider` — `StateNotifierProvider`

---

### 14. Screens

**`BranchInventoryScreen`** (`frontend/lib/features/branches/screens/branch_inventory_screen.dart`)
- Takes `branchId` + `branchName` as constructor params
- `ConsumerStatefulWidget`; loads on `initState`
- States: loading spinner, error+retry, empty (no products), list
- Each item tile shows: product name, SKU, stock qty (colored red if low), active badge, price override if set
- FAB "Add Product" → navigate to `ActivateProductScreen`
- Long-press or trailing icon → `UpdateInventoryDialog` (inline dialog for stock/price/active toggle)
- Swipe or delete icon → confirm then deactivate

**`ActivateProductScreen`** (`frontend/lib/features/branches/screens/activate_product_screen.dart`)
- Takes `branchId`
- Uses `productRepositoryProvider` to list business catalog
- Shows filterable list of products NOT yet in branch inventory
- Tap product → sheet/dialog to enter `stockQuantity`, `priceOverride?`, `lowStockThreshold?`
- On confirm → call `branchInventoryProvider.activate(...)`

---

### 15. Router — `frontend/lib/routes/app_router.dart`

Add:
```dart
GoRoute(
  path: '/branches/:id/inventory',
  builder: (context, state) => BranchInventoryScreen(
    branchId: state.pathParameters['id']!,
    branchName: state.extra as String? ?? '',
  ),
),
```

Also add a navigation link from `BranchManagementScreen` tile actions (e.g. "Inventory" button alongside existing "Access" button).

---

### 16. POS Update — `frontend/lib/data/repositories/pos_repository.dart`

Update `lookupProduct(query)` to accept optional `branchId`:
```dart
Future<ProductModel> lookupProduct(String query, {String? branchId}) async {
  final params = <String, dynamic>{'q': query};
  if (branchId != null) params['branch_id'] = branchId;
  final response = await _dio.get(ApiEndpoints.productLookup, queryParameters: params);
  ...
}
```

Update POS screens/provider to pass the active `branchId` from session or local state.

---

### 17. Localization — `frontend/lib/core/localization/app_localizations.dart`

Add getters + EN/AR translations for:

| Key | EN | AR |
|---|---|---|
| `branchInventory` | Branch Inventory | مخزون الفرع |
| `addProduct` | Add Product | إضافة منتج |
| `activateProduct` | Activate Product | تفعيل المنتج |
| `stockQuantity` | Stock Quantity | كمية المخزون |
| `priceOverride` | Price Override | تجاوز السعر |
| `lowStockThreshold` | Low Stock Alert | تنبيه المخزون المنخفض |
| `noInventoryYet` | No products in this branch yet | لا توجد منتجات في هذا الفرع بعد |
| `deactivateProduct` | Remove from Branch | إزالة من الفرع |
| `effectivePrice` | Effective Price | السعر الفعلي |
| `lowStock` | Low Stock | مخزون منخفض |
| `outOfStock` | Out of Stock | نفاد المخزون |
| `inStock` | In Stock | متوفر |
| `active` (already exists, reuse) | — | — |

---

## File Checklist

### New Files
- `backend/migrations/000013_add_branch_inventory.up.sql`
- `backend/migrations/000013_add_branch_inventory.down.sql`
- `backend/internal/models/branch_inventory.go`
- `backend/internal/repositories/branch_inventory_repository.go`
- `backend/internal/services/branch_inventory_service.go`
- `backend/internal/handlers/branch_inventory_handler.go`
- `frontend/lib/data/models/branch_inventory_model.dart`
- `frontend/lib/data/repositories/branch_inventory_repository.dart`
- `frontend/lib/features/branches/providers/branch_inventory_provider.dart`
- `frontend/lib/features/branches/screens/branch_inventory_screen.dart`
- `frontend/lib/features/branches/screens/activate_product_screen.dart`

### Modified Files
- `backend/internal/handlers/pos_handler.go` — inject branchInventoryService, branch-scope lookup
- `backend/internal/services/pos_service.go` — or keep lookup in handler
- `backend/internal/router/router.go` — add handler param + routes
- `backend/cmd/server/main.go` — DI wiring
- `frontend/lib/data/providers/repository_providers.dart` — add provider
- `frontend/lib/core/constants/api_endpoints.dart` — add endpoints
- `frontend/lib/core/localization/app_localizations.dart` — add 12 keys
- `frontend/lib/routes/app_router.dart` — add route
- `frontend/lib/features/branches/screens/branch_management_screen.dart` — add Inventory nav button
- `frontend/lib/data/repositories/pos_repository.dart` — pass branch_id to lookup

---

## Verification

1. Run migration: `./scripts/run-migrations.sh`
2. Start backend: `./scripts/start-server.sh`
3. Test via `/test-api` skill:
   - `POST /branches/:id/products/:productId` → activate
   - `GET /branches/:id/products` → list
   - `PUT /branches/:id/products/:productId` → update stock
   - `DELETE /branches/:id/products/:productId` → deactivate
   - `GET /products/lookup?q=SKU&branch_id=:id` → POS scoped lookup
4. Run `flutter pub run build_runner build --delete-conflicting-outputs`
5. Run frontend: `flutter run -d chrome`
6. Navigate to Branches → tap branch → tap "Inventory" → add product → adjust stock
