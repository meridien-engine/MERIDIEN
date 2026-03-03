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

// BranchHandler handles branch HTTP requests
type BranchHandler struct {
	branchService *services.BranchService
}

// NewBranchHandler creates a new branch handler instance
func NewBranchHandler(branchService *services.BranchService) *BranchHandler {
	return &BranchHandler{branchService: branchService}
}

// createBranchRequest is the request body for branch creation
type createBranchRequest struct {
	Name    string `json:"name" binding:"required"`
	Address string `json:"address"`
	City    string `json:"city"`
	Phone   string `json:"phone"`
}

// updateBranchRequest is the request body for branch updates
type updateBranchRequest struct {
	Name    *string `json:"name"`
	Address *string `json:"address"`
	City    *string `json:"city"`
	Phone   *string `json:"phone"`
	Status  *string `json:"status"`
}

// grantAccessRequest is the body for granting branch access
type grantAccessRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

// ListBranches handles GET /api/v1/businesses/:id/branches
func (h *BranchHandler) ListBranches(c *gin.Context) {
	businessID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid business ID")
		return
	}

	// Verify caller belongs to this business
	callerBizID, err := middleware.GetBusinessID(c)
	if err != nil || callerBizID != businessID {
		utils.UnauthorizedResponse(c, "Access denied")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))

	branches, total, err := h.branchService.List(businessID, page, perPage)
	if err != nil {
		utils.InternalErrorResponse(c, "Failed to retrieve branches")
		return
	}

	utils.PaginatedSuccessResponse(c, branches, total, page, perPage)
}

// GetBranch handles GET /api/v1/branches/:id
func (h *BranchHandler) GetBranch(c *gin.Context) {
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

	branch, err := h.branchService.GetByID(businessID, branchID)
	if err != nil {
		utils.NotFoundResponse(c, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Branch retrieved successfully", branch)
}

// CreateBranch handles POST /api/v1/businesses/:id/branches
func (h *BranchHandler) CreateBranch(c *gin.Context) {
	businessID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid business ID")
		return
	}

	callerBizID, err := middleware.GetBusinessID(c)
	if err != nil || callerBizID != businessID {
		utils.UnauthorizedResponse(c, "Access denied")
		return
	}

	var req createBranchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	serviceReq := &services.CreateBranchRequest{
		Name:    req.Name,
		Address: req.Address,
		City:    req.City,
		Phone:   req.Phone,
	}

	branch, err := h.branchService.Create(businessID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Branch created successfully", branch)
}

// UpdateBranch handles PUT /api/v1/branches/:id
func (h *BranchHandler) UpdateBranch(c *gin.Context) {
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

	var req updateBranchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	serviceReq := &services.UpdateBranchRequest{
		Name:    req.Name,
		Address: req.Address,
		City:    req.City,
		Phone:   req.Phone,
		Status:  req.Status,
	}

	branch, err := h.branchService.Update(businessID, branchID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Branch updated successfully", branch)
}

// DeleteBranch handles DELETE /api/v1/branches/:id
func (h *BranchHandler) DeleteBranch(c *gin.Context) {
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

	if err := h.branchService.Delete(businessID, branchID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Branch deleted successfully", nil)
}

// ListAccess handles GET /api/v1/branches/:id/users
func (h *BranchHandler) ListAccess(c *gin.Context) {
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

	records, err := h.branchService.ListAccess(businessID, branchID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Branch access list retrieved", records)
}

// GrantAccess handles POST /api/v1/branches/:id/users
func (h *BranchHandler) GrantAccess(c *gin.Context) {
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

	callerID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not found")
		return
	}

	var req grantAccessRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	serviceReq := &services.GrantAccessRequest{UserID: req.UserID}
	if err := h.branchService.GrantAccess(businessID, branchID, serviceReq, callerID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Access granted successfully", nil)
}

// RevokeAccess handles DELETE /api/v1/branches/:id/users/:userId
func (h *BranchHandler) RevokeAccess(c *gin.Context) {
	branchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid branch ID")
		return
	}

	userID, err := uuid.Parse(c.Param("userId"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid user ID")
		return
	}

	businessID, err := middleware.GetBusinessID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Business not found")
		return
	}

	if err := h.branchService.RevokeAccess(businessID, branchID, userID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Access revoked successfully", nil)
}
