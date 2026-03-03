package auth

// Role constants for RBAC
const (
	RoleOwner   = "owner"
	RoleAdmin   = "admin"
	RoleManager = "manager"
	RoleCashier = "cashier"
	RoleViewer  = "viewer"

	// Legacy aliases kept for existing routes
	RoleOperator  = "operator"
	RoleCollector = "collector"
)
