package middleware

import (
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
					// Exec on the connection pool; repositories set LOCAL within transactions for safety
					if err := db.Exec("SET app.current_tenant = ?", tenant).Error; err != nil {
						log.Printf("warning: failed to set app.current_tenant: %v", err)
					}
				}
			}
		}

		c.Next()
	}
}
