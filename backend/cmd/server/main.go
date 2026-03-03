package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/cache"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/config"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/database"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/handlers"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/router"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("❌ Failed to load configuration: %v", err)
	}

	log.Printf("🚀 Starting %s [%s]", cfg.App.Name, cfg.App.Environment)

	// Connect to database
	if err := database.Connect(&cfg.Database, cfg.App.Debug); err != nil {
		log.Fatalf("❌ Failed to connect to database: %v", err)
	}
	defer func() {
		if err := database.Close(); err != nil {
			log.Printf("⚠️  Error closing database: %v", err)
		}
	}()

	// Connect to Redis (optional — app runs without it)
	if err := cache.Connect(&cfg.Redis); err != nil {
		log.Printf("⚠️  Redis unavailable, running without token blacklist and rate limiting: %v", err)
	} else {
		log.Printf("✅ Redis connected at %s:%s", cfg.Redis.Host, cfg.Redis.Port)
		defer cache.Close()
	}

	// Initialize repositories
	userRepo := repositories.NewUserRepository(database.DB)
	businessRepo := repositories.NewBusinessRepository(database.DB)
	branchRepo := repositories.NewBranchRepository(database.DB)
	customerRepo := repositories.NewCustomerRepository(database.DB)
	productRepo := repositories.NewProductRepository(database.DB)
	categoryRepo := repositories.NewCategoryRepository(database.DB)
	orderRepo := repositories.NewOrderRepository(database.DB)
	paymentRepo := repositories.NewPaymentRepository(database.DB)
	courierRepo := repositories.NewCourierRepository(database.DB)
	locationRepo := repositories.NewLocationRepository(database.DB)
	posSessionRepo := repositories.NewPOSSessionRepository(database.DB)
	storeRepo := repositories.NewStoreRepository(database.DB)
	joinReqRepo := repositories.NewJoinRequestRepository(database.DB)
	invitationRepo := repositories.NewInvitationRepository(database.DB)

	// Initialize JWT manager
	jwtManager := utils.NewJWTManager(cfg.JWT.Secret, cfg.JWT.ExpirationHours)

	// Initialize Redis-backed helpers (nil-safe when Redis is unavailable)
	var tokenBlacklist *cache.TokenBlacklist
	var authRateLimiter *middleware.RateLimiter
	if cache.Client != nil {
		tokenBlacklist = cache.NewTokenBlacklist(cache.Client)
		authRateLimiter = middleware.NewRateLimiter(cache.Client, 10, time.Minute)
	}

	// Initialize services
	authService := services.NewAuthService(userRepo, businessRepo, jwtManager, tokenBlacklist)
	businessService := services.NewBusinessService(businessRepo, branchRepo)
	branchService := services.NewBranchService(branchRepo)
	membershipService := services.NewMembershipService(joinReqRepo, invitationRepo, businessRepo, userRepo)
	customerService := services.NewCustomerService(customerRepo)
	productService := services.NewProductService(productRepo, categoryRepo)
	orderService := services.NewOrderService(orderRepo, customerRepo, productRepo, paymentRepo)
	reportService := services.NewReportService(courierRepo)
	locationService := services.NewLocationService(locationRepo)
	posService := services.NewPOSService(posSessionRepo, orderRepo, productRepo, paymentRepo, orderService)
	storeService := services.NewStoreService(storeRepo)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	businessHandler := handlers.NewBusinessHandler(businessService)
	membershipHandler := handlers.NewMembershipHandler(membershipService)
	customerHandler := handlers.NewCustomerHandler(customerService)
	productHandler := handlers.NewProductHandler(productService)
	orderHandler := handlers.NewOrderHandler(orderService)
	reportHandler := handlers.NewReportHandler(reportService)
	locationHandler := handlers.NewLocationHandler(locationService)
	posHandler := handlers.NewPOSHandler(posService)
	storeHandler := handlers.NewStoreHandler(storeService)
	branchHandler := handlers.NewBranchHandler(branchService)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(jwtManager, tokenBlacklist)

	// Setup router
	r := router.Setup(
		cfg.App.Debug,
		authHandler,
		customerHandler,
		productHandler,
		orderHandler,
		reportHandler,
		locationHandler,
		posHandler,
		businessHandler,
		storeHandler,
		membershipHandler,
		branchHandler,
		authMiddleware,
		authRateLimiter,
	)

	// Start server
	go func() {
		addr := fmt.Sprintf(":%s", cfg.App.Port)
		log.Printf("🌐 Server listening on http://localhost%s", addr)
		log.Printf("📊 Health check: http://localhost%s/health", addr)
		log.Printf("🔐 Auth: POST /api/v1/auth/register | POST /api/v1/auth/login")
		log.Printf("🏢 Businesses: GET /api/v1/auth/businesses | POST /api/v1/auth/use-business/:id")
		log.Printf("📦 Business categories: GET /api/v1/business-categories")

		if err := r.Run(addr); err != nil {
			log.Fatalf("❌ Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down server...")
	log.Println("✅ Server stopped")
}
