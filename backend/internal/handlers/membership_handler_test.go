package handlers

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
)

func init() {
	gin.SetMode(gin.TestMode)
}

// membershipRoute builds a minimal router that pre-sets role in the context
// then applies RequireRole, then calls a no-op handler — tests pure RBAC.
func membershipRoute(method, path, contextRole string, requiredRoles ...string) *gin.Engine {
	am := middleware.NewAuthMiddleware(nil, nil)
	r := gin.New()
	r.Handle(method, path,
		func(c *gin.Context) {
			if contextRole != "" {
				c.Set("role", contextRole)
			}
		},
		am.RequireRole(requiredRoles...),
		func(c *gin.Context) { c.JSON(http.StatusOK, gin.H{"ok": true}) },
	)
	return r
}

func doRequest(r *gin.Engine, method, path string) int {
	req := httptest.NewRequest(method, path, nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w.Code
}

// ─── Join requests (admin+) ───────────────────────────────────────────────────

func TestMembershipRBAC_JoinRequests(t *testing.T) {
	id := uuid.New().String()
	reqID := uuid.New().String()

	cases := []struct {
		name       string
		role       string
		wantStatus int
	}{
		{"owner can list join requests", "owner", http.StatusOK},
		{"admin can list join requests", "admin", http.StatusOK},
		{"manager cannot list join requests", "manager", http.StatusForbidden},
		{"cashier cannot list join requests", "cashier", http.StatusForbidden},
		{"viewer cannot list join requests", "viewer", http.StatusForbidden},
		{"no role cannot list join requests", "", http.StatusForbidden},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			r := membershipRoute("GET", "/businesses/:id/join-requests", tc.role, "admin", "owner")
			got := doRequest(r, "GET", "/businesses/"+id+"/join-requests")
			if got != tc.wantStatus {
				t.Errorf("want %d got %d", tc.wantStatus, got)
			}
		})
	}

	// approve / reject follow same admin+ rule
	for _, tc := range cases {
		t.Run("approve — "+tc.name, func(t *testing.T) {
			r := membershipRoute("POST", "/businesses/:id/join-requests/:reqId/approve", tc.role, "admin", "owner")
			got := doRequest(r, "POST", "/businesses/"+id+"/join-requests/"+reqID+"/approve")
			if got != tc.wantStatus {
				t.Errorf("want %d got %d", tc.wantStatus, got)
			}
		})
	}
}

// ─── Invitations (admin+) ─────────────────────────────────────────────────────

func TestMembershipRBAC_Invitations(t *testing.T) {
	id := uuid.New().String()

	cases := []struct {
		role       string
		wantStatus int
	}{
		{"owner", http.StatusOK},
		{"admin", http.StatusOK},
		{"manager", http.StatusForbidden},
		{"cashier", http.StatusForbidden},
		{"viewer", http.StatusForbidden},
	}

	for _, tc := range cases {
		t.Run("send invitation role="+tc.role, func(t *testing.T) {
			r := membershipRoute("POST", "/businesses/:id/invitations", tc.role, "admin", "owner")
			got := doRequest(r, "POST", "/businesses/"+id+"/invitations")
			if got != tc.wantStatus {
				t.Errorf("want %d got %d", tc.wantStatus, got)
			}
		})
	}
}

// ─── Member management ────────────────────────────────────────────────────────

func TestMembershipRBAC_Members(t *testing.T) {
	id := uuid.New().String()
	userID := uuid.New().String()

	// GET /members — admin+
	listCases := []struct {
		role       string
		wantStatus int
	}{
		{"owner", http.StatusOK},
		{"admin", http.StatusOK},
		{"manager", http.StatusForbidden},
		{"viewer", http.StatusForbidden},
	}

	for _, tc := range listCases {
		t.Run("list members role="+tc.role, func(t *testing.T) {
			r := membershipRoute("GET", "/businesses/:id/members", tc.role, "admin", "owner")
			got := doRequest(r, "GET", "/businesses/"+id+"/members")
			if got != tc.wantStatus {
				t.Errorf("want %d got %d", tc.wantStatus, got)
			}
		})
	}

	// DELETE /members/:userId — owner only
	removeCases := []struct {
		role       string
		wantStatus int
	}{
		{"owner", http.StatusOK},
		{"admin", http.StatusForbidden},
		{"manager", http.StatusForbidden},
	}

	for _, tc := range removeCases {
		t.Run("remove member role="+tc.role, func(t *testing.T) {
			r := membershipRoute("DELETE", "/businesses/:id/members/:userId", tc.role, "owner")
			got := doRequest(r, "DELETE", "/businesses/"+id+"/members/"+userID)
			if got != tc.wantStatus {
				t.Errorf("want %d got %d", tc.wantStatus, got)
			}
		})
	}
}

// ─── Owner always bypasses RequireRole ───────────────────────────────────────

func TestMembershipRBAC_OwnerBypassesAll(t *testing.T) {
	id := uuid.New().String()

	routes := []struct{ method, path string }{
		{"GET", "/businesses/" + id + "/join-requests"},
		{"GET", "/businesses/" + id + "/invitations"},
		{"GET", "/businesses/" + id + "/members"},
	}

	for _, route := range routes {
		t.Run(route.method+" "+route.path, func(t *testing.T) {
			r := membershipRoute(route.method, route.path, "owner", "admin")
			got := doRequest(r, route.method, route.path)
			if got != http.StatusOK {
				t.Errorf("owner should bypass any role restriction, got %d", got)
			}
		})
	}
}
