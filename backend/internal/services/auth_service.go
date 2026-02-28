package services

import (
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// AuthService handles authentication business logic
type AuthService struct {
	userRepo   *repositories.UserRepository
	tenantRepo *repositories.TenantRepository
	jwtManager *utils.JWTManager
}

// NewAuthService creates a new auth service instance
func NewAuthService(
	userRepo *repositories.UserRepository,
	tenantRepo *repositories.TenantRepository,
	jwtManager *utils.JWTManager,
) *AuthService {
	return &AuthService{
		userRepo:   userRepo,
		tenantRepo: tenantRepo,
		jwtManager: jwtManager,
	}
}

// RegisterRequest represents a user registration request
type RegisterRequest struct {
	TenantID  uuid.UUID `json:"tenant_id"`
	Email     string    `json:"email"`
	Password  string    `json:"password"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Role      string    `json:"role"`
}

// LoginRequest represents a user login request
type LoginRequest struct {
	TenantID uuid.UUID `json:"tenant_id"`
	Email    string    `json:"email"`
	Password string    `json:"password"`
}

// AuthResponse represents an authentication response
type AuthResponse struct {
	Token string       `json:"token"`
	User  *models.User `json:"user"`
}

// Register creates a new user account
func (s *AuthService) Register(req *RegisterRequest) (*AuthResponse, error) {
	// Validate input
	if err := s.validateRegisterRequest(req); err != nil {
		return nil, err
	}

	// Check if tenant exists
	tenant, err := s.tenantRepo.FindByID(req.TenantID)
	if err != nil {
		return nil, errors.New("invalid tenant")
	}

	// Check if user already exists
	exists, err := s.userRepo.ExistsByEmail(req.Email, req.TenantID)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.New("user with this email already exists")
	}

	// Check tenant user limit
	userCount, err := s.userRepo.CountByTenant(req.TenantID)
	if err != nil {
		return nil, err
	}
	if userCount >= int64(tenant.MaxUsers) {
		return nil, errors.New("tenant has reached maximum user limit")
	}

	// Create user
	user := &models.User{
		TenantID:  req.TenantID,
		Email:     strings.ToLower(strings.TrimSpace(req.Email)),
		FirstName: strings.TrimSpace(req.FirstName),
		LastName:  strings.TrimSpace(req.LastName),
		Role:      req.Role,
		IsActive:  true,
	}

	// Set password
	if err := user.SetPassword(req.Password); err != nil {
		return nil, errors.New("failed to hash password")
	}

	// Save to database
	if err := s.userRepo.Create(user); err != nil {
		return nil, errors.New("failed to create user")
	}

	// Generate JWT token
	token, err := s.jwtManager.GenerateToken(user.ID, user.TenantID, user.Email, user.Role)
	if err != nil {
		return nil, errors.New("failed to generate token")
	}

	// Load tenant relationship
	user.Tenant = tenant

	return &AuthResponse{
		Token: token,
		User:  user,
	}, nil
}

// Login authenticates a user and returns a JWT token
func (s *AuthService) Login(req *LoginRequest) (*AuthResponse, error) {
	// Validate input
	if err := s.validateLoginRequest(req); err != nil {
		return nil, err
	}

	// Find user by email
	user, err := s.userRepo.FindByEmail(strings.ToLower(strings.TrimSpace(req.Email)), req.TenantID)
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	// Check if user is active
	if !user.IsActive {
		return nil, errors.New("account is disabled")
	}

	// Verify password
	if !user.CheckPassword(req.Password) {
		return nil, errors.New("invalid email or password")
	}

	// Update last login
	if err := s.userRepo.UpdateLastLogin(user.ID, user.TenantID); err != nil {
		// Log error but don't fail the login
	}

	// Generate JWT token
	token, err := s.jwtManager.GenerateToken(user.ID, user.TenantID, user.Email, user.Role)
	if err != nil {
		return nil, errors.New("failed to generate token")
	}

	return &AuthResponse{
		Token: token,
		User:  user,
	}, nil
}

// DiscoverTenants authenticates the email/password across all tenants and returns matching tenants.
func (s *AuthService) DiscoverTenants(email, password string) ([]*models.Tenant, error) {
	if err := utils.ValidateEmail(email); err != nil {
		return nil, err
	}
	if password == "" {
		return nil, errors.New("password is required")
	}

	users, err := s.userRepo.FindAllByEmail(strings.ToLower(strings.TrimSpace(email)))
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	var tenants []*models.Tenant
	for _, u := range users {
		// Check password for each user record (per-tenant credentials)
		if !u.IsActive {
			continue
		}

		if u.CheckPassword(password) {
			if u.Tenant != nil {
				tenants = append(tenants, u.Tenant)
			} else {
				t, terr := s.tenantRepo.FindByID(u.TenantID)
				if terr == nil {
					tenants = append(tenants, t)
				}
			}
		}
	}

	if len(tenants) == 0 {
		return nil, errors.New("invalid email or password")
	}

	return tenants, nil
}

// GetTenantBySlug returns tenant by slug via repository
func (s *AuthService) GetTenantBySlug(slug string) (*models.Tenant, error) {
	return s.tenantRepo.FindBySlug(slug)
}

// GetCurrentUser retrieves the current user by ID
func (s *AuthService) GetCurrentUser(userID, tenantID uuid.UUID) (*models.User, error) {
	user, err := s.userRepo.FindByID(userID, tenantID)
	if err != nil {
		return nil, errors.New("user not found")
	}

	return user, nil
}

// ValidateToken validates a JWT token and returns the claims
func (s *AuthService) ValidateToken(tokenString string) (*utils.JWTClaims, error) {
	return s.jwtManager.ValidateToken(tokenString)
}

// RefreshToken generates a new token from an existing valid token
func (s *AuthService) RefreshToken(tokenString string) (string, error) {
	return s.jwtManager.RefreshToken(tokenString)
}

// validateRegisterRequest validates the registration request
func (s *AuthService) validateRegisterRequest(req *RegisterRequest) error {
	if req.TenantID == uuid.Nil {
		return errors.New("tenant ID is required")
	}

	if err := utils.ValidateEmail(req.Email); err != nil {
		return err
	}

	if err := utils.ValidatePassword(req.Password); err != nil {
		return err
	}

	if err := utils.ValidateName(req.FirstName, "first name"); err != nil {
		return err
	}

	if err := utils.ValidateName(req.LastName, "last name"); err != nil {
		return err
	}

	// Default role to "user" if not provided
	if req.Role == "" {
		req.Role = "user"
	}

	if err := utils.ValidateRole(req.Role); err != nil {
		return err
	}

	return nil
}

// validateLoginRequest validates the login request
func (s *AuthService) validateLoginRequest(req *LoginRequest) error {
	if req.TenantID == uuid.Nil {
		return errors.New("tenant ID is required")
	}

	if err := utils.ValidateEmail(req.Email); err != nil {
		return err
	}

	if req.Password == "" {
		return errors.New("password is required")
	}

	return nil
}
