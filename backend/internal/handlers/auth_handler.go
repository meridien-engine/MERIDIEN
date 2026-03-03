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
	return &AuthHandler{authService: authService}
}

// RegisterRequest represents the registration request body
type RegisterRequest struct {
	Email     string `json:"email" binding:"required"`
	Password  string `json:"password" binding:"required"`
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
}

// LoginRequest represents the login request body
type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// UserResponse represents the user data in responses (without password)
type UserResponse struct {
	ID        uuid.UUID `json:"id"`
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

	serviceReq := &services.RegisterRequest{
		Email:     req.Email,
		Password:  req.Password,
		FirstName: req.FirstName,
		LastName:  req.LastName,
	}

	response, err := h.authService.Register(serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	userResp := UserResponse{
		ID:        response.User.ID,
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

// Login handles user authentication and returns a generic JWT
// POST /api/v1/auth/login
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	serviceReq := &services.LoginRequest{
		Email:    req.Email,
		Password: req.Password,
	}

	response, err := h.authService.Login(serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized, err.Error())
		return
	}

	userResp := UserResponse{
		ID:        response.User.ID,
		Email:     response.User.Email,
		FirstName: response.User.FirstName,
		LastName:  response.User.LastName,
		Role:      response.User.Role,
		IsActive:  response.User.IsActive,
	}

	utils.SuccessResponse(c, http.StatusOK, "Login successful", gin.H{
		"token": response.Token,
		"user":  userResp,
		"type":  "generic",
	})
}

// GetUserBusinesses returns all businesses the authenticated user belongs to
// GET /api/v1/auth/businesses
func (h *AuthHandler) GetUserBusinesses(c *gin.Context) {
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	businesses, err := h.authService.GetUserBusinesses(userID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve businesses")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Businesses retrieved", businesses)
}

// UseBusiness issues a scoped JWT for the selected business
// POST /api/v1/auth/use-business/:id
func (h *AuthHandler) UseBusiness(c *gin.Context) {
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	businessIDStr := c.Param("id")
	businessID, err := uuid.Parse(businessIDStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid business ID")
		return
	}

	token, role, err := h.authService.UseBusiness(userID, businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusForbidden, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Business selected", gin.H{
		"token": token,
		"role":  role,
		"type":  "scoped",
	})
}

// GetCurrentUser returns the currently authenticated user
// GET /api/v1/auth/me
func (h *AuthHandler) GetCurrentUser(c *gin.Context) {
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	user, err := h.authService.GetCurrentUser(userID)
	if err != nil {
		utils.NotFoundResponse(c, "User not found")
		return
	}

	userResp := UserResponse{
		ID:        user.ID,
		Email:     user.Email,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Role:      user.Role,
		IsActive:  user.IsActive,
	}

	utils.SuccessResponse(c, http.StatusOK, "User retrieved successfully", userResp)
}

// Logout handles user logout and revokes the bearer token.
// POST /api/v1/auth/logout
func (h *AuthHandler) Logout(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if len(authHeader) > 7 && authHeader[:7] == "Bearer " {
		h.authService.RevokeToken(authHeader[7:])
	}
	utils.SuccessResponse(c, http.StatusOK, "Logged out successfully", nil)
}

// RefreshToken refreshes the JWT token
// POST /api/v1/auth/refresh
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		utils.UnauthorizedResponse(c, "Authorization header is required")
		return
	}

	parts := gin.H{}
	if len(authHeader) > 7 && authHeader[:7] == "Bearer " {
		tokenString := authHeader[7:]

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
