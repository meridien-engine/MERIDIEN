package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
	"github.com/shopspring/decimal"
)

type LocationHandler struct {
	locationService *services.LocationService
}

func NewLocationHandler(locationService *services.LocationService) *LocationHandler {
	return &LocationHandler{
		locationService: locationService,
	}
}

// CreateLocationRequest represents the request body for creating a location
type CreateLocationRequest struct {
	City        string `json:"city" binding:"required"`
	Zone        string `json:"zone"`
	ShippingFee string `json:"shipping_fee" binding:"required"`
}

// UpdateLocationRequest represents the request body for updating a location
type UpdateLocationRequest struct {
	City        string `json:"city"`
	Zone        string `json:"zone"`
	ShippingFee string `json:"shipping_fee"`
}

// Create creates a new location
func (h *LocationHandler) Create(c *gin.Context) {
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
		return
	}

	var req CreateLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationErrorResponse(c, map[string]string{"body": err.Error()})
		return
	}

	// Convert shipping fee string to decimal
	shippingFee, err := decimal.NewFromString(req.ShippingFee)
	if err != nil {
		utils.ValidationErrorResponse(c, map[string]string{"shipping_fee": "invalid decimal format"})
		return
	}

	location, err := h.locationService.CreateLocation(businessID, req.City, req.Zone, shippingFee)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "failed to create location")
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Location created successfully", location)
}

// List retrieves all locations for a tenant
func (h *LocationHandler) List(c *gin.Context) {
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
		return
	}

	page := 1
	pageSize := 20
	if p := c.Query("page"); p != "" {
		if pInt, err := strconv.Atoi(p); err == nil && pInt > 0 {
			page = pInt
		}
	}
	if ps := c.Query("page_size"); ps != "" {
		if psInt, err := strconv.Atoi(ps); err == nil && psInt > 0 && psInt <= 100 {
			pageSize = psInt
		}
	}

	locations, total, err := h.locationService.ListLocations(businessID, page, pageSize)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "failed to list locations")
		return
	}

	meta := utils.Pagination{
		Total:      total,
		Page:       page,
		PerPage:    pageSize,
		TotalPages: int((total + int64(pageSize) - 1) / int64(pageSize)),
	}

	c.JSON(http.StatusOK, utils.PaginatedResponse{
		Success: true,
		Message: "Locations retrieved successfully",
		Data:    locations,
		Meta:    meta,
	})
}

// GetByID retrieves a specific location
func (h *LocationHandler) GetByID(c *gin.Context) {
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
		return
	}

	locationID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ValidationErrorResponse(c, map[string]string{"id": "invalid UUID format"})
		return
	}

	location, err := h.locationService.GetLocation(businessID, locationID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusNotFound, "location not found")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Location retrieved successfully", location)
}

// Update updates a location
func (h *LocationHandler) Update(c *gin.Context) {
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
		return
	}

	locationID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ValidationErrorResponse(c, map[string]string{"id": "invalid UUID format"})
		return
	}

	var req UpdateLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationErrorResponse(c, map[string]string{"body": err.Error()})
		return
	}

	updates := make(map[string]interface{})
	if req.City != "" {
		updates["city"] = req.City
	}
	if req.Zone != "" {
		updates["zone"] = req.Zone
	}
	if req.ShippingFee != "" {
		shippingFee, err := decimal.NewFromString(req.ShippingFee)
		if err != nil {
			utils.ValidationErrorResponse(c, map[string]string{"shipping_fee": "invalid decimal format"})
			return
		}
		updates["shipping_fee"] = shippingFee
	}

	if len(updates) == 0 {
		utils.ValidationErrorResponse(c, map[string]string{"body": "no fields to update"})
		return
	}

	if err := h.locationService.UpdateLocation(businessID, locationID, updates); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "failed to update location")
		return
	}

	location, err := h.locationService.GetLocation(businessID, locationID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "failed to retrieve updated location")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Location updated successfully", location)
}

// Delete deletes a location
func (h *LocationHandler) Delete(c *gin.Context) {
	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
		return
	}

	locationID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ValidationErrorResponse(c, map[string]string{"id": "invalid UUID format"})
		return
	}

	if err := h.locationService.DeleteLocation(businessID, locationID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "failed to delete location")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Location deleted successfully", nil)
}
