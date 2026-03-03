package utils

import (
	"testing"

	"github.com/google/uuid"
)

func newTestManager() *JWTManager {
	return NewJWTManager("test-secret-key-for-unit-tests", 24)
}

// ─── Generic token ────────────────────────────────────────────────────────────

func TestGenerateGenericToken_IsValid(t *testing.T) {
	m := newTestManager()
	userID := uuid.New()

	tok, err := m.GenerateGenericToken(userID, "user@example.com")
	if err != nil {
		t.Fatalf("GenerateGenericToken: %v", err)
	}

	claims, err := m.ValidateToken(tok)
	if err != nil {
		t.Fatalf("ValidateToken: %v", err)
	}

	if claims.UserID != userID {
		t.Errorf("userID mismatch: want %s got %s", userID, claims.UserID)
	}
	if claims.Email != "user@example.com" {
		t.Errorf("email mismatch: got %s", claims.Email)
	}
	if claims.Type != TokenTypeGeneric {
		t.Errorf("expected type=%q, got %q", TokenTypeGeneric, claims.Type)
	}
	if claims.BusinessID != nil {
		t.Errorf("generic token must not carry business_id")
	}
	if claims.Role != "" {
		t.Errorf("generic token must not carry a role, got %q", claims.Role)
	}
}

// ─── Scoped token ─────────────────────────────────────────────────────────────

func TestGenerateScopedToken_IsValid(t *testing.T) {
	m := newTestManager()
	userID := uuid.New()
	businessID := uuid.New()

	tok, err := m.GenerateScopedToken(userID, businessID, "user@example.com", "owner")
	if err != nil {
		t.Fatalf("GenerateScopedToken: %v", err)
	}

	claims, err := m.ValidateToken(tok)
	if err != nil {
		t.Fatalf("ValidateToken: %v", err)
	}

	if claims.Type != TokenTypeScoped {
		t.Errorf("expected type=%q, got %q", TokenTypeScoped, claims.Type)
	}
	if claims.BusinessID == nil {
		t.Fatal("scoped token must carry business_id")
	}
	if *claims.BusinessID != businessID {
		t.Errorf("businessID mismatch: want %s got %s", businessID, *claims.BusinessID)
	}
	if claims.Role != "owner" {
		t.Errorf("role mismatch: want owner got %s", claims.Role)
	}
}

// ─── Token type enforcement ───────────────────────────────────────────────────

func TestTokenTypes_AreDistinct(t *testing.T) {
	if TokenTypeGeneric == TokenTypeScoped {
		t.Error("TokenTypeGeneric and TokenTypeScoped must be different strings")
	}
	if TokenTypeGeneric == "" || TokenTypeScoped == "" {
		t.Error("token type constants must not be empty")
	}
}

func TestGenericToken_RejectsWrongSecret(t *testing.T) {
	m1 := newTestManager()
	m2 := NewJWTManager("a-completely-different-secret", 24)

	tok, _ := m1.GenerateGenericToken(uuid.New(), "x@x.com")
	_, err := m2.ValidateToken(tok)
	if err == nil {
		t.Error("token signed by m1 should not validate with m2's secret")
	}
}

// ─── JTI uniqueness ───────────────────────────────────────────────────────────

func TestGenericToken_HasUniqueJTI(t *testing.T) {
	m := newTestManager()
	userID := uuid.New()

	tok1, _ := m.GenerateGenericToken(userID, "u@u.com")
	tok2, _ := m.GenerateGenericToken(userID, "u@u.com")

	c1, _ := m.ValidateToken(tok1)
	c2, _ := m.ValidateToken(tok2)

	if c1.ID == c2.ID {
		t.Error("each token must have a unique JTI")
	}
}

// ─── RefreshToken ─────────────────────────────────────────────────────────────

func TestRefreshToken_PreservesGenericType(t *testing.T) {
	m := newTestManager()
	tok, _ := m.GenerateGenericToken(uuid.New(), "u@u.com")

	refreshed, err := m.RefreshToken(tok)
	if err != nil {
		t.Fatalf("RefreshToken: %v", err)
	}

	claims, _ := m.ValidateToken(refreshed)
	if claims.Type != TokenTypeGeneric {
		t.Errorf("refreshed generic token should remain generic, got %q", claims.Type)
	}
}

func TestRefreshToken_PreservesScopedType(t *testing.T) {
	m := newTestManager()
	tok, _ := m.GenerateScopedToken(uuid.New(), uuid.New(), "u@u.com", "admin")

	refreshed, err := m.RefreshToken(tok)
	if err != nil {
		t.Fatalf("RefreshToken: %v", err)
	}

	claims, _ := m.ValidateToken(refreshed)
	if claims.Type != TokenTypeScoped {
		t.Errorf("refreshed scoped token should remain scoped, got %q", claims.Type)
	}
	if claims.Role != "admin" {
		t.Errorf("role should be preserved after refresh, got %q", claims.Role)
	}
}
