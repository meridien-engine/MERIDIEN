package auth

import "testing"

func TestRoleConstants(t *testing.T) {
	cases := []struct {
		name     string
		got      string
		expected string
	}{
		{"RoleOwner", RoleOwner, "owner"},
		{"RoleAdmin", RoleAdmin, "admin"},
		{"RoleManager", RoleManager, "manager"},
		{"RoleCashier", RoleCashier, "cashier"},
		{"RoleViewer", RoleViewer, "viewer"},
		{"RoleOperator (legacy)", RoleOperator, "operator"},
		{"RoleCollector (legacy)", RoleCollector, "collector"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if tc.got != tc.expected {
				t.Errorf("expected %q, got %q", tc.expected, tc.got)
			}
		})
	}
}

func TestRolesAreDistinct(t *testing.T) {
	all := []string{
		RoleOwner, RoleAdmin, RoleManager,
		RoleCashier, RoleViewer,
		RoleOperator, RoleCollector,
	}

	seen := make(map[string]struct{}, len(all))
	for _, r := range all {
		if r == "" {
			t.Fatal("role constant must not be empty")
		}
		if _, dup := seen[r]; dup {
			t.Errorf("duplicate role value: %q", r)
		}
		seen[r] = struct{}{}
	}
}

func TestRoleHierarchy_OwnerIsNotAdmin(t *testing.T) {
	// owner and admin are separate roles — owner gets bypass in RequireRole middleware
	// but the constants themselves are distinct strings
	if RoleOwner == RoleAdmin {
		t.Error("owner and admin must be distinct role strings")
	}
}
