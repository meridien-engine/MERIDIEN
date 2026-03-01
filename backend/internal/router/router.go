package router

import (
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	rbac "github.com/mu7ammad-3li/MERIDIEN/backend/internal/auth"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/handlers"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
)

// rateLimiterMiddleware is a local interface so the router doesn't import the middleware package type directly.
type rateLimiterMiddleware interface {
	Middleware() gin.HandlerFunc
}

// Setup configures and returns the router.
// authRateLimiter may be nil; if so, no rate limiting is applied to auth routes.
func Setup(debug bool, authHandler *handlers.AuthHandler, customerHandler *handlers.CustomerHandler, productHandler *handlers.ProductHandler, orderHandler *handlers.OrderHandler, reportHandler *handlers.ReportHandler, locationHandler *handlers.LocationHandler, authMiddleware *middleware.AuthMiddleware, authRateLimiter rateLimiterMiddleware) *gin.Engine {
	// Set Gin mode
	if !debug {
		gin.SetMode(gin.ReleaseMode)
	}

	// Create router
	router := gin.Default()

	// Configure CORS
	router.Use(cors.New(cors.Config{
		AllowOriginFunc: func(origin string) bool {
			// Allow all localhost origins for development
			return origin == "http://localhost:3000" ||
				origin == "http://localhost:8080" ||
				len(origin) >= 16 && origin[:16] == "http://localhost"
		},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "healthy",
			"service": "MERIDIEN API",
			"time":    time.Now().UTC(),
		})
	})

	// API v1 group
	v1 := router.Group("/api/v1")
	{
		// Public routes
		v1.GET("/ping", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"message": "pong",
			})
		})

		// Auth routes (public, rate-limited)
		auth := v1.Group("/auth")
		if authRateLimiter != nil {
			auth.Use(authRateLimiter.Middleware())
		}
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/refresh", authHandler.RefreshToken)
		}

		// Protected auth routes
		authProtected := v1.Group("/auth")
		authProtected.Use(authMiddleware.RequireAuth(), middleware.TenantMiddleware())
		{
			authProtected.GET("/me", authHandler.GetCurrentUser)
			authProtected.POST("/logout", authHandler.Logout)
		}

		// Protected routes (require authentication)
		protected := v1.Group("")
		protected.Use(authMiddleware.RequireAuth(), middleware.TenantMiddleware())
		{
			// Customer routes
			customers := protected.Group("/customers")
			{
				customers.POST("", customerHandler.Create)
				customers.GET("", customerHandler.List)
				customers.GET("/:id", customerHandler.GetByID)
				customers.PUT("/:id", customerHandler.Update)
				customers.DELETE("/:id", customerHandler.Delete)
			}

			// Product routes
			products := protected.Group("/products")
			{
				products.POST("", productHandler.Create)
				products.GET("", productHandler.List)
				products.GET("/:id", productHandler.GetByID)
				products.PUT("/:id", productHandler.Update)
				products.DELETE("/:id", productHandler.Delete)
			}

			// Order routes
			orders := protected.Group("/orders")
			{
				orders.POST("", authMiddleware.RequireRole(rbac.RoleOperator, rbac.RoleOwner), orderHandler.Create)
				orders.GET("", orderHandler.List)
				orders.GET("/:id", orderHandler.GetByID)
				orders.PUT("/:id", orderHandler.Update)
				orders.DELETE("/:id", orderHandler.Delete)

				// Order status transitions
				orders.POST("/:id/confirm", orderHandler.Confirm)
				orders.POST("/:id/ship", authMiddleware.RequireRole(rbac.RoleOperator, rbac.RoleOwner), orderHandler.Ship)
				orders.POST("/:id/deliver", authMiddleware.RequireRole(rbac.RoleOperator, rbac.RoleOwner), orderHandler.Deliver)
				orders.POST("/:id/cancel", orderHandler.Cancel)
				orders.POST("/:id/collect", authMiddleware.RequireRole(rbac.RoleCollector, rbac.RoleOwner), orderHandler.Collect)

				// Order payments
				orders.POST("/:id/payments", orderHandler.RecordPayment)
				orders.GET("/:id/payments", orderHandler.ListPayments)
			}

			// Location routes
			locations := protected.Group("/locations")
			{
				locations.POST("", locationHandler.Create)
				locations.GET("", locationHandler.List)
				locations.GET("/:id", locationHandler.GetByID)
				locations.PUT("/:id", locationHandler.Update)
				locations.DELETE("/:id", locationHandler.Delete)
			}

			// Report routes (owner-only)
			reports := protected.Group("/reports")
			{
				reports.GET("/courier-reconciliation", authMiddleware.RequireRole(rbac.RoleOwner), reportHandler.GetCourierReconciliation)
			}
		}
	}

	return router
}
