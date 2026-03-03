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

// BranchInventoryHandler handles branch inventory HTTP requests
type BranchInventoryHandler struct {
	service *services.BranchInventoryService
}

// NewBranchInventoryHandler creates a new branch inventory handler
func NewBranchInventoryHandler(service *services.BranchInventoryService) *BranchInventoryHandler {
	return &BranchInventoryHandler{service: service}
}

// ── Request structs ───────────────────────────────────────────────────────────

type activateProductRequest struct {
	StockQuantity     int    `json:"stock_quantity"`
	PriceOverride     string `json:"price_override"`
	LowStockThreshold *int   `json:"low_stock_threshold"`
}

type updateInventoryRequest struct {
	IsActive          *bool  `json:"is_active"`
	StockQuantity     *int   `json:"stock_quantity"`
	PriceOverride     string `json:"price_override"`
	LowStockThreshold *int   `json:"low_stock_threshold"`
}

// ── Handlers ──────────────────────────────────────────────────────────────────

// List handles GET /api/v1/branches/:id/products
func (h *BranchInventoryHandler) List(c *gin.Context) {
	branchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid branch ID")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("per_page", "50"))

	items, total, err := h.service.ListByBranch(businessID, branchID, page, limit)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Branch inventory retrieved successfully",
		"data":    items,
		"meta": gin.H{
			"total":       total,
			"page":        page,
			"per_page":    limit,
			"total_pages": (total + int64(limit) - 1) / int64(limit),
		},
	})
}

// Activate handles POST /api/v1/branches/:id/products/:productId
func (h *BranchInventoryHandler) Activate(c *gin.Context) {
	branchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid branch ID")
		return
	}

	productID, err := uuid.Parse(c.Param("productId"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid product ID")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	var req activateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	inv, err := h.service.ActivateProduct(businessID, branchID, productID, &services.ActivateProductRequest{
		StockQuantity:     req.StockQuantity,
		PriceOverride:     req.PriceOverride,
		LowStockThreshold: req.LowStockThreshold,
	})
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Product activated at branch", inv)
}

// Update handles PUT /api/v1/branches/:id/products/:productId
func (h *BranchInventoryHandler) Update(c *gin.Context) {
	branchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid branch ID")
		return
	}

	productID, err := uuid.Parse(c.Param("productId"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid product ID")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	var req updateInventoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	inv, err := h.service.UpdateInventory(businessID, branchID, productID, &services.UpdateInventoryRequest{
		IsActive:          req.IsActive,
		StockQuantity:     req.StockQuantity,
		PriceOverride:     req.PriceOverride,
		LowStockThreshold: req.LowStockThreshold,
	})
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Inventory updated successfully", inv)
}

// Deactivate handles DELETE /api/v1/branches/:id/products/:productId
func (h *BranchInventoryHandler) Deactivate(c *gin.Context) {
	branchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid branch ID")
		return
	}

	productID, err := uuid.Parse(c.Param("productId"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid product ID")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	if err := h.service.DeactivateProduct(businessID, branchID, productID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Product removed from branch inventory", nil)
}
