package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// CustomerHandler handles customer HTTP requests
type CustomerHandler struct {
	customerService *services.CustomerService
}

// NewCustomerHandler creates a new customer handler instance
func NewCustomerHandler(customerService *services.CustomerService) *CustomerHandler {
	return &CustomerHandler{
		customerService: customerService,
	}
}

// CreateCustomerRequest represents the create customer request body
type CreateCustomerRequest struct {
	FirstName    string `json:"first_name" binding:"required"`
	LastName     string `json:"last_name" binding:"required"`
	Email        string `json:"email"`
	Phone        string `json:"phone"`
	AddressLine1 string `json:"address_line1"`
	AddressLine2 string `json:"address_line2"`
	City         string `json:"city"`
	State        string `json:"state"`
	PostalCode   string `json:"postal_code"`
	Country      string `json:"country"`
	CompanyName  string `json:"company_name"`
	TaxID        string `json:"tax_id"`
	CustomerType string `json:"customer_type"`
	Notes        string `json:"notes"`
}

// UpdateCustomerRequest represents the update customer request body
type UpdateCustomerRequest struct {
	FirstName    *string `json:"first_name"`
	LastName     *string `json:"last_name"`
	Email        *string `json:"email"`
	Phone        *string `json:"phone"`
	AddressLine1 *string `json:"address_line1"`
	AddressLine2 *string `json:"address_line2"`
	City         *string `json:"city"`
	State        *string `json:"state"`
	PostalCode   *string `json:"postal_code"`
	Country      *string `json:"country"`
	CompanyName  *string `json:"company_name"`
	TaxID        *string `json:"tax_id"`
	CustomerType *string `json:"customer_type"`
	Status       *string `json:"status"`
	Notes        *string `json:"notes"`
}

// Create handles customer creation
// POST /api/v1/customers
func (h *CustomerHandler) Create(c *gin.Context) {
	var req CreateCustomerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Get tenant ID from context
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Create service request
	serviceReq := &services.CreateCustomerRequest{
		TenantID:     tenantID,
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		Email:        req.Email,
		Phone:        req.Phone,
		AddressLine1: req.AddressLine1,
		AddressLine2: req.AddressLine2,
		City:         req.City,
		State:        req.State,
		PostalCode:   req.PostalCode,
		Country:      req.Country,
		CompanyName:  req.CompanyName,
		TaxID:        req.TaxID,
		CustomerType: req.CustomerType,
		Notes:        req.Notes,
	}

	// Create customer
	customer, err := h.customerService.Create(serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Customer created successfully", customer)
}

// GetByID retrieves a customer by ID
// GET /api/v1/customers/:id
func (h *CustomerHandler) GetByID(c *gin.Context) {
	// Get customer ID from URL
	customerID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid customer ID")
		return
	}

	// Get tenant ID from context
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Get customer
	customer, err := h.customerService.GetByID(customerID, tenantID)
	if err != nil {
		utils.NotFoundResponse(c, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Customer retrieved successfully", customer)
}

// Update updates a customer
// PUT /api/v1/customers/:id
func (h *CustomerHandler) Update(c *gin.Context) {
	// Get customer ID from URL
	customerID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid customer ID")
		return
	}

	var req UpdateCustomerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Get tenant ID from context
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Create service request
	serviceReq := &services.UpdateCustomerRequest{
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		Email:        req.Email,
		Phone:        req.Phone,
		AddressLine1: req.AddressLine1,
		AddressLine2: req.AddressLine2,
		City:         req.City,
		State:        req.State,
		PostalCode:   req.PostalCode,
		Country:      req.Country,
		CompanyName:  req.CompanyName,
		TaxID:        req.TaxID,
		CustomerType: req.CustomerType,
		Status:       req.Status,
		Notes:        req.Notes,
	}

	// Update customer
	customer, err := h.customerService.Update(customerID, tenantID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Customer updated successfully", customer)
}

// Delete deletes a customer
// DELETE /api/v1/customers/:id
func (h *CustomerHandler) Delete(c *gin.Context) {
	// Get customer ID from URL
	customerID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid customer ID")
		return
	}

	// Get tenant ID from context
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Delete customer
	if err := h.customerService.Delete(customerID, tenantID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Customer deleted successfully", nil)
}

// List retrieves a paginated list of customers
// GET /api/v1/customers
func (h *CustomerHandler) List(c *gin.Context) {
	// Get tenant ID from context
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse query parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	search := c.Query("search")
	status := c.Query("status")
	customerType := c.Query("customer_type")
	sortBy := c.DefaultQuery("sort_by", "created_at")
	sortOrder := c.DefaultQuery("sort_order", "DESC")

	// Create service request
	req := &services.ListCustomersRequest{
		TenantID:     tenantID,
		Search:       search,
		Status:       status,
		CustomerType: customerType,
		SortBy:       sortBy,
		SortOrder:    sortOrder,
		Page:         page,
		PerPage:      perPage,
	}

	// Get customers
	customers, total, err := h.customerService.List(req)
	if err != nil {
		utils.InternalErrorResponse(c, "Failed to retrieve customers")
		return
	}

	utils.PaginatedSuccessResponse(c, customers, total, page, perPage)
}
