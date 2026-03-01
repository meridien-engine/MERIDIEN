package middleware

import (
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// blacklistChecker can check whether a JTI has been revoked.
type blacklistChecker interface {
	IsBlacklisted(jti string) (bool, error)
}

// AuthMiddleware handles JWT authentication
type AuthMiddleware struct {
	jwtManager *utils.JWTManager
	blacklist  blacklistChecker
}

// NewAuthMiddleware creates a new auth middleware instance.
// blacklist may be nil; if so, revocation checks are skipped.
func NewAuthMiddleware(jwtManager *utils.JWTManager, blacklist blacklistChecker) *AuthMiddleware {
	return &AuthMiddleware{
		jwtManager: jwtManager,
		blacklist:  blacklist,
	}
}

// RequireAuth middleware validates JWT token
func (m *AuthMiddleware) RequireAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get token from Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			utils.UnauthorizedResponse(c, "Authorization header is required")
			c.Abort()
			return
		}

		// Check if it's a Bearer token
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			utils.UnauthorizedResponse(c, "Invalid authorization header format")
			c.Abort()
			return
		}

		tokenString := parts[1]

		// Validate token
		claims, err := m.jwtManager.ValidateToken(tokenString)
		if err != nil {
			utils.UnauthorizedResponse(c, "Invalid or expired token")
			c.Abort()
			return
		}

		// Check if the token has been revoked (fail open on Redis errors)
		if m.blacklist != nil && claims.ID != "" {
			revoked, err := m.blacklist.IsBlacklisted(claims.ID)
			if err == nil && revoked {
				utils.UnauthorizedResponse(c, "Token has been revoked")
				c.Abort()
				return
			}
		}

		// Set user info in context
		c.Set("user_id", claims.UserID)
		c.Set("tenant_id", claims.TenantID)
		c.Set("email", claims.Email)
		c.Set("role", claims.Role)

		c.Next()
	}
}

// RequireRole middleware checks if user has required role
func (m *AuthMiddleware) RequireRole(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("role")
		if !exists {
			utils.ForbiddenResponse(c, "Role not found in context")
			c.Abort()
			return
		}

		role, ok := userRole.(string)
		if !ok {
			utils.ForbiddenResponse(c, "Invalid role type")
			c.Abort()
			return
		}

		// Owner role always has access
		if role == "owner" {
			c.Next()
			return
		}

		// Check if user has one of the required roles
		hasRole := false
		for _, requiredRole := range roles {
			if role == requiredRole {
				hasRole = true
				break
			}
		}

		if !hasRole {
			utils.ForbiddenResponse(c, "Insufficient permissions")
			c.Abort()
			return
		}

		c.Next()
	}
}

// GetUserID retrieves the user ID from context
func GetUserID(c *gin.Context) (uuid.UUID, error) {
	userID, exists := c.Get("user_id")
	if !exists {
		return uuid.Nil, utils.NewError("user ID not found in context")
	}

	id, ok := userID.(uuid.UUID)
	if !ok {
		return uuid.Nil, utils.NewError("invalid user ID type")
	}

	return id, nil
}

// GetTenantID retrieves the tenant ID from context
func GetTenantID(c *gin.Context) (uuid.UUID, error) {
	tenantID, exists := c.Get("tenant_id")
	if !exists {
		return uuid.Nil, utils.NewError("tenant ID not found in context")
	}

	id, ok := tenantID.(uuid.UUID)
	if !ok {
		return uuid.Nil, utils.NewError("invalid tenant ID type")
	}

	return id, nil
}

// GetEmail retrieves the email from context
func GetEmail(c *gin.Context) (string, error) {
	email, exists := c.Get("email")
	if !exists {
		return "", utils.NewError("email not found in context")
	}

	e, ok := email.(string)
	if !ok {
		return "", utils.NewError("invalid email type")
	}

	return e, nil
}

// GetRole retrieves the role from context
func GetRole(c *gin.Context) (string, error) {
	role, exists := c.Get("role")
	if !exists {
		return "", utils.NewError("role not found in context")
	}

	r, ok := role.(string)
	if !ok {
		return "", utils.NewError("invalid role type")
	}

	return r, nil
}
