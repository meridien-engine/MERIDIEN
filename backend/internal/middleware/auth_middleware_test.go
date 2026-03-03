package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func newRouter(setup func(r *gin.Engine)) *gin.Engine {
	r := gin.New()
	setup(r)
	return r
}

// ─── RequireRole — existing roles ────────────────────────────────────────────

func TestRequireRole_AllowedRole(t *testing.T) {
	am := NewAuthMiddleware(nil, nil)
	r := newRouter(func(r *gin.Engine) {
		r.GET("/test",
			func(c *gin.Context) { c.Set("role", "operator") },
			am.RequireRole("operator", "owner"),
			func(c *gin.Context) { c.JSON(http.StatusOK, nil) },
		)
	})
	w := doGet(r, "/test")
	assertStatus(t, w, http.StatusOK)
}

func TestRequireRole_DeniedRole(t *testing.T) {
	am := NewAuthMiddleware(nil, nil)
	r := newRouter(func(r *gin.Engine) {
		r.GET("/test",
			func(c *gin.Context) { c.Set("role", "collector") },
			am.RequireRole("operator"),
			func(c *gin.Context) { c.JSON(http.StatusOK, nil) },
		)
	})
	assertStatus(t, doGet(r, "/test"), http.StatusForbidden)
}

func TestRequireRole_OwnerBypass(t *testing.T) {
	am := NewAuthMiddleware(nil, nil)
	r := newRouter(func(r *gin.Engine) {
		r.GET("/test",
			func(c *gin.Context) { c.Set("role", "owner") },
			am.RequireRole("operator"),
			func(c *gin.Context) { c.JSON(http.StatusOK, nil) },
		)
	})
	assertStatus(t, doGet(r, "/test"), http.StatusOK)
}

// ─── RequireRole — new role set ───────────────────────────────────────────────

func TestRequireRole_NewRoles(t *testing.T) {
	am := NewAuthMiddleware(nil, nil)

	cases := []struct {
		name         string
		userRole     string
		requiredRole string
		wantStatus   int
	}{
		{"admin allowed on admin route", "admin", "admin", http.StatusOK},
		{"manager denied on admin route", "manager", "admin", http.StatusForbidden},
		{"cashier denied on admin route", "cashier", "admin", http.StatusForbidden},
		{"viewer denied on admin route", "viewer", "admin", http.StatusForbidden},
		{"owner bypasses admin route", "owner", "admin", http.StatusOK},
		{"manager allowed on manager route", "manager", "manager", http.StatusOK},
		{"cashier denied on manager route", "cashier", "manager", http.StatusForbidden},
		{"cashier allowed on cashier route", "cashier", "cashier", http.StatusOK},
		{"viewer denied on cashier route", "viewer", "cashier", http.StatusForbidden},
		{"viewer allowed on viewer route", "viewer", "viewer", http.StatusOK},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			r := newRouter(func(r *gin.Engine) {
				r.GET("/test",
					func(c *gin.Context) { c.Set("role", tc.userRole) },
					am.RequireRole(tc.requiredRole),
					func(c *gin.Context) { c.JSON(http.StatusOK, nil) },
				)
			})
			assertStatus(t, doGet(r, "/test"), tc.wantStatus)
		})
	}
}

func TestRequireRole_MissingRoleContext_Returns403(t *testing.T) {
	am := NewAuthMiddleware(nil, nil)
	r := newRouter(func(r *gin.Engine) {
		r.GET("/test",
			// no role set in context
			am.RequireRole("operator"),
			func(c *gin.Context) { c.JSON(http.StatusOK, nil) },
		)
	})
	assertStatus(t, doGet(r, "/test"), http.StatusForbidden)
}

// ─── RequireAuth — rejects generic token ─────────────────────────────────────

func TestRequireAuth_RejectsNoAuthHeader(t *testing.T) {
	am := NewAuthMiddleware(nil, nil)
	r := newRouter(func(r *gin.Engine) {
		r.GET("/protected", am.RequireAuth(), func(c *gin.Context) {
			c.JSON(http.StatusOK, nil)
		})
	})
	assertStatus(t, doGet(r, "/protected"), http.StatusUnauthorized)
}

// ─── RequireGenericAuth ───────────────────────────────────────────────────────

func TestRequireGenericAuth_RejectsNoAuthHeader(t *testing.T) {
	am := NewAuthMiddleware(nil, nil)
	r := newRouter(func(r *gin.Engine) {
		r.GET("/generic", am.RequireGenericAuth(), func(c *gin.Context) {
			c.JSON(http.StatusOK, nil)
		})
	})
	assertStatus(t, doGet(r, "/generic"), http.StatusUnauthorized)
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

func doGet(r *gin.Engine, path string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodGet, path, nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

func assertStatus(t *testing.T, w *httptest.ResponseRecorder, want int) {
	t.Helper()
	if w.Code != want {
		t.Errorf("expected HTTP %d, got %d", want, w.Code)
	}
}
