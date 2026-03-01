package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// POSHandler handles POS HTTP requests
type POSHandler struct {
	posService *services.POSService
}

// NewPOSHandler creates a new POS handler
func NewPOSHandler(posService *services.POSService) *POSHandler {
	return &POSHandler{posService: posService}
}

// ── Request structs ──────────────────────────────────────────────────────────

// OpenSessionHTTPRequest is the body for POST /pos/sessions
type OpenSessionHTTPRequest struct {
	OpeningFloat string `json:"opening_float" binding:"required"`
}

// CloseSessionHTTPRequest is the body for POST /pos/sessions/:id/close
type CloseSessionHTTPRequest struct {
	ClosingCash string `json:"closing_cash" binding:"required"`
}

// CheckoutHTTPRequest is the body for POST /pos/checkout
type CheckoutHTTPRequest struct {
	SessionID      string               `json:"session_id"      binding:"required"`
	CustomerName   string               `json:"customer_name"`
	Items          []CheckoutItemHTTPReq `json:"items"          binding:"required,min=1"`
	CashTendered   string               `json:"cash_tendered"   binding:"required"`
	DiscountAmount string               `json:"discount_amount"`
}

// CheckoutItemHTTPReq represents a single item in the checkout
type CheckoutItemHTTPReq struct {
	ProductID string `json:"product_id" binding:"required"`
	Quantity  int    `json:"quantity"   binding:"required,min=1"`
}

// ── Handlers ─────────────────────────────────────────────────────────────────

// OpenSession handles POST /api/v1/pos/sessions
func (h *POSHandler) OpenSession(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	cashierID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not found")
		return
	}

	var req OpenSessionHTTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	session, err := h.posService.OpenSession(&services.OpenSessionRequest{
		TenantID:     tenantID,
		CashierID:    cashierID,
		OpeningFloat: req.OpeningFloat,
	})
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Session opened successfully", session)
}

// CloseSession handles POST /api/v1/pos/sessions/:id/close
func (h *POSHandler) CloseSession(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	cashierID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not found")
		return
	}

	sessionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid session ID")
		return
	}

	var req CloseSessionHTTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	session, err := h.posService.CloseSession(&services.CloseSessionRequest{
		SessionID:   sessionID,
		TenantID:    tenantID,
		CashierID:   cashierID,
		ClosingCash: req.ClosingCash,
	})
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Session closed successfully", session)
}

// GetCurrentSession handles GET /api/v1/pos/sessions/current
func (h *POSHandler) GetCurrentSession(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	cashierID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not found")
		return
	}

	session, err := h.posService.GetCurrentSession(cashierID, tenantID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	if session == nil {
		utils.ErrorResponse(c, http.StatusNotFound, "No open session found")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Current session retrieved", session)
}

// GetSession handles GET /api/v1/pos/sessions/:id
func (h *POSHandler) GetSession(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	sessionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid session ID")
		return
	}

	session, err := h.posService.GetSession(sessionID, tenantID)
	if err != nil {
		utils.NotFoundResponse(c, "Session not found")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Session retrieved", session)
}

// ListSessions handles GET /api/v1/pos/sessions
func (h *POSHandler) ListSessions(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 100 {
		perPage = 20
	}

	filters := repositories.POSSessionFilters{
		Status:    c.Query("status"),
		SortBy:    c.Query("sort_by"),
		SortOrder: c.Query("sort_order"),
		Limit:     perPage,
		Offset:    (page - 1) * perPage,
	}

	sessions, total, err := h.posService.ListSessions(tenantID, filters)
	if err != nil {
		utils.InternalErrorResponse(c, "Failed to retrieve sessions")
		return
	}

	utils.PaginatedSuccessResponse(c, sessions, total, page, perPage)
}

// LookupProduct handles GET /api/v1/products/lookup?q=xxx
func (h *POSHandler) LookupProduct(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	query := c.Query("q")
	if query == "" {
		utils.ErrorResponse(c, http.StatusBadRequest, "Query parameter 'q' is required")
		return
	}

	product, err := h.posService.LookupProduct(query, tenantID)
	if err != nil {
		utils.NotFoundResponse(c, "Product not found")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Product found", product)
}

// Checkout handles POST /api/v1/pos/checkout
func (h *POSHandler) Checkout(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	cashierID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not found")
		return
	}

	var req CheckoutHTTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	sessionID, err := uuid.Parse(req.SessionID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid session ID")
		return
	}

	items := make([]services.POSCheckoutItem, len(req.Items))
	for i, item := range req.Items {
		items[i] = services.POSCheckoutItem{
			ProductID: item.ProductID,
			Quantity:  item.Quantity,
		}
	}

	result, err := h.posService.Checkout(&services.POSCheckoutRequest{
		TenantID:       tenantID,
		CashierID:      cashierID,
		SessionID:      sessionID,
		CustomerName:   req.CustomerName,
		Items:          items,
		CashTendered:   req.CashTendered,
		DiscountAmount: req.DiscountAmount,
	})
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Checkout completed successfully", result)
}
