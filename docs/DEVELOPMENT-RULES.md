# Development Rules & Guidelines - The Implementation Manifesto

## Table of Contents
1. [Core Principles](#core-principles)
2. [Backend (Go) Rules](#backend-go-rules)
3. [Frontend (Flutter/Dart) Rules](#frontend-flutterdart-rules)
4. [Database Rules](#database-rules)
5. [API Design Rules](#api-design-rules)
6. [Security Rules](#security-rules)
7. [Testing Rules](#testing-rules)
8. [Git & Version Control Rules](#git--version-control-rules)
9. [Code Review Checklist](#code-review-checklist)
10. [Integration Guidelines](#integration-guidelines)

---

## Core Principles

### The Sacred Laws (NEVER Break These)

1. **Security First, Always**
   - Never store sensitive data in plain text
   - Never trust user input
   - Never expose internal IDs without validation
   - Never commit secrets to version control
   - Never skip authentication/authorization checks

2. **Multi-Tenancy is Non-Negotiable**
   - Every database query MUST filter by `tenant_id`
   - Every API endpoint MUST validate tenant context
   - Never allow cross-tenant data access
   - Never share resources between tenants without explicit design

3. **Data Integrity is Sacred**
   - Use foreign keys with proper cascading
   - Use transactions for multi-step operations
   - Never hard delete important data (use soft deletes)
   - Never skip validation
   - Always maintain audit trails

4. **Simplicity Over Cleverness**
   - Write code for humans, not compilers
   - Prefer boring, proven solutions over trendy ones
   - If you need a comment to explain it, refactor it
   - YAGNI (You Aren't Gonna Need It) - build what's needed now

5. **Fail Fast, Fail Loud**
   - Don't swallow errors silently
   - Return errors, don't panic (except in truly exceptional cases)
   - Log errors with context
   - Validate early, validate often

---

## Backend (Go) Rules

### Project Structure

```
internal/
├── config/          # Configuration management
├── database/        # Database connection & migrations
├── models/          # GORM models (database entities)
├── dto/             # Data Transfer Objects (API contracts)
├── repositories/    # Data access layer
├── services/        # Business logic layer
├── handlers/        # HTTP handlers (controllers)
├── middleware/      # HTTP middleware
├── utils/           # Utility functions
├── workers/         # Background jobs
└── integrations/    # External service integrations
```

### Naming Conventions

#### Files
```
✅ customer_service.go
✅ order_repository.go
✅ auth_handler.go
✅ jwt_utils.go

❌ CustomerService.go       (don't use PascalCase for files)
❌ orderRepo.go             (use full words, not abbreviations)
❌ authHandler.go           (use snake_case, not camelCase)
```

#### Variables & Functions
```go
// ✅ CORRECT
var customerName string
var orderTotal decimal.Decimal
func calculateTax(amount decimal.Decimal) decimal.Decimal
func GetCustomerByID(id int) (*models.Customer, error)

// ❌ WRONG
var CustomerName string        // unexported should be camelCase
var order_total decimal.Decimal // don't use snake_case
func CalculateTax()            // exported should have doc comment
func getCustomerById()         // use ID not Id
```

#### Types (Structs, Interfaces)
```go
// ✅ CORRECT
type Customer struct { }
type OrderService interface { }
type CreateCustomerDTO struct { }
type PaginationResponse struct { }

// ❌ WRONG
type customer struct { }           // exported types should be PascalCase
type orderservice interface { }    // use PascalCase
type customerDTO struct { }        // exported types should be PascalCase
```

#### Constants
```go
// ✅ CORRECT
const (
    OrderStatusPending   = "pending"
    OrderStatusConfirmed = "confirmed"
    MaxPageSize          = 100
    DefaultTimeout       = 30 * time.Second
)

// ❌ WRONG
const ORDER_STATUS_PENDING = "pending"  // don't use SCREAMING_SNAKE_CASE
const maxpagesize = 100                 // exported consts should be PascalCase
```

### Code Organization Rules

#### 1. Models (Database Entities)

**Location:** `internal/models/`

```go
// ✅ CORRECT - internal/models/customer.go
package models

import (
    "time"
    "gorm.io/gorm"
)

// Customer represents a customer in the system
type Customer struct {
    ID          uint           `gorm:"primaryKey" json:"id"`
    TenantID    uint           `gorm:"not null;index:idx_customers_tenant" json:"tenant_id"`
    Name        string         `gorm:"type:varchar(255);not null" json:"name"`
    Email       string         `gorm:"type:varchar(255);index" json:"email"`
    Phone       string         `gorm:"type:varchar(50)" json:"phone"`
    Address     string         `gorm:"type:text" json:"address"`
    City        string         `gorm:"type:varchar(100)" json:"city"`
    Government  string         `gorm:"type:varchar(100)" json:"government"`
    IsActive    bool           `gorm:"default:true" json:"is_active"`
    CreatedAt   time.Time      `json:"created_at"`
    UpdatedAt   time.Time      `json:"updated_at"`
    DeletedAt   gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
    CreatedBy   *uint          `gorm:"index" json:"created_by,omitempty"`
    UpdatedBy   *uint          `gorm:"index" json:"updated_by,omitempty"`
    
    // Relationships
    Tenant      Tenant         `gorm:"foreignKey:TenantID" json:"-"`
    Orders      []Order        `gorm:"foreignKey:CustomerID" json:"orders,omitempty"`
}

// TableName overrides the table name
func (Customer) TableName() string {
    return "customers"
}

// BeforeCreate hook
func (c *Customer) BeforeCreate(tx *gorm.DB) error {
    // Add any pre-creation logic here
    return nil
}
```

**Model Rules:**
- ✅ Always include: `ID`, `TenantID`, `CreatedAt`, `UpdatedAt`, `DeletedAt`
- ✅ Use `gorm` tags for database mappings
- ✅ Use `json` tags for API responses
- ✅ Add `json:"-"` to exclude fields from JSON (like Tenant relationship)
- ✅ Use pointers for optional fields (`*uint`, `*string`)
- ✅ Document the struct with a comment
- ✅ Override `TableName()` for explicit table names
- ❌ Never put business logic in models
- ❌ Never put database queries in models

#### 2. DTOs (Data Transfer Objects)

**Location:** `internal/dto/`

```go
// ✅ CORRECT - internal/dto/customer_dto.go
package dto

// CreateCustomerRequest represents the request to create a customer
type CreateCustomerRequest struct {
    Name       string `json:"name" binding:"required,min=2,max=255"`
    Email      string `json:"email" binding:"omitempty,email"`
    Phone      string `json:"phone" binding:"required,min=10,max=50"`
    Address    string `json:"address" binding:"omitempty,max=1000"`
    City       string `json:"city" binding:"required,max=100"`
    Government string `json:"government" binding:"required,max=100"`
}

// UpdateCustomerRequest represents the request to update a customer
type UpdateCustomerRequest struct {
    Name       *string `json:"name" binding:"omitempty,min=2,max=255"`
    Email      *string `json:"email" binding:"omitempty,email"`
    Phone      *string `json:"phone" binding:"omitempty,min=10,max=50"`
    Address    *string `json:"address" binding:"omitempty,max=1000"`
    City       *string `json:"city" binding:"omitempty,max=100"`
    Government *string `json:"government" binding:"omitempty,max=100"`
    IsActive   *bool   `json:"is_active"`
}

// CustomerResponse represents a customer in API responses
type CustomerResponse struct {
    ID         uint      `json:"id"`
    Name       string    `json:"name"`
    Email      string    `json:"email"`
    Phone      string    `json:"phone"`
    Address    string    `json:"address"`
    City       string    `json:"city"`
    Government string    `json:"government"`
    IsActive   bool      `json:"is_active"`
    CreatedAt  time.Time `json:"created_at"`
    UpdatedAt  time.Time `json:"updated_at"`
}

// CustomerListResponse represents paginated customer list
type CustomerListResponse struct {
    Data       []CustomerResponse `json:"data"`
    Pagination PaginationMeta     `json:"pagination"`
}
```

**DTO Rules:**
- ✅ Use `Request` suffix for input DTOs
- ✅ Use `Response` suffix for output DTOs
- ✅ Use `binding` tags for validation
- ✅ Use pointers in update DTOs (allows partial updates)
- ✅ Never expose sensitive fields (passwords, tokens)
- ✅ Keep DTOs flat and simple
- ❌ Never reuse models as DTOs
- ❌ Never put business logic in DTOs

#### 3. Repositories (Data Access Layer)

**Location:** `internal/repositories/`

```go
// ✅ CORRECT - internal/repositories/customer_repository.go
package repositories

import (
    "context"
    "business-management/internal/models"
    "gorm.io/gorm"
)

// CustomerRepository defines the interface for customer data access
type CustomerRepository interface {
    Create(ctx context.Context, customer *models.Customer) error
    GetByID(ctx context.Context, tenantID, id uint) (*models.Customer, error)
    GetAll(ctx context.Context, tenantID uint, filter CustomerFilter) ([]models.Customer, int64, error)
    Update(ctx context.Context, customer *models.Customer) error
    Delete(ctx context.Context, tenantID, id uint) error
    Search(ctx context.Context, tenantID uint, query string) ([]models.Customer, error)
}

// customerRepository implements CustomerRepository
type customerRepository struct {
    db *gorm.DB
}

// NewCustomerRepository creates a new customer repository
func NewCustomerRepository(db *gorm.DB) CustomerRepository {
    return &customerRepository{db: db}
}

// Create creates a new customer
func (r *customerRepository) Create(ctx context.Context, customer *models.Customer) error {
    return r.db.WithContext(ctx).Create(customer).Error
}

// GetByID retrieves a customer by ID (tenant-scoped)
func (r *customerRepository) GetByID(ctx context.Context, tenantID, id uint) (*models.Customer, error) {
    var customer models.Customer
    err := r.db.WithContext(ctx).
        Where("tenant_id = ? AND id = ?", tenantID, id).
        First(&customer).Error
    
    if err != nil {
        return nil, err
    }
    return &customer, nil
}

// GetAll retrieves all customers for a tenant with pagination
func (r *customerRepository) GetAll(ctx context.Context, tenantID uint, filter CustomerFilter) ([]models.Customer, int64, error) {
    var customers []models.Customer
    var total int64
    
    query := r.db.WithContext(ctx).
        Where("tenant_id = ?", tenantID)
    
    // Apply filters
    if filter.IsActive != nil {
        query = query.Where("is_active = ?", *filter.IsActive)
    }
    if filter.City != "" {
        query = query.Where("city = ?", filter.City)
    }
    
    // Count total
    query.Model(&models.Customer{}).Count(&total)
    
    // Apply pagination
    offset := (filter.Page - 1) * filter.Limit
    err := query.
        Offset(offset).
        Limit(filter.Limit).
        Order(filter.SortBy + " " + filter.SortOrder).
        Find(&customers).Error
    
    return customers, total, err
}

// Update updates a customer
func (r *customerRepository) Update(ctx context.Context, customer *models.Customer) error {
    return r.db.WithContext(ctx).
        Model(customer).
        Updates(customer).Error
}

// Delete soft deletes a customer
func (r *customerRepository) Delete(ctx context.Context, tenantID, id uint) error {
    return r.db.WithContext(ctx).
        Where("tenant_id = ? AND id = ?", tenantID, id).
        Delete(&models.Customer{}).Error
}

// CustomerFilter represents filters for customer queries
type CustomerFilter struct {
    Page      int
    Limit     int
    SortBy    string
    SortOrder string
    IsActive  *bool
    City      string
}
```

**Repository Rules:**
- ✅ Define an interface for each repository
- ✅ Use lowercase struct for implementation
- ✅ Always use `context.Context` as first parameter
- ✅ Always filter by `tenant_id` (CRITICAL!)
- ✅ Return errors, don't handle them
- ✅ Use meaningful function names (GetByID, not Get)
- ✅ Use GORM best practices (avoid N+1 queries)
- ❌ Never put business logic in repositories
- ❌ Never call other repositories directly
- ❌ Never skip tenant_id validation

#### 4. Services (Business Logic Layer)

**Location:** `internal/services/`

```go
// ✅ CORRECT - internal/services/customer_service.go
package services

import (
    "context"
    "errors"
    "business-management/internal/dto"
    "business-management/internal/models"
    "business-management/internal/repositories"
)

// CustomerService defines the interface for customer business logic
type CustomerService interface {
    CreateCustomer(ctx context.Context, tenantID uint, req *dto.CreateCustomerRequest) (*dto.CustomerResponse, error)
    GetCustomer(ctx context.Context, tenantID, id uint) (*dto.CustomerResponse, error)
    ListCustomers(ctx context.Context, tenantID uint, filter repositories.CustomerFilter) (*dto.CustomerListResponse, error)
    UpdateCustomer(ctx context.Context, tenantID, id uint, req *dto.UpdateCustomerRequest) (*dto.CustomerResponse, error)
    DeleteCustomer(ctx context.Context, tenantID, id uint) error
    SearchCustomers(ctx context.Context, tenantID uint, query string) ([]dto.CustomerResponse, error)
}

// customerService implements CustomerService
type customerService struct {
    customerRepo repositories.CustomerRepository
    auditService AuditService
}

// NewCustomerService creates a new customer service
func NewCustomerService(
    customerRepo repositories.CustomerRepository,
    auditService AuditService,
) CustomerService {
    return &customerService{
        customerRepo: customerRepo,
        auditService: auditService,
    }
}

// CreateCustomer creates a new customer
func (s *customerService) CreateCustomer(ctx context.Context, tenantID uint, req *dto.CreateCustomerRequest) (*dto.CustomerResponse, error) {
    // Validate business rules
    if err := s.validateCustomerEmail(ctx, tenantID, req.Email); err != nil {
        return nil, err
    }
    
    // Map DTO to model
    customer := &models.Customer{
        TenantID:   tenantID,
        Name:       req.Name,
        Email:      req.Email,
        Phone:      req.Phone,
        Address:    req.Address,
        City:       req.City,
        Government: req.Government,
        IsActive:   true,
    }
    
    // Set created_by from context
    if userID := getUserIDFromContext(ctx); userID != nil {
        customer.CreatedBy = userID
    }
    
    // Create in database
    if err := s.customerRepo.Create(ctx, customer); err != nil {
        return nil, err
    }
    
    // Log audit trail
    s.auditService.LogCreate(ctx, "customer", customer.ID, customer)
    
    // Map model to response
    return s.mapToResponse(customer), nil
}

// GetCustomer retrieves a customer by ID
func (s *customerService) GetCustomer(ctx context.Context, tenantID, id uint) (*dto.CustomerResponse, error) {
    customer, err := s.customerRepo.GetByID(ctx, tenantID, id)
    if err != nil {
        return nil, err
    }
    
    return s.mapToResponse(customer), nil
}

// UpdateCustomer updates a customer
func (s *customerService) UpdateCustomer(ctx context.Context, tenantID, id uint, req *dto.UpdateCustomerRequest) (*dto.CustomerResponse, error) {
    // Get existing customer
    customer, err := s.customerRepo.GetByID(ctx, tenantID, id)
    if err != nil {
        return nil, err
    }
    
    // Store old values for audit
    oldValues := *customer
    
    // Apply updates (only non-nil fields)
    if req.Name != nil {
        customer.Name = *req.Name
    }
    if req.Email != nil {
        customer.Email = *req.Email
    }
    // ... other fields
    
    // Set updated_by from context
    if userID := getUserIDFromContext(ctx); userID != nil {
        customer.UpdatedBy = userID
    }
    
    // Update in database
    if err := s.customerRepo.Update(ctx, customer); err != nil {
        return nil, err
    }
    
    // Log audit trail
    s.auditService.LogUpdate(ctx, "customer", customer.ID, &oldValues, customer)
    
    return s.mapToResponse(customer), nil
}

// DeleteCustomer deletes a customer
func (s *customerService) DeleteCustomer(ctx context.Context, tenantID, id uint) error {
    // Check if customer has orders
    hasOrders, err := s.customerRepo.HasOrders(ctx, tenantID, id)
    if err != nil {
        return err
    }
    if hasOrders {
        return errors.New("cannot delete customer with existing orders")
    }
    
    // Delete
    if err := s.customerRepo.Delete(ctx, tenantID, id); err != nil {
        return err
    }
    
    // Log audit trail
    s.auditService.LogDelete(ctx, "customer", id)
    
    return nil
}

// Private helper methods
func (s *customerService) validateCustomerEmail(ctx context.Context, tenantID uint, email string) error {
    if email == "" {
        return nil // Email is optional
    }
    
    // Check if email already exists
    existing, _ := s.customerRepo.GetByEmail(ctx, tenantID, email)
    if existing != nil {
        return errors.New("email already exists")
    }
    
    return nil
}

func (s *customerService) mapToResponse(customer *models.Customer) *dto.CustomerResponse {
    return &dto.CustomerResponse{
        ID:         customer.ID,
        Name:       customer.Name,
        Email:      customer.Email,
        Phone:      customer.Phone,
        Address:    customer.Address,
        City:       customer.City,
        Government: customer.Government,
        IsActive:   customer.IsActive,
        CreatedAt:  customer.CreatedAt,
        UpdatedAt:  customer.UpdatedAt,
    }
}
```

**Service Rules:**
- ✅ Define an interface for each service
- ✅ Inject dependencies via constructor
- ✅ Implement business logic here
- ✅ Validate business rules
- ✅ Orchestrate multiple repositories
- ✅ Handle transactions when needed
- ✅ Log audit trails
- ✅ Map between DTOs and models
- ✅ Return descriptive errors
- ❌ Never access database directly (use repositories)
- ❌ Never handle HTTP concerns (that's for handlers)
- ❌ Never skip tenant_id validation

#### 5. Handlers (HTTP Controllers)

**Location:** `internal/handlers/`

```go
// ✅ CORRECT - internal/handlers/customer_handler.go
package handlers

import (
    "net/http"
    "strconv"
    
    "business-management/internal/dto"
    "business-management/internal/services"
    "business-management/internal/utils"
    
    "github.com/gin-gonic/gin"
)

// CustomerHandler handles customer HTTP requests
type CustomerHandler struct {
    customerService services.CustomerService
}

// NewCustomerHandler creates a new customer handler
func NewCustomerHandler(customerService services.CustomerService) *CustomerHandler {
    return &CustomerHandler{
        customerService: customerService,
    }
}

// Create godoc
// @Summary Create a new customer
// @Description Create a new customer for the authenticated tenant
// @Tags customers
// @Accept json
// @Produce json
// @Param customer body dto.CreateCustomerRequest true "Customer data"
// @Success 201 {object} utils.SuccessResponse{data=dto.CustomerResponse}
// @Failure 400 {object} utils.ErrorResponse
// @Failure 401 {object} utils.ErrorResponse
// @Failure 422 {object} utils.ErrorResponse
// @Security BearerAuth
// @Router /customers [post]
func (h *CustomerHandler) Create(c *gin.Context) {
    // Get tenant ID from context (set by auth middleware)
    tenantID := utils.GetTenantID(c)
    
    // Parse and validate request
    var req dto.CreateCustomerRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request", err)
        return
    }
    
    // Call service
    customer, err := h.customerService.CreateCustomer(c.Request.Context(), tenantID, &req)
    if err != nil {
        utils.ErrorResponse(c, http.StatusUnprocessableEntity, "Failed to create customer", err)
        return
    }
    
    // Return success response
    utils.SuccessResponse(c, http.StatusCreated, "Customer created successfully", customer)
}

// GetByID godoc
// @Summary Get customer by ID
// @Description Get a customer by ID for the authenticated tenant
// @Tags customers
// @Produce json
// @Param id path int true "Customer ID"
// @Success 200 {object} utils.SuccessResponse{data=dto.CustomerResponse}
// @Failure 404 {object} utils.ErrorResponse
// @Security BearerAuth
// @Router /customers/{id} [get]
func (h *CustomerHandler) GetByID(c *gin.Context) {
    tenantID := utils.GetTenantID(c)
    
    // Parse ID from URL
    id, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        utils.ErrorResponse(c, http.StatusBadRequest, "Invalid customer ID", err)
        return
    }
    
    // Call service
    customer, err := h.customerService.GetCustomer(c.Request.Context(), tenantID, uint(id))
    if err != nil {
        utils.ErrorResponse(c, http.StatusNotFound, "Customer not found", err)
        return
    }
    
    utils.SuccessResponse(c, http.StatusOK, "Customer retrieved successfully", customer)
}

// List godoc
// @Summary List customers
// @Description Get paginated list of customers for the authenticated tenant
// @Tags customers
// @Produce json
// @Param page query int false "Page number" default(1)
// @Param limit query int false "Items per page" default(20)
// @Param sort_by query string false "Sort field" default(created_at)
// @Param sort_order query string false "Sort order (asc/desc)" default(desc)
// @Param is_active query bool false "Filter by active status"
// @Param city query string false "Filter by city"
// @Success 200 {object} utils.SuccessResponse{data=dto.CustomerListResponse}
// @Failure 400 {object} utils.ErrorResponse
// @Security BearerAuth
// @Router /customers [get]
func (h *CustomerHandler) List(c *gin.Context) {
    tenantID := utils.GetTenantID(c)
    
    // Parse query parameters
    filter := repositories.CustomerFilter{
        Page:      utils.ParseInt(c.Query("page"), 1),
        Limit:     utils.ParseInt(c.Query("limit"), 20),
        SortBy:    utils.DefaultString(c.Query("sort_by"), "created_at"),
        SortOrder: utils.DefaultString(c.Query("sort_order"), "desc"),
    }
    
    // Validate limit (max 100)
    if filter.Limit > 100 {
        filter.Limit = 100
    }
    
    // Parse optional filters
    if isActive := c.Query("is_active"); isActive != "" {
        active := isActive == "true"
        filter.IsActive = &active
    }
    if city := c.Query("city"); city != "" {
        filter.City = city
    }
    
    // Call service
    customers, err := h.customerService.ListCustomers(c.Request.Context(), tenantID, filter)
    if err != nil {
        utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to list customers", err)
        return
    }
    
    utils.SuccessResponse(c, http.StatusOK, "Customers retrieved successfully", customers)
}

// Update godoc
// @Summary Update customer
// @Description Update an existing customer
// @Tags customers
// @Accept json
// @Produce json
// @Param id path int true "Customer ID"
// @Param customer body dto.UpdateCustomerRequest true "Customer data"
// @Success 200 {object} utils.SuccessResponse{data=dto.CustomerResponse}
// @Failure 400 {object} utils.ErrorResponse
// @Failure 404 {object} utils.ErrorResponse
// @Security BearerAuth
// @Router /customers/{id} [put]
func (h *CustomerHandler) Update(c *gin.Context) {
    tenantID := utils.GetTenantID(c)
    
    id, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        utils.ErrorResponse(c, http.StatusBadRequest, "Invalid customer ID", err)
        return
    }
    
    var req dto.UpdateCustomerRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request", err)
        return
    }
    
    customer, err := h.customerService.UpdateCustomer(c.Request.Context(), tenantID, uint(id), &req)
    if err != nil {
        utils.ErrorResponse(c, http.StatusUnprocessableEntity, "Failed to update customer", err)
        return
    }
    
    utils.SuccessResponse(c, http.StatusOK, "Customer updated successfully", customer)
}

// Delete godoc
// @Summary Delete customer
// @Description Soft delete a customer
// @Tags customers
// @Produce json
// @Param id path int true "Customer ID"
// @Success 204
// @Failure 400 {object} utils.ErrorResponse
// @Failure 404 {object} utils.ErrorResponse
// @Security BearerAuth
// @Router /customers/{id} [delete]
func (h *CustomerHandler) Delete(c *gin.Context) {
    tenantID := utils.GetTenantID(c)
    
    id, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        utils.ErrorResponse(c, http.StatusBadRequest, "Invalid customer ID", err)
        return
    }
    
    if err := h.customerService.DeleteCustomer(c.Request.Context(), tenantID, uint(id)); err != nil {
        utils.ErrorResponse(c, http.StatusUnprocessableEntity, "Failed to delete customer", err)
        return
    }
    
    c.Status(http.StatusNoContent)
}
```

**Handler Rules:**
- ✅ Handle HTTP concerns only (parsing, validation, responses)
- ✅ Get tenant_id from context (set by middleware)
- ✅ Use Swagger comments for API documentation
- ✅ Validate input using Gin's binding
- ✅ Parse query parameters with defaults
- ✅ Use consistent response format (utils.SuccessResponse/ErrorResponse)
- ✅ Return appropriate HTTP status codes
- ✅ Pass context to service layer
- ❌ Never put business logic in handlers
- ❌ Never access database directly
- ❌ Never handle errors silently

#### 6. Middleware

**Location:** `internal/middleware/`

```go
// ✅ CORRECT - internal/middleware/auth.go
package middleware

import (
    "net/http"
    "strings"
    
    "business-management/internal/utils"
    
    "github.com/gin-gonic/gin"
)

// AuthMiddleware validates JWT and sets user context
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Extract token from Authorization header
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            c.JSON(http.StatusUnauthorized, gin.H{
                "success": false,
                "message": "Authorization header required",
            })
            c.Abort()
            return
        }
        
        // Check Bearer scheme
        parts := strings.Split(authHeader, " ")
        if len(parts) != 2 || parts[0] != "Bearer" {
            c.JSON(http.StatusUnauthorized, gin.H{
                "success": false,
                "message": "Invalid authorization header format",
            })
            c.Abort()
            return
        }
        
        token := parts[1]
        
        // Validate token
        claims, err := utils.ValidateJWT(token)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{
                "success": false,
                "message": "Invalid or expired token",
            })
            c.Abort()
            return
        }
        
        // Set context values
        c.Set("user_id", claims.UserID)
        c.Set("tenant_id", claims.TenantID)
        c.Set("email", claims.Email)
        c.Set("role", claims.Role)
        
        c.Next()
    }
}

// ✅ CORRECT - internal/middleware/rbac.go
// RequirePermission checks if user has required permission
func RequirePermission(permission string) gin.HandlerFunc {
    return func(c *gin.Context) {
        userID := c.GetUint("user_id")
        
        // Get user permissions (from cache or database)
        permissions, err := getPermissions(userID)
        if err != nil {
            c.JSON(http.StatusForbidden, gin.H{
                "success": false,
                "message": "Failed to check permissions",
            })
            c.Abort()
            return
        }
        
        // Check if user has the required permission
        if !hasPermission(permissions, permission) {
            c.JSON(http.StatusForbidden, gin.H{
                "success": false,
                "message": "Insufficient permissions",
            })
            c.Abort()
            return
        }
        
        c.Next()
    }
}

// ✅ CORRECT - internal/middleware/tenant.go
// TenantMiddleware validates tenant context
func TenantMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        tenantID := c.GetUint("tenant_id")
        
        if tenantID == 0 {
            c.JSON(http.StatusBadRequest, gin.H{
                "success": false,
                "message": "Invalid tenant context",
            })
            c.Abort()
            return
        }
        
        // Optionally: validate tenant is active
        // tenant, err := getTenant(tenantID)
        // if err != nil || !tenant.IsActive { ... }
        
        c.Next()
    }
}
```

**Middleware Rules:**
- ✅ Keep middleware focused on one concern
- ✅ Call `c.Abort()` when rejecting requests
- ✅ Call `c.Next()` when allowing requests
- ✅ Set context values for downstream handlers
- ✅ Return consistent error responses
- ❌ Never put business logic in middleware
- ❌ Never query database excessively (use caching)

### Error Handling

```go
// ✅ CORRECT - internal/utils/errors.go
package utils

import "errors"

var (
    ErrNotFound          = errors.New("resource not found")
    ErrUnauthorized      = errors.New("unauthorized")
    ErrForbidden         = errors.New("forbidden")
    ErrInvalidInput      = errors.New("invalid input")
    ErrDuplicateEntry    = errors.New("duplicate entry")
    ErrTenantMismatch    = errors.New("tenant mismatch")
)

// Custom error types
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return e.Field + ": " + e.Message
}
```

**Error Handling Rules:**
- ✅ Define error variables for common errors
- ✅ Use `errors.New()` for simple errors
- ✅ Create custom error types for complex errors
- ✅ Wrap errors with context using `fmt.Errorf("context: %w", err)`
- ✅ Check errors with `errors.Is()` and `errors.As()`
- ❌ Never ignore errors
- ❌ Never panic in production code (except in main/init)

### Logging

```go
// ✅ CORRECT
log.WithFields(log.Fields{
    "tenant_id":  tenantID,
    "user_id":    userID,
    "request_id": requestID,
    "action":     "create_customer",
    "customer_id": customer.ID,
}).Info("Customer created successfully")

log.WithFields(log.Fields{
    "tenant_id": tenantID,
    "error":     err.Error(),
}).Error("Failed to create customer")

// ❌ WRONG
log.Println("Customer created")  // No context
fmt.Println("Error:", err)       // Don't use fmt for logging
```

**Logging Rules:**
- ✅ Use structured logging (logrus with fields)
- ✅ Include context (tenant_id, user_id, request_id)
- ✅ Use appropriate log levels (Debug, Info, Warn, Error)
- ✅ Log errors with full context
- ✅ Redact sensitive data (passwords, tokens)
- ❌ Never log passwords or tokens
- ❌ Never use `fmt.Println` for logging

---

## Frontend (Flutter/Dart) Rules

### Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/                # Core utilities
│   ├── constants/
│   ├── config/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── utils/
│   └── themes/
├── shared/              # Shared across features
│   ├── widgets/
│   ├── models/
│   ├── providers/
│   └── services/
├── features/            # Feature modules
│   ├── auth/
│   ├── customers/
│   ├── products/
│   ├── orders/
│   └── dashboard/
└── routes/              # Navigation
```

### Naming Conventions

#### Files
```
✅ customer_list_page.dart
✅ customer_card.dart
✅ auth_controller.dart
✅ api_client.dart

❌ CustomerListPage.dart    (don't use PascalCase for files)
❌ customerCard.dart         (use snake_case)
❌ AuthCtrl.dart            (use full words)
```

#### Classes
```dart
// ✅ CORRECT
class CustomerListPage extends StatelessWidget { }
class CustomerCard extends StatelessWidget { }
class AuthController extends StateNotifier { }
class ApiClient { }

// ❌ WRONG
class customerListPage { }    // Use PascalCase
class Customer_Card { }       // Don't use underscores
```

#### Variables & Functions
```dart
// ✅ CORRECT
String customerName;
int orderId;
void createCustomer() { }
Future<Customer> fetchCustomer() async { }

// ❌ WRONG
String CustomerName;          // Use camelCase for variables
int order_id;                 // Don't use snake_case
void CreateCustomer() { }     // Use camelCase for functions
```

#### Constants
```dart
// ✅ CORRECT
const String apiBaseUrl = 'https://api.example.com';
const int maxPageSize = 100;
const Duration defaultTimeout = Duration(seconds: 30);

// ❌ WRONG
const String API_BASE_URL = '...';  // Don't use SCREAMING_SNAKE_CASE
const String ApiBaseUrl = '...';    // Use camelCase
```

### Code Organization Rules

#### 1. Models (Freezed with JSON)

**Location:** `lib/shared/models/` or `lib/features/{feature}/data/models/`

```dart
// ✅ CORRECT - lib/shared/models/customer.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required int id,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? city,
    String? government,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

// Request DTOs
@freezed
class CreateCustomerRequest with _$CreateCustomerRequest {
  const factory CreateCustomerRequest({
    required String name,
    required String phone,
    String? email,
    String? address,
    required String city,
    required String government,
  }) = _CreateCustomerRequest;

  factory CreateCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCustomerRequestFromJson(json);
}
```

**Model Rules:**
- ✅ Use Freezed for immutability
- ✅ Use `required` for non-nullable fields
- ✅ Use `?` for nullable fields
- ✅ Use `@Default()` for default values
- ✅ Separate request/response models
- ✅ Generate JSON serialization
- ❌ Never make models mutable
- ❌ Never put business logic in models

#### 2. Providers (Riverpod)

**Location:** `lib/features/{feature}/presentation/providers/`

```dart
// ✅ CORRECT - lib/features/customers/presentation/providers/customer_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:business_management/shared/models/customer.dart';
import 'package:business_management/shared/services/customer_service.dart';

// State
@freezed
class CustomerListState with _$CustomerListState {
  const factory CustomerListState({
    @Default([]) List<Customer> customers,
    @Default(false) bool isLoading,
    @Default(1) int currentPage,
    @Default(0) int totalPages,
    String? error,
  }) = _CustomerListState;
}

// Controller
class CustomerListController extends StateNotifier<CustomerListState> {
  final CustomerService _customerService;

  CustomerListController(this._customerService)
      : super(const CustomerListState());

  Future<void> loadCustomers({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _customerService.getCustomers(page: page);
      
      state = state.copyWith(
        customers: result.data,
        currentPage: result.pagination.currentPage,
        totalPages: result.pagination.totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createCustomer(CreateCustomerRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _customerService.createCustomer(request);
      await loadCustomers(); // Reload list
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow; // Let UI handle error
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _customerService.deleteCustomer(id);
      await loadCustomers(); // Reload list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Provider
final customerListControllerProvider =
    StateNotifierProvider<CustomerListController, CustomerListState>((ref) {
  final customerService = ref.watch(customerServiceProvider);
  return CustomerListController(customerService);
});
```

**Provider Rules:**
- ✅ Use Freezed for state classes
- ✅ Use StateNotifier for mutable state
- ✅ Keep controllers focused on one feature
- ✅ Handle loading and error states
- ✅ Inject dependencies via constructor
- ✅ Use `ref.watch()` for dependencies
- ❌ Never access BuildContext in providers
- ❌ Never put UI logic in providers

#### 3. Services (API Calls)

**Location:** `lib/shared/services/`

```dart
// ✅ CORRECT - lib/shared/services/customer_service.dart
import 'package:dio/dio.dart';
import 'package:business_management/core/network/api_client.dart';
import 'package:business_management/shared/models/customer.dart';
import 'package:business_management/shared/models/pagination.dart';

class CustomerService {
  final ApiClient _apiClient;

  CustomerService(this._apiClient);

  Future<PaginatedResponse<Customer>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await _apiClient.get(
        '/customers',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
        },
      );

      return PaginatedResponse<Customer>.fromJson(
        response.data,
        (json) => Customer.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Customer> getCustomer(int id) async {
    try {
      final response = await _apiClient.get('/customers/$id');
      return Customer.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Customer> createCustomer(CreateCustomerRequest request) async {
    try {
      final response = await _apiClient.post(
        '/customers',
        data: request.toJson(),
      );
      return Customer.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Customer> updateCustomer(
    int id,
    UpdateCustomerRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '/customers/$id',
        data: request.toJson(),
      );
      return Customer.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _apiClient.delete('/customers/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'An error occurred';
      return Exception(message);
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}

// Provider
final customerServiceProvider = Provider<CustomerService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerService(apiClient);
});
```

**Service Rules:**
- ✅ Handle API calls only
- ✅ Use ApiClient for HTTP requests
- ✅ Convert JSON to models
- ✅ Handle errors consistently
- ✅ Return typed responses
- ❌ Never handle UI state in services
- ❌ Never store data in services (use providers)

#### 4. Pages (Screens)

**Location:** `lib/features/{feature}/presentation/pages/`

```dart
// ✅ CORRECT - lib/features/customers/presentation/pages/customer_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerListPage extends ConsumerStatefulWidget {
  const CustomerListPage({super.key});

  @override
  ConsumerState<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends ConsumerState<CustomerListPage> {
  @override
  void initState() {
    super.initState();
    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerListControllerProvider.notifier).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateCustomer(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CustomerListState state) {
    if (state.isLoading && state.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            ElevatedButton(
              onPressed: () => ref
                  .read(customerListControllerProvider.notifier)
                  .loadCustomers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.customers.isEmpty) {
      return const Center(child: Text('No customers found'));
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(customerListControllerProvider.notifier)
          .loadCustomers(),
      child: ListView.builder(
        itemCount: state.customers.length,
        itemBuilder: (context, index) {
          final customer = state.customers[index];
          return CustomerCard(
            customer: customer,
            onTap: () => _navigateToCustomerDetail(customer.id),
            onDelete: () => _deleteCustomer(customer.id),
          );
        },
      ),
    );
  }

  void _navigateToCreateCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerFormPage(),
      ),
    ).then((_) {
      // Refresh list after returning
      ref.read(customerListControllerProvider.notifier).loadCustomers();
    });
  }

  void _navigateToCustomerDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailPage(customerId: id),
      ),
    );
  }

  Future<void> _deleteCustomer(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(customerListControllerProvider.notifier)
            .deleteCustomer(id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
```

**Page Rules:**
- ✅ Use ConsumerWidget or ConsumerStatefulWidget
- ✅ Load data in initState or didChangeDependencies
- ✅ Use `ref.watch()` for state
- ✅ Use `ref.read()` for actions
- ✅ Handle loading, error, and empty states
- ✅ Extract complex widgets to separate files
- ✅ Use const constructors when possible
- ❌ Never put business logic in pages
- ❌ Never make direct API calls from pages

#### 5. Widgets (Reusable Components)

**Location:** `lib/shared/widgets/` or `lib/features/{feature}/presentation/widgets/`

```dart
// ✅ CORRECT - lib/features/customers/presentation/widgets/customer_card.dart
import 'package:flutter/material.dart';
import 'package:business_management/shared/models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(customer.name),
        subtitle: Text('${customer.city}, ${customer.government}'),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
```

**Widget Rules:**
- ✅ Keep widgets small and focused
- ✅ Use const constructors when possible
- ✅ Pass callbacks for actions
- ✅ Extract magic numbers to constants
- ✅ Use meaningful parameter names
- ❌ Never put business logic in widgets
- ❌ Never access providers in reusable widgets (pass data as props)

### Flutter Best Practices

```dart
// ✅ CORRECT - Use const constructors
const Text('Hello')
const SizedBox(height: 16)
const EdgeInsets.all(8)

// ✅ CORRECT - Extract constants
class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

// ✅ CORRECT - Use extensions
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// ✅ CORRECT - Handle async properly
Future<void> loadData() async {
  try {
    final data = await fetchData();
    // Use data
  } catch (e) {
    // Handle error
  }
}

// ❌ WRONG - Avoid unnecessary setState
setState(() {
  counter++; // ✅ Correct
  fetchData(); // ❌ Wrong - async in setState
});

// ✅ CORRECT - Check mounted before setState
if (mounted) {
  setState(() {
    // Update state
  });
}
```

---

## Database Rules

### Table Naming
```sql
-- ✅ CORRECT
CREATE TABLE customers (...);
CREATE TABLE order_items (...);
CREATE TABLE shipping_info (...);

-- ❌ WRONG
CREATE TABLE Customer (...);      -- Use lowercase
CREATE TABLE OrderItems (...);    -- Use snake_case
CREATE TABLE shipping (...);      -- Be specific
```

### Column Naming
```sql
-- ✅ CORRECT
id SERIAL PRIMARY KEY
tenant_id INT
customer_name VARCHAR(255)
created_at TIMESTAMP
is_active BOOLEAN

-- ❌ WRONG
ID                    -- Use lowercase
tenantId              -- Use snake_case
CustomerName          -- Use snake_case
createdat             -- Use underscores
active                -- Use is_ prefix for booleans
```

### Required Fields in Every Table
```sql
CREATE TABLE example (
    id SERIAL PRIMARY KEY,              -- ✅ REQUIRED
    tenant_id INT REFERENCES tenants(id), -- ✅ REQUIRED (except system tables)
    -- ... other fields ...
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- ✅ REQUIRED
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- ✅ REQUIRED
    deleted_at TIMESTAMP,               -- ✅ REQUIRED (soft delete)
    created_by INT REFERENCES users(id), -- ✅ RECOMMENDED
    updated_by INT REFERENCES users(id)  -- ✅ RECOMMENDED
);
```

### Index Rules
```sql
-- ✅ ALWAYS index foreign keys
CREATE INDEX idx_customers_tenant_id ON customers(tenant_id);

-- ✅ ALWAYS index commonly queried fields
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date DESC);

-- ✅ Use composite indexes for multi-column queries
CREATE INDEX idx_orders_tenant_date ON orders(tenant_id, order_date DESC);

-- ✅ Index deleted_at for soft deletes
CREATE INDEX idx_customers_deleted_at ON customers(deleted_at);

-- ❌ DON'T over-index (impacts write performance)
```

### Foreign Key Rules
```sql
-- ✅ CORRECT - Always use foreign keys
customer_id INT REFERENCES customers(id) ON DELETE RESTRICT

-- ✅ CORRECT - Use CASCADE for dependent data
CREATE TABLE order_items (
    order_id INT REFERENCES orders(id) ON DELETE CASCADE
);

-- ✅ CORRECT - Use SET NULL for optional references
supplier_id INT REFERENCES suppliers(id) ON DELETE SET NULL

-- ❌ WRONG - No foreign key constraint
customer_id INT  -- Missing REFERENCES
```

### Data Types
```sql
-- ✅ CORRECT
id SERIAL or BIGSERIAL (for high volume)
VARCHAR(255) for names
TEXT for long content
DECIMAL(15, 2) for money
BOOLEAN for flags
TIMESTAMP for dates with time
DATE for dates without time
JSONB for flexible data (not JSON)
INET for IP addresses

-- ❌ WRONG
INT for money                  -- Use DECIMAL
VARCHAR for long text          -- Use TEXT
CHAR for variable length       -- Use VARCHAR
JSON instead of JSONB          -- Use JSONB (indexable)
```

---

## API Design Rules

### URL Structure
```
✅ CORRECT
GET    /api/v1/customers
GET    /api/v1/customers/123
POST   /api/v1/customers
PUT    /api/v1/customers/123
DELETE /api/v1/customers/123
GET    /api/v1/customers/123/orders

❌ WRONG
GET    /api/getCustomers           -- Use nouns, not verbs
GET    /api/customer/123            -- Use plural
POST   /api/v1/customer/create     -- No action in URL
GET    /customers                   -- No version
```

### HTTP Methods
```
✅ CORRECT
GET    - Read (safe, idempotent)
POST   - Create (not idempotent)
PUT    - Update (idempotent)
DELETE - Delete (idempotent)
PATCH  - Partial update

❌ WRONG
POST /customers/delete  -- Use DELETE method
GET /customers/create   -- Use POST method
```

### Status Codes
```
✅ CORRECT
200 OK - Successful GET, PUT
201 Created - Successful POST
204 No Content - Successful DELETE
400 Bad Request - Invalid input
401 Unauthorized - Not authenticated
403 Forbidden - Not authorized
404 Not Found - Resource doesn't exist
422 Unprocessable Entity - Validation error
429 Too Many Requests - Rate limited
500 Internal Server Error - Server error

❌ WRONG
200 for errors  -- Use appropriate error codes
404 for validation errors -- Use 422
```

### Response Format
```json
// ✅ CORRECT - Success response
{
  "success": true,
  "message": "Customer created successfully",
  "data": {
    "id": 123,
    "name": "Ahmed Ali",
    ...
  }
}

// ✅ CORRECT - List response with pagination
{
  "success": true,
  "message": "Customers retrieved successfully",
  "data": [...],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_items": 100
  }
}

// ✅ CORRECT - Error response
{
  "success": false,
  "message": "Validation failed",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": {
      "name": ["Name is required"],
      "email": ["Invalid email format"]
    }
  }
}

// ❌ WRONG - Inconsistent format
{
  "customer": {...}  // Missing success, message
}

// ❌ WRONG - Exposing internal errors
{
  "error": "pq: duplicate key value violates unique constraint"
}
```

### Pagination
```
✅ CORRECT - Query parameters
GET /api/v1/customers?page=1&limit=20&sort_by=created_at&sort_order=desc

✅ CORRECT - Response includes pagination
{
  "data": [...],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_items": 100,
    "has_next": true,
    "has_prev": false
  }
}

❌ WRONG - No pagination
GET /api/v1/customers  -- Returns all (could be millions)
```

### Filtering & Searching
```
✅ CORRECT
GET /api/v1/customers?search=ahmed
GET /api/v1/customers?is_active=true
GET /api/v1/customers?city=Baghdad
GET /api/v1/orders?status=confirmed&payment_status=paid

❌ WRONG
POST /api/v1/customers/search  -- Use GET with query params
GET /api/v1/customers/active   -- Use query params
```

---

## Security Rules

### Authentication
```go
// ✅ CORRECT
password_hash, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

// Validate password
err := bcrypt.CompareHashAndPassword(password_hash, []byte(password))

// Generate JWT
token, _ := utils.GenerateJWT(userID, tenantID, email, role)

// ❌ WRONG
password := request.Password  // Storing plain text
```

### Authorization
```go
// ✅ CORRECT - Check tenant_id
customer, err := repo.GetByID(ctx, tenantID, customerID)

// ✅ CORRECT - Check permissions
if !hasPermission(userID, "customer.delete") {
    return ErrForbidden
}

// ❌ WRONG - No tenant check
customer, err := repo.GetByID(ctx, customerID)  // Missing tenantID!
```

### Input Validation
```go
// ✅ CORRECT - Validate all inputs
type CreateCustomerRequest struct {
    Name  string `json:"name" binding:"required,min=2,max=255"`
    Email string `json:"email" binding:"omitempty,email"`
    Phone string `json:"phone" binding:"required,e164"` // E.164 format
}

// ✅ CORRECT - Sanitize inputs
name = html.EscapeString(req.Name)

// ❌ WRONG - No validation
db.Exec("INSERT INTO customers (name) VALUES ('" + name + "')")  // SQL injection!
```

### Secrets Management
```bash
# ✅ CORRECT - Use environment variables
export DB_PASSWORD="secret"
export JWT_SECRET="very-secret-key"

# ✅ CORRECT - .env file (not committed)
DB_PASSWORD=secret
JWT_SECRET=very-secret-key

# ❌ WRONG - Hardcoded secrets
const jwtSecret = "my-secret-key"  // Never commit secrets!
```

### Rate Limiting
```go
// ✅ CORRECT - Implement rate limiting
limiter := rate.NewLimiter(rate.Limit(100), 200) // 100 req/sec, burst 200

// ✅ CORRECT - Per-user rate limiting
limiter := getUserRateLimiter(userID)

// ❌ WRONG - No rate limiting
```

---

## Testing Rules

### Unit Tests
```go
// ✅ CORRECT - Test file naming
customer_service_test.go  // Name ends with _test.go

// ✅ CORRECT - Test function naming
func TestCreateCustomer(t *testing.T) { }
func TestCreateCustomer_WithInvalidEmail_ReturnsError(t *testing.T) { }

// ✅ CORRECT - Table-driven tests
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid email", "test@example.com", false},
        {"invalid email", "invalid", true},
        {"empty email", "", true},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("ValidateEmail() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

// ✅ CORRECT - Use testify
assert.Equal(t, expected, actual)
assert.NoError(t, err)
assert.True(t, condition)
```

### Integration Tests
```go
// ✅ CORRECT - Use test database
func setupTestDB() *gorm.DB {
    db, _ := gorm.Open(postgres.Open("test_db_connection"), &gorm.Config{})
    db.AutoMigrate(&models.Customer{})
    return db
}

func teardownTestDB(db *gorm.DB) {
    db.Exec("DROP TABLE customers")
}

func TestCustomerHandler_Create(t *testing.T) {
    db := setupTestDB()
    defer teardownTestDB(db)
    
    // Test handler
}
```

### Frontend Tests
```dart
// ✅ CORRECT - Widget tests
void main() {
  testWidgets('CustomerCard displays customer name', (tester) async {
    final customer = Customer(
      id: 1,
      name: 'Ahmed Ali',
      // ...
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCard(customer: customer),
      ),
    );
    
    expect(find.text('Ahmed Ali'), findsOneWidget);
  });
}

// ✅ CORRECT - Unit tests for services
void main() {
  group('CustomerService', () {
    test('getCustomers returns customer list', () async {
      final mockClient = MockApiClient();
      final service = CustomerService(mockClient);
      
      when(mockClient.get('/customers')).thenAnswer(
        (_) async => Response(data: {'data': []}),
      );
      
      final result = await service.getCustomers();
      
      expect(result, isNotEmpty);
    });
  });
}
```

---

## Git & Version Control Rules

### Branch Naming
```bash
# ✅ CORRECT
feature/add-customer-search
bugfix/fix-order-total-calculation
hotfix/security-vulnerability
release/v1.2.0

# ❌ WRONG
my-feature  # Not descriptive
Feature1    # No type prefix
```

### Commit Messages
```bash
# ✅ CORRECT - Conventional Commits
feat: add customer search functionality
fix: correct order total calculation
refactor: extract customer validation logic
docs: update API documentation
test: add unit tests for customer service
chore: update dependencies

feat(auth): add JWT refresh token support
fix(orders): prevent negative quantities

# ❌ WRONG
Update files       # Not descriptive
Fixed bug          # Which bug?
WIP                # Too vague
```

### Pull Request Rules
- ✅ Create PR from feature branch to main/develop
- ✅ Write descriptive PR title and description
- ✅ Link to issue/ticket
- ✅ Request at least 1 reviewer
- ✅ Ensure CI passes before merging
- ✅ Squash commits when merging (optional)
- ❌ Never commit directly to main
- ❌ Never force push to shared branches

---

## Code Review Checklist

### For Reviewers

**Functionality:**
- [ ] Does the code do what it's supposed to do?
- [ ] Are edge cases handled?
- [ ] Are errors handled properly?

**Security:**
- [ ] Is user input validated?
- [ ] Is tenant_id checked on all queries?
- [ ] Are there any SQL injection risks?
- [ ] Are secrets properly managed?

**Performance:**
- [ ] Are database queries optimized?
- [ ] Are there any N+1 queries?
- [ ] Is caching used appropriately?
- [ ] Are indexes used?

**Code Quality:**
- [ ] Is the code readable?
- [ ] Are naming conventions followed?
- [ ] Is the code DRY (Don't Repeat Yourself)?
- [ ] Are there appropriate comments?

**Testing:**
- [ ] Are there unit tests?
- [ ] Are there integration tests?
- [ ] Do tests cover edge cases?
- [ ] Do all tests pass?

**Documentation:**
- [ ] Is API documented (Swagger)?
- [ ] Are complex functions commented?
- [ ] Is README updated if needed?

---

## Integration Guidelines

### External API Integration Pattern
```go
// ✅ CORRECT - internal/integrations/shipping/posta.go
package shipping

import (
    "context"
    "time"
)

// PostaClient handles Posta API integration
type PostaClient struct {
    apiKey     string
    baseURL    string
    httpClient *http.Client
    timeout    time.Duration
}

// NewPostaClient creates a new Posta client
func NewPostaClient(apiKey, baseURL string) *PostaClient {
    return &PostaClient{
        apiKey:  apiKey,
        baseURL: baseURL,
        httpClient: &http.Client{
            Timeout: 30 * time.Second,
        },
    }
}

// CreateShipment creates a shipment in Posta
func (c *PostaClient) CreateShipment(ctx context.Context, req *CreateShipmentRequest) (*ShipmentResponse, error) {
    // Prepare request
    url := c.baseURL + "/shipments"
    body, _ := json.Marshal(req)
    
    httpReq, _ := http.NewRequestWithContext(ctx, "POST", url, bytes.NewReader(body))
    httpReq.Header.Set("Authorization", "Bearer "+c.apiKey)
    httpReq.Header.Set("Content-Type", "application/json")
    
    // Make request
    resp, err := c.httpClient.Do(httpReq)
    if err != nil {
        return nil, fmt.Errorf("posta api request failed: %w", err)
    }
    defer resp.Body.Close()
    
    // Handle response
    if resp.StatusCode != http.StatusCreated {
        return nil, fmt.Errorf("posta api error: status %d", resp.StatusCode)
    }
    
    var result ShipmentResponse
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return nil, fmt.Errorf("failed to decode response: %w", err)
    }
    
    return &result, nil
}

// GetTracking gets tracking information
func (c *PostaClient) GetTracking(ctx context.Context, trackingNumber string) (*TrackingResponse, error) {
    // Implementation
}
```

**Integration Rules:**
- ✅ Create separate package for each integration
- ✅ Use context for cancellation
- ✅ Set timeouts on HTTP clients
- ✅ Handle errors gracefully
- ✅ Log requests and responses (sanitize sensitive data)
- ✅ Use retry logic for transient failures
- ✅ Use circuit breaker for reliability
- ❌ Never expose API keys in logs
- ❌ Never hardcode credentials

---

## Final Checklist Before Committing Code

- [ ] Code follows naming conventions
- [ ] All functions have comments (exported ones)
- [ ] No hardcoded values (use constants/config)
- [ ] No secrets in code (use environment variables)
- [ ] Error handling is implemented
- [ ] Logging is implemented with context
- [ ] Input validation is done
- [ ] Tenant_id is checked (if applicable)
- [ ] Tests are written
- [ ] Tests pass
- [ ] No unused imports
- [ ] No commented-out code
- [ ] Formatter has been run (`go fmt` or `flutter format`)
- [ ] Linter passes (`golangci-lint` or `flutter analyze`)
- [ ] Documentation is updated

---

**This is our manifesto. Follow it religiously for consistent, maintainable, and secure code.**

**Version:** 1.0  
**Last Updated:** 2025-12-23  
**Status:** Living Document - Will be updated as we learn
