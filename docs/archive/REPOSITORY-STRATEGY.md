# MERIDIEN Repository Strategy

## The Question: Monorepo vs Separate Repos?

We need to decide between two approaches:

1. **Monorepo** - Single repository containing both backend and frontend
2. **Separate Repos** - Two repositories: `meridien-backend` and `meridien-frontend`

---

## Recommended Approach: **Monorepo** ✅

### Why Monorepo is Better for MERIDIEN

#### ✅ Advantages

1. **Synchronized Versioning**
   - Backend and frontend versions always match
   - No confusion about which frontend works with which backend
   - Single version number (MERIDIEN v1.0.0)

2. **Atomic Changes**
   - Change API contract in both backend and frontend in one commit
   - No breaking changes between repos
   - Example: Add new field to Customer model → update backend + frontend in one PR

3. **Simplified Development Workflow**
   - Clone once, get everything
   - New developers onboard faster
   - Single CI/CD pipeline
   - Shared documentation in one place

4. **Easier Code Review**
   - Reviewers see full picture of feature
   - No need to jump between repos
   - API changes and UI changes reviewed together

5. **Shared Tooling & Config**
   - Shared scripts (setup, deployment)
   - Shared documentation
   - Single issue tracker
   - Single project board

6. **Better for MVP Development**
   - Faster iteration
   - Less overhead
   - Simpler dependency management

#### ❌ Disadvantages (and mitigations)

1. **Larger Repository Size**
   - **Mitigation**: Not a real issue for modern Git
   - Flutter web assets are small
   - Go binaries not committed

2. **All or Nothing Clone**
   - **Mitigation**: Sparse checkout if needed (rare)
   - Most developers need both anyway

3. **Mixed Languages in One Repo**
   - **Mitigation**: Clear directory structure
   - Separate CI jobs for each

---

## Alternative: Separate Repos

### When to Use Separate Repos?

- ✅ **Large team** (10+ developers) with separate backend/frontend teams
- ✅ **Different release cycles** (backend weekly, frontend daily)
- ✅ **Multiple frontends** (web, iOS, Android all separate)
- ✅ **Public backend, private frontend** (or vice versa)
- ✅ **Different programming languages teams** that never collaborate

### Why NOT for MERIDIEN (at least initially)?

- ❌ Small team (1-3 developers initially)
- ❌ Synchronized releases (backend + frontend together)
- ❌ One frontend (Flutter web, mobile comes later)
- ❌ Both private or both public
- ❌ Full-stack developers who work on both

---

## Recommended Structure: Monorepo

```
MERIDIEN/
├── README.md                      # Main project README
├── .gitignore                     # Root gitignore
├── .github/                       # GitHub workflows (CI/CD)
│   └── workflows/
│       ├── backend-ci.yml
│       ├── frontend-ci.yml
│       └── deploy.yml
├── docs/                          # Shared documentation
│   ├── MERIDIEN-BRAND.md
│   ├── plan-three.md
│   ├── mvp-analysis.md
│   ├── DEVELOPMENT-RULES.md
│   ├── api/                       # API documentation
│   │   └── API-REFERENCE.md
│   └── guides/                    # User guides
│       ├── GETTING-STARTED.md
│       └── DEPLOYMENT.md
├── scripts/                       # Shared scripts
│   ├── setup.sh                   # Setup both backend + frontend
│   ├── dev.sh                     # Run both in dev mode
│   ├── test.sh                    # Run all tests
│   └── deploy.sh                  # Deploy both
├── backend/                       # Go backend
│   ├── cmd/
│   ├── internal/
│   ├── migrations/
│   ├── configs/
│   ├── go.mod
│   ├── go.sum
│   ├── Makefile
│   ├── Dockerfile
│   └── README.md
├── frontend/                      # Flutter frontend
│   ├── lib/
│   ├── test/
│   ├── web/
│   ├── pubspec.yaml
│   ├── README.md
│   └── Dockerfile
├── docker-compose.yml             # Run full stack locally
├── .env.example                   # Example environment variables
└── CHANGELOG.md                   # Unified changelog
```

### Benefits of This Structure

1. **Clear Separation**: Backend and frontend in separate folders
2. **Independent Build**: Each can build independently
3. **Shared Docs**: All documentation in one place
4. **Unified Scripts**: Single setup, single deployment
5. **Docker Compose**: Run full stack with one command

---

## Migration Path (If Needed Later)

If we grow and need to split:

```bash
# Extract backend to separate repo (preserving history)
git subtree split -P backend -b backend-only
git push <backend-repo-url> backend-only:main

# Extract frontend to separate repo
git subtree split -P frontend -b frontend-only
git push <frontend-repo-url> frontend-only:main
```

This means we can **start with monorepo** and **split later if needed** without losing history.

---

## Decision: Monorepo ✅

**For MERIDIEN, we'll use a monorepo because:**

1. ✅ Small team (1-3 developers initially)
2. ✅ Synchronized releases
3. ✅ Faster MVP development
4. ✅ Simpler onboarding
5. ✅ Easier code reviews
6. ✅ Can split later if needed

---

## Directory Structure Details

### Root Level Files

```
MERIDIEN/
├── README.md                      # Project overview, quick start
├── .gitignore                     # Ignore node_modules, bin/, .env, etc.
├── .env.example                   # Example environment variables
├── docker-compose.yml             # Full stack (postgres, backend, frontend)
├── CHANGELOG.md                   # Version history
├── LICENSE                        # License file
└── CONTRIBUTING.md                # Contribution guidelines
```

### Backend Structure

```
backend/
├── cmd/
│   ├── server/
│   │   └── main.go                # API server
│   ├── worker/
│   │   └── main.go                # Background workers
│   └── migrate/
│       └── main.go                # Migration runner
├── internal/
│   ├── config/
│   ├── database/
│   ├── models/
│   ├── dto/
│   ├── repositories/
│   ├── services/
│   ├── handlers/
│   ├── middleware/
│   ├── utils/
│   ├── workers/
│   ├── integrations/
│   └── router/
├── migrations/
│   ├── 000001_init_schema.up.sql
│   └── 000001_init_schema.down.sql
├── tests/
│   ├── unit/
│   └── integration/
├── configs/
│   ├── .env.example
│   └── .env
├── scripts/
│   ├── migrate.sh
│   └── seed.sh
├── docs/
│   └── swagger/
├── go.mod
├── go.sum
├── Makefile
├── Dockerfile
├── .air.toml
└── README.md
```

### Frontend Structure

```
frontend/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   ├── shared/
│   ├── features/
│   └── routes/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── web/
│   ├── index.html
│   └── favicon.png
├── assets/
│   ├── images/
│   ├── fonts/
│   └── icons/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── Dockerfile
└── README.md
```

### Shared Documentation

```
docs/
├── MERIDIEN-BRAND.md              # Brand guidelines
├── plan-three.md                  # Technical architecture
├── mvp-analysis.md                # MVP phases
├── DEVELOPMENT-RULES.md           # Coding standards
├── api/
│   ├── API-REFERENCE.md           # API documentation
│   ├── AUTHENTICATION.md          # Auth guide
│   ├── CUSTOMERS.md               # Customer endpoints
│   ├── PRODUCTS.md                # Product endpoints
│   └── ORDERS.md                  # Order endpoints
├── guides/
│   ├── GETTING-STARTED.md         # Quick start guide
│   ├── BACKEND-SETUP.md           # Backend setup
│   ├── FRONTEND-SETUP.md          # Frontend setup
│   ├── DEPLOYMENT.md              # Deployment guide
│   ├── MULTI-TENANCY.md           # Multi-tenancy guide
│   └── CUSTOM-FIELDS.md           # Custom fields guide
└── architecture/
    ├── DATABASE-SCHEMA.md         # Database design
    ├── AUTHENTICATION.md          # Auth architecture
    └── MULTI-TENANCY.md           # Multi-tenancy design
```

### Shared Scripts

```
scripts/
├── setup.sh                       # Setup entire project
├── dev.sh                         # Run both backend & frontend
├── test.sh                        # Run all tests
├── build.sh                       # Build both
├── deploy.sh                      # Deploy both
├── db/
│   ├── create.sh                  # Create database
│   ├── migrate.sh                 # Run migrations
│   ├── seed.sh                    # Seed data
│   └── backup.sh                  # Backup database
└── docker/
    ├── build.sh                   # Build Docker images
    └── push.sh                    # Push to registry
```

---

## Git Workflow

### Branch Strategy

```
main                               # Production-ready code
├── develop                        # Development branch
│   ├── feature/auth-module       # Feature branches
│   ├── feature/customer-crud
│   └── feature/order-management
├── release/v1.0.0                 # Release branches
└── hotfix/security-patch          # Hotfix branches
```

### Commit Message Convention

```
feat(backend): add customer authentication
feat(frontend): add customer list page
fix(backend): correct order total calculation
fix(frontend): fix date picker validation
docs: update API documentation
chore: update dependencies
test(backend): add customer service tests
style(frontend): format code
refactor(backend): extract validation logic
```

### Pull Request Process

1. Create feature branch from `develop`
2. Make changes (backend, frontend, or both)
3. Write tests
4. Create PR to `develop`
5. CI runs tests for both backend and frontend
6. Code review
7. Merge to `develop`
8. When ready for release, merge `develop` to `main`

---

## CI/CD Pipeline

### Backend CI (.github/workflows/backend-ci.yml)

```yaml
name: Backend CI

on:
  push:
    paths:
      - 'backend/**'
      - '.github/workflows/backend-ci.yml'
  pull_request:
    paths:
      - 'backend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: Run tests
        run: |
          cd backend
          make test
```

### Frontend CI (.github/workflows/frontend-ci.yml)

```yaml
name: Frontend CI

on:
  push:
    paths:
      - 'frontend/**'
      - '.github/workflows/frontend-ci.yml'
  pull_request:
    paths:
      - 'frontend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - name: Run tests
        run: |
          cd frontend
          flutter pub get
          flutter test
```

---

## Docker Compose Setup

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: meridien_dev
      POSTGRES_USER: meridien
      POSTGRES_PASSWORD: meridien
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      DB_HOST: postgres
      REDIS_HOST: redis
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend:/app

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
    volumes:
      - ./frontend:/app

volumes:
  postgres_data:
```

**Run full stack:**
```bash
docker-compose up
```

---

## Quick Start Commands

```bash
# Clone repository
git clone https://github.com/yourorg/meridien.git
cd meridien

# Setup (both backend and frontend)
./scripts/setup.sh

# Run in development mode
./scripts/dev.sh

# Run tests
./scripts/test.sh

# Build for production
./scripts/build.sh

# Deploy
./scripts/deploy.sh
```

---

## Final Decision Summary

✅ **MONOREPO Structure**
- Single repository: `meridien`
- Backend in `backend/` directory
- Frontend in `frontend/` directory
- Shared documentation in `docs/`
- Shared scripts in `scripts/`

✅ **Version Control**
- Single Git repository
- Unified versioning (MERIDIEN v1.0.0)
- Clear branch strategy
- Conventional commits

✅ **CI/CD**
- Separate CI jobs for backend and frontend
- Run only affected tests on changes
- Unified deployment process

✅ **Migration Path**
- Can split into separate repos later if needed
- Git history preserved

---

**Let's proceed with creating the monorepo structure!** 🚀
