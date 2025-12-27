# Order Management System - Overview & Planning

## Module Information
**Phase:** Week 4-6 - Order Management  
**Dependencies:** Authentication, Customer, Product modules  
**Status:** Planning Phase  

---

## Executive Summary

The Order Management System is the core transaction module of MERIDIEN. It handles the complete sales order lifecycle from creation to fulfillment, integrating customers, products, inventory, and payments. This module will enable businesses to:

- Create and manage sales orders
- Track order status through the fulfillment workflow
- Manage payments and invoicing
- Automatically update inventory
- Generate sales reports and analytics
- Handle returns and refunds (future enhancement)

---

## Core Entities

### 1. Orders (Main Entity)
The order represents a sales transaction from a customer.

**Key Fields:**
- Order number (auto-generated, human-readable)
- Customer reference
- Order date and timestamps
- Status (draft, pending, confirmed, processing, shipped, delivered, cancelled)
- Subtotal, tax, discount, shipping, total amounts
- Payment status (unpaid, partial, paid, refunded)
- Shipping address
- Notes and custom fields
- Multi-tenant isolation

**Business Rules:**
- Each order must have at least one order item
- Order number must be unique per tenant
- Order total must match sum of items + tax + shipping - discount
- Status transitions must follow defined workflow
- Inventory is reserved when order is confirmed
- Inventory is deducted when order is shipped/delivered
- Cancelled orders release reserved inventory

### 2. Order Items (Line Items)
Individual products within an order.

**Key Fields:**
- Product reference
- Product name (snapshot at order time)
- SKU (snapshot at order time)
- Quantity ordered
- Unit price (snapshot at order time)
- Discount amount/percentage
- Tax amount
- Line total (quantity × price - discount + tax)

**Business Rules:**
- Product details are snapshotted (price, name, SKU) to preserve history
- Quantity must be positive
- Line total must be calculated correctly
- Product must exist and be active at order creation
- Stock availability must be checked (if track_inventory = true)

### 3. Payments
Track payments made against orders.

**Key Fields:**
- Order reference
- Payment date
- Payment method (cash, card, bank_transfer, etc.)
- Amount paid
- Transaction reference
- Payment status (pending, completed, failed, refunded)
- Notes

**Business Rules:**
- Payment amount must be positive
- Total payments cannot exceed order total
- Order payment_status updates based on payments received
- Payment methods are configurable per tenant

### 4. Invoices (Future Enhancement)
Generate invoices for orders.

**Key Fields:**
- Order reference
- Invoice number
- Invoice date
- Due date
- PDF file path
- Status (draft, sent, paid, overdue, cancelled)

---

## Database Schema Design

### Orders Table
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id),
    
    -- Order Identification
    order_number VARCHAR(50) NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Order Status
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    payment_status VARCHAR(50) NOT NULL DEFAULT 'unpaid',
    
    -- Financial Information
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    shipping_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    
    -- Shipping Information
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(100),
    
    -- Additional Information
    notes TEXT,
    internal_notes TEXT,
    custom_fields JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    UNIQUE(tenant_id, order_number)
);

CREATE INDEX idx_orders_tenant_id ON orders(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_customer_id ON orders(customer_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_status ON orders(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_payment_status ON orders(payment_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_order_date ON orders(order_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_order_number ON orders(order_number) WHERE deleted_at IS NULL;
```

### Order Items Table
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    
    -- Product Snapshot (preserved even if product changes/deleted)
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100),
    
    -- Quantity and Pricing
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    line_total DECIMAL(15,2) NOT NULL,
    
    -- Additional Information
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_unit_price CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

### Payments Table
```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Payment Information
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    
    -- Transaction Details
    transaction_reference VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'completed',
    
    -- Additional Information
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT positive_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_tenant_id ON payments(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_payments_order_id ON payments(order_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_payments_payment_date ON payments(payment_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_payments_payment_method ON payments(payment_method) WHERE deleted_at IS NULL;
```

---

## Order Status Workflow

### Status Transitions

```
draft → pending → confirmed → processing → shipped → delivered
  ↓        ↓          ↓           ↓          ↓
  └────────┴──────────┴───────────┴──────────┴─→ cancelled
```

### Status Definitions

1. **draft** - Order created but not submitted
   - Can be edited freely
   - No inventory impact
   - Can be deleted

2. **pending** - Order submitted, awaiting confirmation
   - Customer submitted order
   - Awaiting stock verification
   - Awaiting payment (if required)

3. **confirmed** - Order confirmed and accepted
   - Stock verified/reserved
   - Payment received or approved
   - Ready for processing

4. **processing** - Order being prepared
   - Items being picked/packed
   - Inventory reserved but not yet deducted

5. **shipped** - Order dispatched to customer
   - Inventory deducted from stock
   - Tracking information available
   - Cannot be cancelled (only returned)

6. **delivered** - Order received by customer
   - Transaction complete
   - Cannot be modified

7. **cancelled** - Order cancelled
   - Reserved inventory released
   - Payments refunded if applicable
   - Cannot be reopened (create new order instead)

### Payment Status

1. **unpaid** - No payments received
2. **partial** - Some payment received, balance remaining
3. **paid** - Full payment received
4. **refunded** - Payment returned to customer
5. **overdue** - Payment deadline passed (for invoiced orders)

---

## API Endpoints Design

### Order Endpoints

```
POST   /api/v1/orders              - Create new order
GET    /api/v1/orders              - List orders with filters
GET    /api/v1/orders/:id          - Get order details
PUT    /api/v1/orders/:id          - Update order (limited by status)
DELETE /api/v1/orders/:id          - Delete order (soft delete, only if draft)
POST   /api/v1/orders/:id/confirm  - Confirm order (pending → confirmed)
POST   /api/v1/orders/:id/ship     - Mark as shipped (processing → shipped)
POST   /api/v1/orders/:id/deliver  - Mark as delivered (shipped → delivered)
POST   /api/v1/orders/:id/cancel   - Cancel order (any status except shipped/delivered)
```

### Payment Endpoints

```
POST   /api/v1/orders/:id/payments     - Record payment for order
GET    /api/v1/orders/:id/payments     - List payments for order
GET    /api/v1/payments/:id            - Get payment details
PUT    /api/v1/payments/:id            - Update payment
DELETE /api/v1/payments/:id            - Delete payment (soft delete)
```

### Query Parameters (List Orders)

```
?customer_id=<uuid>           - Filter by customer
?status=<status>              - Filter by order status
?payment_status=<status>      - Filter by payment status
?from_date=<date>             - Orders from date
?to_date=<date>               - Orders to date
?search=<text>                - Search by order number, customer name
?sort_by=<field>              - Sort field (order_date, total_amount, status)
?sort_order=<asc|desc>        - Sort direction
?page=<number>                - Page number
?per_page=<number>            - Items per page
```

---

## Business Logic & Validations

### Order Creation
1. Validate customer exists and is active
2. Validate all products exist and are active
3. Check stock availability for products with track_inventory=true
4. Calculate line totals (quantity × price - discount + tax)
5. Calculate order subtotal (sum of line totals before tax/shipping)
6. Calculate tax amount (based on tenant settings)
7. Apply order-level discount if any
8. Add shipping amount
9. Calculate total amount
10. Generate unique order number
11. Create order with status='draft' or 'pending'
12. Create all order items
13. If auto-confirm enabled, transition to 'confirmed' and reserve inventory

### Order Update
1. Check if order status allows updates (only draft/pending)
2. Validate updated data
3. Recalculate totals if items changed
4. Update timestamps

### Order Confirmation
1. Verify order is in 'pending' status
2. Check stock availability again
3. Reserve inventory (decrement stock or mark as reserved)
4. Update status to 'confirmed'
5. Create inventory transactions (if implementing inventory tracking)

### Order Shipping
1. Verify order is in 'processing' status
2. Deduct inventory from stock (if not already done)
3. Update status to 'shipped'
4. Record shipping date and tracking info

### Order Cancellation
1. Verify order can be cancelled (not shipped/delivered)
2. Release reserved inventory
3. Update status to 'cancelled'
4. Refund payments if applicable

### Payment Recording
1. Validate payment amount > 0
2. Validate payment method
3. Check total payments don't exceed order total
4. Update order.paid_amount
5. Update order.payment_status based on paid vs total:
   - paid_amount = 0 → 'unpaid'
   - paid_amount < total_amount → 'partial'
   - paid_amount >= total_amount → 'paid'

---

## Inventory Integration

### Stock Reservation Strategy

**Option 1: Reserve on Confirmation (Recommended for MVP)**
- Stock reserved when order confirmed
- Stock deducted when order shipped
- Simpler logic, better for businesses with fast fulfillment

**Option 2: Deduct on Confirmation**
- Stock deducted immediately when order confirmed
- Simpler but may oversell if orders are cancelled
- Works for digital products or services

**For MVP:** We'll implement Option 1 with reservation on confirmation.

### Inventory Transactions

Create an audit trail of inventory changes:

```sql
CREATE TABLE inventory_transactions (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    product_id UUID NOT NULL,
    order_id UUID,
    transaction_type VARCHAR(50), -- 'sale', 'return', 'adjustment', 'reservation'
    quantity INTEGER NOT NULL,
    reason TEXT,
    created_at TIMESTAMP
);
```

---

## Reporting & Analytics (Future)

### Key Metrics
- Total sales (daily, weekly, monthly)
- Average order value
- Orders by status
- Payment collection rate
- Top selling products
- Sales by customer
- Revenue trends

### Reports to Implement
1. Sales Summary Report
2. Order Status Report
3. Payment Collection Report
4. Product Performance Report
5. Customer Purchase History

---

## Implementation Plan

### Phase 1: Core Order Management (Week 4)
- [x] Design database schema
- [ ] Create migrations for orders, order_items, payments
- [ ] Create Order, OrderItem, Payment models
- [ ] Create order repository with CRUD operations
- [ ] Create order service with business logic
- [ ] Create order handlers
- [ ] Implement order creation
- [ ] Implement order listing and filtering
- [ ] Test basic CRUD operations

### Phase 2: Order Workflow (Week 5)
- [ ] Implement status transition logic
- [ ] Implement order confirmation with inventory check
- [ ] Implement order shipping
- [ ] Implement order cancellation
- [ ] Create inventory transaction logging
- [ ] Test all status transitions
- [ ] Test inventory integration

### Phase 3: Payments & Finalization (Week 6)
- [ ] Implement payment recording
- [ ] Implement payment status updates
- [ ] Create payment repository and handlers
- [ ] Test payment workflows
- [ ] Create order summary/receipt endpoint
- [ ] Generate sales reports (basic)
- [ ] Integration testing
- [ ] Documentation

---

## Data Models (Go Structs Preview)

### Order Model
```go
type Order struct {
    BaseModel
    TenantID   uuid.UUID
    CustomerID uuid.UUID
    
    // Order Info
    OrderNumber string
    OrderDate   time.Time
    Status      string // draft, pending, confirmed, processing, shipped, delivered, cancelled
    PaymentStatus string // unpaid, partial, paid, refunded
    
    // Financial
    Subtotal       decimal.Decimal
    TaxAmount      decimal.Decimal
    DiscountAmount decimal.Decimal
    ShippingAmount decimal.Decimal
    TotalAmount    decimal.Decimal
    PaidAmount     decimal.Decimal
    
    // Shipping Address
    ShippingAddressLine1 string
    ShippingAddressLine2 string
    ShippingCity         string
    ShippingState        string
    ShippingPostalCode   string
    ShippingCountry      string
    
    // Additional
    Notes         string
    InternalNotes string
    CustomFields  JSONB
    
    // Relationships
    Tenant   *Tenant
    Customer *Customer
    Items    []OrderItem
    Payments []Payment
}
```

### Order Item Model
```go
type OrderItem struct {
    ID        uuid.UUID
    OrderID   uuid.UUID
    ProductID *uuid.UUID // nullable if product deleted
    
    // Snapshot
    ProductName string
    ProductSKU  string
    
    // Pricing
    Quantity       int
    UnitPrice      decimal.Decimal
    DiscountAmount decimal.Decimal
    TaxAmount      decimal.Decimal
    LineTotal      decimal.Decimal
    
    Notes string
    
    // Relationships
    Order   *Order
    Product *Product
}
```

### Payment Model
```go
type Payment struct {
    BaseModel
    TenantID uuid.UUID
    OrderID  uuid.UUID
    
    PaymentDate          time.Time
    PaymentMethod        string
    Amount               decimal.Decimal
    TransactionReference string
    Status               string // pending, completed, failed, refunded
    Notes                string
    
    // Relationships
    Tenant *Tenant
    Order  *Order
}
```

---

## Sample Data for Testing

### Test Scenario 1: Simple Cash Order
- Customer: John Doe
- Items: 2× Wireless Mouse ($29.99 each)
- Subtotal: $59.98
- Tax (10%): $6.00
- Total: $65.98
- Payment: Cash, full payment
- Status Flow: draft → confirmed → shipped → delivered

### Test Scenario 2: Multi-item Order with Discount
- Customer: Jane Smith (Business)
- Items:
  - 5× USB Keyboard ($79.99 each)
  - 10× Wireless Mouse ($29.99 each)
- Subtotal: $699.85
- Discount: $50.00
- Subtotal after discount: $649.85
- Tax (10%): $64.99
- Shipping: $20.00
- Total: $734.84
- Payment: Partial payment $500, balance $234.84
- Status: confirmed → processing

### Test Scenario 3: Cancelled Order
- Customer: Bob Wilson
- Items: 1× Gaming Headset ($99.99)
- Total: $109.99 (with tax)
- Status: draft → pending → cancelled
- Inventory: No stock deduction

---

## Security & Permissions

### Access Control
- **Admin:** Full access to all orders
- **Manager:** View all orders, create orders, update non-delivered orders
- **Staff:** View and create orders, update own orders (if draft/pending)
- **Customer Portal (Future):** View own orders only

### Data Validation
- Tenant isolation on all queries
- Order number uniqueness per tenant
- Amount validations (positive, totals match)
- Status transition validations
- Stock availability checks
- Payment amount limits

---

## Performance Considerations

### Indexing Strategy
- Index on tenant_id, customer_id, status, payment_status
- Index on order_date for date range queries
- Composite index on (tenant_id, order_number) for lookups
- Index on order_items.order_id for joins

### Optimization
- Preload customer and items when fetching order details
- Pagination on order lists (default 20, max 100)
- Cache order counts and totals per tenant
- Use database transactions for order creation

---

## Questions & Decisions Needed

1. **Tax Calculation:** Should tax be calculated automatically or entered manually?
   - **Decision:** Manual for MVP, automatic based on tenant settings in future

2. **Order Number Format:** What format for order numbers?
   - **Decision:** ORD-YYYYMMDD-XXXX (e.g., ORD-20251224-0001)

3. **Inventory Reservation:** When to reserve inventory?
   - **Decision:** Reserve on confirmation, deduct on shipping

4. **Payment Methods:** What payment methods to support?
   - **Decision:** cash, card, bank_transfer, check, other (configurable)

5. **Multiple Shipping Addresses:** Support different shipping address per order?
   - **Decision:** Yes, override customer's default address

6. **Partial Shipments:** Can order be shipped in multiple parts?
   - **Decision:** Not in MVP, add in future enhancement

7. **Order Editing:** Can confirmed orders be edited?
   - **Decision:** No, cancel and create new order instead

---

## Success Criteria

### Functional Requirements
- ✅ Create orders with multiple items
- ✅ Calculate totals accurately (subtotal, tax, discount, shipping)
- ✅ Track order status through workflow
- ✅ Record payments and update payment status
- ✅ Integrate with inventory (check availability, deduct stock)
- ✅ List and filter orders by various criteria
- ✅ Soft delete for data retention

### Technical Requirements
- ✅ Multi-tenant data isolation
- ✅ Database transactions for data consistency
- ✅ Proper error handling and validation
- ✅ RESTful API design
- ✅ Comprehensive testing
- ✅ Documentation

### Performance Requirements
- ✅ Order creation < 500ms
- ✅ Order list endpoint < 1s (for 1000 orders)
- ✅ Support 100+ concurrent order creations
- ✅ Proper indexing for fast queries

---

## Next Steps

1. Review and approve this overview
2. Create database migrations
3. Implement models
4. Build repositories
5. Develop services with business logic
6. Create API handlers
7. Test thoroughly
8. Document API endpoints

**Estimated Timeline:** 3 weeks (Week 4-6 of MVP)

---

**Status:** 📋 Planning Complete - Ready for Implementation  
**Last Updated:** December 24, 2025
