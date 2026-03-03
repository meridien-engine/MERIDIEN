package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// BusinessHandler handles business management HTTP requests
type BusinessHandler struct {
	businessService *services.BusinessService
}

// NewBusinessHandler creates a new business handler instance
func NewBusinessHandler(businessService *services.BusinessService) *BusinessHandler {
	return &BusinessHandler{businessService: businessService}
}

// CreateBusinessRequest represents the request body for creating a business
type CreateBusinessRequest struct {
	Name         string `json:"name" binding:"required"`
	Slug         string `json:"slug"`
	BusinessType string `json:"business_type"`
	CategoryID   string `json:"category_id"`
	ContactPhone string `json:"contact_phone"`
	ContactEmail string `json:"contact_email"`
}

// CreateBusiness creates a new business for the authenticated user
// POST /api/v1/businesses
func (h *BusinessHandler) CreateBusiness(c *gin.Context) {
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	var req CreateBusinessRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	serviceReq := &services.CreateBusinessRequest{
		Name:         req.Name,
		Slug:         req.Slug,
		BusinessType: req.BusinessType,
		CategoryID:   req.CategoryID,
		ContactPhone: req.ContactPhone,
		ContactEmail: req.ContactEmail,
	}

	business, err := h.businessService.CreateBusiness(userID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Business created successfully", business)
}

// GetBusiness retrieves a business by ID
// GET /api/v1/businesses/:id
func (h *BusinessHandler) GetBusiness(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid business ID")
		return
	}

	business, err := h.businessService.GetByID(id)
	if err != nil {
		utils.NotFoundResponse(c, "Business not found")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Business retrieved", business)
}

// GetCategories returns all available business categories
// GET /api/v1/business-categories
func (h *BusinessHandler) GetCategories(c *gin.Context) {
	categories, err := h.businessService.GetCategories()
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve categories")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Categories retrieved", categories)
}
