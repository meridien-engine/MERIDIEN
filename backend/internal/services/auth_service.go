package services

import (
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// tokenBlacklist is a minimal interface so the service doesn't import the cache package directly.
type tokenBlacklist interface {
	Add(jti string, ttl time.Duration) error
}

// AuthService handles authentication business logic
type AuthService struct {
	userRepo     *repositories.UserRepository
	businessRepo *repositories.BusinessRepository
	jwtManager   *utils.JWTManager
	blacklist    tokenBlacklist
}

// NewAuthService creates a new auth service instance.
// blacklist may be nil; if so, token revocation is a no-op.
func NewAuthService(
	userRepo *repositories.UserRepository,
	businessRepo *repositories.BusinessRepository,
	jwtManager *utils.JWTManager,
	blacklist tokenBlacklist,
) *AuthService {
	return &AuthService{
		userRepo:     userRepo,
		businessRepo: businessRepo,
		jwtManager:   jwtManager,
		blacklist:    blacklist,
	}
}

// RegisterRequest represents a user registration request
type RegisterRequest struct {
	Email     string `json:"email"`
	Password  string `json:"password"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

// LoginRequest represents a user login request
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// AuthResponse represents a generic (step-1) authentication response
type AuthResponse struct {
	Token string       `json:"token"`
	User  *models.User `json:"user"`
}

// Register creates a new user account and returns a generic JWT
func (s *AuthService) Register(req *RegisterRequest) (*AuthResponse, error) {
	if err := s.validateRegisterRequest(req); err != nil {
		return nil, err
	}

	// Check if email already exists globally
	exists, err := s.userRepo.ExistsByEmail(req.Email)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.New("user with this email already exists")
	}

	// Create user
	user := &models.User{
		Email:     strings.ToLower(strings.TrimSpace(req.Email)),
		FirstName: strings.TrimSpace(req.FirstName),
		LastName:  strings.TrimSpace(req.LastName),
		Role:      "user",
		IsActive:  true,
	}

	if err := user.SetPassword(req.Password); err != nil {
		return nil, errors.New("failed to hash password")
	}

	if err := s.userRepo.Create(user); err != nil {
		return nil, errors.New("failed to create user")
	}

	// Issue generic token (no business yet)
	token, err := s.jwtManager.GenerateGenericToken(user.ID, user.Email)
	if err != nil {
		return nil, errors.New("failed to generate token")
	}

	return &AuthResponse{Token: token, User: user}, nil
}

// Login authenticates a user and returns a generic JWT
func (s *AuthService) Login(req *LoginRequest) (*AuthResponse, error) {
	if err := s.validateLoginRequest(req); err != nil {
		return nil, err
	}

	user, err := s.userRepo.FindByEmail(strings.ToLower(strings.TrimSpace(req.Email)))
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	if !user.IsActive {
		return nil, errors.New("account is disabled")
	}

	if !user.CheckPassword(req.Password) {
		return nil, errors.New("invalid email or password")
	}

	// Best-effort update last login
	_ = s.userRepo.UpdateLastLogin(user.ID)

	// Issue generic token
	token, err := s.jwtManager.GenerateGenericToken(user.ID, user.Email)
	if err != nil {
		return nil, errors.New("failed to generate token")
	}

	return &AuthResponse{Token: token, User: user}, nil
}

// GetUserBusinesses returns all businesses the user belongs to
func (s *AuthService) GetUserBusinesses(userID uuid.UUID) ([]*models.Business, error) {
	return s.businessRepo.GetUserBusinesses(userID)
}

// UseBusiness issues a scoped JWT for the given business if the user is a member
func (s *AuthService) UseBusiness(userID, businessID uuid.UUID) (string, string, error) {
	membership, err := s.businessRepo.GetMembership(userID, businessID)
	if err != nil {
		return "", "", errors.New("you are not a member of this business")
	}

	if membership.Status != "active" {
		return "", "", errors.New("membership is not active")
	}

	token, err := s.jwtManager.GenerateScopedToken(userID, businessID, "", membership.Role)
	if err != nil {
		return "", "", errors.New("failed to generate token")
	}

	return token, membership.Role, nil
}

// GetCurrentUser retrieves the current user by ID
func (s *AuthService) GetCurrentUser(userID uuid.UUID) (*models.User, error) {
	user, err := s.userRepo.FindByID(userID)
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

// RevokeToken blacklists the given token so it cannot be used again.
func (s *AuthService) RevokeToken(tokenString string) {
	if s.blacklist == nil {
		return
	}
	claims, err := s.jwtManager.ValidateToken(tokenString)
	if err != nil || claims.ID == "" {
		return
	}
	ttl := time.Until(claims.ExpiresAt.Time)
	_ = s.blacklist.Add(claims.ID, ttl)
}

// validateRegisterRequest validates the registration request
func (s *AuthService) validateRegisterRequest(req *RegisterRequest) error {
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
	return nil
}

// validateLoginRequest validates the login request
func (s *AuthService) validateLoginRequest(req *LoginRequest) error {
	if err := utils.ValidateEmail(req.Email); err != nil {
		return err
	}
	if req.Password == "" {
		return errors.New("password is required")
	}
	return nil
}
