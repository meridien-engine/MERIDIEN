# Business Management System - Enhanced Comprehensive Plan

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [System Architecture](#system-architecture)
4. [Frontend Structure (Flutter)](#frontend-structure-flutter)
5. [Backend Structure (Go)](#backend-structure-go)
6. [Database Schema](#database-schema)
7. [API Design](#api-design)
8. [Security & Authentication](#security--authentication)
9. [Business Customization Strategy](#business-customization-strategy)
10. [Multi-Tenancy Architecture](#multi-tenancy-architecture)
11. [Deployment & DevOps](#deployment--devops)
12. [Testing Strategy](#testing-strategy)
13. [Monitoring & Observability](#monitoring--observability)
14. [Development Workflow](#development-workflow)

---

## Project Overview

### Objective
Develop a scalable, multi-tenant Business Management System targeting the Middle Eastern retail market, supporting both direct retail and dropshipping models. The system is designed to serve 100+ businesses with customizable attributes and workflows.

### Target Platforms
- **Web** (Primary - Desktop & Mobile Responsive)
- **Mobile Apps** (iOS/Android - Future Phase)
- **Desktop** (Windows/macOS - Future Phase)

### Key Features
- Customer Relationship Management (CRM)
- Product & Inventory Management
- Order Processing & Fulfillment
- Multi-carrier Shipping Integration (Posta, DHL, Aramex)
- Revenue & Financial Reporting
- Multi-tenant Architecture with Business Customization
- Role-Based Access Control (RBAC)
- Tax Management (VAT/Tax compliance)
- Invoice & Receipt Generation
- Audit Logging

### Target Market
- Small to medium retail businesses in Middle East
- Dropshipping operations
- Multi-branch retail chains
- B2B and B2C operations

---

## Technology Stack

### Frontend
- **Framework:** Flutter 3.x (Dart)
- **State Management:** Riverpod 2.x
- **HTTP Client:** dio
- **Local Storage:** Hive (structured data) + flutter_secure_storage (sensitive data)
- **Code Generation:** freezed, json_serializable, build_runner
- **Navigation:** go_router
- **Localization:** flutter_localizations, intl
- **UI Components:** Material Design 3
- **Charts:** fl_chart
- **Forms:** flutter_form_builder
- **File Handling:** file_picker, image_picker
- **Caching:** cached_network_image
- **PDF Generation:** pdf, printing

### Backend
- **Language:** Go 1.21+
- **Web Framework:** Gin-Gonic
- **Database:** PostgreSQL 15+ (primary), Redis (caching & sessions)
- **ORM:** GORM
- **Authentication:** JWT (golang-jwt/jwt)
- **Configuration:** viper
- **Logging:** logrus + structured logging
- **Validation:** go-playground/validator.v10
- **API Documentation:** swaggo/gin-swagger
- **Password Hashing:** golang.org/x/crypto/bcrypt
- **Migration:** golang-migrate/migrate
- **Testing:** testify, go-sqlmock
- **File Storage:** S3-compatible (MinIO for dev, AWS S3 for prod)
- **Background Jobs:** asynq (Redis-based task queue)
- **Monitoring:** Prometheus client
- **Rate Limiting:** golang.org/x/time/rate

### DevOps & Infrastructure
- **Version Control:** Git (GitHub/GitLab)
- **Containerization:** Docker, Docker Compose
- **Container Orchestration:** Kubernetes (for scaling) or Docker Swarm
- **CI/CD:** GitHub Actions / GitLab CI
- **Cloud Provider:** AWS / GCP / Azure (cloud-agnostic design)
- **Reverse Proxy:** Nginx / Traefik
- **SSL/TLS:** Let's Encrypt (automated)
- **Monitoring:** Prometheus + Grafana
- **Log Aggregation:** ELK Stack (Elasticsearch, Logstash, Kibana) or Loki
- **Error Tracking:** Sentry
- **Backup:** Automated PostgreSQL backups (pg_dump + S3)
- **CDN:** CloudFlare / AWS CloudFront

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Client Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Flutter Web  │  │ Mobile Apps  │  │ Desktop Apps │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      CDN / Load Balancer                     │
│                     (CloudFlare / Nginx)                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     API Gateway Layer                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Rate Limiting │ Auth │ CORS │ Logging │ Security     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer (Go)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Handlers │  │ Services │  │  Workers │  │ Integrat.│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ PostgreSQL  │ │    Redis    │ │  S3 Storage │
    │  (Primary)  │ │  (Cache)    │ │   (Files)   │
    └─────────────┘ └─────────────┘ └─────────────┘
```

### Multi-Tenancy Model
**Hybrid Approach: Database-per-tenant with Shared Infrastructure**
- Each business gets isolated database schema
- Shared application servers
- Tenant identification via subdomain or tenant_id in JWT
- Easy data isolation and compliance
- Simplified backup and migration per tenant

---

## Frontend Structure (Flutter)

```
lib/
├── main.dart                          # Entry point with multi-tenant init
├── app.dart                           # MaterialApp setup, theme, routing
├── bootstrap.dart                     # App initialization logic
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── api_constants.dart         # API endpoints
│   │   ├── storage_keys.dart          # Storage key constants
│   │   └── validation_constants.dart  # Validation rules
│   │
│   ├── config/
│   │   ├── app_config.dart            # Environment-specific config
│   │   ├── tenant_config.dart         # Tenant-specific settings
│   │   └── feature_flags.dart         # Feature toggles
│   │
│   ├── errors/
│   │   ├── exceptions.dart            # Custom exceptions
│   │   ├── failure.dart               # Failure models
│   │   └── error_handler.dart         # Global error handling
│   │
│   ├── network/
│   │   ├── api_client.dart            # Dio configuration
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── tenant_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   └── error_interceptor.dart
│   │   └── network_info.dart          # Network connectivity
│   │
│   ├── storage/
│   │   ├── secure_storage.dart        # Secure storage wrapper
│   │   ├── local_storage.dart         # Hive wrapper
│   │   └── cache_manager.dart         # Cache management
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── extensions.dart
│   │   ├── helpers.dart
│   │   ├── date_utils.dart
│   │   ├── currency_utils.dart
│   │   └── pdf_generator.dart
│   │
│   └── themes/
│       ├── app_theme.dart
│       ├── colors.dart
│       ├── text_styles.dart
│       └── dimensions.dart
│
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── icon_button.dart
│   │   ├── inputs/
│   │   │   ├── custom_text_field.dart
│   │   │   ├── dropdown_field.dart
│   │   │   ├── date_picker_field.dart
│   │   │   └── search_field.dart
│   │   ├── layouts/
│   │   │   ├── responsive_layout.dart
│   │   │   ├── page_wrapper.dart
│   │   │   └── card_wrapper.dart
│   │   ├── feedback/
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   └── success_dialog.dart
│   │   ├── data_display/
│   │   │   ├── data_table.dart
│   │   │   ├── pagination.dart
│   │   │   ├── stat_card.dart
│   │   │   └── badge.dart
│   │   └── navigation/
│   │       ├── app_drawer.dart
│   │       ├── app_bar.dart
│   │       └── bottom_nav.dart
│   │
│   ├── models/
│   │   ├── user.dart
│   │   ├── tenant.dart
│   │   ├── customer.dart
│   │   ├── product.dart
│   │   ├── order.dart
│   │   ├── order_item.dart
│   │   ├── shipping_info.dart
│   │   ├── invoice.dart
│   │   ├── revenue_summary.dart
│   │   ├── pagination.dart
│   │   └── api_response.dart
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── tenant_provider.dart
│   │   ├── theme_provider.dart
│   │   ├── locale_provider.dart
│   │   └── connectivity_provider.dart
│   │
│   └── services/
│       ├── api_service.dart           # Base API service
│       ├── auth_service.dart
│       ├── storage_service.dart
│       ├── file_service.dart
│       └── analytics_service.dart
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   ├── forgot_password_page.dart
│   │   │   │   └── reset_password_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── auth_form.dart
│   │   │   │   └── tenant_selector.dart
│   │   │   └── providers/
│   │   │       └── auth_controller.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── auth_remote_datasource.dart
│   │       ├── models/
│   │       │   └── user_model.dart
│   │       └── repositories/
│   │           └── auth_repository_impl.dart
│   │
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── dashboard_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── stats_overview.dart
│   │   │   │   ├── recent_orders.dart
│   │   │   │   ├── revenue_chart.dart
│   │   │   │   └── low_stock_alerts.dart
│   │   │   └── providers/
│   │   │       └── dashboard_controller.dart
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── customers/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── customer_list_page.dart
│   │   │   │   ├── customer_detail_page.dart
│   │   │   │   ├── customer_form_page.dart
│   │   │   │   └── customer_orders_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── customer_card.dart
│   │   │   │   ├── customer_stats.dart
│   │   │   │   ├── customer_address_form.dart
│   │   │   │   └── customer_notes_widget.dart
│   │   │   └── providers/
│   │   │       ├── customer_list_controller.dart
│   │   │       ├── customer_detail_controller.dart
│   │   │       └── customer_form_controller.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── customer_entity.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── customer_remote_datasource.dart
│   │       ├── models/
│   │       │   └── customer_model.dart
│   │       └── repositories/
│   │           └── customer_repository_impl.dart
│   │
│   ├── products/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── product_list_page.dart
│   │   │   │   ├── product_detail_page.dart
│   │   │   │   ├── product_form_page.dart
│   │   │   │   └── category_management_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── product_card.dart
│   │   │   │   ├── product_image_picker.dart
│   │   │   │   ├── product_price_form.dart
│   │   │   │   ├── stock_indicator.dart
│   │   │   │   └── category_selector.dart
│   │   │   └── providers/
│   │   │       ├── product_list_controller.dart
│   │   │       ├── product_detail_controller.dart
│   │   │       └── product_form_controller.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── product_entity.dart
│   │   │   │   └── category_entity.dart
│   │   │   └── repositories/
│   │   │       └── product_repository.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── product_remote_datasource.dart
│   │       ├── models/
│   │       │   ├── product_model.dart
│   │       │   └── category_model.dart
│   │       └── repositories/
│   │           └── product_repository_impl.dart
│   │
│   ├── inventory/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── inventory_list_page.dart
│   │   │   │   ├── stock_adjustment_page.dart
│   │   │   │   └── low_stock_alerts_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── inventory_status_card.dart
│   │   │   │   ├── stock_movement_history.dart
│   │   │   │   └── adjustment_form.dart
│   │   │   └── providers/
│   │   │       └── inventory_controller.dart
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── orders/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── order_list_page.dart
│   │   │   │   ├── order_detail_page.dart
│   │   │   │   ├── order_creation_page.dart
│   │   │   │   └── order_fulfillment_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── order_card.dart
│   │   │   │   ├── order_items_list.dart
│   │   │   │   ├── order_status_badge.dart
│   │   │   │   ├── order_timeline.dart
│   │   │   │   └── payment_status_widget.dart
│   │   │   └── providers/
│   │   │       ├── order_list_controller.dart
│   │   │       ├── order_detail_controller.dart
│   │   │       └── order_creation_controller.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── order_entity.dart
│   │   │   │   └── order_item_entity.dart
│   │   │   └── repositories/
│   │   │       └── order_repository.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── order_remote_datasource.dart
│   │       ├── models/
│   │       │   ├── order_model.dart
│   │       │   └── order_item_model.dart
│   │       └── repositories/
│   │           └── order_repository_impl.dart
│   │
│   ├── shipping/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── shipping_list_page.dart
│   │   │   │   ├── shipping_detail_page.dart
│   │   │   │   └── create_shipment_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── shipping_card.dart
│   │   │   │   ├── tracking_timeline.dart
│   │   │   │   ├── carrier_selector.dart
│   │   │   │   └── shipping_label_viewer.dart
│   │   │   └── providers/
│   │   │       ├── shipping_list_controller.dart
│   │   │       └── shipping_detail_controller.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── shipping_entity.dart
│   │   │   └── repositories/
│   │   │       └── shipping_repository.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── shipping_remote_datasource.dart
│   │       ├── models/
│   │       │   └── shipping_model.dart
│   │       └── repositories/
│   │           └── shipping_repository_impl.dart
│   │
│   ├── revenue/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── revenue_dashboard_page.dart
│   │   │   │   ├── revenue_report_page.dart
│   │   │   │   └── financial_overview_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── revenue_summary_card.dart
│   │   │   │   ├── revenue_chart.dart
│   │   │   │   ├── profit_margin_chart.dart
│   │   │   │   └── date_range_selector.dart
│   │   │   └── providers/
│   │   │       ├── revenue_dashboard_controller.dart
│   │   │       └── revenue_report_controller.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── revenue_summary_entity.dart
│   │   │   └── repositories/
│   │   │       └── revenue_repository.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── revenue_remote_datasource.dart
│   │       ├── models/
│   │       │   └── revenue_summary_model.dart
│   │       └── repositories/
│   │           └── revenue_repository_impl.dart
│   │
│   ├── invoices/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── invoice_list_page.dart
│   │   │   │   ├── invoice_detail_page.dart
│   │   │   │   └── invoice_preview_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── invoice_card.dart
│   │   │   │   └── invoice_template.dart
│   │   │   └── providers/
│   │   │       └── invoice_controller.dart
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── users/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── user_list_page.dart
│   │   │   │   ├── user_detail_page.dart
│   │   │   │   ├── user_form_page.dart
│   │   │   │   └── role_management_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── user_card.dart
│   │   │   │   ├── role_selector.dart
│   │   │   │   └── permission_matrix.dart
│   │   │   └── providers/
│   │   │       └── user_controller.dart
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── settings/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── settings_page.dart
│   │   │   │   ├── business_profile_page.dart
│   │   │   │   ├── custom_fields_page.dart
│   │   │   │   └── integration_settings_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── settings_section.dart
│   │   │   │   └── custom_field_builder.dart
│   │   │   └── providers/
│   │   │       └── settings_controller.dart
│   │   ├── domain/
│   │   └── data/
│   │
│   └── reports/
│       ├── presentation/
│       │   ├── pages/
│       │   │   ├── reports_page.dart
│       │   │   ├── sales_report_page.dart
│       │   │   ├── inventory_report_page.dart
│       │   │   └── customer_report_page.dart
│       │   ├── widgets/
│       │   │   ├── report_card.dart
│       │   │   └── export_button.dart
│       │   └── providers/
│       │       └── reports_controller.dart
│       ├── domain/
│       └── data/
│
├── routes/
│   ├── app_router.dart
│   ├── route_guards.dart
│   └── route_names.dart
│
└── l10n/
    ├── app_en.arb                     # English
    ├── app_ar.arb                     # Arabic
    ├── app_he.arb                     # Hebrew (optional)
    └── app_tr.arb                     # Turkish (optional)
```

---

## Backend Structure (Go)

```
business-management-backend/
├── cmd/
│   ├── server/
│   │   └── main.go                    # HTTP server entry point
│   ├── worker/
│   │   └── main.go                    # Background worker entry point
│   └── migrate/
│       └── main.go                    # Migration runner
│
├── internal/
│   ├── config/
│   │   ├── config.go                  # Configuration management
│   │   └── constants.go               # Application constants
│   │
│   ├── database/
│   │   ├── database.go                # Database connection
│   │   ├── migrations.go              # Migration runner
│   │   └── seeder.go                  # Database seeding
│   │
│   ├── cache/
│   │   ├── redis.go                   # Redis client setup
│   │   └── cache_service.go           # Caching logic
│   │
│   ├── models/
│   │   ├── base_model.go              # Base model with common fields
│   │   ├── tenant.go
│   │   ├── user.go
│   │   ├── role.go
│   │   ├── permission.go
│   │   ├── customer.go
│   │   ├── supplier.go
│   │   ├── category.go
│   │   ├── product.go
│   │   ├── product_image.go
│   │   ├── custom_field.go            # For business-specific attributes
│   │   ├── custom_field_value.go
│   │   ├── order.go
│   │   ├── order_item.go
│   │   ├── shipping_info.go
│   │   ├── shipping_tracking_update.go
│   │   ├── invoice.go
│   │   ├── inventory_movement.go
│   │   ├── revenue_summary.go
│   │   └── audit_log.go
│   │
│   ├── dto/                            # Data Transfer Objects
│   │   ├── auth_dto.go
│   │   ├── customer_dto.go
│   │   ├── product_dto.go
│   │   ├── order_dto.go
│   │   ├── pagination_dto.go
│   │   └── response_dto.go
│   │
│   ├── repositories/
│   │   ├── base_repository.go         # Base repository with common CRUD
│   │   ├── tenant_repository.go
│   │   ├── user_repository.go
│   │   ├── customer_repository.go
│   │   ├── product_repository.go
│   │   ├── order_repository.go
│   │   ├── shipping_repository.go
│   │   ├── revenue_repository.go
│   │   ├── inventory_repository.go
│   │   ├── invoice_repository.go
│   │   ├── custom_field_repository.go
│   │   └── audit_log_repository.go
│   │
│   ├── services/
│   │   ├── tenant_service.go          # Multi-tenancy logic
│   │   ├── auth_service.go
│   │   ├── user_service.go
│   │   ├── customer_service.go
│   │   ├── product_service.go
│   │   ├── order_service.go
│   │   ├── shipping_service.go
│   │   ├── revenue_service.go
│   │   ├── inventory_service.go
│   │   ├── invoice_service.go
│   │   ├── notification_service.go
│   │   ├── file_service.go            # File upload/download
│   │   ├── export_service.go          # Export reports
│   │   └── custom_field_service.go    # Dynamic fields management
│   │
│   ├── handlers/
│   │   ├── health_handler.go          # Health check endpoints
│   │   ├── auth_handler.go
│   │   ├── tenant_handler.go
│   │   ├── user_handler.go
│   │   ├── customer_handler.go
│   │   ├── product_handler.go
│   │   ├── category_handler.go
│   │   ├── order_handler.go
│   │   ├── shipping_handler.go
│   │   ├── revenue_handler.go
│   │   ├── inventory_handler.go
│   │   ├── invoice_handler.go
│   │   ├── report_handler.go
│   │   └── settings_handler.go
│   │
│   ├── middleware/
│   │   ├── auth.go                    # JWT authentication
│   │   ├── tenant.go                  # Tenant context injection
│   │   ├── rbac.go                    # Role-based access control
│   │   ├── cors.go                    # CORS configuration
│   │   ├── logger.go                  # Request logging
│   │   ├── rate_limiter.go            # Rate limiting
│   │   ├── recovery.go                # Panic recovery
│   │   ├── request_id.go              # Request ID tracking
│   │   ├── audit.go                   # Audit logging
│   │   └── metrics.go                 # Prometheus metrics
│   │
│   ├── workers/
│   │   ├── revenue_calculator.go      # Periodic revenue calculation
│   │   ├── shipping_tracker.go        # Fetch shipping updates from APIs
│   │   ├── low_stock_alerter.go       # Low stock notifications
│   │   ├── invoice_generator.go       # Async invoice generation
│   │   └── report_generator.go        # Async report generation
│   │
│   ├── integrations/
│   │   ├── storage/
│   │   │   ├── s3.go                  # S3-compatible storage
│   │   │   └── storage_interface.go
│   │   ├── shipping/
│   │   │   ├── posta.go               # Posta API integration
│   │   │   ├── dhl.go                 # DHL API integration
│   │   │   ├── aramex.go              # Aramex API integration
│   │   │   └── shipping_interface.go
│   │   ├── payment/                   # Future payment gateway integrations
│   │   │   └── payment_interface.go
│   │   └── notification/
│   │       ├── email.go               # Email notifications
│   │       ├── sms.go                 # SMS notifications
│   │       └── notification_interface.go
│   │
│   ├── utils/
│   │   ├── jwt.go                     # JWT utilities
│   │   ├── hash.go                    # Password hashing
│   │   ├── validators.go              # Custom validators
│   │   ├── helpers.go                 # General helpers
│   │   ├── pagination.go              # Pagination utilities
│   │   ├── response.go                # Response formatting
│   │   ├── errors.go                  # Error handling utilities
│   │   └── permissions.go             # Permission checking utilities
│   │
│   └── router/
│       ├── router.go                  # Main router setup
│       ├── routes.go                  # Route definitions
│       └── swagger.go                 # Swagger documentation setup
│
├── pkg/                                # Public libraries (reusable)
│   ├── logger/
│   │   └── logger.go
│   └── validator/
│       └── validator.go
│
├── migrations/
│   ├── 000001_init_schema.up.sql
│   ├── 000001_init_schema.down.sql
│   ├── 000002_add_custom_fields.up.sql
│   ├── 000002_add_custom_fields.down.sql
│   └── ...
│
├── docs/
│   ├── swagger/                        # Generated Swagger documentation
│   ├── api.md                          # API documentation
│   └── architecture.md                 # Architecture documentation
│
├── scripts/
│   ├── migrate.sh                      # Migration script
│   ├── seed.sh                         # Seeding script
│   ├── backup.sh                       # Backup script
│   └── deploy.sh                       # Deployment script
│
├── tests/
│   ├── unit/
│   │   ├── services/
│   │   ├── repositories/
│   │   └── utils/
│   ├── integration/
│   │   └── handlers/
│   └── e2e/
│       └── scenarios/
│
├── configs/
│   ├── .env.example
│   ├── .env.development
│   ├── .env.staging
│   └── .env.production
│
├── deployments/
│   ├── docker/
│   │   ├── Dockerfile
│   │   ├── Dockerfile.worker
│   │   └── docker-compose.yml
│   ├── kubernetes/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   └── configmap.yaml
│   └── nginx/
│       └── nginx.conf
│
├── .gitignore
├── .dockerignore
├── go.mod
├── go.sum
├── Makefile                            # Build automation
└── README.md
```

---

## Database Schema

### Core Design Principles
1. **Multi-tenancy**: Each tenant gets isolated schema with `tenant_id` in shared tables (if using shared DB) or separate databases
2. **Soft Deletes**: All tables include `deleted_at` for data recovery
3. **Audit Trail**: Track who created/updated records
4. **Extensibility**: Custom fields support for business-specific attributes
5. **Normalization**: Properly normalized with foreign keys
6. **Indexing**: Strategic indexes for performance

### Schema Structure

#### Multi-Tenancy & User Management

```sql
-- Tenants (Businesses)
CREATE TABLE tenants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    database_name VARCHAR(100) UNIQUE,  -- For database-per-tenant model
    status VARCHAR(50) DEFAULT 'active', -- active, suspended, cancelled
    plan_type VARCHAR(50) DEFAULT 'basic', -- basic, professional, enterprise
    settings JSONB,                     -- Business-specific settings
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Users (Multi-tenant aware)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_id INT REFERENCES roles(id),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id)
);

CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
```

#### RBAC (Role-Based Access Control)

```sql
-- Roles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_system_role BOOLEAN DEFAULT false, -- true for predefined roles
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, name)
);

-- Permissions
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,     -- e.g., 'customer.create'
    resource VARCHAR(50) NOT NULL,         -- e.g., 'customer'
    action VARCHAR(50) NOT NULL,           -- e.g., 'create', 'read', 'update', 'delete'
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role-Permission Mapping
CREATE TABLE role_permissions (
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);
```

#### Custom Fields (Business-specific attributes)

```sql
-- Custom Field Definitions
CREATE TABLE custom_fields (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    entity_type VARCHAR(50) NOT NULL,      -- 'customer', 'product', 'order', etc.
    field_name VARCHAR(100) NOT NULL,
    field_label VARCHAR(255) NOT NULL,
    field_type VARCHAR(50) NOT NULL,       -- 'text', 'number', 'date', 'dropdown', 'checkbox'
    field_options JSONB,                   -- For dropdown options
    is_required BOOLEAN DEFAULT false,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE(tenant_id, entity_type, field_name)
);

-- Custom Field Values
CREATE TABLE custom_field_values (
    id SERIAL PRIMARY KEY,
    custom_field_id INT REFERENCES custom_fields(id) ON DELETE CASCADE,
    entity_id INT NOT NULL,                -- ID of the customer/product/order
    entity_type VARCHAR(50) NOT NULL,      -- Must match custom_field.entity_type
    field_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(custom_field_id, entity_id)
);

CREATE INDEX idx_custom_field_values_entity ON custom_field_values(entity_type, entity_id);
```

#### Customers

```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone_number VARCHAR(50),
    
    -- Address fields
    address_line1 TEXT,
    address_line2 TEXT,
    city VARCHAR(100),
    government VARCHAR(100),               -- Governorate/State/Region
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Iraq',   -- Or relevant ME country
    landmark_near TEXT,
    
    -- CRM fields
    customer_type VARCHAR(50) DEFAULT 'individual', -- individual, business
    customer_rank VARCHAR(50) DEFAULT 'regular',    -- regular, vip, platinum
    credit_limit DECIMAL(15, 2) DEFAULT 0,
    outstanding_balance DECIMAL(15, 2) DEFAULT 0,
    notes TEXT,
    
    -- Metadata
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id)
);

CREATE INDEX idx_customers_tenant_id ON customers(tenant_id);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone_number);
```

#### Suppliers

```sql
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(50),
    address TEXT,
    payment_terms TEXT,
    rating DECIMAL(3, 2),                  -- 1.00 to 5.00
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id)
);

CREATE INDEX idx_suppliers_tenant_id ON suppliers(tenant_id);
```

#### Categories

```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    parent_id INT REFERENCES categories(id), -- For nested categories
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255),
    description TEXT,
    image_url TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id),
    UNIQUE(tenant_id, slug)
);

CREATE INDEX idx_categories_tenant_id ON categories(tenant_id);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
```

#### Products

```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    sku VARCHAR(100),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Pricing
    price DECIMAL(15, 2) NOT NULL,
    discount_price DECIMAL(15, 2),
    product_cost DECIMAL(15, 2),           -- Cost to business
    tax_rate DECIMAL(5, 2) DEFAULT 0,      -- Tax percentage (e.g., 15.00 for 15%)
    
    -- Inventory
    stock_quantity INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 10,
    track_inventory BOOLEAN DEFAULT true,
    
    -- Shipping
    weight DECIMAL(10, 2),                 -- in kg
    dimensions JSONB,                      -- {length, width, height} in cm
    
    -- Categorization
    category_id INT REFERENCES categories(id),
    supplier_id INT REFERENCES suppliers(id),
    
    -- Metadata
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id),
    UNIQUE(tenant_id, sku)
);

CREATE INDEX idx_products_tenant_id ON products(tenant_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_stock ON products(stock_quantity);
```

#### Product Images

```sql
CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_images_product_id ON product_images(product_id);
```

#### Orders

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    order_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id INT REFERENCES customers(id),
    
    -- Order details
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending_payment',
    -- Status: pending_payment, confirmed, processing, awaiting_fulfillment,
    --         shipped, out_for_delivery, delivered, returned, cancelled
    
    -- Financial
    subtotal DECIMAL(15, 2) NOT NULL,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    discount_code VARCHAR(100),
    tax_amount DECIMAL(15, 2) DEFAULT 0,
    shipping_cost DECIMAL(15, 2) DEFAULT 0,
    total_amount DECIMAL(15, 2) NOT NULL,
    
    -- Payment
    payment_method VARCHAR(50),            -- credit_card, cash_on_delivery, bank_transfer
    payment_status VARCHAR(50) DEFAULT 'pending', -- pending, paid, failed, refunded
    paid_at TIMESTAMP,
    
    -- Shipping address (snapshot at order time)
    shipping_name VARCHAR(255),
    shipping_phone VARCHAR(50),
    shipping_address_line1 TEXT,
    shipping_address_line2 TEXT,
    shipping_city VARCHAR(100),
    shipping_government VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(100),
    shipping_landmark TEXT,
    
    -- Metadata
    notes TEXT,
    internal_notes TEXT,                   -- For staff only
    cancelled_at TIMESTAMP,
    cancelled_by INT REFERENCES users(id),
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id)
);

CREATE INDEX idx_orders_tenant_id ON orders(tenant_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
```

#### Order Items

```sql
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT REFERENCES products(id),
    
    -- Snapshot of product at order time
    product_name VARCHAR(255),
    product_sku VARCHAR(100),
    
    -- Pricing
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    unit_cost DECIMAL(15, 2),              -- Cost at order time
    tax_rate DECIMAL(5, 2) DEFAULT 0,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    total_price DECIMAL(15, 2) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

#### Shipping

```sql
CREATE TABLE shipping_info (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Carrier info
    carrier_name VARCHAR(100),             -- posta, dhl, aramex, other
    tracking_number VARCHAR(255),
    shipping_label_url TEXT,
    
    -- Recipient (can differ from order shipping address)
    recipient_name VARCHAR(255),
    recipient_phone VARCHAR(50),
    recipient_address TEXT,
    
    -- Costs
    shipping_cost_to_customer DECIMAL(15, 2),
    shipping_cost_to_business DECIMAL(15, 2),
    
    -- Dates
    shipped_date TIMESTAMP,
    estimated_delivery_date TIMESTAMP,
    actual_delivery_date TIMESTAMP,
    
    -- Status
    current_status VARCHAR(100),
    last_tracked_update TIMESTAMP,
    
    -- Metadata
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id),
    updated_by INT REFERENCES users(id)
);

CREATE INDEX idx_shipping_info_tenant_id ON shipping_info(tenant_id);
CREATE INDEX idx_shipping_info_order_id ON shipping_info(order_id);
CREATE INDEX idx_shipping_info_tracking_number ON shipping_info(tracking_number);
```

#### Shipping Tracking Updates

```sql
CREATE TABLE shipping_tracking_updates (
    id SERIAL PRIMARY KEY,
    shipping_info_id INT REFERENCES shipping_info(id) ON DELETE CASCADE,
    event_timestamp TIMESTAMP NOT NULL,
    event_description TEXT NOT NULL,
    location VARCHAR(255),
    status_code VARCHAR(50),
    raw_data JSONB,                        -- Raw API response
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tracking_updates_shipping_id ON shipping_tracking_updates(shipping_info_id);
CREATE INDEX idx_tracking_updates_event_timestamp ON shipping_tracking_updates(event_timestamp);
```

#### Invoices

```sql
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    order_id INT REFERENCES orders(id),
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    
    -- Financial breakdown
    subtotal DECIMAL(15, 2) NOT NULL,
    tax_amount DECIMAL(15, 2) DEFAULT 0,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    shipping_amount DECIMAL(15, 2) DEFAULT 0,
    total_amount DECIMAL(15, 2) NOT NULL,
    
    -- Currency (for future multi-currency support)
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Dates
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date TIMESTAMP,
    paid_at TIMESTAMP,
    
    -- Files
    pdf_url TEXT,
    
    -- Metadata
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by INT REFERENCES users(id)
);

CREATE INDEX idx_invoices_tenant_id ON invoices(tenant_id);
CREATE INDEX idx_invoices_order_id ON invoices(order_id);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
```

#### Inventory Management

```sql
CREATE TABLE inventory_movements (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    product_id INT REFERENCES products(id),
    
    -- Movement details
    movement_type VARCHAR(50) NOT NULL,    -- in, out, adjustment, return
    quantity INT NOT NULL,                 -- positive for IN, negative for OUT
    quantity_before INT NOT NULL,
    quantity_after INT NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50),            -- order, supplier_shipment, adjustment
    reference_id INT,                      -- order_id or other reference
    
    -- Details
    reason VARCHAR(255),
    notes TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT REFERENCES users(id)
);

CREATE INDEX idx_inventory_movements_tenant_id ON inventory_movements(tenant_id);
CREATE INDEX idx_inventory_movements_product_id ON inventory_movements(product_id);
CREATE INDEX idx_inventory_movements_created_at ON inventory_movements(created_at);
```

#### Revenue & Analytics

```sql
CREATE TABLE revenue_summary (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    
    -- Date range
    summary_period_type VARCHAR(50) NOT NULL, -- daily, weekly, monthly, quarterly, yearly
    date_range_start DATE NOT NULL,
    date_range_end DATE NOT NULL,
    
    -- Metrics
    total_orders_count INT DEFAULT 0,
    total_gross_revenue DECIMAL(15, 2) DEFAULT 0,
    total_discount_given DECIMAL(15, 2) DEFAULT 0,
    total_tax_collected DECIMAL(15, 2) DEFAULT 0,
    total_shipping_revenue DECIMAL(15, 2) DEFAULT 0,
    total_net_revenue DECIMAL(15, 2) DEFAULT 0,
    total_product_costs DECIMAL(15, 2) DEFAULT 0,
    total_shipping_costs DECIMAL(15, 2) DEFAULT 0,
    calculated_profit DECIMAL(15, 2) DEFAULT 0,
    
    -- Customer metrics
    new_customers_count INT DEFAULT 0,
    returning_customers_count INT DEFAULT 0,
    
    -- Order metrics
    completed_orders_count INT DEFAULT 0,
    cancelled_orders_count INT DEFAULT 0,
    returned_orders_count INT DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, summary_period_type, date_range_start)
);

CREATE INDEX idx_revenue_summary_tenant_id ON revenue_summary(tenant_id);
CREATE INDEX idx_revenue_summary_dates ON revenue_summary(date_range_start, date_range_end);
```

#### Audit Logs

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    user_id INT REFERENCES users(id),
    
    -- Action details
    action VARCHAR(50) NOT NULL,           -- create, update, delete, view
    resource_type VARCHAR(50) NOT NULL,    -- customer, product, order, etc.
    resource_id INT,
    
    -- Changes
    old_values JSONB,
    new_values JSONB,
    
    -- Request context
    ip_address INET,
    user_agent TEXT,
    request_id VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_tenant_id ON audit_logs(tenant_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

#### Settings & Configuration

```sql
CREATE TABLE tenant_settings (
    id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(id),
    
    -- Business info
    business_name VARCHAR(255),
    business_logo_url TEXT,
    tax_id VARCHAR(100),
    
    -- Contact
    business_email VARCHAR(255),
    business_phone VARCHAR(50),
    business_address TEXT,
    
    -- Tax settings
    default_tax_rate DECIMAL(5, 2) DEFAULT 0,
    tax_number VARCHAR(100),
    
    -- Invoice settings
    invoice_prefix VARCHAR(10) DEFAULT 'INV',
    invoice_counter INT DEFAULT 1,
    invoice_footer TEXT,
    
    -- Notification settings
    low_stock_threshold INT DEFAULT 10,
    enable_email_notifications BOOLEAN DEFAULT true,
    enable_sms_notifications BOOLEAN DEFAULT false,
    
    -- Other settings
    settings JSONB,                        -- Flexible JSON for additional settings
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id)
);
```

---

## API Design

### Base URL Structure
```
Production: https://api.yourdomain.com/v1
Staging:    https://api-staging.yourdomain.com/v1
Development: http://localhost:8080/api/v1
```

### Authentication Endpoints

```
POST   /auth/register              # Register new tenant/user
POST   /auth/login                 # Login and get JWT
POST   /auth/refresh               # Refresh JWT token
POST   /auth/logout                # Logout (invalidate token)
POST   /auth/forgot-password       # Request password reset
POST   /auth/reset-password        # Reset password with token
GET    /auth/me                    # Get current user info
PUT    /auth/me                    # Update current user profile
PUT    /auth/change-password       # Change password
```

### User Management

```
GET    /users                      # List users (paginated, filtered)
GET    /users/:id                  # Get user by ID
POST   /users                      # Create user
PUT    /users/:id                  # Update user
DELETE /users/:id                  # Delete user (soft delete)
GET    /users/:id/permissions      # Get user permissions
PUT    /users/:id/activate         # Activate user
PUT    /users/:id/deactivate       # Deactivate user
```

### Role & Permission Management

```
GET    /roles                      # List roles
GET    /roles/:id                  # Get role details
POST   /roles                      # Create role
PUT    /roles/:id                  # Update role
DELETE /roles/:id                  # Delete role
GET    /roles/:id/permissions      # Get role permissions
PUT    /roles/:id/permissions      # Update role permissions

GET    /permissions                # List all available permissions
```

### Customer Management

```
GET    /customers                  # List customers (paginated, filtered)
GET    /customers/search           # Search customers
GET    /customers/:id              # Get customer details
POST   /customers                  # Create customer
PUT    /customers/:id              # Update customer
DELETE /customers/:id              # Delete customer
GET    /customers/:id/orders       # Get customer orders
GET    /customers/:id/statistics   # Get customer statistics (total spent, order count, etc.)
POST   /customers/:id/notes        # Add customer note
GET    /customers/export           # Export customers (CSV/Excel)
```

### Product Management

```
GET    /products                   # List products (paginated, filtered)
GET    /products/search            # Search products
GET    /products/low-stock         # Get low stock products
GET    /products/:id               # Get product details
POST   /products                   # Create product
PUT    /products/:id               # Update product
DELETE /products/:id               # Delete product
POST   /products/:id/images        # Upload product images
DELETE /products/:id/images/:imgId # Delete product image
GET    /products/export            # Export products

# Categories
GET    /categories                 # List categories
GET    /categories/:id             # Get category details
POST   /categories                 # Create category
PUT    /categories/:id             # Update category
DELETE /categories/:id             # Delete category
```

### Inventory Management

```
GET    /inventory                  # Get inventory status
GET    /inventory/:productId       # Get product inventory
POST   /inventory/adjust           # Adjust inventory
GET    /inventory/movements        # Get inventory movements history
GET    /inventory/low-stock-alerts # Get low stock alerts
```

### Order Management

```
GET    /orders                     # List orders (paginated, filtered)
GET    /orders/search              # Search orders
GET    /orders/:id                 # Get order details
POST   /orders                     # Create order
PUT    /orders/:id                 # Update order
PUT    /orders/:id/status          # Update order status
DELETE /orders/:id                 # Cancel order
POST   /orders/:id/cancel          # Cancel order with reason
POST   /orders/:id/return          # Create return request
GET    /orders/:id/invoice         # Get order invoice
GET    /orders/:id/shipping        # Get order shipping info
GET    /orders/export              # Export orders
```

### Shipping Management

```
GET    /shipping                   # List shipments
GET    /shipping/:id               # Get shipment details
POST   /shipping                   # Create shipment
PUT    /shipping/:id               # Update shipment
GET    /shipping/:id/tracking      # Get tracking updates
POST   /shipping/:id/refresh       # Refresh tracking from carrier API
GET    /shipping/:id/label         # Get shipping label PDF
POST   /shipping/carriers/:carrier/quote # Get shipping quote
```

### Invoice Management

```
GET    /invoices                   # List invoices
GET    /invoices/:id               # Get invoice details
POST   /invoices/generate          # Generate invoice for order
GET    /invoices/:id/pdf           # Download invoice PDF
PUT    /invoices/:id/paid          # Mark invoice as paid
```

### Revenue & Reports

```
GET    /reports/revenue-summary    # Get revenue summary
  ?period=daily|weekly|monthly
  &start_date=YYYY-MM-DD
  &end_date=YYYY-MM-DD

GET    /reports/sales-by-product   # Sales breakdown by product
GET    /reports/sales-by-customer  # Sales breakdown by customer
GET    /reports/sales-by-category  # Sales breakdown by category
GET    /reports/inventory-status   # Current inventory report
GET    /reports/profit-margin      # Profit margin analysis
GET    /reports/top-customers      # Top customers by revenue
GET    /reports/top-products       # Top selling products
GET    /reports/export             # Export report data
```

### Settings & Custom Fields

```
GET    /settings                   # Get tenant settings
PUT    /settings                   # Update tenant settings

# Custom Fields
GET    /custom-fields              # List custom fields
  ?entity_type=customer|product|order
GET    /custom-fields/:id          # Get custom field details
POST   /custom-fields              # Create custom field
PUT    /custom-fields/:id          # Update custom field
DELETE /custom-fields/:id          # Delete custom field
```

### Health & Monitoring

```
GET    /health                     # Health check
GET    /health/ready               # Readiness check
GET    /health/live                # Liveness check
GET    /metrics                    # Prometheus metrics
```

### Request/Response Format

**Common Query Parameters:**
```
?page=1                 # Page number (default: 1)
&limit=20               # Items per page (default: 20, max: 100)
&sort=created_at        # Sort field
&order=desc             # Sort order (asc|desc)
&search=query           # Search query
&filter[status]=active  # Filter by field
```

**Success Response:**
```json
{
  "success": true,
  "message": "Request successful",
  "data": {
    // Response data
  },
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_items": 100
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description",
  "error": {
    "code": "ERROR_CODE",
    "details": {
      // Validation errors or additional details
    }
  }
}
```

**HTTP Status Codes:**
- `200 OK` - Successful GET/PUT request
- `201 Created` - Successful POST request
- `204 No Content` - Successful DELETE request
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

---

## Security & Authentication

### JWT Authentication

**JWT Token Structure:**
```json
{
  "user_id": 123,
  "tenant_id": 456,
  "email": "user@example.com",
  "role": "admin",
  "permissions": ["customer.create", "order.read"],
  "exp": 1234567890,
  "iat": 1234567890
}
```

**Token Lifecycle:**
- Access token: 15 minutes expiry
- Refresh token: 7 days expiry (stored in httpOnly cookie or secure storage)
- Token blacklisting in Redis for logout

### RBAC Implementation

**Default Roles:**
- **Super Admin**: Full system access (tenant management)
- **Admin**: Full tenant access
- **Manager**: Order, product, customer management
- **Staff**: Order processing, customer service
- **Read-Only**: View-only access

**Permission Format:**
```
{resource}.{action}

Examples:
- customer.create
- customer.read
- customer.update
- customer.delete
- order.*
- *.read
```

### Security Measures

1. **Rate Limiting**
   - Per IP: 100 requests/minute
   - Per user: 1000 requests/hour
   - Per endpoint: Custom limits

2. **Input Validation**
   - All inputs validated using validator.v10
   - SQL injection prevention (GORM parameterized queries)
   - XSS prevention (input sanitization)

3. **CORS**
   - Whitelist allowed origins
   - Credentials support for cookies

4. **HTTPS Only**
   - Force SSL in production
   - HSTS headers

5. **Secrets Management**
   - Environment variables for secrets
   - AWS Secrets Manager / HashiCorp Vault for production

6. **File Upload Security**
   - File type validation
   - File size limits
   - Virus scanning (ClamAV)
   - Secure file storage (S3 with pre-signed URLs)

---

## Business Customization Strategy

### Custom Fields System

**Use Cases:**
- Add "WhatsApp Number" to customers
- Add "Batch Number" to products
- Add "Gift Message" to orders
- Industry-specific attributes

**Implementation:**
```json
// Custom field definition
{
  "entity_type": "customer",
  "field_name": "whatsapp_number",
  "field_label": "WhatsApp Number",
  "field_type": "text",
  "is_required": false,
  "validation_rules": {
    "pattern": "^[0-9]{10,15}$"
  }
}

// Custom field value
{
  "custom_field_id": 1,
  "entity_id": 123,  // customer_id
  "entity_type": "customer",
  "field_value": "+9647501234567"
}
```

**Supported Field Types:**
- `text` - Single line text
- `textarea` - Multi-line text
- `number` - Numeric input
- `decimal` - Decimal numbers
- `date` - Date picker
- `datetime` - Date and time picker
- `dropdown` - Select from options
- `multi_select` - Multiple selection
- `checkbox` - Boolean
- `url` - URL validation
- `email` - Email validation
- `phone` - Phone number validation

### Workflow Customization

**Configurable Business Rules:**
```json
// Example: Auto-approve orders under certain amount
{
  "rule_name": "auto_approve_small_orders",
  "trigger": "order.created",
  "conditions": {
    "total_amount": {"less_than": 100},
    "payment_method": "prepaid"
  },
  "actions": [
    {"set_status": "confirmed"},
    {"send_notification": "customer"}
  ]
}
```

### Template System

**Customizable Templates:**
- Invoice templates (HTML/PDF)
- Email templates
- Receipt templates
- Report templates

**Template Variables:**
```
{{business_name}}
{{order_number}}
{{customer_name}}
{{total_amount}}
{{items}}
etc.
```

---

## Multi-Tenancy Architecture

### Tenant Isolation Strategy

**Database-per-Tenant Model:**

**Pros:**
- Complete data isolation
- Easy compliance (GDPR, data sovereignty)
- Custom schema per tenant
- Easy backup/restore per tenant
- Performance isolation

**Cons:**
- More complex database management
- Higher infrastructure costs
- Schema migration challenges

**Implementation:**
```go
// Tenant context middleware
func TenantMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Extract tenant from subdomain or header
        subdomain := extractSubdomain(c.Request.Host)
        
        // Get tenant from cache or DB
        tenant := getTenant(subdomain)
        
        // Set tenant context
        c.Set("tenant_id", tenant.ID)
        c.Set("tenant_db", tenant.DatabaseName)
        
        c.Next()
    }
}

// Dynamic database connection
func GetTenantDB(c *gin.Context) *gorm.DB {
    dbName := c.GetString("tenant_db")
    return getDBConnection(dbName)
}
```

### Tenant Provisioning

**Onboarding Flow:**
1. Tenant registration (subdomain, business details)
2. Create tenant record in master DB
3. Create isolated database for tenant
4. Run migrations on tenant DB
5. Seed default data (roles, permissions, settings)
6. Create admin user for tenant
7. Send welcome email

**Automation Script:**
```bash
#!/bin/bash
# scripts/provision_tenant.sh

TENANT_NAME=$1
SUBDOMAIN=$2
ADMIN_EMAIL=$3

# Create database
createdb ${SUBDOMAIN}_db

# Run migrations
migrate -path migrations -database "postgres://localhost/${SUBDOMAIN}_db" up

# Seed data
go run cmd/seeder/main.go --tenant=${SUBDOMAIN}

# Create admin user
go run cmd/create_admin/main.go --tenant=${SUBDOMAIN} --email=${ADMIN_EMAIL}
```

### Scaling for 100+ Tenants

**Architecture Patterns:**

1. **Connection Pooling**
   - Use PgBouncer for PostgreSQL connection pooling
   - Limit connections per tenant

2. **Caching Strategy**
   - Redis for session management
   - Cache tenant metadata
   - Cache frequently accessed data
   - Cache custom field definitions

3. **Database Sharding** (Future)
   - Group tenants across multiple database servers
   - Shard by tenant_id or subdomain hash

4. **Read Replicas**
   - Master for writes
   - Read replicas for reports and analytics

5. **Resource Limits**
   - API rate limiting per tenant
   - Storage quotas per tenant
   - Database size limits

6. **Monitoring per Tenant**
   - Track resource usage
   - Alert on anomalies
   - Billing based on usage

**Load Balancing:**
```
                    ┌──────────────┐
                    │ Load Balancer│
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐        ┌────▼────┐       ┌────▼────┐
   │  App 1  │        │  App 2  │       │  App 3  │
   └────┬────┘        └────┬────┘       └────┬────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                    ┌──────▼───────┐
                    │ PgBouncer    │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐        ┌────▼────┐       ┌────▼────┐
   │ Tenant1 │        │ Tenant2 │       │ Tenant3 │
   │   DB    │        │   DB    │       │   DB    │
   └─────────┘        └─────────┘       └─────────┘
```

---

## Deployment & DevOps

### Containerization

**Dockerfile (API Server):**
```dockerfile
# Multi-stage build
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server cmd/server/main.go

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/

COPY --from=builder /app/server .
COPY --from=builder /app/configs ./configs

EXPOSE 8080
CMD ["./server"]
```

**docker-compose.yml (Development):**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
      POSTGRES_DB: business_mgmt
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: password123
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data

  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      REDIS_HOST: redis
      REDIS_PORT: 6379
      S3_ENDPOINT: minio:9000
    depends_on:
      - postgres
      - redis
      - minio
    volumes:
      - ./configs:/root/configs

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

### CI/CD Pipeline

**GitHub Actions (.github/workflows/deploy.yml):**
```yaml
name: Deploy

on:
  push:
    branches: [main, staging]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: Run tests
        run: go test ./...
      
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Push to registry
        run: |
          docker tag myapp:${{ github.sha }} registry.example.com/myapp:latest
          docker push registry.example.com/myapp:latest
      
      - name: Deploy to Kubernetes
        run: kubectl apply -f deployments/kubernetes/
```

### Kubernetes Deployment

**deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api
        image: registry.example.com/myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: host
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Backup Strategy

**Database Backups:**
```bash
#!/bin/bash
# Daily automated backups

BACKUP_DIR="/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup each tenant database
for DB in $(psql -t -c "SELECT database_name FROM tenants WHERE status='active'"); do
  pg_dump $DB | gzip > $BACKUP_DIR/${DB}_${TIMESTAMP}.sql.gz
  
  # Upload to S3
  aws s3 cp $BACKUP_DIR/${DB}_${TIMESTAMP}.sql.gz s3://backups/postgres/
  
  # Delete local backups older than 7 days
  find $BACKUP_DIR -name "${DB}_*.sql.gz" -mtime +7 -delete
done
```

---

## Testing Strategy

### Unit Tests
```go
// Example: services/customer_service_test.go
func TestCreateCustomer(t *testing.T) {
    // Setup
    mockRepo := new(MockCustomerRepository)
    service := NewCustomerService(mockRepo)
    
    customer := &models.Customer{
        Name:  "Test Customer",
        Email: "test@example.com",
    }
    
    mockRepo.On("Create", customer).Return(nil)
    
    // Execute
    err := service.CreateCustomer(customer)
    
    // Assert
    assert.NoError(t, err)
    mockRepo.AssertExpectations(t)
}
```

### Integration Tests
```go
// Example: handlers/customer_handler_test.go
func TestCustomerHandler_Create(t *testing.T) {
    // Setup test database
    db := setupTestDB()
    defer teardownTestDB(db)
    
    router := setupRouter(db)
    
    // Create request
    payload := `{"name":"Test Customer","email":"test@example.com"}`
    req, _ := http.NewRequest("POST", "/api/v1/customers", strings.NewReader(payload))
    req.Header.Set("Content-Type", "application/json")
    req.Header.Set("Authorization", "Bearer "+getTestToken())
    
    // Execute
    w := httptest.NewRecorder()
    router.ServeHTTP(w, req)
    
    // Assert
    assert.Equal(t, http.StatusCreated, w.Code)
}
```

### E2E Tests
```go
// Example: Complete order flow test
func TestCompleteOrderFlow(t *testing.T) {
    // 1. Create customer
    // 2. Create products
    // 3. Create order
    // 4. Process payment
    // 5. Create shipment
    // 6. Verify inventory updated
    // 7. Verify revenue calculated
}
```

### Frontend Tests
```dart
// Widget test
void main() {
  testWidgets('Customer form validation', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    
    // Find form fields
    final nameField = find.byKey(Key('customer_name'));
    final emailField = find.byKey(Key('customer_email'));
    final submitButton = find.byKey(Key('submit_button'));
    
    // Test validation
    await tester.tap(submitButton);
    await tester.pump();
    
    expect(find.text('Name is required'), findsOneWidget);
  });
}
```

---

## Monitoring & Observability

### Prometheus Metrics

**Custom Metrics:**
```go
var (
    requestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "HTTP request latency",
        },
        []string{"method", "endpoint", "status"},
    )
    
    ordersCreated = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "orders_created_total",
            Help: "Total orders created",
        },
        []string{"tenant_id"},
    )
)
```

### Logging

**Structured Logging:**
```go
log.WithFields(log.Fields{
    "tenant_id":  tenantID,
    "user_id":    userID,
    "request_id": requestID,
    "action":     "create_order",
}).Info("Order created successfully")
```

### Grafana Dashboards

**Key Metrics to Monitor:**
- Request rate (requests/second)
- Error rate (%)
- Response time (p50, p95, p99)
- Database connections
- Cache hit rate
- Orders per minute
- Revenue per day
- Active users
- Low stock alerts

### Alerting

**Alert Rules:**
- Error rate > 5% for 5 minutes
- Response time p95 > 1s for 5 minutes
- Database connection pool > 80% for 5 minutes
- Disk usage > 85%
- Memory usage > 90%
- Failed background jobs

---

## Development Workflow

### 1. Initial Setup

```bash
# Clone repository
git clone https://github.com/yourorg/business-management.git
cd business-management

# Backend setup
cd backend
cp configs/.env.example configs/.env
# Edit .env with your settings

# Start dependencies with Docker
docker-compose up -d postgres redis minio

# Run migrations
make migrate-up

# Seed database
make seed

# Run backend
go run cmd/server/main.go

# Frontend setup
cd ../frontend
flutter pub get
flutter run -d chrome
```

### 2. Feature Development Flow

```bash
# Create feature branch
git checkout -b feature/add-custom-fields

# Backend: Create model, repository, service, handler
# Frontend: Create feature module with clean architecture

# Write tests
make test

# Commit with conventional commits
git commit -m "feat: add custom fields support"

# Push and create PR
git push origin feature/add-custom-fields
```

### 3. Database Migrations

```bash
# Create migration
migrate create -ext sql -dir migrations -seq add_custom_fields

# Apply migration
make migrate-up

# Rollback migration
make migrate-down
```

### 4. Code Quality

**Pre-commit Hooks:**
```bash
# Backend
- go fmt
- golangci-lint
- go test

# Frontend
- flutter analyze
- flutter format
- flutter test
```

---

## Key Dependencies

### Backend (go.mod)
```go
require (
    github.com/gin-gonic/gin v1.9.1
    gorm.io/gorm v1.25.5
    gorm.io/driver/postgres v1.5.4
    github.com/golang-jwt/jwt/v5 v5.1.0
    github.com/spf13/viper v1.17.0
    github.com/sirupsen/logrus v1.9.3
    github.com/go-playground/validator/v10 v10.16.0
    github.com/swaggo/gin-swagger v1.6.0
    github.com/swaggo/files v1.0.1
    github.com/swaggo/swag v1.16.2
    github.com/golang-migrate/migrate/v4 v4.16.2
    github.com/stretchr/testify v1.8.4
    github.com/go-redis/redis/v8 v8.11.5
    github.com/hibiken/asynq v0.24.1
    golang.org/x/crypto v0.16.0
    golang.org/x/time v0.5.0
    github.com/prometheus/client_golang v1.17.0
    github.com/aws/aws-sdk-go v1.48.0
)
```

### Frontend (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Network
  dio: ^5.4.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # Serialization
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # Navigation
  go_router: ^13.0.0
  
  # UI
  flutter_hooks: ^0.20.4
  cached_network_image: ^3.3.1
  
  # Forms
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # File Handling
  file_picker: ^6.1.1
  image_picker: ^1.0.5
  
  # Charts
  fl_chart: ^0.66.0
  
  # PDF
  pdf: ^3.10.7
  printing: ^5.11.1
  
  # Localization
  intl: ^0.18.1
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  flutter_lints: ^3.0.1
```

---

## Next Steps

1. **Review and approve this plan**
2. **See [mvp-analysis.md](./mvp-analysis.md) for phase breakdown**
3. **Set up development environment**
4. **Begin MVP Phase 1 implementation**

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-23  
**Status:** Draft - Pending Review
