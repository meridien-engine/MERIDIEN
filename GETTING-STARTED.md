# MERIDIEN - Getting Started Guide

**Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine**  
*Navigate Your Business to Success*

---

## 🎯 Quick Start (5 Minutes)

### Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Go 1.21+** installed
- [ ] **PostgreSQL 15+** installed and running
- [ ] **Git** installed
- [ ] **Make** installed (optional but recommended)
- [ ] Terminal/Command line access

---

## 📦 Step 1: Install Prerequisites

### Install Go 1.21+

**Ubuntu/Debian:**
```bash
# Download Go
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz

# Remove old version (if exists)
sudo rm -rf /usr/local/go

# Extract to /usr/local
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# Add to PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc

# Verify
go version
```

**macOS:**
```bash
brew install go@1.21
go version
```

### Install PostgreSQL 15+

**Ubuntu/Debian:**
```bash
# Install PostgreSQL
sudo apt update
sudo apt install -y postgresql-15 postgresql-contrib-15

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verify
sudo -u postgres psql --version
```

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
psql --version
```

### Install Make (Optional)

**Ubuntu/Debian:**
```bash
sudo apt install -y build-essential
```

**macOS:**
```bash
# Usually pre-installed
# If not:
xcode-select --install
```

---

## 🚀 Step 2: Clone and Setup

### Clone the Repository

```bash
# Using SSH (recommended)
git clone git@github.com:mu7ammad-3li/MERIDIEN.git
cd MERIDIEN

# Or using HTTPS
git clone https://github.com/mu7ammad-3li/MERIDIEN.git
cd MERIDIEN
```

### Run Automated Setup

```bash
# Run the backend setup script
./scripts/setup-backend.sh
```

This script will:
- ✅ Check if Go is installed
- ✅ Initialize Go module
- ✅ Install all dependencies
- ✅ Install development tools (Air, GolangCI-Lint, Swag)
- ✅ Create configuration files

---

## 🗄️ Step 3: Setup Database

### Create PostgreSQL Database

```bash
# Create database
sudo -u postgres psql -c "CREATE DATABASE meridien_dev;"

# Create user (optional)
sudo -u postgres psql -c "CREATE USER meridien WITH PASSWORD 'meridien';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE meridien_dev TO meridien;"

# Enable UUID extension
sudo -u postgres psql -d meridien_dev -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
```

### Configure Database Connection

Edit `backend/configs/.env`:

```bash
cd backend
nano configs/.env  # or use your preferred editor
```

Update these values:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres       # or 'meridien' if you created a user
DB_PASSWORD=postgres   # or your password
DB_NAME=meridien_dev
```

---

## 🏗️ Step 4: Initialize Backend

### Navigate to Backend

```bash
cd backend
```

### Verify Go Module

```bash
# Should see go.mod file
ls -la go.mod

# Should show: github.com/mu7ammad-3li/MERIDIEN/backend
```

### Create Database Migrations

We'll create the first migration for users and tenants:

```bash
# Create migration
migrate create -ext sql -dir migrations -seq init_schema
```

This creates two files:
- `migrations/000001_init_schema.up.sql`
- `migrations/000001_init_schema.down.sql`

### Run Migrations

```bash
# Run migrations
make migrate-up

# Or manually:
migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/meridien_dev?sslmode=disable" up
```

---

## 🎨 Step 5: Create Basic Server

### Create Main Entry Point

The setup script should have created the basic structure. Let's verify:

```bash
# Check if main.go exists
ls -la cmd/server/main.go
```

### Run the Server

```bash
# Option 1: Using Make (with hot reload)
make dev

# Option 2: Direct run
go run cmd/server/main.go

# Option 3: Build and run
make build
./bin/meridien-server
```

You should see:
```
╔══════════════════════════════════════════════════════════════╗
║  🧭 MERIDIEN
║  📦 Environment: development  
║  🌐 Server: http://localhost:8080
║  💚 Health: http://localhost:8080/health
║  🎯 API: http://localhost:8080/api/v1
╚══════════════════════════════════════════════════════════════╝
```

---

## ✅ Step 6: Verify Installation

### Test Health Endpoint

```bash
# Test health check
curl http://localhost:8080/health

# Expected response:
# {"status":"ok","message":"MERIDIEN API is running","env":"development"}
```

### Test Database Connection

The server should log:
```
✅ Database connection established
```

If you see this, everything is working!

---

## 📚 Step 7: Start Building

Now you're ready to build the MVP! Follow this order:

### Week 1: Authentication (Days 1-7)

**Day 1-2: User Model & Repository**
- [ ] Create user model (`internal/models/user.go`)
- [ ] Create user repository (`internal/repositories/user_repository.go`)
- [ ] Write tests

**Day 3-4: Authentication Service**
- [ ] Create auth service (`internal/services/auth_service.go`)
- [ ] Implement registration
- [ ] Implement login (JWT)
- [ ] Write tests

**Day 5-6: Authentication Handlers**
- [ ] Create auth handler (`internal/handlers/auth_handler.go`)
- [ ] Create auth middleware (`internal/middleware/auth.go`)
- [ ] Wire up routes

**Day 7: Testing & Documentation**
- [ ] Integration tests
- [ ] API documentation (Swagger)
- [ ] Test all endpoints

### Week 2: Customers (Days 8-14)

**Day 8-9: Customer Model & Repository**
- [ ] Create customer model
- [ ] Create customer repository
- [ ] Write tests

**Day 10-11: Customer Service**
- [ ] Create customer service
- [ ] Implement CRUD operations
- [ ] Write tests

**Day 12-13: Customer Handlers**
- [ ] Create customer handlers
- [ ] Wire up routes
- [ ] Add validation

**Day 14: Testing**
- [ ] Integration tests
- [ ] API documentation

---

## 🛠️ Development Workflow

### Daily Workflow

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/auth-register
   ```

3. **Make changes** (following DEVELOPMENT-RULES.md)

4. **Test changes**
   ```bash
   make test
   ```

5. **Commit changes**
   ```bash
   git add .
   git commit -m "feat(backend): implement user registration"
   ```

6. **Push and create PR**
   ```bash
   git push origin feature/auth-register
   ```

### Useful Commands

```bash
# Run server with hot reload
make dev

# Run tests
make test

# Run linter
make lint

# Format code
make fmt

# Run migrations
make migrate-up

# Rollback migration
make migrate-down

# Generate Swagger docs
make swagger

# Build for production
make build

# Clean build files
make clean
```

---

## 📖 Documentation Reference

### Key Documents

1. **`docs/mvp-analysis.md`** - Your MVP roadmap (read this first!)
2. **`docs/DEVELOPMENT-RULES.md`** - Coding standards (follow this always!)
3. **`docs/plan-three.md`** - Technical architecture
4. **`docs/MERIDIEN-BRAND.md`** - Brand guidelines
5. **`docs/guides/BACKEND-SETUP.md`** - Detailed backend setup

### Code Examples

All code should follow the patterns in `docs/DEVELOPMENT-RULES.md`:
- Go naming conventions
- Clean architecture (models → repositories → services → handlers)
- Error handling patterns
- Logging standards
- Testing patterns

---

## 🐛 Troubleshooting

### Go not found

```bash
# Ensure Go is in PATH
echo $PATH

# Should include /usr/local/go/bin
# If not, add to ~/.bashrc:
export PATH=$PATH:/usr/local/go/bin
source ~/.bashrc
```

### PostgreSQL connection failed

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start if not running
sudo systemctl start postgresql

# Test connection
psql -h localhost -U postgres -d meridien_dev
```

### Port 8080 already in use

```bash
# Find process using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>

# Or change port in configs/.env
APP_PORT=8081
```

### Migration failed

```bash
# Check migration status
migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/meridien_dev?sslmode=disable" version

# Force version if dirty
migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/meridien_dev?sslmode=disable" force 1
```

---

## 🎯 Success Criteria

You know setup is successful when:

- [x] Server starts without errors
- [x] Health endpoint returns 200 OK
- [x] Database connection is established
- [x] You can access http://localhost:8080/health
- [x] You can create and run migrations
- [x] Hot reload works (file changes trigger server restart)

---

## 🚀 Next Steps

1. **Read the MVP Roadmap**: `docs/mvp-analysis.md`
2. **Review Development Rules**: `docs/DEVELOPMENT-RULES.md`
3. **Start Week 1**: Authentication module
4. **Join the journey**: Build MERIDIEN component by component!

---

## 📞 Need Help?

- **Documentation**: Check `docs/` folder
- **Code Examples**: See `docs/DEVELOPMENT-RULES.md`
- **Architecture**: Read `docs/plan-three.md`
- **Issues**: Create GitHub issue

---

**MERIDIEN** - Navigate Your Business to Success  
*Let's build something amazing! 🎉*

---

**Last Updated**: 2024-12-23  
**Version**: 0.1.0 (MVP Setup)
