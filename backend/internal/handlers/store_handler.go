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

// StoreHandler handles store HTTP requests
type StoreHandler struct {
	storeService *services.StoreService
}

// NewStoreHandler creates a new store handler instance
func NewStoreHandler(storeService *services.StoreService) *StoreHandler {
	return &StoreHandler{storeService: storeService}
}

// createStoreRequest represents the create store request body
type createStoreRequest struct {
	Name     string `json:"name" binding:"required"`
	Address  string `json:"address"`
	City     string `json:"city"`
	Phone    string `json:"phone"`
	IsActive *bool  `json:"is_active"`
}

// updateStoreRequest represents the update store request body
type updateStoreRequest struct {
	Name     *string `json:"name"`
	Address  *string `json:"address"`
	City     *string `json:"city"`
	Phone    *string `json:"phone"`
	IsActive *bool   `json:"is_active"`
}

// ListStores handles GET /api/v1/stores
func (h *StoreHandler) ListStores(c *gin.Context) {
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	search := c.Query("search")

	stores, total, err := h.storeService.List(businessID, page, perPage, search)
	if err != nil {
		utils.InternalErrorResponse(c, "Failed to retrieve stores")
		return
	}

	utils.PaginatedSuccessResponse(c, stores, total, page, perPage)
}

// GetStore handles GET /api/v1/stores/:id
func (h *StoreHandler) GetStore(c *gin.Context) {
	storeID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid store ID")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	store, err := h.storeService.GetByID(businessID, storeID)
	if err != nil {
		utils.NotFoundResponse(c, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Store retrieved successfully", store)
}

// CreateStore handles POST /api/v1/stores
func (h *StoreHandler) CreateStore(c *gin.Context) {
	var req createStoreRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	serviceReq := &services.CreateStoreRequest{
		Name:     req.Name,
		Address:  req.Address,
		City:     req.City,
		Phone:    req.Phone,
		IsActive: req.IsActive,
	}

	store, err := h.storeService.Create(businessID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Store created successfully", store)
}

// UpdateStore handles PUT /api/v1/stores/:id
func (h *StoreHandler) UpdateStore(c *gin.Context) {
	storeID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid store ID")
		return
	}

	var req updateStoreRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	serviceReq := &services.UpdateStoreRequest{
		Name:     req.Name,
		Address:  req.Address,
		City:     req.City,
		Phone:    req.Phone,
		IsActive: req.IsActive,
	}

	store, err := h.storeService.Update(businessID, storeID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Store updated successfully", store)
}

// DeleteStore handles DELETE /api/v1/stores/:id
func (h *StoreHandler) DeleteStore(c *gin.Context) {
	storeID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid store ID")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	if err := h.storeService.Delete(businessID, storeID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Store deleted successfully", nil)
}
