# MERIDIEN Directory Structure

## Complete Project Layout

```
MERIDIEN/                                          # Root monorepo
│
├── README.md                                      # Main project overview
├── CHANGELOG.md                                   # Version history
├── LICENSE                                        # License file
├── .gitignore                                     # Git ignore rules
├── .env.example                                   # Example environment variables
├── docker-compose.yml                             # Full stack orchestration
├── REPOSITORY-STRATEGY.md                         # Monorepo strategy documentation
│
├── .github/                                       # GitHub configuration
│   └── workflows/                                 # CI/CD workflows
│       ├── backend-ci.yml                        # Backend continuous integration
│       ├── frontend-ci.yml                       # Frontend continuous integration
│       └── deploy.yml                            # Deployment workflow
│
├── docs/                                          # 📚 Shared Documentation
│   ├── MERIDIEN-BRAND.md                         # Brand guidelines
│   ├── plan-three.md                             # Technical architecture
│   ├── mvp-analysis.md                           # MVP phase breakdown
│   ├── DEVELOPMENT-RULES.md                      # Coding standards
│   │
│   ├── api/                                      # API Documentation
│   │   ├── API-REFERENCE.md                      # Complete API reference
│   │   ├── AUTHENTICATION.md                     # Auth endpoints
│   │   ├── CUSTOMERS.md                          # Customer endpoints
│   │   ├── PRODUCTS.md                           # Product endpoints
│   │   ├── ORDERS.md                             # Order endpoints
│   │   └── SHIPPING.md                           # Shipping endpoints
│   │
│   ├── guides/                                   # User Guides
│   │   ├── GETTING-STARTED.md                    # Quick start
│   │   ├── BACKEND-SETUP.md                      # Backend setup guide
│   │   ├── FRONTEND-SETUP.md                     # Frontend setup guide
│   │   ├── DEPLOYMENT.md                         # Deployment guide
│   │   ├── MULTI-TENANCY.md                      # Multi-tenancy guide
│   │   └── CUSTOM-FIELDS.md                      # Custom fields guide
│   │
│   └── architecture/                             # Architecture Docs
│       ├── DATABASE-SCHEMA.md                    # Database design
│       ├── AUTHENTICATION.md                     # Auth architecture
│       ├── MULTI-TENANCY.md                      # Multi-tenancy design
│       └── SECURITY.md                           # Security architecture
│
├── scripts/                                       # 🔧 Shared Scripts
│   ├── setup.sh                                  # Setup entire project
│   ├── dev.sh                                    # Run both backend & frontend
│   ├── test.sh                                   # Run all tests
│   ├── build.sh                                  # Build both
│   ├── deploy.sh                                 # Deploy both
│   │
│   ├── db/                                       # Database scripts
│   │   ├── create.sh                             # Create database
│   │   ├── migrate.sh                            # Run migrations
│   │   ├── seed.sh                               # Seed data
│   │   └── backup.sh                             # Backup database
│   │
│   └── docker/                                   # Docker scripts
│       ├── build.sh                              # Build images
│       └── push.sh                               # Push to registry
│
├── backend/                                       # 🔷 Go Backend
│   ├── cmd/                                      # Application entry points
│   │   ├── server/
│   │   │   └── main.go                           # API server
│   │   ├── worker/
│   │   │   └── main.go                           # Background workers
│   │   └── migrate/
│   │       └── main.go                           # Migration runner
│   │
│   ├── internal/                                 # Internal packages
│   │   ├── config/                               # Configuration
│   │   │   └── config.go
│   │   │
│   │   ├── database/                             # Database connection
│   │   │   └── database.go
│   │   │
│   │   ├── models/                               # GORM models
│   │   │   ├── base_model.go
│   │   │   ├── tenant.go
│   │   │   ├── user.go
│   │   │   ├── customer.go
│   │   │   ├── product.go
│   │   │   ├── order.go
│   │   │   └── ...
│   │   │
│   │   ├── dto/                                  # Data Transfer Objects
│   │   │   ├── auth_dto.go
│   │   │   ├── customer_dto.go
│   │   │   ├── product_dto.go
│   │   │   ├── pagination_dto.go
│   │   │   └── response_dto.go
│   │   │
│   │   ├── repositories/                         # Data access layer
│   │   │   ├── customer_repository.go
│   │   │   ├── product_repository.go
│   │   │   ├── order_repository.go
│   │   │   └── ...
│   │   │
│   │   ├── services/                             # Business logic
│   │   │   ├── auth_service.go
│   │   │   ├── customer_service.go
│   │   │   ├── product_service.go
│   │   │   ├── order_service.go
│   │   │   └── ...
│   │   │
│   │   ├── handlers/                             # HTTP handlers
│   │   │   ├── auth_handler.go
│   │   │   ├── customer_handler.go
│   │   │   ├── product_handler.go
│   │   │   ├── order_handler.go
│   │   │   └── ...
│   │   │
│   │   ├── middleware/                           # HTTP middleware
│   │   │   ├── auth.go
│   │   │   ├── tenant.go
│   │   │   ├── rbac.go
│   │   │   ├── cors.go
│   │   │   ├── logger.go
│   │   │   └── rate_limiter.go
│   │   │
│   │   ├── utils/                                # Utilities
│   │   │   ├── jwt.go
│   │   │   ├── hash.go
│   │   │   ├── validators.go
│   │   │   ├── response.go
│   │   │   └── helpers.go
│   │   │
│   │   ├── workers/                              # Background jobs
│   │   │   ├── revenue_calculator.go
│   │   │   ├── shipping_tracker.go
│   │   │   └── low_stock_alerter.go
│   │   │
│   │   ├── integrations/                         # External integrations
│   │   │   ├── storage/
│   │   │   │   └── s3.go
│   │   │   └── shipping/
│   │   │       ├── posta.go
│   │   │       ├── dhl.go
│   │   │       └── aramex.go
│   │   │
│   │   └── router/                               # Route definitions
│   │       ├── router.go
│   │       └── routes.go
│   │
│   ├── migrations/                               # Database migrations
│   │   ├── 000001_init_schema.up.sql
│   │   ├── 000001_init_schema.down.sql
│   │   ├── 000002_add_customers.up.sql
│   │   └── 000002_add_customers.down.sql
│   │
│   ├── tests/                                    # Tests
│   │   ├── unit/                                 # Unit tests
│   │   │   ├── services/
│   │   │   ├── repositories/
│   │   │   └── utils/
│   │   └── integration/                          # Integration tests
│   │       └── handlers/
│   │
│   ├── configs/                                  # Configuration files
│   │   ├── .env.example
│   │   └── .env
│   │
│   ├── scripts/                                  # Backend scripts
│   │   ├── migrate.sh
│   │   └── seed.sh
│   │
│   ├── docs/                                     # Backend docs
│   │   └── swagger/                              # Generated Swagger
│   │
│   ├── go.mod                                    # Go dependencies
│   ├── go.sum                                    # Go checksums
│   ├── Makefile                                  # Build automation
│   ├── Dockerfile                                # Docker image
│   ├── .air.toml                                 # Hot reload config
│   └── README.md                                 # Backend README
│
└── frontend/                                      # 🔶 Flutter Frontend
    ├── lib/                                      # Source code
    │   ├── main.dart                             # Entry point
    │   ├── app.dart                              # App configuration
    │   │
    │   ├── core/                                 # Core utilities
    │   │   ├── constants/                        # Constants
    │   │   │   ├── app_constants.dart
    │   │   │   ├── api_constants.dart
    │   │   │   └── colors.dart
    │   │   │
    │   │   ├── config/                           # Configuration
    │   │   │   ├── app_config.dart
    │   │   │   └── tenant_config.dart
    │   │   │
    │   │   ├── errors/                           # Error handling
    │   │   │   ├── exceptions.dart
    │   │   │   └── failure.dart
    │   │   │
    │   │   ├── network/                          # Network layer
    │   │   │   ├── api_client.dart
    │   │   │   └── interceptors/
    │   │   │
    │   │   ├── storage/                          # Local storage
    │   │   │   ├── secure_storage.dart
    │   │   │   └── local_storage.dart
    │   │   │
    │   │   ├── utils/                            # Utilities
    │   │   │   ├── validators.dart
    │   │   │   ├── formatters.dart
    │   │   │   └── extensions.dart
    │   │   │
    │   │   └── themes/                           # Themes
    │   │       ├── app_theme.dart
    │   │       └── colors.dart
    │   │
    │   ├── shared/                               # Shared across features
    │   │   ├── widgets/                          # Reusable widgets
    │   │   │   ├── buttons/
    │   │   │   ├── inputs/
    │   │   │   ├── layouts/
    │   │   │   └── feedback/
    │   │   │
    │   │   ├── models/                           # Shared models
    │   │   │   ├── user.dart
    │   │   │   ├── customer.dart
    │   │   │   ├── product.dart
    │   │   │   └── ...
    │   │   │
    │   │   ├── providers/                        # Global providers
    │   │   │   ├── auth_provider.dart
    │   │   │   ├── tenant_provider.dart
    │   │   │   └── theme_provider.dart
    │   │   │
    │   │   └── services/                         # Shared services
    │   │       ├── api_service.dart
    │   │       ├── auth_service.dart
    │   │       └── storage_service.dart
    │   │
    │   ├── features/                             # Feature modules
    │   │   ├── auth/                             # Authentication
    │   │   │   ├── presentation/
    │   │   │   │   ├── pages/
    │   │   │   │   ├── widgets/
    │   │   │   │   └── providers/
    │   │   │   ├── domain/
    │   │   │   └── data/
    │   │   │
    │   │   ├── dashboard/                        # Dashboard
    │   │   ├── customers/                        # Customer management
    │   │   ├── products/                         # Product management
    │   │   ├── orders/                           # Order management
    │   │   ├── revenue/                          # Revenue & reports
    │   │   ├── shipping/                         # Shipping management
    │   │   ├── invoices/                         # Invoice management
    │   │   ├── users/                            # User management
    │   │   ├── settings/                         # Settings
    │   │   └── reports/                          # Advanced reports
    │   │
    │   └── routes/                               # Navigation
    │       ├── app_router.dart
    │       └── route_guards.dart
    │
    ├── test/                                     # Tests
    │   ├── unit/                                 # Unit tests
    │   ├── widget/                               # Widget tests
    │   └── integration/                          # Integration tests
    │
    ├── web/                                      # Web-specific files
    │   ├── index.html
    │   └── favicon.png
    │
    ├── assets/                                   # Assets
    │   ├── images/                               # Images
    │   ├── fonts/                                # Fonts
    │   └── icons/                                # Icons
    │
    ├── pubspec.yaml                              # Dependencies
    ├── pubspec.lock                              # Locked versions
    ├── analysis_options.yaml                     # Linter config
    ├── Dockerfile                                # Docker image
    └── README.md                                 # Frontend README
```

## Quick Navigation

### 📚 Documentation
- Main docs in `docs/`
- API reference in `docs/api/`
- Setup guides in `docs/guides/`
- Architecture in `docs/architecture/`

### 🔷 Backend Development
- Entry points in `backend/cmd/`
- Business logic in `backend/internal/services/`
- Database models in `backend/internal/models/`
- API handlers in `backend/internal/handlers/`

### 🔶 Frontend Development
- Features in `frontend/lib/features/`
- Shared code in `frontend/lib/shared/`
- Core utilities in `frontend/lib/core/`

### 🔧 Scripts
- Setup: `scripts/setup.sh`
- Development: `scripts/dev.sh`
- Testing: `scripts/test.sh`

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Project overview |
| `docker-compose.yml` | Run full stack locally |
| `backend/go.mod` | Go dependencies |
| `frontend/pubspec.yaml` | Flutter dependencies |
| `docs/DEVELOPMENT-RULES.md` | Coding standards |
| `docs/mvp-analysis.md` | MVP roadmap |

## Git Strategy

✅ **Single Repository (Monorepo)**
- Backend and frontend in one repo
- Synchronized versioning
- Unified release process
- Single issue tracker

## Next Steps

1. ✅ Directory structure created
2. ⏭️ Initialize Git repository
3. ⏭️ Move documentation files
4. ⏭️ Set up backend
5. ⏭️ Set up frontend

---

**MERIDIEN** - Navigate Your Business to Success
