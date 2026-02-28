package auth

import "testing"

func TestRoleConstants(t *testing.T) {
	if RoleOperator != "operator" {
		t.Errorf("RoleOperator should be 'operator', got %s", RoleOperator)
	}
	if RoleCollector != "collector" {
		t.Errorf("RoleCollector should be 'collector', got %s", RoleCollector)
	}
	if RoleOwner != "owner" {
		t.Errorf("RoleOwner should be 'owner', got %s", RoleOwner)
	}
}

func TestRolesAreDistinct(t *testing.T) {
	roles := map[string]bool{
		RoleOperator:  false,
		RoleCollector: false,
		RoleOwner:     false,
	}

	if len(roles) != 3 {
		t.Error("Roles should be distinct")
	}

	for role := range roles {
		if role == "" {
			t.Error("Role should not be empty")
		}
	}
}
