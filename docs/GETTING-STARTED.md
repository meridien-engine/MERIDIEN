# Getting Started

Quick setup guide for MERIDIEN development environment.

## Prerequisites

- Go 1.21+
- PostgreSQL 15+
- Flutter 3.24+ (for frontend)
- Git

## Installation

### 1. Install Go

**Linux:**
```bash
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
go version
```

**macOS:**
```bash
brew install go@1.21
go version
```

### 2. Install PostgreSQL

**Linux:**
```bash
sudo apt update
sudo apt install -y postgresql-15 postgresql-contrib-15
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

### 3. Install Flutter (Optional)

**Linux/macOS:**
```bash
# Download from https://flutter.dev/docs/get-started/install
# Or use snap (Linux)
sudo snap install flutter --classic
flutter doctor
```

## Backend Setup

### Clone Repository

```bash
git clone https://github.com/mu7ammad-3li/MERIDIEN.git
cd MERIDIEN/backend
```

### Configure Database

```bash
# Create database
sudo -u postgres psql -c "CREATE DATABASE meridien_dev;"
sudo -u postgres psql -c "CREATE USER meridien WITH PASSWORD 'meridien';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE meridien_dev TO meridien;"
sudo -u postgres psql -d meridien_dev -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
```

### Configure Environment

Edit `backend/configs/.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=meridien_dev

JWT_SECRET=your-secret-key-here
JWT_EXPIRY=24h

APP_ENV=development
APP_PORT=8080
```

### Run Migrations

```bash
cd backend
./scripts/run-migrations.sh
```

### Start Server

```bash
./scripts/start-server.sh
# Server runs on http://localhost:8080
```

### Verify

```bash
# Health check
curl http://localhost:8080/health

# Expected: {"status":"ok","message":"MERIDIEN API is running"}
```

## Frontend Setup (Optional)

```bash
cd frontend

# Install dependencies
flutter pub get

# Generate Freezed models
flutter pub run build_runner build --delete-conflicting-outputs

# Run web
flutter run -d chrome

# Or mobile
flutter run
```

## Test Login

**Default credentials:**
- Tenant: `demo`
- Email: `admin@meridien.com`
- Password: `Admin123`

**API test:**
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"tenant_slug":"demo","email":"admin@meridien.com","password":"Admin123"}' \
  | jq -r '.token')

curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/customers
```

## Development Workflow

### Common Commands

**Backend:**
```bash
make dev          # Hot reload
make test         # Run tests
make build        # Production build
make migrate-up   # Run migrations
make migrate-down # Rollback migration
make lint         # Run linter
```

**Frontend:**
```bash
flutter run                  # Development
flutter test                 # Run tests
flutter build web           # Production build
flutter analyze             # Lint
flutter pub run build_runner build --delete-conflicting-outputs  # Generate models
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/feature-name

# Make changes and commit
git add .
git commit -m "feat: add feature description"

# Push and create PR
git push origin feature/feature-name
```

**Commit conventions:**
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Tests
- `chore:` Maintenance

## Troubleshooting

### Go not found
```bash
echo $PATH  # Should include /usr/local/go/bin
export PATH=$PATH:/usr/local/go/bin
```

### PostgreSQL connection failed
```bash
sudo systemctl status postgresql  # Check if running
sudo systemctl start postgresql   # Start if stopped
psql -h localhost -U postgres -d meridien_dev  # Test connection
```

### Port 8080 in use
```bash
lsof -i :8080        # Find process
kill -9 <PID>        # Kill process
# Or change port in configs/.env
```

### Migration failed
```bash
# Check status
migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/meridien_dev?sslmode=disable" version

# Force version if dirty
migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/meridien_dev?sslmode=disable" force 1
```

## Next Steps

1. Review [Development Rules](DEVELOPMENT-RULES.md)
2. Check [API Documentation](api/API-DOCUMENTATION.md)
3. Read [Project Status](PROJECT-STATUS.md)
4. Start building!

## Resources

- **Backend Setup:** [docs/guides/BACKEND-SETUP.md](docs/guides/BACKEND-SETUP.md)
- **Development Rules:** [docs/DEVELOPMENT-RULES.md](docs/DEVELOPMENT-RULES.md)
- **API Reference:** [backend/API-DOCUMENTATION.md](backend/API-DOCUMENTATION.md)

---

**Need help?** Check documentation in `docs/` or create a GitHub issue.
