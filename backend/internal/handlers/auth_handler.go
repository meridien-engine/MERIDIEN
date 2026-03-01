package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// AuthHandler handles authentication HTTP requests
type AuthHandler struct {
	authService *services.AuthService
}

// NewAuthHandler creates a new auth handler instance
func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

// RegisterRequest represents the registration request body
type RegisterRequest struct {
	TenantSlug string `json:"tenant_slug" binding:"required"`
	Email      string `json:"email" binding:"required"`
	Password   string `json:"password" binding:"required"`
	FirstName  string `json:"first_name" binding:"required"`
	LastName   string `json:"last_name" binding:"required"`
	Role       string `json:"role"`
}

// LoginRequest represents the login request body
type LoginRequest struct {
	TenantSlug string `json:"tenant_slug"`
	Email      string `json:"email" binding:"required"`
	Password   string `json:"password" binding:"required"`
}

// UserResponse represents the user data in responses (without password)
type UserResponse struct {
	ID        uuid.UUID `json:"id"`
	TenantID  uuid.UUID `json:"tenant_id"`
	Email     string    `json:"email"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Role      string    `json:"role"`
	IsActive  bool      `json:"is_active"`
}

// Register handles user registration
// POST /api/v1/auth/register
func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	// For MVP, we'll use the demo tenant
	// In production, you'd look up tenant by slug
	tenantID := uuid.MustParse("bae1577c-1b95-4a0e-8eae-9a44654278b2") // Demo tenant ID

	// Default role to "user" if not provided
	if req.Role == "" {
		req.Role = "user"
	}

	// Create service request
	serviceReq := &services.RegisterRequest{
		TenantID:  tenantID,
		Email:     req.Email,
		Password:  req.Password,
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Role:      req.Role,
	}

	// Register user
	response, err := h.authService.Register(serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	// Build response
	userResp := UserResponse{
		ID:        response.User.ID,
		TenantID:  response.User.TenantID,
		Email:     response.User.Email,
		FirstName: response.User.FirstName,
		LastName:  response.User.LastName,
		Role:      response.User.Role,
		IsActive:  response.User.IsActive,
	}

	utils.SuccessResponse(c, http.StatusCreated, "User registered successfully", gin.H{
		"token": response.Token,
		"user":  userResp,
	})
}

// Login handles user authentication
// POST /api/v1/auth/login
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	// If tenant slug is not provided, attempt workspace discovery by email/password
	if req.TenantSlug == "" {
		tenants, err := h.authService.DiscoverTenants(req.Email, req.Password)
		if err != nil {
			utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
			return
		}

		// Return tenant list (id, slug, name) for the client to choose
		result := make([]gin.H, 0, len(tenants))
		for _, t := range tenants {
			result = append(result, gin.H{
				"id":        t.ID,
				"slug":      t.Slug,
				"name":      t.Name,
				"is_active": t.SubscriptionStatus == "active",
			})
		}

		utils.SuccessResponse(c, http.StatusOK, "Workspaces found", gin.H{"workspaces": result})
		return
	}

	// Tenant slug provided: perform normal login for that tenant
	tenant, err := h.authService.GetTenantBySlug(req.TenantSlug)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid tenant")
		return
	}

	// Create service request
	serviceReq := &services.LoginRequest{
		TenantID: tenant.ID,
		Email:    req.Email,
		Password: req.Password,
	}

	// Login user
	response, err := h.authService.Login(serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
		return
	}

	// Build response
	userResp := UserResponse{
		ID:        response.User.ID,
		TenantID:  response.User.TenantID,
		Email:     response.User.Email,
		FirstName: response.User.FirstName,
		LastName:  response.User.LastName,
		Role:      response.User.Role,
		IsActive:  response.User.IsActive,
	}

	utils.SuccessResponse(c, http.StatusOK, "Login successful", gin.H{
		"token": response.Token,
		"user":  userResp,
	})
}

// GetCurrentUser returns the currently authenticated user
// GET /api/v1/auth/me
func (h *AuthHandler) GetCurrentUser(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Get user from database
	user, err := h.authService.GetCurrentUser(userID, tenantID)
	if err != nil {
		utils.NotFoundResponse(c, "User not found")
		return
	}

	// Build response
	userResp := UserResponse{
		ID:        user.ID,
		TenantID:  user.TenantID,
		Email:     user.Email,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Role:      user.Role,
		IsActive:  user.IsActive,
	}

	utils.SuccessResponse(c, http.StatusOK, "User retrieved successfully", userResp)
}

// Logout handles user logout
// POST /api/v1/auth/logout
func (h *AuthHandler) Logout(c *gin.Context) {
	// For JWT-based auth, logout is handled client-side by removing the token
	// Here we just confirm the logout
	utils.SuccessResponse(c, http.StatusOK, "Logged out successfully", nil)
}

// RefreshToken refreshes the JWT token
// POST /api/v1/auth/refresh
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	// Get current token from Authorization header
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		utils.UnauthorizedResponse(c, "Authorization header is required")
		return
	}

	// Extract token
	parts := gin.H{}
	if len(authHeader) > 7 && authHeader[:7] == "Bearer " {
		tokenString := authHeader[7:]

		// Refresh token
		newToken, err := h.authService.RefreshToken(tokenString)
		if err != nil {
			utils.UnauthorizedResponse(c, "Invalid or expired token")
			return
		}

		parts["token"] = newToken
	} else {
		utils.UnauthorizedResponse(c, "Invalid authorization header format")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Token refreshed successfully", parts)
}
