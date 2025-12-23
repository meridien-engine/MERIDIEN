#!/bin/bash

# MERIDIEN Directory Structure Creation Script

echo "🚀 Creating MERIDIEN directory structure..."

# Root directories
mkdir -p .github/workflows
mkdir -p docs/{api,guides,architecture}
mkdir -p scripts/{db,docker}

# Backend structure
mkdir -p backend/{cmd/{server,worker,migrate},internal/{config,database,models,dto,repositories,services,handlers,middleware,utils,workers,integrations,router},migrations,tests/{unit,integration},configs,scripts,docs/swagger}

# Frontend structure
mkdir -p frontend/{lib/{core/{constants,config,errors,network,storage,utils,themes},shared/{widgets,models,providers,services},features/{auth,dashboard,customers,products,orders,revenue,shipping,invoices,users,settings,reports}/{presentation/{pages,widgets,providers},domain,data},routes},test/{unit,widget,integration},web,assets/{images,fonts,icons}}

# Create placeholder READMEs
cat > README.md << 'MAIN_README'
# MERIDIEN

**Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine**  
*Navigate Your Business to Success*

## Quick Start

```bash
# Setup entire project
./scripts/setup.sh

# Run in development mode
./scripts/dev.sh

# Run tests
./scripts/test.sh
```

## Documentation

- [Brand Guidelines](docs/MERIDIEN-BRAND.md)
- [Technical Architecture](docs/plan-three.md)
- [MVP Analysis](docs/mvp-analysis.md)
- [Development Rules](docs/DEVELOPMENT-RULES.md)
- [Backend Setup](docs/guides/BACKEND-SETUP.md)
- [Frontend Setup](docs/guides/FRONTEND-SETUP.md)

## Project Structure

```
MERIDIEN/
├── backend/        # Go + Gin backend
├── frontend/       # Flutter frontend
├── docs/           # Documentation
└── scripts/        # Shared scripts
```

## License

Copyright © 2024 MERIDIEN. All rights reserved.
MAIN_README

cat > backend/README.md << 'BACKEND_README'
# MERIDIEN Backend

Go + Gin + PostgreSQL backend for MERIDIEN.

## Setup

```bash
cd backend
make install
make migrate-up
make dev
```

## API Documentation

http://localhost:8080/swagger/index.html

## Testing

```bash
make test
make test-coverage
```
BACKEND_README

cat > frontend/README.md << 'FRONTEND_README'
# MERIDIEN Frontend

Flutter web and mobile frontend for MERIDIEN.

## Setup

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## Testing

```bash
flutter test
```
FRONTEND_README

echo "✅ Directory structure created successfully!"
echo ""
echo "📁 Structure:"
tree -L 2 -d

