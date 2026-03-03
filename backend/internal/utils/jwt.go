package utils

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// Token type constants
const (
	TokenTypeGeneric = "generic"
	TokenTypeScoped  = "scoped"
)

// JWTClaims represents the claims in a JWT token
type JWTClaims struct {
	UserID     uuid.UUID  `json:"user_id"`
	BusinessID *uuid.UUID `json:"business_id,omitempty"`
	Email      string     `json:"email"`
	Role       string     `json:"role,omitempty"`
	Type       string     `json:"type"` // "generic" | "scoped"
	jwt.RegisteredClaims
}

// JWTManager handles JWT token operations
type JWTManager struct {
	secretKey       string
	expirationHours int
}

// NewJWTManager creates a new JWT manager
func NewJWTManager(secretKey string, expirationHours int) *JWTManager {
	return &JWTManager{
		secretKey:       secretKey,
		expirationHours: expirationHours,
	}
}

// GenerateGenericToken creates a token without a business scope (step 1 of login)
func (m *JWTManager) GenerateGenericToken(userID uuid.UUID, email string) (string, error) {
	claims := JWTClaims{
		UserID: userID,
		Email:  email,
		Type:   TokenTypeGeneric,
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        uuid.New().String(),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * time.Duration(m.expirationHours))),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "MERIDIEN",
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(m.secretKey))
}

// GenerateScopedToken creates a token scoped to a specific business (step 2 of login)
func (m *JWTManager) GenerateScopedToken(userID, businessID uuid.UUID, email, role string) (string, error) {
	claims := JWTClaims{
		UserID:     userID,
		BusinessID: &businessID,
		Email:      email,
		Role:       role,
		Type:       TokenTypeScoped,
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        uuid.New().String(),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * time.Duration(m.expirationHours))),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "MERIDIEN",
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(m.secretKey))
}

// GenerateToken is a backward-compatible wrapper that issues a scoped token
func (m *JWTManager) GenerateToken(userID, businessID uuid.UUID, email, role string) (string, error) {
	return m.GenerateScopedToken(userID, businessID, email, role)
}

// ValidateToken validates a JWT token and returns the claims
func (m *JWTManager) ValidateToken(tokenString string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("invalid signing method")
		}
		return []byte(m.secretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	claims, ok := token.Claims.(*JWTClaims)
	if !ok {
		return nil, errors.New("invalid token claims")
	}

	return claims, nil
}

// RefreshToken generates a new token with extended expiration (preserves type)
func (m *JWTManager) RefreshToken(tokenString string) (string, error) {
	claims, err := m.ValidateToken(tokenString)
	if err != nil {
		return "", err
	}

	if claims.Type == TokenTypeGeneric {
		return m.GenerateGenericToken(claims.UserID, claims.Email)
	}

	if claims.BusinessID == nil {
		return "", errors.New("scoped token missing business_id")
	}
	return m.GenerateScopedToken(claims.UserID, *claims.BusinessID, claims.Email, claims.Role)
}
