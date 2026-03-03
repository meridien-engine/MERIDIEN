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
func Setup(
	debug bool,
	authHandler *handlers.AuthHandler,
	customerHandler *handlers.CustomerHandler,
	productHandler *handlers.ProductHandler,
	orderHandler *handlers.OrderHandler,
	reportHandler *handlers.ReportHandler,
	locationHandler *handlers.LocationHandler,
	posHandler *handlers.POSHandler,
	businessHandler *handlers.BusinessHandler,
	storeHandler *handlers.StoreHandler,
	membershipHandler *handlers.MembershipHandler,
	branchHandler *handlers.BranchHandler,
	branchInventoryHandler *handlers.BranchInventoryHandler,
	authMiddleware *middleware.AuthMiddleware,
	authRateLimiter rateLimiterMiddleware,
) *gin.Engine {
	if !debug {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	// Configure CORS
	router.Use(cors.New(cors.Config{
		AllowOriginFunc: func(origin string) bool {
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

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "healthy",
			"service": "MERIDIEN API",
			"time":    time.Now().UTC(),
		})
	})

	v1 := router.Group("/api/v1")
	{
		v1.GET("/ping", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"message": "pong"})
		})

		// ── Public auth routes (rate-limited) ──────────────────────────
		auth := v1.Group("/auth")
		if authRateLimiter != nil {
			auth.Use(authRateLimiter.Middleware())
		}
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/refresh", authHandler.RefreshToken)
		}

		// ── Generic-auth auth routes (generic OR scoped token) ──────────
		authGeneric := v1.Group("/auth")
		authGeneric.Use(authMiddleware.RequireGenericAuth())
		{
			authGeneric.GET("/me", authHandler.GetCurrentUser)
			authGeneric.POST("/logout", authHandler.Logout)
			authGeneric.GET("/businesses", authHandler.GetUserBusinesses)
			authGeneric.POST("/use-business/:id", authHandler.UseBusiness)
		}

		// ── Generic-auth business routes ────────────────────────────────
		bizGeneric := v1.Group("")
		bizGeneric.Use(authMiddleware.RequireGenericAuth())
		{
			bizGeneric.GET("/business-categories", businessHandler.GetCategories)
			bizGeneric.POST("/businesses", businessHandler.CreateBusiness)

			// Business lookup by slug (no business context needed)
			bizGeneric.GET("/businesses/slug/:slug", membershipHandler.LookupBusiness)

			// Join requests (submitted by users who aren't yet members)
			bizGeneric.POST("/join-requests", membershipHandler.SubmitJoinRequest)
			bizGeneric.GET("/join-requests", membershipHandler.ListMyJoinRequests)

			// Invitation token validation and acceptance
			bizGeneric.GET("/invitations/:token", membershipHandler.ValidateInvitation)
			bizGeneric.POST("/invitations/:token/accept", membershipHandler.AcceptInvitation)
		}

		// ── Protected routes (require SCOPED token) ─────────────────────
		protected := v1.Group("")
		protected.Use(authMiddleware.RequireAuth(), middleware.BusinessMiddleware())
		{
			// Business details
			protected.GET("/businesses/:id", businessHandler.GetBusiness)

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
				products.GET("/lookup", posHandler.LookupProduct)
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

				orders.POST("/:id/confirm", orderHandler.Confirm)
				orders.POST("/:id/ship", authMiddleware.RequireRole(rbac.RoleOperator, rbac.RoleOwner), orderHandler.Ship)
				orders.POST("/:id/deliver", authMiddleware.RequireRole(rbac.RoleOperator, rbac.RoleOwner), orderHandler.Deliver)
				orders.POST("/:id/cancel", orderHandler.Cancel)
				orders.POST("/:id/collect", authMiddleware.RequireRole(rbac.RoleCollector, rbac.RoleOwner), orderHandler.Collect)

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

			// POS routes
			pos := protected.Group("/pos")
			{
				pos.POST("/sessions", posHandler.OpenSession)
				pos.GET("/sessions", posHandler.ListSessions)
				pos.GET("/sessions/current", posHandler.GetCurrentSession)
				pos.GET("/sessions/:id", posHandler.GetSession)
				pos.POST("/sessions/:id/close", posHandler.CloseSession)
				pos.POST("/checkout", posHandler.Checkout)
			}

			// Store routes
			stores := protected.Group("/stores")
			{
				stores.GET("", storeHandler.ListStores)
				stores.GET("/:id", storeHandler.GetStore)
				stores.POST("", storeHandler.CreateStore)
				stores.PUT("/:id", storeHandler.UpdateStore)
				stores.DELETE("/:id", storeHandler.DeleteStore)
			}

			// Report routes (owner-only)
			reports := protected.Group("/reports")
			{
				reports.GET("/courier-reconciliation", authMiddleware.RequireRole(rbac.RoleOwner), reportHandler.GetCourierReconciliation)
			}

			// Membership management routes (scoped token required)
			protected.GET("/businesses/:id/join-requests", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), membershipHandler.ListBusinessJoinRequests)
			protected.POST("/businesses/:id/join-requests/:reqId/approve", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), membershipHandler.ApproveJoinRequest)
			protected.POST("/businesses/:id/join-requests/:reqId/reject", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), membershipHandler.RejectJoinRequest)
			protected.POST("/businesses/:id/invitations", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), membershipHandler.SendInvitation)
			protected.GET("/businesses/:id/invitations", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), membershipHandler.ListInvitations)
			protected.GET("/businesses/:id/members", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), membershipHandler.GetMembers)
			protected.PATCH("/businesses/:id/members/:userId", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), membershipHandler.UpdateMemberRole)
			protected.DELETE("/businesses/:id/members/:userId", authMiddleware.RequireRole(rbac.RoleOwner), membershipHandler.RemoveMember)

			// Branch routes (nested under /businesses/:id/branches for create/list)
			protected.POST("/businesses/:id/branches", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), branchHandler.CreateBranch)
			protected.GET("/businesses/:id/branches", branchHandler.ListBranches)

			// Branch routes (standalone, scoped via JWT business_id)
			branches := protected.Group("/branches")
			{
				branches.GET("/:id", branchHandler.GetBranch)
				branches.PUT("/:id", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), branchHandler.UpdateBranch)
				branches.DELETE("/:id", authMiddleware.RequireRole(rbac.RoleOwner), branchHandler.DeleteBranch)
				branches.GET("/:id/users", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), branchHandler.ListAccess)
				branches.POST("/:id/users", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), branchHandler.GrantAccess)
				branches.DELETE("/:id/users/:userId", authMiddleware.RequireRole(rbac.RoleOwner), branchHandler.RevokeAccess)

				// Branch inventory routes
				branches.GET("/:id/products", branchInventoryHandler.List)
				branches.POST("/:id/products/:productId", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), branchInventoryHandler.Activate)
				branches.PUT("/:id/products/:productId", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), branchInventoryHandler.Update)
				branches.DELETE("/:id/products/:productId", authMiddleware.RequireRole(rbac.RoleAdmin, rbac.RoleOwner), branchInventoryHandler.Deactivate)
			}
		}
	}

	return router
}
