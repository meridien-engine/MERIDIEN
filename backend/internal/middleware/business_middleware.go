package middleware

import (
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/database"
)

// BusinessMiddleware attempts to set the current business on the DB session for the request.
// Repositories still set LOCAL business per-transaction to guarantee isolation.
func BusinessMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		if businessID, exists := c.Get("business_id"); exists && businessID != nil {
			var idStr string

			// business_id is stored as *uuid.UUID from JWT claims
			switch v := businessID.(type) {
			case *interface{}:
				_ = v
			default:
				idStr = fmt.Sprintf("%v", businessID)
			}

			if idStr != "" && idStr != "<nil>" {
				if db := database.GetDB(); db != nil {
					if _, err := db.DB(); err == nil {
						if err := db.Exec(fmt.Sprintf("SET app.current_business = '%s'", idStr)).Error; err != nil {
							log.Printf("warning: failed to set app.current_business: %v", err)
						}
					}
				}
			}
		}

		c.Next()
	}
}

// TenantMiddleware is kept for backward compatibility — delegates to BusinessMiddleware.
// Deprecated: use BusinessMiddleware.
func TenantMiddleware() gin.HandlerFunc {
	return BusinessMiddleware()
}
