package handlers

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
)

func TestRBAC_OperatorCanShip(t *testing.T) {
	gin.SetMode(gin.TestMode)
	tenantID := uuid.New()
	orderID := uuid.New()

	authMid := middleware.NewAuthMiddleware(nil)
	router := gin.New()
	router.POST("/orders/:id/ship",
		func(c *gin.Context) {
			c.Set("role", "operator")
			c.Set("tenant_id", tenantID)
		},
		authMid.RequireRole("operator", "owner"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "shipped"})
		},
	)

	req := httptest.NewRequest("POST", "/orders/"+orderID.String()+"/ship", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("operator should be able to ship, got %d", w.Code)
	}
}

func TestRBAC_CollectorCannotShip(t *testing.T) {
	gin.SetMode(gin.TestMode)
	tenantID := uuid.New()
	orderID := uuid.New()

	authMid := middleware.NewAuthMiddleware(nil)
	router := gin.New()
	router.POST("/orders/:id/ship",
		func(c *gin.Context) {
			c.Set("role", "collector")
			c.Set("tenant_id", tenantID)
		},
		authMid.RequireRole("operator", "owner"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "shipped"})
		},
	)

	req := httptest.NewRequest("POST", "/orders/"+orderID.String()+"/ship", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Errorf("collector should be forbidden from shipping, got %d", w.Code)
	}
}

func TestRBAC_CollectorCanCollect(t *testing.T) {
	gin.SetMode(gin.TestMode)
	tenantID := uuid.New()
	orderID := uuid.New()

	authMid := middleware.NewAuthMiddleware(nil)
	router := gin.New()
	router.POST("/orders/:id/collect",
		func(c *gin.Context) {
			c.Set("role", "collector")
			c.Set("tenant_id", tenantID)
		},
		authMid.RequireRole("collector", "owner"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "collected"})
		},
	)

	req := httptest.NewRequest("POST", "/orders/"+orderID.String()+"/collect", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("collector should be able to collect, got %d", w.Code)
	}
}

func TestRBAC_OperatorCannotCollect(t *testing.T) {
	gin.SetMode(gin.TestMode)
	tenantID := uuid.New()
	orderID := uuid.New()

	authMid := middleware.NewAuthMiddleware(nil)
	router := gin.New()
	router.POST("/orders/:id/collect",
		func(c *gin.Context) {
			c.Set("role", "operator")
			c.Set("tenant_id", tenantID)
		},
		authMid.RequireRole("collector", "owner"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "collected"})
		},
	)

	req := httptest.NewRequest("POST", "/orders/"+orderID.String()+"/collect", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Errorf("operator should be forbidden from collecting, got %d", w.Code)
	}
}

func TestRBAC_OwnerCanShip(t *testing.T) {
	gin.SetMode(gin.TestMode)
	tenantID := uuid.New()
	orderID := uuid.New()

	authMid := middleware.NewAuthMiddleware(nil)
	router := gin.New()
	router.POST("/orders/:id/ship",
		func(c *gin.Context) {
			c.Set("role", "owner")
			c.Set("tenant_id", tenantID)
		},
		authMid.RequireRole("operator"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "shipped"})
		},
	)

	req := httptest.NewRequest("POST", "/orders/"+orderID.String()+"/ship", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("owner should be able to ship, got %d", w.Code)
	}
}

func TestRBAC_OwnerCanCollect(t *testing.T) {
	gin.SetMode(gin.TestMode)
	tenantID := uuid.New()
	orderID := uuid.New()

	authMid := middleware.NewAuthMiddleware(nil)
	router := gin.New()
	router.POST("/orders/:id/collect",
		func(c *gin.Context) {
			c.Set("role", "owner")
			c.Set("tenant_id", tenantID)
		},
		authMid.RequireRole("collector"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "collected"})
		},
	)

	req := httptest.NewRequest("POST", "/orders/"+orderID.String()+"/collect", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("owner should be able to collect, got %d", w.Code)
	}
}

func TestRBAC_NoRoleReturns403(t *testing.T) {
	gin.SetMode(gin.TestMode)
	orderID := uuid.New()

	authMid := middleware.NewAuthMiddleware(nil)
	router := gin.New()
	router.POST("/orders/:id/ship",
		authMid.RequireRole("operator"),
		func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "shipped"})
		},
	)

	req := httptest.NewRequest("POST", "/orders/"+orderID.String()+"/ship", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Errorf("missing role should return 403, got %d", w.Code)
	}
}
