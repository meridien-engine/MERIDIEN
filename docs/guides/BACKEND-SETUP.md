# Backend Setup Guide - Go + Gin + PostgreSQL

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [Project Initialization](#project-initialization)
4. [Database Setup](#database-setup)
5. [Environment Configuration](#environment-configuration)
6. [Running the Server](#running-the-server)
7. [Verification](#verification)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements
- **OS:** Linux (Ubuntu 20.04+), macOS, or Windows with WSL2
- **RAM:** Minimum 4GB (8GB recommended)
- **Disk:** 2GB free space

### Required Software

#### 1. Go (Version 1.21+)

**Ubuntu/Debian:**
```bash
# Remove old Go version (if exists)
sudo rm -rf /usr/local/go

# Download Go 1.21.5
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz

# Extract to /usr/local
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc

# Reload shell configuration
source ~/.bashrc

# Verify installation
go version
# Should output: go version go1.21.5 linux/amd64
```

**macOS:**
```bash
# Using Homebrew
brew install go@1.21

# Verify installation
go version
```

**Windows (WSL2):**
```bash
# Same as Ubuntu/Debian instructions above
```

#### 2. PostgreSQL (Version 15+)

**Ubuntu/Debian:**
```bash
# Add PostgreSQL repository
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import repository signing key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update package list
sudo apt update

# Install PostgreSQL 15
sudo apt install -y postgresql-15 postgresql-contrib-15

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verify installation
sudo -u postgres psql --version
# Should output: psql (PostgreSQL) 15.x
```

**macOS:**
```bash
# Using Homebrew
brew install postgresql@15

# Start PostgreSQL service
brew services start postgresql@15

# Verify installation
psql --version
```

**Windows (WSL2):**
```bash
# Same as Ubuntu/Debian instructions
# Note: Use sudo service postgresql start instead of systemctl
sudo service postgresql start
```

#### 3. Git

**Ubuntu/Debian:**
```bash
sudo apt install -y git

# Verify
git --version
```

**macOS:**
```bash
brew install git

# Verify
git --version
```

#### 4. Make (Optional but recommended)

**Ubuntu/Debian:**
```bash
sudo apt install -y build-essential

# Verify
make --version
```

**macOS:**
```bash
# Usually pre-installed
# If not:
xcode-select --install

# Verify
make --version
```

#### 5. Redis (Optional - for MVP, required for Production)

**Ubuntu/Debian:**
```bash
sudo apt install -y redis-server

# Start Redis
sudo systemctl start redis
sudo systemctl enable redis

# Verify
redis-cli ping
# Should output: PONG
```

**macOS:**
```bash
brew install redis

# Start Redis
brew services start redis

# Verify
redis-cli ping
```

---

## Installation Steps

### Step 1: Create Project Directory

```bash
# Navigate to your workspace
cd ~/Work/Identity/BM

# Create backend directory
mkdir -p backend
cd backend
```

### Step 2: Initialize Go Module

```bash
# Initialize Go module
go mod init business-management-backend

# This creates go.mod file
```

### Step 3: Install Core Dependencies

```bash
# Install Gin web framework
go get -u github.com/gin-gonic/gin

# Install GORM (ORM)
go get -u gorm.io/gorm
go get -u gorm.io/driver/postgres

# Install JWT library
go get -u github.com/golang-jwt/jwt/v5

# Install configuration management
go get -u github.com/spf13/viper

# Install logging
go get -u github.com/sirupsen/logrus

# Install validation
go get -u github.com/go-playground/validator/v10

# Install password hashing
go get -u golang.org/x/crypto/bcrypt

# Install environment variables
go get -u github.com/joho/godotenv

# Install CORS middleware
go get -u github.com/gin-contrib/cors

# Install database migrations
go get -u github.com/golang-migrate/migrate/v4
go get -u github.com/golang-migrate/migrate/v4/database/postgres
go get -u github.com/golang-migrate/migrate/v4/source/file

# Install UUID support
go get -u github.com/google/uuid

# Install decimal support (for money)
go get -u github.com/shopspring/decimal
```

### Step 4: Install Development Dependencies

```bash
# Install air (live reload for development)
go install github.com/cosmtrek/air@latest

# Install golangci-lint (linting)
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2

# Install swagger (API documentation)
go install github.com/swaggo/swag/cmd/swag@latest

# Verify installations
air -v
golangci-lint --version
swag --version
```

### Step 5: Create Project Structure

```bash
# Create directory structure
mkdir -p cmd/server
mkdir -p cmd/migrate
mkdir -p internal/config
mkdir -p internal/database
mkdir -p internal/models
mkdir -p internal/dto
mkdir -p internal/repositories
mkdir -p internal/services
mkdir -p internal/handlers
mkdir -p internal/middleware
mkdir -p internal/utils
mkdir -p internal/router
mkdir -p migrations
mkdir -p configs
mkdir -p scripts
mkdir -p docs
mkdir -p tests/unit
mkdir -p tests/integration

# Verify structure
tree -L 2
```

Expected output:
```
.
├── cmd
│   ├── migrate
│   └── server
├── configs
├── docs
├── go.mod
├── internal
│   ├── config
│   ├── database
│   ├── dto
│   ├── handlers
│   ├── middleware
│   ├── models
│   ├── repositories
│   ├── router
│   ├── services
│   └── utils
├── migrations
├── scripts
└── tests
    ├── integration
    └── unit
```

---

## Project Initialization

### Step 6: Create Configuration Files

#### Create `.gitignore`
```bash
cat > .gitignore << 'EOF'
# Binaries
*.exe
*.exe~
*.dll
*.so
*.dylib
bin/
dist/

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool
*.out

# Go workspace file
go.work

# Environment files
.env
.env.local
.env.*.local
configs/.env

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Database
*.db
*.sqlite

# Air (live reload)
tmp/

# Swagger docs (generated)
docs/swagger/

EOF
```

#### Create `.env.example`
```bash
cat > configs/.env.example << 'EOF'
# Server Configuration
APP_NAME=Business Management System
APP_ENV=development
APP_PORT=8080
APP_DEBUG=true

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=business_mgmt_dev
DB_SSLMODE=disable
DB_MAX_CONNECTIONS=100
DB_MAX_IDLE_CONNECTIONS=10
DB_CONNECTION_MAX_LIFETIME=3600

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION_HOURS=24
JWT_REFRESH_EXPIRATION_HOURS=168

# Redis Configuration (Optional for MVP)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# CORS Configuration
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization

# Rate Limiting
RATE_LIMIT_REQUESTS_PER_MINUTE=100
RATE_LIMIT_BURST=200

# File Upload
MAX_UPLOAD_SIZE=10485760
UPLOAD_PATH=./uploads

# Logging
LOG_LEVEL=debug
LOG_FORMAT=json

EOF
```

#### Create actual `.env` file
```bash
# Copy example to actual .env
cp configs/.env.example configs/.env

# Edit .env with your actual values
nano configs/.env
# Or use your preferred editor (vim, code, etc.)
```

#### Create `Makefile`
```bash
cat > Makefile << 'EOF'
.PHONY: help build run dev test clean migrate-up migrate-down migrate-create

# Variables
BINARY_NAME=business-management-server
MIGRATE=migrate

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	go mod download
	go mod verify

build: ## Build the application
	@echo "Building..."
	go build -o bin/$(BINARY_NAME) cmd/server/main.go

run: build ## Build and run the application
	@echo "Running..."
	./bin/$(BINARY_NAME)

dev: ## Run with hot reload (requires air)
	@echo "Running in development mode with hot reload..."
	air

test: ## Run tests
	@echo "Running tests..."
	go test -v ./tests/...

test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	go test -v -coverprofile=coverage.out ./tests/...
	go tool cover -html=coverage.out -o coverage.html

lint: ## Run linter
	@echo "Running linter..."
	golangci-lint run

fmt: ## Format code
	@echo "Formatting code..."
	go fmt ./...

clean: ## Clean build files
	@echo "Cleaning..."
	rm -rf bin/
	rm -rf tmp/
	rm -f coverage.out coverage.html

migrate-up: ## Run database migrations
	@echo "Running migrations..."
	$(MIGRATE) -path migrations -database "postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" up

migrate-down: ## Rollback last migration
	@echo "Rolling back migration..."
	$(MIGRATE) -path migrations -database "postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" down 1

migrate-create: ## Create new migration (usage: make migrate-create NAME=create_users_table)
	@echo "Creating migration: $(NAME)"
	$(MIGRATE) create -ext sql -dir migrations -seq $(NAME)

swagger: ## Generate Swagger documentation
	@echo "Generating Swagger docs..."
	swag init -g cmd/server/main.go -o docs/swagger

docker-up: ## Start Docker containers
	docker-compose up -d

docker-down: ## Stop Docker containers
	docker-compose down

docker-logs: ## View Docker logs
	docker-compose logs -f

.DEFAULT_GOAL := help

EOF
```

#### Create `air.toml` (for hot reload)
```bash
cat > .air.toml << 'EOF'
root = "."
testdata_dir = "testdata"
tmp_dir = "tmp"

[build]
  args_bin = []
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ./cmd/server/main.go"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "testdata", "tests"]
  exclude_file = []
  exclude_regex = ["_test.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "tpl", "tmpl", "html"]
  include_file = []
  kill_delay = "0s"
  log = "build-errors.log"
  poll = false
  poll_interval = 0
  rerun = false
  rerun_delay = 500
  send_interrupt = false
  stop_on_error = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  main_only = false
  time = false

[misc]
  clean_on_exit = false

[screen]
  clear_on_rebuild = false
  keep_scroll = true

EOF
```

---

## Database Setup

### Step 7: Create PostgreSQL Database

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL prompt, run:
```

```sql
-- Create database
CREATE DATABASE business_mgmt_dev;

-- Create user (optional, or use default postgres user)
CREATE USER bm_admin WITH PASSWORD 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE business_mgmt_dev TO bm_admin;

-- Connect to database
\c business_mgmt_dev

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Exit psql
\q
```

**Or use a one-liner:**
```bash
sudo -u postgres psql -c "CREATE DATABASE business_mgmt_dev;"
sudo -u postgres psql -c "CREATE USER bm_admin WITH PASSWORD 'secure_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE business_mgmt_dev TO bm_admin;"
sudo -u postgres psql -d business_mgmt_dev -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
```

### Step 8: Verify Database Connection

```bash
# Test connection
psql -h localhost -U postgres -d business_mgmt_dev -c "SELECT version();"

# You should see PostgreSQL version info
```

### Step 9: Create Initial Migration

```bash
# Create first migration
migrate create -ext sql -dir migrations -seq init_schema

# This creates:
# migrations/000001_init_schema.up.sql
# migrations/000001_init_schema.down.sql
```

#### Edit `migrations/000001_init_schema.up.sql`
```bash
cat > migrations/000001_init_schema.up.sql << 'EOF'
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tenants table
CREATE TABLE IF NOT EXISTS tenants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id)
);

-- Create indexes
CREATE INDEX idx_tenants_subdomain ON tenants(subdomain);
CREATE INDEX idx_tenants_deleted_at ON tenants(deleted_at);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);

EOF
```

#### Edit `migrations/000001_init_schema.down.sql`
```bash
cat > migrations/000001_init_schema.down.sql << 'EOF'
-- Drop indexes
DROP INDEX IF EXISTS idx_users_deleted_at;
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_tenant_id;
DROP INDEX IF EXISTS idx_tenants_deleted_at;
DROP INDEX IF EXISTS idx_tenants_subdomain;

-- Drop tables
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tenants;

EOF
```

---

## Environment Configuration

### Step 10: Create Core Files

#### Create `cmd/server/main.go`
```bash
cat > cmd/server/main.go << 'EOF'
package main

import (
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// Set Gin mode
	gin.SetMode(gin.DebugMode)

	// Create Gin router
	r := gin.Default()

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "Business Management System API is running",
		})
	})

	// API v1 group
	v1 := r.Group("/api/v1")
	{
		v1.GET("/ping", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "pong",
			})
		})
	}

	// Start server
	port := "8080"
	fmt.Printf("🚀 Server starting on http://localhost:%s\n", port)
	fmt.Printf("📚 Health check: http://localhost:%s/health\n", port)
	fmt.Printf("🎯 API endpoint: http://localhost:%s/api/v1/ping\n", port)

	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

EOF
```

#### Create `internal/config/config.go`
```bash
mkdir -p internal/config
cat > internal/config/config.go << 'EOF'
package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	// Server
	AppName  string
	AppEnv   string
	AppPort  string
	AppDebug bool

	// Database
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string

	// JWT
	JWTSecret            string
	JWTExpirationHours   int
	JWTRefreshExpiration int

	// Redis
	RedisHost     string
	RedisPort     string
	RedisPassword string
	RedisDB       int
}

var AppConfig *Config

// Load loads configuration from environment variables
func Load() {
	// Load .env file
	if err := godotenv.Load("configs/.env"); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	AppConfig = &Config{
		AppName:  getEnv("APP_NAME", "Business Management System"),
		AppEnv:   getEnv("APP_ENV", "development"),
		AppPort:  getEnv("APP_PORT", "8080"),
		AppDebug: getEnvBool("APP_DEBUG", true),

		DBHost:     getEnv("DB_HOST", "localhost"),
		DBPort:     getEnv("DB_PORT", "5432"),
		DBUser:     getEnv("DB_USER", "postgres"),
		DBPassword: getEnv("DB_PASSWORD", "postgres"),
		DBName:     getEnv("DB_NAME", "business_mgmt_dev"),
		DBSSLMode:  getEnv("DB_SSLMODE", "disable"),

		JWTSecret:            getEnv("JWT_SECRET", "your-secret-key-change-this"),
		JWTExpirationHours:   getEnvInt("JWT_EXPIRATION_HOURS", 24),
		JWTRefreshExpiration: getEnvInt("JWT_REFRESH_EXPIRATION_HOURS", 168),

		RedisHost:     getEnv("REDIS_HOST", "localhost"),
		RedisPort:     getEnv("REDIS_PORT", "6379"),
		RedisPassword: getEnv("REDIS_PASSWORD", ""),
		RedisDB:       getEnvInt("REDIS_DB", 0),
	}
}

// Helper functions
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

func getEnvBool(key string, defaultValue bool) bool {
	if value := os.Getenv(key); value != "" {
		if boolValue, err := strconv.ParseBool(value); err == nil {
			return boolValue
		}
	}
	return defaultValue
}

EOF
```

#### Create `internal/database/database.go`
```bash
mkdir -p internal/database
cat > internal/database/database.go << 'EOF'
package database

import (
	"fmt"
	"log"
	"time"

	"business-management-backend/internal/config"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// Connect establishes database connection
func Connect() error {
	cfg := config.AppConfig

	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.DBHost,
		cfg.DBPort,
		cfg.DBUser,
		cfg.DBPassword,
		cfg.DBName,
		cfg.DBSSLMode,
	)

	// Configure GORM logger
	gormConfig := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
		NowFunc: func() time.Time {
			return time.Now().UTC()
		},
	}

	if !cfg.AppDebug {
		gormConfig.Logger = logger.Default.LogMode(logger.Silent)
	}

	// Connect to database
	db, err := gorm.Open(postgres.Open(dsn), gormConfig)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	// Get underlying SQL DB
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("failed to get database instance: %w", err)
	}

	// Set connection pool settings
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetConnMaxLifetime(time.Hour)

	// Test connection
	if err := sqlDB.Ping(); err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	DB = db
	log.Println("✅ Database connection established")
	return nil
}

// Close closes database connection
func Close() error {
	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}

EOF
```

#### Update `cmd/server/main.go` to use config and database
```bash
cat > cmd/server/main.go << 'EOF'
package main

import (
	"fmt"
	"log"

	"business-management-backend/internal/config"
	"business-management-backend/internal/database"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration
	config.Load()
	cfg := config.AppConfig

	// Set Gin mode
	if cfg.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	} else {
		gin.SetMode(gin.DebugMode)
	}

	// Connect to database
	if err := database.Connect(); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer database.Close()

	// Create Gin router
	r := gin.Default()

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "Business Management System API is running",
			"env":     cfg.AppEnv,
		})
	})

	// API v1 group
	v1 := r.Group("/api/v1")
	{
		v1.GET("/ping", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "pong",
			})
		})
	}

	// Start server
	fmt.Printf("\n")
	fmt.Printf("╔══════════════════════════════════════════════════════════╗\n")
	fmt.Printf("║  🚀 %s\n", cfg.AppName)
	fmt.Printf("║  📦 Environment: %s\n", cfg.AppEnv)
	fmt.Printf("║  🌐 Server: http://localhost:%s\n", cfg.AppPort)
	fmt.Printf("║  💚 Health: http://localhost:%s/health\n", cfg.AppPort)
	fmt.Printf("║  🎯 API: http://localhost:%s/api/v1\n", cfg.AppPort)
	fmt.Printf("╚══════════════════════════════════════════════════════════╝\n")
	fmt.Printf("\n")

	if err := r.Run(":" + cfg.AppPort); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

EOF
```

---

## Running the Server

### Step 11: Run Database Migrations

```bash
# Make sure you're in the backend directory
cd ~/Work/Identity/BM/backend

# Load environment variables (for migration command)
source configs/.env

# Run migrations
make migrate-up

# Or run directly:
migrate -path migrations -database "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" up
```

Expected output:
```
Running migrations...
1/u init_schema (123.45ms)
```

### Step 12: Build and Run

```bash
# Option 1: Build and run manually
make build
make run

# Option 2: Build and run in one command
make run

# Option 3: Run with hot reload (recommended for development)
make dev
```

Expected output:
```
╔══════════════════════════════════════════════════════════╗
║  🚀 Business Management System
║  📦 Environment: development
║  🌐 Server: http://localhost:8080
║  💚 Health: http://localhost:8080/health
║  🎯 API: http://localhost:8080/api/v1
╚══════════════════════════════════════════════════════════╝

[GIN-debug] GET    /health                   --> main.main.func1 (3 handlers)
[GIN-debug] GET    /api/v1/ping              --> main.main.func2 (3 handlers)
[GIN-debug] Listening and serving HTTP on :8080
```

---

## Verification

### Step 13: Test Endpoints

```bash
# Test health endpoint
curl http://localhost:8080/health

# Expected output:
# {"env":"development","message":"Business Management System API is running","status":"ok"}

# Test API ping endpoint
curl http://localhost:8080/api/v1/ping

# Expected output:
# {"message":"pong"}
```

### Step 14: Verify Database Connection

```bash
# Check if tables were created
psql -h localhost -U postgres -d business_mgmt_dev -c "\dt"

# Expected output:
#              List of relations
#  Schema |   Name   | Type  |  Owner   
# --------+----------+-------+----------
#  public | tenants  | table | postgres
#  public | users    | table | postgres
```

---

## Troubleshooting

### Common Issues

#### 1. Port already in use
```bash
# Error: bind: address already in use

# Find process using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>

# Or change the port in configs/.env
APP_PORT=8081
```

#### 2. Database connection failed
```bash
# Error: failed to connect to database

# Check if PostgreSQL is running
sudo systemctl status postgresql
# or
sudo service postgresql status

# Start PostgreSQL if not running
sudo systemctl start postgresql
# or
sudo service postgresql start

# Verify credentials in configs/.env match database
psql -h localhost -U postgres -d business_mgmt_dev
```

#### 3. Migration failed
```bash
# Error: Dirty database version

# Force version to clean state
migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/business_mgmt_dev?sslmode=disable" force 1

# Then retry migration
make migrate-up
```

#### 4. Go module issues
```bash
# Error: cannot find package

# Clean Go cache
go clean -modcache

# Reinstall dependencies
go mod download
go mod tidy
```

#### 5. Permission denied (Linux)
```bash
# Error: permission denied when running binary

# Make binary executable
chmod +x bin/business-management-server

# Run again
./bin/business-management-server
```

---

## Next Steps

### ✅ Backend is now set up and running!

**What's next:**

1. **Add Authentication**
   - Create user registration endpoint
   - Create login endpoint
   - Implement JWT middleware

2. **Add Customer CRUD**
   - Create models
   - Create repositories
   - Create services
   - Create handlers

3. **Add Tests**
   - Write unit tests
   - Write integration tests

4. **Set up Swagger**
   - Generate API documentation
   - Access at http://localhost:8080/swagger/index.html

---

## Quick Reference Commands

```bash
# Development
make dev              # Run with hot reload
make test             # Run tests
make lint             # Run linter
make fmt              # Format code

# Database
make migrate-up       # Run migrations
make migrate-down     # Rollback last migration
make migrate-create NAME=create_customers_table  # Create new migration

# Build & Run
make build            # Build binary
make run              # Build and run
make clean            # Clean build files

# Documentation
make swagger          # Generate Swagger docs

# Help
make help             # Show all available commands
```

---

**Setup Complete! 🎉**

Your Go backend is now ready for development. The server is running at http://localhost:8080.

Refer to DEVELOPMENT-RULES.md for coding standards and best practices.
