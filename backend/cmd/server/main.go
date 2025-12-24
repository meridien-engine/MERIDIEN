package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

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

	// Initialize repositories
	userRepo := repositories.NewUserRepository(database.DB)
	tenantRepo := repositories.NewTenantRepository(database.DB)
	customerRepo := repositories.NewCustomerRepository(database.DB)
	productRepo := repositories.NewProductRepository(database.DB)
	categoryRepo := repositories.NewCategoryRepository(database.DB)
	orderRepo := repositories.NewOrderRepository(database.DB)
	paymentRepo := repositories.NewPaymentRepository(database.DB)

	// Initialize JWT manager
	jwtManager := utils.NewJWTManager(cfg.JWT.Secret, cfg.JWT.ExpirationHours)

	// Initialize services
	authService := services.NewAuthService(userRepo, tenantRepo, jwtManager)
	customerService := services.NewCustomerService(customerRepo)
	productService := services.NewProductService(productRepo, categoryRepo)
	orderService := services.NewOrderService(orderRepo, customerRepo, productRepo, paymentRepo)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	customerHandler := handlers.NewCustomerHandler(customerService)
	productHandler := handlers.NewProductHandler(productService)
	orderHandler := handlers.NewOrderHandler(orderService)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(jwtManager)

	// Setup router
	r := router.Setup(cfg.App.Debug, authHandler, customerHandler, productHandler, orderHandler, authMiddleware)

	// Start server in goroutine
	go func() {
		addr := fmt.Sprintf(":%s", cfg.App.Port)
		log.Printf("🌐 Server listening on http://localhost%s", addr)
		log.Printf("📊 Health check: http://localhost%s/health", addr)
		log.Printf("🔌 API endpoint: http://localhost%s/api/v1/ping", addr)
		log.Printf("🔐 Auth endpoints:")
		log.Printf("   POST http://localhost%s/api/v1/auth/register", addr)
		log.Printf("   POST http://localhost%s/api/v1/auth/login", addr)
		log.Printf("   GET  http://localhost%s/api/v1/auth/me (protected)", addr)
		log.Printf("👥 Customer endpoints:")
		log.Printf("   GET    http://localhost%s/api/v1/customers (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/customers (protected)", addr)
		log.Printf("   GET    http://localhost%s/api/v1/customers/:id (protected)", addr)
		log.Printf("   PUT    http://localhost%s/api/v1/customers/:id (protected)", addr)
		log.Printf("   DELETE http://localhost%s/api/v1/customers/:id (protected)", addr)
		log.Printf("📦 Product endpoints:")
		log.Printf("   GET    http://localhost%s/api/v1/products (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/products (protected)", addr)
		log.Printf("   GET    http://localhost%s/api/v1/products/:id (protected)", addr)
		log.Printf("   PUT    http://localhost%s/api/v1/products/:id (protected)", addr)
		log.Printf("   DELETE http://localhost%s/api/v1/products/:id (protected)", addr)
		log.Printf("🛒 Order endpoints:")
		log.Printf("   GET    http://localhost%s/api/v1/orders (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/orders (protected)", addr)
		log.Printf("   GET    http://localhost%s/api/v1/orders/:id (protected)", addr)
		log.Printf("   PUT    http://localhost%s/api/v1/orders/:id (protected)", addr)
		log.Printf("   DELETE http://localhost%s/api/v1/orders/:id (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/orders/:id/confirm (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/orders/:id/ship (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/orders/:id/deliver (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/orders/:id/cancel (protected)", addr)
		log.Printf("   POST   http://localhost%s/api/v1/orders/:id/payments (protected)", addr)
		log.Printf("   GET    http://localhost%s/api/v1/orders/:id/payments (protected)", addr)

		if err := r.Run(addr); err != nil {
			log.Fatalf("❌ Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down server...")
	log.Println("✅ Server stopped")
}
