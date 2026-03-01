package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestRequireRole_AllowedRole(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	am := NewAuthMiddleware(nil, nil)

	router.GET("/test",
		func(c *gin.Context) {
			c.Set("role", "operator")
		},
		am.RequireRole("operator", "owner"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "ok"})
		},
	)

	req := httptest.NewRequest("GET", "/test", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

func TestRequireRole_DeniedRole(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	am := NewAuthMiddleware(nil, nil)

	router.GET("/test",
		func(c *gin.Context) {
			c.Set("role", "collector")
		},
		am.RequireRole("operator"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "ok"})
		},
	)

	req := httptest.NewRequest("GET", "/test", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Errorf("expected 403, got %d", w.Code)
	}
}

func TestRequireRole_OwnerBypass(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	am := NewAuthMiddleware(nil, nil)

	router.GET("/test",
		func(c *gin.Context) {
			c.Set("role", "owner")
		},
		am.RequireRole("operator"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "ok"})
		},
	)

	req := httptest.NewRequest("GET", "/test", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected owner to be allowed, got %d", w.Code)
	}
}
