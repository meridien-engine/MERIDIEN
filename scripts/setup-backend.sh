#!/bin/bash

# MERIDIEN Backend Setup Script
# This script sets up the Go backend development environment

set -e  # Exit on error

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                   🧭 MERIDIEN Backend Setup                              ║"
echo "║              Navigate Your Business to Success                           ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed!"
    echo ""
    echo "Please install Go 1.21+ first:"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz"
    echo "  sudo rm -rf /usr/local/go"
    echo "  sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz"
    echo "  echo 'export PATH=\$PATH:/usr/local/go/bin' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    echo ""
    echo "macOS:"
    echo "  brew install go@1.21"
    echo ""
    exit 1
fi

echo "✅ Go $(go version | awk '{print $3}') found"
echo ""

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL is not installed!"
    echo ""
    echo "Please install PostgreSQL 15+ first:"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt install -y postgresql-15 postgresql-contrib-15"
    echo "  sudo systemctl start postgresql"
    echo ""
    echo "macOS:"
    echo "  brew install postgresql@15"
    echo "  brew services start postgresql@15"
    echo ""
    echo "Continuing without PostgreSQL check..."
    echo ""
else
    echo "✅ PostgreSQL found"
    echo ""
fi

# Navigate to backend directory
cd "$(dirname "$0")/../backend"

echo "📦 Initializing Go module..."
if [ ! -f "go.mod" ]; then
    go mod init github.com/mu7ammad-3li/MERIDIEN/backend
    echo "✅ Go module initialized"
else
    echo "✅ Go module already exists"
fi
echo ""

echo "📚 Installing dependencies..."
echo ""

# Core dependencies
echo "→ Installing Gin web framework..."
go get -u github.com/gin-gonic/gin

echo "→ Installing GORM..."
go get -u gorm.io/gorm
go get -u gorm.io/driver/postgres

echo "→ Installing JWT library..."
go get -u github.com/golang-jwt/jwt/v5

echo "→ Installing configuration management..."
go get -u github.com/spf13/viper

echo "→ Installing logging..."
go get -u github.com/sirupsen/logrus

echo "→ Installing validation..."
go get -u github.com/go-playground/validator/v10

echo "→ Installing password hashing..."
go get -u golang.org/x/crypto/bcrypt

echo "→ Installing environment variables..."
go get -u github.com/joho/godotenv

echo "→ Installing CORS middleware..."
go get -u github.com/gin-contrib/cors

echo "→ Installing database migrations..."
go get -u github.com/golang-migrate/migrate/v4
go get -u github.com/golang-migrate/migrate/v4/database/postgres
go get -u github.com/golang-migrate/migrate/v4/source/file

echo "→ Installing UUID support..."
go get -u github.com/google/uuid

echo "→ Installing decimal support..."
go get -u github.com/shopspring/decimal

echo ""
echo "✅ All dependencies installed!"
echo ""

echo "🛠️  Installing development tools..."
echo ""

# Install development tools
echo "→ Installing Air (live reload)..."
go install github.com/cosmtrek/air@latest

echo "→ Installing GolangCI-Lint..."
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2

echo "→ Installing Swag (API documentation)..."
go install github.com/swaggo/swag/cmd/swag@latest

echo ""
echo "✅ Development tools installed!"
echo ""

echo "📝 Creating configuration files..."
echo ""

# Create .env.example if it doesn't exist
if [ ! -f "configs/.env.example" ]; then
    mkdir -p configs
    cat > configs/.env.example << 'EOF'
# MERIDIEN Backend Configuration

# Server
APP_NAME=MERIDIEN
APP_ENV=development
APP_PORT=8080
APP_DEBUG=true

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=meridien_dev
DB_SSLMODE=disable

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION_HOURS=24
JWT_REFRESH_EXPIRATION_HOURS=168

# Redis (Optional for MVP)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Rate Limiting
RATE_LIMIT_REQUESTS_PER_MINUTE=100

# Logging
LOG_LEVEL=debug
LOG_FORMAT=json
EOF
    echo "✅ Created configs/.env.example"
fi

# Copy to .env if it doesn't exist
if [ ! -f "configs/.env" ]; then
    cp configs/.env.example configs/.env
    echo "✅ Created configs/.env (please update with your settings)"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ Backend Setup Complete!                            ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Update database credentials in: backend/configs/.env"
echo ""
echo "2. Create PostgreSQL database:"
echo "   sudo -u postgres psql -c \"CREATE DATABASE meridien_dev;\""
echo ""
echo "3. Run the backend:"
echo "   cd backend"
echo "   make dev"
echo ""
echo "4. Start building! Follow the MVP roadmap in docs/mvp-analysis.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
