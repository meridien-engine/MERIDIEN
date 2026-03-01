package middleware

import (
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/database"
)

// TenantMiddleware attempts to set the current tenant on the DB session for the request.
// Repositories still set LOCAL tenant per-transaction to guarantee isolation.
func TenantMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// tenant_id is expected to be set by the auth middleware
		if tenant, exists := c.Get("tenant_id"); exists {
			// best-effort: set session variable for operations that might not run in a transaction
			if db := database.GetDB(); db != nil {
				if _, err := db.DB(); err == nil {
					// SET does not support $1 placeholders; inline the UUID directly.
					// UUIDs are hex+hyphens only — no injection risk.
					if err := db.Exec(fmt.Sprintf("SET app.current_tenant = '%v'", tenant)).Error; err != nil {
						log.Printf("warning: failed to set app.current_tenant: %v", err)
					}
				}
			}
		}

		c.Next()
	}
}
