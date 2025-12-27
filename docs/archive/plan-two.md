# Business Management Web App - Detailed Project Structure

## Table of Contents
- [Project Overview](#project-overview)
- [Technology Stack](#technology-stack)
- [Frontend Structure (Flutter)](#frontend-structure-flutter)
- [Backend Structure (Go & Gin)](#backend-structure-go--gin)
- [Development Workflow](#development-workflow)

---

## Project Overview

This document outlines the detailed structure for a comprehensive Business Management Web Application targeting the Middle Eastern retail market. It supports both direct retail and dropshipping models, managing customers, products, orders, revenue, CRM, and integrating with regional shipping services like Posta, DHL, and Aramex.

---

## Technology Stack

### Frontend
- **Framework:** Flutter
- **State Management:** Riverpod
- **HTTP Client:** dio
- **Local Storage:** Hive / shared_preferences
- **UI Widgets:** Standard Flutter widgets

### Backend
- **Language:** Go (Golang)
- **Web Framework:** Gin-Gonic
- **Database:** PostgreSQL / MySQL
- **ORM/Query Builder:** GORM
- **Authentication:** JWT (JSON Web Tokens)
- **Environment Variables:** godotenv
- **Logging:** logrus / standard log
- **Validation:** gin binding tags / validator.v10
- **API Documentation:** Swagger (swaggo/gin-swagger)

---

## Frontend Structure (Flutter)

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp setup, theme, routing
├── core/
│   ├── constants/            # App-wide constants (strings, colors, numbers)
│   │   └── app_constants.dart
│   ├── errors/               # Custom exceptions and error handling
│   │   ├── exceptions.dart
│   │   └── failure.dart
│   ├── network/              # HTTP client setup, interceptors
│   │   ├── api_client.dart
│   │   └── interceptors.dart
│   ├── utils/                # Helper functions (formatters, validators)
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   └── themes/               # Theme definitions
│       └── app_theme.dart
├── features/
│   ├── auth/                 # Authentication screens, states, providers
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   ├── domain/
│   │   └── data/
│   ├── customers/            # Customer management feature
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   ├── products/             # Product management feature
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   ├── orders/               # Order management feature
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   ├── revenue/              # Revenue reporting feature
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   └── shipping/             # Shipping tracking feature
│       ├── presentation/
│       ├── domain/
│       └── data/
├── shared/
│   ├── widgets/              # Reusable UI components (buttons, inputs, dialogs)
│   ├── models/               # Shared data models (DTOs, Entities)
│   ├── providers/            # Global state providers (Riverpod)
│   └── services/             # Shared business logic/services (API calls, caching)
└── routes/                   # App routing definitions
    └── app_router.dart
```

### Core Layer (`lib/core/`)
- **constants/**: Defines application-wide constants like API base URLs, default styling values, etc.
- **errors/**: Houses custom exception classes and error/failure models for consistent error handling.
- **network/**: Sets up the HTTP client (dio), configures base options, and implements interceptors for adding headers (like Authorization).
- **utils/**: Contains utility functions for string formatting, date/time parsing, input validation, and extension methods on common types.
- **themes/**: Defines the application's visual theme (colors, text styles, etc.) using Flutter's `ThemeData`.

### Features Layer (`lib/features/`)
Organizes the application into distinct business features. Each feature follows a layered architecture:
- **presentation/**: Contains UI screens (`pages`) and reusable UI components (`widgets`) specific to the feature. Uses Riverpod providers to access domain and data layers.
- **domain/**: Contains business logic entities (models) and use cases (repository interfaces and service classes) specific to the feature.
- **data/**: Contains implementations of repository interfaces, typically handling API calls and local data caching.

### Shared Layer (`lib/shared/`)
- **widgets/**: Generic, reusable UI components (e.g., custom buttons, text fields, loading indicators) used across multiple features.
- **models/**: Data models (DTOs/Entities) shared across features (e.g., `Customer`, `Product`, `Order`).
- **providers/**: Global Riverpod providers for application-wide state (e.g., current user, app settings).
- **services/**: Shared business logic or services (e.g., `ApiService` for common API interactions, `StorageService` for caching).

---

## Backend Structure (Go & Gin)

```
business-management-backend/
├── cmd/
│   └── server/
│       └── main.go           # Entry point for the application binary
├── internal/                 # Internal application code, not importable by other projects
│   ├── config/
│   │   └── config.go         # Configuration loading (from env vars, files)
│   ├── database/
│   │   └── database.go       # Database connection setup using GORM
│   ├── handlers/             # Gin route handlers (controllers)
│   │   ├── auth_handler.go
│   │   ├── customer_handler.go
│   │   ├── product_handler.go
│   │   ├── order_handler.go
│   │   ├── revenue_handler.go
│   │   └── shipping_handler.go
│   ├── middleware/           # Custom middleware (auth, logging, recovery)
│   │   ├── auth.go
│   │   ├── cors.go
│   │   └── logger.go
│   ├── models/               # GORM models (structs mapping to DB tables)
│   │   ├── customer.go
│   │   ├── product.go
│   │   ├── order.go
│   │   ├── order_item.go
│   │   ├── supplier.go
│   │   ├── category.go
│   │   ├── shipping_info.go
│   │   ├── shipping_tracking_update.go
│   │   └── revenue_summary.go
│   ├── repositories/         # Data access layer (interacts with GORM)
│   │   ├── customer_repository.go
│   │   ├── product_repository.go
│   │   ├── order_repository.go
│   │   ├── shipping_repository.go
│   │   └── revenue_repository.go
│   ├── services/             # Business logic layer
│   │   ├── customer_service.go
│   │   ├── product_service.go
│   │   ├── order_service.go
│   │   ├── shipping_service.go
│   │   └── revenue_service.go
│   ├── utils/
│   │   ├── jwt.go            # JWT token generation/verification
│   │   ├── hash.go           # Password hashing (bcrypt)
│   │   ├── validators.go     # Custom validation logic
│   │   └── helpers.go        # General helper functions
│   └── router/               # API route registration
│       └── router.go
├── pkg/                      # Public libraries, reusable by other projects (if needed)
│   └── ...
├── migrations/               # Database migration files (if using a migration tool like golang-migrate)
│   └── ...
├── docs/                     # API documentation files (if not using Swagger UI)
│   └── ...
├── tests/                    # Integration and unit tests
│   └── ...
├── .env                      # Environment variables file (example, not committed)
├── .gitignore                # Files and directories to ignore in Git
├── Dockerfile                # Instructions for building the Docker image
├── docker-compose.yml        # Docker Compose configuration for local development
├── go.mod                    # Go module definition
├── go.sum                    # Dependency checksums
└── README.md                 # Project documentation
```

### Cmd Directory (`cmd/server/main.go`)
- **Purpose:** The entry point for the application. This is where `go run` starts execution.
- **Responsibilities:**
    - Load configuration using the `config` package.
    - Initialize the database connection using the `database` package.
    - Initialize the Gin router using the `router` package, passing dependencies like the database instance.
    - Start the HTTP server listening on the configured port.

### Internal Directory (`internal/`)
This is the core of the application, containing all business logic. Code here is not intended to be imported by other Go projects.

- **config/**: Manages application configuration, loading values from environment variables (using `godotenv` for local development) or command-line flags. Defines a `Config` struct to hold these values.
- **database/**: Handles the initialization of the GORM database connection based on the loaded configuration. Returns a `*gorm.DB` instance for use by other components.
- **handlers/**: Contains Gin route handlers (often called controllers in other frameworks). These functions receive HTTP requests, parse input, call the appropriate service layer functions, and return HTTP responses. They should be thin, delegating complex logic to the service layer.
- **middleware/**: Houses custom Gin middleware functions for cross-cutting concerns like authentication, logging, request ID injection, and panic recovery.
- **models/**: Defines Go structs that map directly to database tables using GORM tags. These represent the core data entities of the application.
- **repositories/**: Implements data access logic. Contains methods for creating, reading, updating, and deleting (CRUD) entities using GORM. This layer abstracts the database interaction from the service layer.
- **services/**: Contains the core business logic. Services orchestrate calls to repositories and potentially other services. They implement the use cases of the application (e.g., `CreateOrder`, `CalculateRevenue`, `ProcessShippingUpdate`).
- **utils/**: Houses utility functions that don't belong to a specific layer, such as JWT helpers, password hashing, custom validators, and general helpers.
- **router/**: Sets up the Gin router engine, registers all API routes (e.g., `/api/v1/customers`, `/api/v1/orders`), applies global middleware, and maps routes to their corresponding handler functions.

### Pkg Directory (`pkg/`)
- **Purpose:** Contains libraries that are intended to be reusable by *other* projects. Code in `internal` is private to this project, while `pkg` is public. Use sparingly; most code belongs in `internal`.

### Other Files
- **.env:** Example environment variable file (not committed to version control).
- **.gitignore:** Specifies files and directories Git should ignore (e.g., `*.env`, `bin/`, IDE files).
- **Dockerfile:** Instructions for building a Docker image of the application.
- **docker-compose.yml:** Configuration for running the application and its dependencies (like PostgreSQL) locally using Docker Compose.
- **go.mod / go.sum:** Go module files managing dependencies.
- **README.md:** Project overview, setup instructions, etc.

---

## Development Workflow

1.  **Setup:**
    - Initialize Go module.
    - Install dependencies using `go get`.
    - Set up a local PostgreSQL/MySQL instance (or use Docker).
    - Create a `.env` file based on the example.
2.  **Backend Development:**
    - Start with `internal/config` and `cmd/server/main.go`.
    - Define models in `internal/models`.
    - Implement database connection in `internal/database`.
    - Build repositories in `internal/repositories`.
    - Implement services in `internal/services`.
    - Create handlers in `internal/handlers`.
    - Set up routing in `internal/router`.
    - Add middleware as needed.
3.  **Frontend Development:**
    - Define shared models in `lib/shared/models`.
    - Implement API service in `lib/shared/services`.
    - Create feature-specific data layers (`lib/features/[feature]/data`).
    - Implement feature-specific domain logic (`lib/features/[feature]/domain`).
    - Build UI components and screens (`lib/features/[feature]/presentation`).
    - Integrate state management using Riverpod.
4.  **Testing:**
    - Write unit tests for services and repositories.
    - Write integration tests for handlers/API endpoints.
    - Write widget tests for Flutter UI components.
5.  **Building & Deployment:**
    - Use Docker to containerize the Go backend.
    - Build the Flutter web app (`flutter build web`).
    - Deploy the backend container and host the static web files.
