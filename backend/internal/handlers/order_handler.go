package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// OrderHandler handles order HTTP requests
type OrderHandler struct {
	orderService *services.OrderService
}

// NewOrderHandler creates a new order handler instance
func NewOrderHandler(orderService *services.OrderService) *OrderHandler {
	return &OrderHandler{
		orderService: orderService,
	}
}

// CreateOrderRequest represents the HTTP request body for creating an order
type CreateOrderHTTPRequest struct {
	CustomerID      string                     `json:"customer_id" binding:"required"`
	Items           []OrderItemHTTPRequest     `json:"items" binding:"required,min=1"`
	TaxAmount       string                     `json:"tax_amount"`
	DiscountAmount  string                     `json:"discount_amount"`
	ShippingAmount  string                     `json:"shipping_amount"`
	ShippingAddress ShippingAddressHTTPRequest `json:"shipping_address"`
	Notes           string                     `json:"notes"`
	InternalNotes   string                     `json:"internal_notes"`
}

// OrderItemHTTPRequest represents an item in the order request
type OrderItemHTTPRequest struct {
	ProductID      string `json:"product_id" binding:"required"`
	Quantity       int    `json:"quantity" binding:"required,min=1"`
	DiscountAmount string `json:"discount_amount"`
	TaxAmount      string `json:"tax_amount"`
	Notes          string `json:"notes"`
}

// ShippingAddressHTTPRequest represents the shipping address
type ShippingAddressHTTPRequest struct {
	AddressLine1 string `json:"address_line1"`
	AddressLine2 string `json:"address_line2"`
	City         string `json:"city"`
	State        string `json:"state"`
	PostalCode   string `json:"postal_code"`
	Country      string `json:"country"`
}

// UpdateOrderHTTPRequest represents the HTTP request body for updating an order
type UpdateOrderHTTPRequest struct {
	TaxAmount       *string                     `json:"tax_amount"`
	DiscountAmount  *string                     `json:"discount_amount"`
	ShippingAmount  *string                     `json:"shipping_amount"`
	ShippingAddress *ShippingAddressHTTPRequest `json:"shipping_address"`
	Notes           *string                     `json:"notes"`
	InternalNotes   *string                     `json:"internal_notes"`
}

// RecordPaymentRequest represents the HTTP request body for recording a payment
type RecordPaymentRequest struct {
	PaymentMethod        string `json:"payment_method" binding:"required"`
	Amount               string `json:"amount" binding:"required"`
	TransactionReference string `json:"transaction_reference"`
	Notes                string `json:"notes"`
}

// Create handles order creation
// POST /api/v1/orders
func (h *OrderHandler) Create(c *gin.Context) {
	var req CreateOrderHTTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse customer ID
	customerID, err := uuid.Parse(req.CustomerID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid customer ID")
		return
	}

	// Parse order items
	items := make([]services.OrderItemRequest, len(req.Items))
	for i, item := range req.Items {
		productID, err := uuid.Parse(item.ProductID)
		if err != nil {
			utils.ErrorResponse(c, http.StatusBadRequest, "Invalid product ID")
			return
		}

		items[i] = services.OrderItemRequest{
			ProductID:      productID,
			Quantity:       item.Quantity,
			DiscountAmount: item.DiscountAmount,
			TaxAmount:      item.TaxAmount,
			Notes:          item.Notes,
		}
	}

	// Create service request
	serviceReq := &services.CreateOrderRequest{
		BusinessID:       businessID,
		CustomerID:     customerID,
		Items:          items,
		TaxAmount:      req.TaxAmount,
		DiscountAmount: req.DiscountAmount,
		ShippingAmount: req.ShippingAmount,
		ShippingAddress: services.ShippingAddressRequest{
			AddressLine1: req.ShippingAddress.AddressLine1,
			AddressLine2: req.ShippingAddress.AddressLine2,
			City:         req.ShippingAddress.City,
			State:        req.ShippingAddress.State,
			PostalCode:   req.ShippingAddress.PostalCode,
			Country:      req.ShippingAddress.Country,
		},
		Notes:         req.Notes,
		InternalNotes: req.InternalNotes,
	}

	// Create order
	order, err := h.orderService.Create(serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Order created successfully", order)
}

// List handles listing orders
// GET /api/v1/orders
func (h *OrderHandler) List(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse query parameters
	filters := repositories.OrderListFilters{
		Search:        c.Query("search"),
		Status:        c.Query("status"),
		PaymentStatus: c.Query("payment_status"),
		SortBy:        c.Query("sort_by"),
		SortOrder:     c.Query("sort_order"),
	}

	// Parse customer ID
	if customerIDStr := c.Query("customer_id"); customerIDStr != "" {
		customerID, err := uuid.Parse(customerIDStr)
		if err == nil {
			filters.CustomerID = customerID
		}
	}

	// Parse date filters
	if fromDateStr := c.Query("from_date"); fromDateStr != "" {
		fromDate, err := time.Parse("2006-01-02", fromDateStr)
		if err == nil {
			filters.FromDate = fromDate
		}
	}

	if toDateStr := c.Query("to_date"); toDateStr != "" {
		toDate, err := time.Parse("2006-01-02", toDateStr)
		if err == nil {
			filters.ToDate = toDate
		}
	}

	// Parse pagination
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))

	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 100 {
		perPage = 20
	}

	filters.Limit = perPage
	filters.Offset = (page - 1) * perPage

	// Get orders
	orders, total, err := h.orderService.List(businessID, filters)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve orders")
		return
	}

	// Build pagination response
	utils.PaginatedSuccessResponse(c, orders, total, page, perPage)
}

// GetByID handles retrieving an order by ID
// GET /api/v1/orders/:id
func (h *OrderHandler) GetByID(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Get order
	order, err := h.orderService.GetByID(orderID, businessID)
	if err != nil {
		utils.NotFoundResponse(c, "Order not found")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order retrieved successfully", order)
}

// Update handles updating an order
// PUT /api/v1/orders/:id
func (h *OrderHandler) Update(c *gin.Context) {
	var req UpdateOrderHTTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Convert HTTP request to service request
	serviceReq := &services.UpdateOrderRequest{
		TaxAmount:      req.TaxAmount,
		DiscountAmount: req.DiscountAmount,
		ShippingAmount: req.ShippingAmount,
		Notes:          req.Notes,
		InternalNotes:  req.InternalNotes,
	}

	if req.ShippingAddress != nil {
		serviceReq.ShippingAddress = &services.ShippingAddressRequest{
			AddressLine1: req.ShippingAddress.AddressLine1,
			AddressLine2: req.ShippingAddress.AddressLine2,
			City:         req.ShippingAddress.City,
			State:        req.ShippingAddress.State,
			PostalCode:   req.ShippingAddress.PostalCode,
			Country:      req.ShippingAddress.Country,
		}
	}

	// Update order
	order, err := h.orderService.Update(orderID, businessID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order updated successfully", order)
}

// Delete handles deleting an order
// DELETE /api/v1/orders/:id
func (h *OrderHandler) Delete(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Delete order
	if err := h.orderService.Delete(orderID, businessID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order deleted successfully", nil)
}

// Confirm handles confirming an order
// POST /api/v1/orders/:id/confirm
func (h *OrderHandler) Confirm(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Confirm order
	order, err := h.orderService.ConfirmOrder(orderID, businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order confirmed successfully", order)
}

// Ship handles shipping an order
// POST /api/v1/orders/:id/ship
func (h *OrderHandler) Ship(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Ship order
	order, err := h.orderService.ShipOrder(orderID, businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order shipped successfully", order)
}

// Deliver handles marking an order as delivered
// POST /api/v1/orders/:id/deliver
func (h *OrderHandler) Deliver(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Deliver order
	order, err := h.orderService.DeliverOrder(orderID, businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order delivered successfully", order)
}

// Collect handles marking a delivered order as collected
// POST /api/v1/orders/:id/collect
func (h *OrderHandler) Collect(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Collect order
	order, err := h.orderService.CollectOrder(orderID, businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order collected successfully", order)
}

// Cancel handles cancelling an order
// POST /api/v1/orders/:id/cancel
func (h *OrderHandler) Cancel(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Cancel order
	order, err := h.orderService.CancelOrder(orderID, businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Order cancelled successfully", order)
}

// RecordPayment handles recording a payment for an order
// POST /api/v1/orders/:id/payments
func (h *OrderHandler) RecordPayment(c *gin.Context) {
	var req RecordPaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Record payment
	payment, err := h.orderService.RecordPayment(
		orderID,
		businessID,
		req.PaymentMethod,
		req.Amount,
		req.TransactionReference,
		req.Notes,
	)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Payment recorded successfully", payment)
}

// ListPayments handles listing payments for an order
// GET /api/v1/orders/:id/payments
func (h *OrderHandler) ListPayments(c *gin.Context) {
	// Get tenant ID from context
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse order ID
	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid order ID")
		return
	}

	// Get payments
	payments, err := h.orderService.GetOrderPayments(orderID, businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve payments")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Payments retrieved successfully", payments)
}
