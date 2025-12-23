# Business Management System - MVP & Phased Development Analysis

## Table of Contents
1. [Project Phases Overview](#project-phases-overview)
2. [MVP Phase (Month 1-2)](#mvp-phase-month-1-2)
3. [Production Ready Phase (Month 3-4)](#production-ready-phase-month-3-4)
4. [Scale to 100+ Clients Phase (Month 5-6)](#scale-to-100-clients-phase-month-5-6)
5. [Business Customization Strategy](#business-customization-strategy)
6. [Future-Proofing Considerations](#future-proofing-considerations)
7. [Technical Debt Prevention](#technical-debt-prevention)
8. [Timeline & Resource Allocation](#timeline--resource-allocation)

---

## Project Phases Overview

### Phase Classification

```
┌─────────────────────────────────────────────────────────────────┐
│ MVP (Month 1-2)                                                  │
│ • Core features only                                             │
│ • Single tenant                                                  │
│ • Basic UI/UX                                                    │
│ • Manual deployment                                              │
│ Target: Validate business idea with 1-3 pilot businesses        │
└─────────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Production Ready (Month 3-4)                                     │
│ • Multi-tenancy                                                  │
│ • Enhanced security                                              │
│ • Automated deployment                                           │
│ • Monitoring & logging                                           │
│ Target: Serve 5-10 paying customers reliably                    │
└─────────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Scale to 100+ Clients (Month 5-6)                               │
│ • Performance optimization                                       │
│ • Advanced customization                                         │
│ • Enterprise features                                            │
│ • High availability                                              │
│ Target: Handle 100+ concurrent businesses efficiently           │
└─────────────────────────────────────────────────────────────────┘
```

---

## MVP Phase (Month 1-2)

### Goal
Build a **functional prototype** to validate the business model with 1-3 pilot businesses. Focus on core workflows only.

### Core Features (Must-Have)

#### 1. Authentication (Week 1)
- [ ] User registration (email + password)
- [ ] User login with JWT
- [ ] Logout
- [ ] Basic password validation
- **NO multi-tenancy yet** - Single business mode
- **NO forgot password** - Handle manually if needed
- **NO OAuth/SSO** - Email only

#### 2. Customer Management (Week 1-2)
- [ ] Create customer (name, phone, address, city, government)
- [ ] List customers (simple table with pagination)
- [ ] View customer details
- [ ] Edit customer
- [ ] Delete customer (hard delete for MVP)
- [ ] Basic search by name
- **NO custom fields** - Fixed schema only
- **NO customer ranking** - All treated equally
- **NO CRM notes** - Can add in production phase

**Database: Simple `customers` table**
```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    government VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 3. Product Management (Week 2)
- [ ] Create product (name, price, cost, stock quantity)
- [ ] List products (table view with stock levels)
- [ ] Edit product
- [ ] Delete product
- [ ] Simple stock tracking (number field)
- **NO product images** - Text only
- **NO categories** - Flat list
- **NO suppliers** - Not tracked yet
- **NO discount pricing** - Single price only

**Database: Simple `products` table**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE,
    price DECIMAL(15, 2) NOT NULL,
    cost DECIMAL(15, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. Order Management (Week 3-4)
- [ ] Create order (select customer, add products, calculate total)
- [ ] List orders (with status filter)
- [ ] View order details
- [ ] Update order status manually (dropdown)
- [ ] Basic statuses only: Pending, Confirmed, Shipped, Delivered, Cancelled
- [ ] Auto-deduct stock when order confirmed
- **NO payment tracking** - Assume cash
- **NO tax calculation** - Include tax in price
- **NO shipping integration** - Manual tracking
- **NO invoice generation** - Can add later

**Database: `orders` and `order_items` tables**
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id INT REFERENCES customers(id),
    total_amount DECIMAL(15, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT REFERENCES products(id),
    product_name VARCHAR(255),
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    total_price DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 5. Basic Reporting (Week 4)
- [ ] Revenue summary (total sales for date range)
- [ ] Simple metrics: Total orders, Total revenue, Total profit
- [ ] Product sales report (which products sold most)
- **NO charts** - Numbers only
- **NO complex analytics** - Basic SQL queries
- **NO export** - View only

#### 6. Simple Dashboard (Week 4)
- [ ] Show today's orders count
- [ ] Show this month's revenue
- [ ] Show low stock alerts (products with stock < 5)
- [ ] Quick links to create order/customer/product

### Technology Stack (MVP Simplifications)

#### Backend
- **Go + Gin** (as planned)
- **PostgreSQL** (single database, no multi-tenancy)
- **No Redis** (not needed yet)
- **No Docker** (local development only)
- **No migrations tool** (run SQL files manually)
- **godotenv** for config
- **GORM** for database
- **JWT** for auth (simple implementation)

#### Frontend
- **Flutter Web** (responsive)
- **Riverpod** (state management)
- **dio** (HTTP client)
- **Hive** (store JWT locally)
- **No complex routing** - Simple push/pop navigation
- **Material Design** default theme
- **No localization** - English only for MVP
- **No custom theming** - Standard colors

#### Deployment
- **Manual deployment** to single VPS
- **No CI/CD** - Manual builds
- **No monitoring** - Check logs manually
- **SQLite or PostgreSQL** on VPS
- **Nginx** as reverse proxy
- **No SSL** for initial testing (add before pilot)

### What's Deliberately Excluded from MVP

#### Authentication & Users
- ❌ Multi-user support (single admin user only)
- ❌ Roles & permissions
- ❌ Forgot password flow
- ❌ Email verification
- ❌ Session management

#### Customers
- ❌ Customer ranking/segmentation
- ❌ CRM notes
- ❌ Customer history/statistics
- ❌ Credit limits
- ❌ Custom fields

#### Products
- ❌ Product images
- ❌ Categories
- ❌ Suppliers
- ❌ Discount pricing
- ❌ Product variants
- ❌ Advanced inventory (movements, adjustments)

#### Orders
- ❌ Payment method tracking
- ❌ Tax calculation
- ❌ Shipping costs
- ❌ Order notes
- ❌ Invoice generation
- ❌ Return/refund flow

#### Shipping
- ❌ Shipping carrier integration
- ❌ Tracking numbers
- ❌ Shipping labels
- ❌ Shipping addresses separate from customer

#### Reports
- ❌ Charts and graphs
- ❌ Export to Excel/PDF
- ❌ Advanced analytics
- ❌ Custom date range reports

#### Infrastructure
- ❌ Multi-tenancy
- ❌ Background jobs
- ❌ Caching
- ❌ Rate limiting
- ❌ Monitoring
- ❌ Automated backups

### MVP API Endpoints (Minimal Set)

```
# Auth
POST   /api/auth/login
POST   /api/auth/register
GET    /api/auth/me

# Customers
GET    /api/customers
GET    /api/customers/:id
POST   /api/customers
PUT    /api/customers/:id
DELETE /api/customers/:id

# Products
GET    /api/products
GET    /api/products/:id
POST   /api/products
PUT    /api/products/:id
DELETE /api/products/:id

# Orders
GET    /api/orders
GET    /api/orders/:id
POST   /api/orders
PUT    /api/orders/:id/status

# Reports
GET    /api/reports/revenue?start_date=X&end_date=Y
GET    /api/reports/top-products

# Dashboard
GET    /api/dashboard/stats
```

### MVP Success Criteria

- [ ] Single user can login
- [ ] Can manage 100+ customers
- [ ] Can manage 50+ products
- [ ] Can create and track orders
- [ ] Stock automatically updates
- [ ] Can see revenue reports
- [ ] System doesn't crash with 10 concurrent users
- [ ] Response time < 2 seconds for all operations
- [ ] Mobile responsive (works on tablet/phone)

### Development Timeline (8 weeks)

**Week 1: Foundation**
- Backend: Setup project, database, auth
- Frontend: Setup project, auth screens
- Deliverable: Working login/registration

**Week 2: Customers & Products**
- Backend: Customer & Product APIs
- Frontend: Customer & Product management screens
- Deliverable: CRUD for customers and products

**Week 3: Orders (Part 1)**
- Backend: Order creation API
- Frontend: Order creation flow
- Deliverable: Can create orders

**Week 4: Orders (Part 2)**
- Backend: Order listing, status updates
- Frontend: Order list, order details, status management
- Deliverable: Full order workflow

**Week 5: Reports & Dashboard**
- Backend: Report APIs
- Frontend: Dashboard, reports
- Deliverable: Basic analytics

**Week 6-7: Testing & Bug Fixes**
- Integration testing
- Bug fixes
- UI/UX improvements
- Performance testing

**Week 8: Pilot Deployment**
- Deploy to VPS
- Setup domain and SSL
- Onboard 1-3 pilot businesses
- Gather feedback

---

## Production Ready Phase (Month 3-4)

### Goal
Transform MVP into a **production-grade system** capable of serving 5-10 paying customers with reliability, security, and professional features.

### Critical Additions

#### 1. Multi-Tenancy (Week 9-10)
- [ ] Add `tenants` table
- [ ] Add `tenant_id` to all tables
- [ ] Tenant context middleware
- [ ] Subdomain-based tenant detection
- [ ] Tenant isolation in queries
- [ ] Tenant provisioning workflow
- [ ] Admin panel for tenant management

**Migration Strategy:**
```sql
-- Add tenant support
ALTER TABLE customers ADD COLUMN tenant_id INT REFERENCES tenants(id);
ALTER TABLE products ADD COLUMN tenant_id INT REFERENCES tenants(id);
ALTER TABLE orders ADD COLUMN tenant_id INT REFERENCES tenants(id);

-- Migrate existing data to first tenant
UPDATE customers SET tenant_id = 1;
UPDATE products SET tenant_id = 1;
UPDATE orders SET tenant_id = 1;
```

#### 2. User Management & RBAC (Week 10-11)
- [ ] Multi-user support per tenant
- [ ] Roles table (admin, manager, staff)
- [ ] Permissions system
- [ ] User invitation flow
- [ ] User profile management
- [ ] Activity logging per user

**Default Roles:**
- **Admin**: Full access to tenant
- **Manager**: Can manage orders, products, customers
- **Staff**: Can view and create orders only

#### 3. Enhanced Security (Week 11)
- [ ] Refresh token implementation
- [ ] Token blacklisting (Redis)
- [ ] Password strength requirements
- [ ] Rate limiting (per IP and per user)
- [ ] CORS configuration
- [ ] Input sanitization
- [ ] SQL injection prevention audit
- [ ] XSS prevention
- [ ] HTTPS enforcement
- [ ] Security headers (HSTS, CSP, etc.)

#### 4. Soft Deletes & Audit Trail (Week 11)
- [ ] Add `deleted_at` to all tables
- [ ] Implement soft delete
- [ ] Add `created_by`, `updated_by` fields
- [ ] Audit logs table
- [ ] Track all CRUD operations
- [ ] UI for viewing audit logs (admin only)

#### 5. Advanced Product Features (Week 12)
- [ ] Product categories
- [ ] Product images (upload to S3/MinIO)
- [ ] Discount pricing
- [ ] Product suppliers
- [ ] Stock low alerts
- [ ] Inventory movement tracking

#### 6. Advanced Order Features (Week 12-13)
- [ ] Payment method tracking
- [ ] Payment status
- [ ] Tax calculation (configurable rate per tenant)
- [ ] Shipping cost
- [ ] Order notes (customer-facing and internal)
- [ ] Invoice generation (PDF)
- [ ] Order cancellation workflow
- [ ] Email notifications (order confirmation, status updates)

#### 7. Shipping Integration (Week 13)
- [ ] Shipping info table
- [ ] Manual tracking number entry
- [ ] Shipping status tracking
- [ ] Shipping label upload
- [ ] Basic carrier integration (Posta API)
- **Future:** DHL, Aramex integrations

#### 8. Enhanced Reporting (Week 13)
- [ ] Charts (fl_chart)
- [ ] Date range selectors
- [ ] Export to Excel/CSV
- [ ] Profit margin reports
- [ ] Customer statistics
- [ ] Product performance reports

#### 9. DevOps & Infrastructure (Week 14)
- [ ] Docker containerization
- [ ] docker-compose for local dev
- [ ] Redis for caching and sessions
- [ ] Database migrations (golang-migrate)
- [ ] Automated backups (daily)
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Staging environment
- [ ] Production environment
- [ ] Deployment scripts

#### 10. Monitoring & Logging (Week 14)
- [ ] Structured logging (logrus)
- [ ] Prometheus metrics
- [ ] Grafana dashboards
- [ ] Error tracking (Sentry or similar)
- [ ] Health check endpoints
- [ ] Uptime monitoring
- [ ] Alert system (email/Slack)

#### 11. Background Jobs (Week 14)
- [ ] Async task queue (asynq)
- [ ] Email sending worker
- [ ] Report generation worker
- [ ] Inventory sync worker
- [ ] Revenue calculation worker

#### 12. Customer Features (Week 15)
- [ ] Customer ranking (regular, VIP, platinum)
- [ ] CRM notes
- [ ] Customer order history
- [ ] Customer statistics (total spent, order count, etc.)
- [ ] Customer search improvements

#### 13. Testing (Week 15-16)
- [ ] Unit tests for services (80% coverage)
- [ ] Integration tests for APIs
- [ ] End-to-end tests (critical flows)
- [ ] Load testing (100 concurrent users)
- [ ] Security testing
- [ ] Cross-browser testing (Chrome, Firefox, Safari)

#### 14. UI/UX Improvements (Week 16)
- [ ] Professional theme
- [ ] Responsive design polish
- [ ] Loading states
- [ ] Error handling UI
- [ ] Toast notifications
- [ ] Form validation feedback
- [ ] Keyboard shortcuts
- [ ] Accessibility improvements

### Production Ready Checklist

**Security:**
- [x] HTTPS enabled
- [x] JWT with refresh tokens
- [x] Rate limiting active
- [x] Input validation on all endpoints
- [x] CORS properly configured
- [x] SQL injection prevention verified
- [x] XSS prevention verified
- [x] Passwords hashed with bcrypt
- [x] Secrets stored securely (env vars)

**Reliability:**
- [x] Database backups automated
- [x] Error tracking enabled
- [x] Logging comprehensive
- [x] Health checks implemented
- [x] Monitoring dashboards created
- [x] Alert system configured
- [x] Uptime > 99.5%

**Performance:**
- [x] Response time < 500ms (p95)
- [x] Caching implemented
- [x] Database indexes optimized
- [x] N+1 queries eliminated
- [x] Load tested (100 concurrent users)
- [x] CDN for static assets

**Functionality:**
- [x] Multi-tenancy working
- [x] User roles enforced
- [x] Soft deletes implemented
- [x] Audit logging active
- [x] Email notifications working
- [x] PDF invoice generation
- [x] Reports accurate

**DevOps:**
- [x] CI/CD pipeline functional
- [x] Automated tests passing
- [x] Deployment automated
- [x] Rollback procedure documented
- [x] Staging environment matches production
- [x] Database migration process safe

---

## Scale to 100+ Clients Phase (Month 5-6)

### Goal
Optimize the system to efficiently handle **100+ concurrent tenants** with high performance, advanced customization, and enterprise features.

### Scaling Challenges

1. **Database Performance**: 100+ tenant databases to manage
2. **Connection Pooling**: Thousands of concurrent connections
3. **Resource Isolation**: Prevent one tenant from affecting others
4. **Data Volume**: Millions of records across all tenants
5. **Customization**: Each business has unique needs
6. **Support**: Managing 100+ different configurations

### Solutions & Enhancements

#### 1. Database Optimization (Week 17-18)

**Connection Pooling:**
```go
// PgBouncer configuration
[databases]
* = host=postgres port=5432 pool_mode=transaction

[pgbouncer]
pool_mode = transaction
max_client_conn = 10000
default_pool_size = 25
reserve_pool_size = 5
```

**Database Sharding Strategy:**
- Group tenants by creation date or size
- Shard across multiple PostgreSQL servers
- Use consistent hashing for tenant routing

**Read Replicas:**
- Master for writes
- Read replicas for reports and queries
- Route based on query type

**Index Optimization:**
```sql
-- Composite indexes for common queries
CREATE INDEX idx_orders_tenant_date ON orders(tenant_id, order_date DESC);
CREATE INDEX idx_products_tenant_active ON products(tenant_id, is_active);
CREATE INDEX idx_customers_tenant_name ON customers(tenant_id, name);

-- Partial indexes for performance
CREATE INDEX idx_orders_pending ON orders(tenant_id) WHERE status = 'pending';
```

**Query Optimization:**
- Implement query result caching
- Use materialized views for reports
- Optimize N+1 queries with preloading
- Database query monitoring

#### 2. Caching Strategy (Week 18)

**Redis Cache Layers:**
```
L1: Application Memory Cache (5 min TTL)
    ↓
L2: Redis Cache (1 hour TTL)
    ↓
L3: Database
```

**What to Cache:**
- Tenant metadata (subdomain → tenant_id)
- User permissions (per user_id)
- Product catalog (per tenant)
- Custom field definitions (per tenant)
- Report data (15 min TTL)
- API responses (configurable)

**Cache Invalidation:**
```go
// Invalidate on update
func (s *ProductService) UpdateProduct(product *Product) error {
    if err := s.repo.Update(product); err != nil {
        return err
    }
    
    // Invalidate cache
    s.cache.Delete(fmt.Sprintf("product:%d", product.ID))
    s.cache.Delete(fmt.Sprintf("tenant:%d:products", product.TenantID))
    
    return nil
}
```

#### 3. Custom Fields System (Week 19)

**Dynamic Attributes for Business Customization:**

```go
// Example: Business A needs "Gift Message" for orders
// Example: Business B needs "Batch Number" for products
// Example: Business C needs "WhatsApp Number" for customers

// Custom field definition
type CustomField struct {
    ID          int
    TenantID    int
    EntityType  string  // 'customer', 'product', 'order'
    FieldName   string  // 'whatsapp_number'
    FieldLabel  string  // 'WhatsApp Number'
    FieldType   string  // 'text', 'number', 'date', 'dropdown'
    FieldOptions JSON   // For dropdown: ["option1", "option2"]
    IsRequired  bool
    DisplayOrder int
}

// Custom field value
type CustomFieldValue struct {
    ID            int
    CustomFieldID int
    EntityID      int    // customer_id, product_id, order_id
    EntityType    string
    FieldValue    string
}
```

**API for Custom Fields:**
```
GET    /api/custom-fields?entity_type=customer
POST   /api/custom-fields
PUT    /api/custom-fields/:id
DELETE /api/custom-fields/:id

# Set values
POST   /api/customers/:id/custom-fields
{
  "whatsapp_number": "+9647501234567",
  "preferred_delivery_time": "evening"
}

# Query with custom fields
GET    /api/customers/:id
{
  "id": 123,
  "name": "Ahmed Ali",
  "phone": "07501234567",
  "custom_fields": {
    "whatsapp_number": "+9647501234567",
    "preferred_delivery_time": "evening"
  }
}
```

**Frontend Dynamic Form Builder:**
```dart
// Automatically render form based on custom field definitions
class CustomFieldsForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customFields = ref.watch(customFieldsProvider);
    
    return Column(
      children: customFields.map((field) {
        switch (field.type) {
          case 'text':
            return TextFormField(
              decoration: InputDecoration(labelText: field.label),
              validator: field.isRequired ? requiredValidator : null,
            );
          case 'dropdown':
            return DropdownButtonFormField(
              decoration: InputDecoration(labelText: field.label),
              items: field.options.map((opt) => 
                DropdownMenuItem(value: opt, child: Text(opt))
              ).toList(),
            );
          case 'date':
            return DatePickerField(label: field.label);
          // ... other types
        }
      }).toList(),
    );
  }
}
```

#### 4. Advanced Multi-Tenancy Features (Week 19)

**Tenant-Specific Settings:**
```json
{
  "tenant_id": 123,
  "settings": {
    "theme": {
      "primary_color": "#1976D2",
      "logo_url": "https://..."
    },
    "business_info": {
      "name": "Ahmed's Electronics",
      "tax_id": "123456789",
      "address": "Baghdad, Iraq"
    },
    "features": {
      "enable_shipping": true,
      "enable_invoices": true,
      "enable_sms": false
    },
    "tax": {
      "default_rate": 15.0,
      "tax_number": "TAX123"
    },
    "notifications": {
      "low_stock_threshold": 5,
      "email_on_order": true
    }
  }
}
```

**Tenant Resource Limits:**
```go
type TenantPlan struct {
    MaxUsers        int  // 5 for basic, 50 for pro
    MaxProducts     int  // 500 for basic, unlimited for pro
    MaxOrders       int  // 1000/month for basic
    MaxStorage      int  // 5GB for basic, 50GB for pro
    MaxAPIRequests  int  // 10k/day for basic
}

// Enforce limits in middleware
func CheckTenantLimits() gin.HandlerFunc {
    return func(c *gin.Context) {
        tenant := getTenant(c)
        resource := getResourceType(c)
        
        if exceedsLimit(tenant, resource) {
            c.JSON(403, gin.H{
                "error": "Plan limit exceeded. Please upgrade.",
            })
            c.Abort()
            return
        }
        
        c.Next()
    }
}
```

#### 5. Performance Optimization (Week 20)

**Backend Optimizations:**
- [ ] Implement connection pooling with PgBouncer
- [ ] Add Redis caching layer
- [ ] Optimize database queries
- [ ] Implement lazy loading
- [ ] Use goroutines for parallel processing
- [ ] Add response compression (gzip)
- [ ] Implement HTTP/2
- [ ] CDN for static assets

**Frontend Optimizations:**
- [ ] Code splitting
- [ ] Lazy loading routes
- [ ] Image optimization
- [ ] Virtual scrolling for large lists
- [ ] Debounce search inputs
- [ ] Optimize bundle size
- [ ] Service worker for offline capability
- [ ] Progressive Web App (PWA)

**Performance Targets:**
- API response time p50: < 200ms
- API response time p95: < 500ms
- API response time p99: < 1s
- Database query time: < 100ms
- Page load time: < 2s
- Time to interactive: < 3s
- Support 1000 requests/second
- Support 100 concurrent tenants

#### 6. Advanced Analytics (Week 20)

**Tenant Analytics Dashboard:**
- [ ] Real-time metrics (active users, orders/minute)
- [ ] Customer lifetime value (CLV)
- [ ] Customer acquisition cost (CAC)
- [ ] Churn rate
- [ ] Product performance trends
- [ ] Revenue forecasting
- [ ] Cohort analysis
- [ ] A/B testing framework

**Admin Analytics (Cross-Tenant):**
- [ ] Platform-wide metrics
- [ ] Tenant growth tracking
- [ ] Revenue per tenant
- [ ] Resource usage per tenant
- [ ] Top performing tenants
- [ ] Tenant health scores

#### 7. Enterprise Features (Week 21)

**API Access:**
- [ ] Public API for integrations
- [ ] API key management
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Webhooks (order.created, product.updated, etc.)
- [ ] Rate limiting per API key

**Data Import/Export:**
- [ ] Bulk import (CSV, Excel)
- [ ] Bulk export (CSV, Excel, PDF)
- [ ] Data migration tools
- [ ] Automated backups per tenant
- [ ] Data portability (GDPR compliance)

**Advanced Integrations:**
- [ ] Accounting software (QuickBooks, Xero)
- [ ] Payment gateways (Stripe, PayPal, local ME gateways)
- [ ] Email marketing (Mailchimp, SendGrid)
- [ ] SMS providers (Twilio, local ME providers)
- [ ] Social media (Facebook, Instagram shops)

**White-Label Support:**
- [ ] Custom domain per tenant
- [ ] Custom branding (logo, colors)
- [ ] Custom email templates
- [ ] Custom invoice templates
- [ ] Custom mobile app (future)

#### 8. High Availability (Week 21-22)

**Infrastructure:**
```
                    ┌──────────────────┐
                    │ Load Balancer    │
                    │ (HAProxy/Nginx)  │
                    └────────┬─────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │  API 1  │          │  API 2  │          │  API 3  │
   └────┬────┘          └────┬────┘          └────┬────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼─────────┐
                    │ Redis Cluster    │
                    │ (Sentinel)       │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │ PgBouncer        │
                    └────────┬─────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │ Master  │────────>│ Replica │          │ Replica │
   │   DB    │          │   DB    │          │   DB    │
   └─────────┘          └─────────┘          └─────────┘
```

**Redundancy:**
- [ ] Multiple application servers (horizontal scaling)
- [ ] Database replication (master-replica)
- [ ] Redis Sentinel for cache HA
- [ ] Load balancer with health checks
- [ ] Automated failover
- [ ] Zero-downtime deployments

**Disaster Recovery:**
- [ ] Automated backups (hourly snapshots)
- [ ] Multi-region backup storage
- [ ] Disaster recovery plan documented
- [ ] Regular disaster recovery drills
- [ ] RTO (Recovery Time Objective): < 1 hour
- [ ] RPO (Recovery Point Objective): < 15 minutes

#### 9. Cost Optimization (Week 22)

**Resource Management:**
- [ ] Auto-scaling based on load
- [ ] Scheduled scaling (reduce resources at night)
- [ ] Database connection pooling to reduce connections
- [ ] CDN to reduce bandwidth costs
- [ ] Object storage lifecycle policies
- [ ] Inactive tenant archiving

**Monitoring Costs:**
- [ ] Track costs per tenant
- [ ] Identify expensive queries
- [ ] Optimize storage usage
- [ ] Right-size infrastructure
- [ ] Reserved instances for predictable load

#### 10. Support & Maintenance Tools (Week 22-23)

**Admin Portal:**
- [ ] Tenant management (create, suspend, delete)
- [ ] User impersonation (for support)
- [ ] System health dashboard
- [ ] Logs viewer
- [ ] Database query tool (admin only)
- [ ] Tenant usage statistics

**Customer Support Tools:**
- [ ] In-app chat support
- [ ] Help documentation
- [ ] Video tutorials
- [ ] Feature request tracking
- [ ] Bug reporting
- [ ] Status page (uptime, incidents)

**Automated Maintenance:**
- [ ] Database vacuum/analyze
- [ ] Log rotation
- [ ] Cache warming
- [ ] Dead session cleanup
- [ ] Old data archiving

### Scaling Success Metrics

**Performance:**
- [ ] Supports 100 concurrent tenants
- [ ] 1000+ requests/second
- [ ] < 500ms API response time (p95)
- [ ] 99.9% uptime
- [ ] < 100ms database query time

**Business:**
- [ ] Onboarding time < 10 minutes
- [ ] Tenant churn rate < 5%
- [ ] Customer satisfaction > 4.5/5
- [ ] Support response time < 2 hours
- [ ] Feature request turnaround < 30 days

**Technical:**
- [ ] Zero-downtime deployments
- [ ] Automated scaling working
- [ ] Monitoring covering all critical paths
- [ ] Incident response time < 15 minutes
- [ ] All critical systems redundant

---

## Business Customization Strategy

### The Challenge
Different businesses need different attributes and workflows:
- **Electronics Store**: Needs warranty period, IMEI numbers
- **Clothing Store**: Needs sizes, colors, fabric type
- **Pharmacy**: Needs expiration dates, batch numbers
- **Food Delivery**: Needs delivery time slots, allergen info
- **Dropshipping**: Needs supplier tracking, shipping times

### Solution Architecture

#### 1. Custom Fields (Flexible Attributes)

**Entity Types Supporting Custom Fields:**
- Customers
- Products
- Orders
- Suppliers (future)

**Field Type System:**
```typescript
type FieldType = 
  | 'text'           // Single line text
  | 'textarea'       // Multi-line text
  | 'number'         // Integer
  | 'decimal'        // Decimal number
  | 'currency'       // Money
  | 'date'           // Date only
  | 'datetime'       // Date and time
  | 'time'           // Time only
  | 'dropdown'       // Select one option
  | 'multi_select'   // Select multiple options
  | 'checkbox'       // Boolean (yes/no)
  | 'url'            // URL with validation
  | 'email'          // Email with validation
  | 'phone'          // Phone with validation
  | 'color'          // Color picker
  | 'file'           // File upload
  | 'image'          // Image upload
```

**Example: Electronics Store Custom Fields**
```json
{
  "entity_type": "product",
  "custom_fields": [
    {
      "field_name": "warranty_period",
      "field_label": "Warranty Period (Months)",
      "field_type": "number",
      "is_required": true,
      "default_value": "12"
    },
    {
      "field_name": "imei_number",
      "field_label": "IMEI Number",
      "field_type": "text",
      "is_required": true,
      "validation_pattern": "^[0-9]{15}$"
    },
    {
      "field_name": "condition",
      "field_label": "Condition",
      "field_type": "dropdown",
      "options": ["New", "Refurbished", "Used"],
      "default_value": "New"
    }
  ]
}
```

**Example: Pharmacy Custom Fields**
```json
{
  "entity_type": "product",
  "custom_fields": [
    {
      "field_name": "expiration_date",
      "field_label": "Expiration Date",
      "field_type": "date",
      "is_required": true
    },
    {
      "field_name": "batch_number",
      "field_label": "Batch Number",
      "field_type": "text",
      "is_required": true
    },
    {
      "field_name": "requires_prescription",
      "field_label": "Requires Prescription",
      "field_type": "checkbox",
      "default_value": "false"
    },
    {
      "field_name": "active_ingredient",
      "field_label": "Active Ingredient",
      "field_type": "text"
    }
  ]
}
```

#### 2. Workflow Customization

**Configurable Business Rules:**

```json
{
  "tenant_id": 123,
  "workflow_rules": [
    {
      "name": "Auto-approve small orders",
      "enabled": true,
      "trigger": "order.created",
      "conditions": [
        {"field": "total_amount", "operator": "less_than", "value": 100},
        {"field": "payment_method", "operator": "equals", "value": "prepaid"}
      ],
      "actions": [
        {"type": "set_status", "value": "confirmed"},
        {"type": "send_email", "template": "order_confirmed"},
        {"type": "create_shipment", "carrier": "posta"}
      ]
    },
    {
      "name": "Low stock notification",
      "enabled": true,
      "trigger": "product.stock_updated",
      "conditions": [
        {"field": "stock_quantity", "operator": "less_than", "value": 10}
      ],
      "actions": [
        {"type": "send_notification", "recipients": ["admin"], "message": "Low stock alert"}
      ]
    }
  ]
}
```

**Status Workflow Customization:**
```json
{
  "entity": "order",
  "statuses": [
    {
      "value": "pending_payment",
      "label": "Pending Payment",
      "color": "#FFA500",
      "allowed_transitions": ["confirmed", "cancelled"]
    },
    {
      "value": "confirmed",
      "label": "Confirmed",
      "color": "#4CAF50",
      "allowed_transitions": ["processing", "cancelled"]
    },
    {
      "value": "processing",
      "label": "Processing",
      "color": "#2196F3",
      "allowed_transitions": ["shipped", "cancelled"]
    }
    // Business can add custom statuses
  ]
}
```

#### 3. Template Customization

**Invoice Templates:**
- Default template provided
- Business can customize:
  - Header (logo, business info)
  - Footer (terms, bank details)
  - Colors and fonts
  - Additional fields to show
  - Language

**Email Templates:**
- Order confirmation
- Shipping notification
- Invoice email
- Password reset
- Welcome email

**Template Variables:**
```handlebars
{{business_name}}
{{business_logo}}
{{business_address}}
{{customer_name}}
{{order_number}}
{{order_date}}
{{total_amount}}
{{items}}
{{custom_field.warranty_period}}
```

#### 4. Integration Customization

**Webhook System:**
```json
{
  "webhooks": [
    {
      "event": "order.created",
      "url": "https://business-a.com/webhooks/order",
      "secret": "webhook_secret_key",
      "enabled": true
    },
    {
      "event": "product.stock_low",
      "url": "https://inventory-system.com/notify",
      "enabled": true
    }
  ]
}
```

**Supported Webhook Events:**
- `order.created`
- `order.updated`
- `order.cancelled`
- `product.created`
- `product.updated`
- `product.stock_low`
- `customer.created`
- `invoice.generated`

#### 5. UI Customization

**Tenant Branding:**
```json
{
  "branding": {
    "logo_url": "https://cdn.example.com/tenant123/logo.png",
    "favicon_url": "https://cdn.example.com/tenant123/favicon.ico",
    "primary_color": "#1976D2",
    "secondary_color": "#FFC107",
    "font_family": "Roboto",
    "custom_css": "/* optional custom CSS */"
  }
}
```

**Layout Customization:**
- Show/hide features (e.g., disable shipping if not needed)
- Reorder menu items
- Rename menu items
- Add custom dashboard widgets

#### 6. Field Visibility & Permissions

**Per-Role Field Visibility:**
```json
{
  "entity": "product",
  "field": "cost",
  "visibility": {
    "admin": true,
    "manager": true,
    "staff": false  // Staff can't see product cost
  }
}
```

### Implementation Guidelines

**Database Schema (Custom Fields):**
```sql
-- Already shown in plan-three.md
CREATE TABLE custom_fields (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    entity_type VARCHAR(50) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    field_label VARCHAR(255) NOT NULL,
    field_type VARCHAR(50) NOT NULL,
    field_options JSONB,
    is_required BOOLEAN DEFAULT false,
    validation_rules JSONB,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE(tenant_id, entity_type, field_name)
);

CREATE TABLE custom_field_values (
    id SERIAL PRIMARY KEY,
    custom_field_id INT REFERENCES custom_fields(id) ON DELETE CASCADE,
    entity_id INT NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    field_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(custom_field_id, entity_id)
);
```

**API Pattern:**
```
# Get entity with custom fields
GET /api/products/123
Response:
{
  "id": 123,
  "name": "iPhone 14",
  "price": 999.00,
  "custom_fields": {
    "warranty_period": "12",
    "imei_number": "123456789012345",
    "condition": "New"
  }
}

# Update entity with custom fields
PUT /api/products/123
{
  "name": "iPhone 14 Pro",
  "custom_fields": {
    "warranty_period": "24"
  }
}
```

**Frontend Dynamic Rendering:**
- Fetch custom field definitions on app load (cached)
- Render forms dynamically based on definitions
- Validate based on field rules
- Show/hide fields based on permissions

---

## Future-Proofing Considerations

### Design Decisions for Frictionless Future Expansion

#### 1. Database Design

**DO NOW (Foundation):**
- [ ] Use UUIDs for IDs (future distributed systems)
- [ ] Include `created_at`, `updated_at`, `deleted_at` in all tables
- [ ] Always use foreign keys with proper cascading
- [ ] Design for sharding (include `tenant_id` everywhere)
- [ ] Use JSONB for flexible data (settings, metadata)

**ENABLES FUTURE:**
- Easy migration to distributed databases
- Audit trails without refactoring
- Multi-region deployment
- Data archiving strategies

#### 2. API Design

**DO NOW:**
- [ ] Version APIs from day one (`/api/v1/...`)
- [ ] Use consistent response format
- [ ] Design RESTful endpoints
- [ ] Include pagination in all list endpoints
- [ ] Support filtering and sorting
- [ ] Return resource URLs in responses

**ENABLES FUTURE:**
- Backward compatibility when adding features
- Third-party integrations
- Mobile app development
- Public API offering

**Example:**
```json
{
  "data": {
    "id": 123,
    "type": "product",
    "attributes": { ... },
    "links": {
      "self": "/api/v1/products/123",
      "images": "/api/v1/products/123/images"
    }
  }
}
```

#### 3. Authentication & Authorization

**DO NOW:**
- [ ] JWT with short expiry + refresh tokens
- [ ] Permissions-based (not just roles)
- [ ] Store permissions in token claims
- [ ] Design for OAuth2 flow (even if not implementing yet)

**ENABLES FUTURE:**
- SSO integration (Google, Microsoft)
- Third-party app access (OAuth)
- Fine-grained permissions
- API access tokens

#### 4. File Storage

**DO NOW:**
- [ ] Use S3-compatible storage (MinIO for dev, AWS S3 for prod)
- [ ] Never store files in database
- [ ] Generate pre-signed URLs for uploads
- [ ] Store file metadata separately

**ENABLES FUTURE:**
- Multi-region CDN
- Easy migration between cloud providers
- Efficient file serving
- Advanced features (image processing, virus scanning)

#### 5. Background Jobs

**DO NOW:**
- [ ] Use task queue (asynq) for async operations
- [ ] Design all long-running tasks as background jobs
- [ ] Make jobs idempotent
- [ ] Include retry logic

**ENABLES FUTURE:**
- Horizontal scaling of workers
- Complex workflows (multi-step jobs)
- Scheduled tasks
- Distributed processing

#### 6. Event-Driven Architecture

**DO NOW (Optional but Recommended):**
- [ ] Emit events for important actions
- [ ] Use consistent event naming (`resource.action`)
- [ ] Store events in audit log
- [ ] Design webhook system

**ENABLES FUTURE:**
- Real-time features (WebSockets)
- Complex business rules
- Analytics and tracking
- Third-party integrations
- Event sourcing (if needed)

**Example Events:**
```
order.created
order.updated
order.cancelled
product.stock_low
customer.created
payment.received
shipment.delivered
```

#### 7. Localization

**DO NOW:**
- [ ] Use i18n library from start
- [ ] Store all text in translation files
- [ ] Design database for multi-language (if needed)
- [ ] Use UTF-8 everywhere

**ENABLES FUTURE:**
- Easy addition of new languages
- RTL support (Arabic, Hebrew)
- Regional customization
- Global expansion

#### 8. Configuration Management

**DO NOW:**
- [ ] Use environment variables for config
- [ ] Never hardcode URLs, keys, or constants
- [ ] Use feature flags for new features
- [ ] Make everything configurable

**ENABLES FUTURE:**
- Easy deployment across environments
- A/B testing
- Gradual rollouts
- Tenant-specific features

#### 9. Monitoring & Observability

**DO NOW:**
- [ ] Add request IDs to all logs
- [ ] Use structured logging
- [ ] Instrument code with metrics
- [ ] Add health check endpoints

**ENABLES FUTURE:**
- Distributed tracing
- Performance debugging
- Capacity planning
- Anomaly detection

#### 10. Code Organization

**DO NOW:**
- [ ] Follow clean architecture
- [ ] Separate concerns (handlers, services, repositories)
- [ ] Use dependency injection
- [ ] Write testable code

**ENABLES FUTURE:**
- Easy refactoring
- Microservices migration (if needed)
- Team scalability
- Code reusability

### What NOT to Build Now (But Keep in Mind)

**DON'T BUILD:**
- ❌ Microservices (monolith is fine for 100 tenants)
- ❌ Complex caching (simple Redis is enough)
- ❌ Real-time features (polling is fine initially)
- ❌ Mobile apps (web is enough)
- ❌ Advanced analytics (basic reports are fine)
- ❌ Multi-region deployment
- ❌ AI/ML features
- ❌ Blockchain integration
- ❌ IoT integrations

**BUT DESIGN SO THESE ARE POSSIBLE:**
- Make APIs ready for mobile consumption
- Event system enables real-time later
- Modular code enables microservices extraction
- Database design supports analytics

---

## Technical Debt Prevention

### Common Pitfalls to Avoid

#### 1. Database Anti-Patterns

**AVOID:**
- ❌ No foreign keys (data integrity issues)
- ❌ No indexes (slow queries)
- ❌ EAV (Entity-Attribute-Value) for core data
- ❌ Storing JSON when relational is better
- ❌ No soft deletes (data loss)

**DO:**
- ✅ Proper foreign keys with cascading
- ✅ Index all foreign keys and common query fields
- ✅ Use JSONB for truly flexible data (settings, metadata)
- ✅ Normalize core entities
- ✅ Soft delete important records

#### 2. API Anti-Patterns

**AVOID:**
- ❌ Inconsistent response formats
- ❌ No error codes (just messages)
- ❌ Exposing database IDs without validation
- ❌ No rate limiting
- ❌ Overfetching/underfetching data

**DO:**
- ✅ Consistent response structure
- ✅ Proper HTTP status codes
- ✅ Validate all inputs
- ✅ Rate limiting from day one
- ✅ Return exactly what's needed

#### 3. Security Anti-Patterns

**AVOID:**
- ❌ Storing passwords in plain text
- ❌ No input validation
- ❌ SQL concatenation (SQL injection)
- ❌ No HTTPS in production
- ❌ Exposing sensitive data in logs

**DO:**
- ✅ Hash passwords (bcrypt)
- ✅ Validate and sanitize all inputs
- ✅ Use parameterized queries
- ✅ HTTPS everywhere
- ✅ Redact sensitive data in logs

#### 4. Code Anti-Patterns

**AVOID:**
- ❌ God objects (classes doing too much)
- ❌ Global state
- ❌ Tight coupling
- ❌ No error handling
- ❌ Magic numbers/strings

**DO:**
- ✅ Single Responsibility Principle
- ✅ Dependency injection
- ✅ Loose coupling
- ✅ Proper error handling
- ✅ Named constants

#### 5. Testing Anti-Patterns

**AVOID:**
- ❌ No tests
- ❌ Testing implementation details
- ❌ Brittle tests
- ❌ No integration tests

**DO:**
- ✅ Test critical paths
- ✅ Test behavior, not implementation
- ✅ Stable, reliable tests
- ✅ Unit + Integration + E2E tests

### Refactoring Strategy

**When to Refactor:**
- When adding a third similar feature (rule of three)
- When fixing a bug for the third time
- When code is hard to understand
- When tests are hard to write
- When performance is unacceptable

**How to Refactor Safely:**
1. Write tests for existing behavior
2. Make small, incremental changes
3. Run tests after each change
4. Commit frequently
5. Don't mix refactoring with new features

---

## Timeline & Resource Allocation

### Team Structure

**MVP Phase (2 months):**
- 1 Backend Developer (Go)
- 1 Frontend Developer (Flutter)
- 1 Product Manager (part-time)

**Production Phase (2 months):**
- 1 Senior Backend Developer
- 1 Senior Frontend Developer
- 1 DevOps Engineer (part-time)
- 1 Product Manager

**Scale Phase (2 months):**
- 1 Backend Team Lead
- 1 Frontend Team Lead
- 1 DevOps Engineer (full-time)
- 1 QA Engineer
- 1 Product Manager

### Detailed Timeline

```
Month 1: MVP Development
├── Week 1: Auth + Customers
├── Week 2: Products
├── Week 3: Orders (Part 1)
└── Week 4: Orders (Part 2) + Reports

Month 2: MVP Completion
├── Week 5: Reports + Dashboard
├── Week 6-7: Testing + Bug Fixes
└── Week 8: Deployment + Pilot

Month 3: Production Features
├── Week 9-10: Multi-Tenancy
├── Week 11: Security + RBAC
└── Week 12: Advanced Products

Month 4: Production Completion
├── Week 13: Advanced Orders + Shipping
├── Week 14: DevOps + Monitoring
├── Week 15: Customer Features + Testing
└── Week 16: UI/UX Polish

Month 5: Scaling
├── Week 17-18: Database Optimization
├── Week 19: Custom Fields + Multi-Tenancy
├── Week 20: Performance Optimization
└── Week 21: Enterprise Features

Month 6: Scale Completion
├── Week 22: HA + Cost Optimization
├── Week 23: Support Tools
└── Week 24: Final Testing + Launch
```

### Budget Estimate (Rough)

**Development (6 months):**
- Developers: $50,000 - $80,000
- DevOps: $10,000 - $20,000
- Product Management: $15,000 - $25,000

**Infrastructure (Annual):**
- Servers: $2,000 - $5,000
- Database: $1,000 - $3,000
- CDN/Storage: $500 - $2,000
- Monitoring: $500 - $1,000
- Email/SMS: $500 - $2,000
- Total: ~$4,500 - $13,000/year

**Ongoing (Monthly):**
- Maintenance: $2,000 - $5,000
- Support: $1,000 - $3,000
- Marketing: Variable

---

## Success Metrics by Phase

### MVP Success
- [ ] 3 pilot businesses onboarded
- [ ] 50+ real orders processed
- [ ] Zero critical bugs
- [ ] Positive feedback from pilots
- [ ] < 2s response time

### Production Success
- [ ] 10 paying customers
- [ ] 99% uptime
- [ ] < 4 hour support response
- [ ] NPS score > 40
- [ ] Monthly churn < 10%

### Scale Success
- [ ] 100+ active tenants
- [ ] 99.9% uptime
- [ ] < 500ms API response (p95)
- [ ] < 2 hour support response
- [ ] NPS score > 50
- [ ] Monthly churn < 5%
- [ ] Profitable unit economics

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-23  
**Status:** Draft - Pending Review

**Next Steps:**
1. Review and approve this phased approach
2. Prioritize features within each phase
3. Assign team members to features
4. Set up development environment
5. Begin MVP Week 1 development
