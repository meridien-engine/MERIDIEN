# MERIDIEN Flutter Frontend - Development Plan

## Overview
Building a professional Flutter frontend for the MERIDIEN multi-tenant retail and inventory management system.

**Timeline:** 3-4 weeks  
**Platform:** Flutter (iOS, Android, Web)  
**Backend:** Already complete (Go + Gin + PostgreSQL)

---

## Technology Stack

### Core
- **Flutter SDK:** Latest stable version
- **Dart:** Latest version
- **State Management:** Riverpod (modern, type-safe)
- **HTTP Client:** Dio (interceptors, error handling)
- **Routing:** GoRouter (declarative routing)

### Essential Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  
  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.1.0  # Type-safe API client
  json_annotation: ^4.8.1
  
  # Storage
  shared_preferences: ^2.2.2  # JWT storage
  flutter_secure_storage: ^9.0.0  # Sensitive data
  
  # Routing
  go_router: ^13.0.0
  
  # UI Components
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  
  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Utils
  intl: ^0.19.0  # Date formatting
  logger: ^2.0.2  # Logging
  freezed_annotation: ^2.4.1  # Immutable models
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.6
  riverpod_generator: ^2.3.9
  
  flutter_lints: ^3.0.1
```

---

## Project Structure

```
lib/
├── main.dart
├── app.dart                          # App root widget
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Color palette
│   │   ├── app_strings.dart         # Text constants
│   │   ├── app_routes.dart          # Route names
│   │   └── api_endpoints.dart       # API URLs
│   │
│   ├── theme/
│   │   ├── app_theme.dart           # Light/dark themes
│   │   └── text_styles.dart         # Typography
│   │
│   ├── utils/
│   │   ├── validators.dart          # Form validators
│   │   ├── formatters.dart          # Date, currency formatters
│   │   ├── extensions.dart          # Dart extensions
│   │   └── snackbar_utils.dart      # Notifications
│   │
│   ├── errors/
│   │   ├── exceptions.dart          # Custom exceptions
│   │   └── failures.dart            # Error handling
│   │
│   └── widgets/
│       ├── loading_indicator.dart   # Shared loading
│       ├── error_widget.dart        # Error displays
│       ├── empty_state.dart         # Empty lists
│       └── custom_button.dart       # Reusable buttons
│
├── data/
│   ├── models/
│   │   ├── user_model.dart          # User, Tenant
│   │   ├── customer_model.dart      # Customer
│   │   ├── product_model.dart       # Product, Category
│   │   ├── order_model.dart         # Order, OrderItem
│   │   ├── payment_model.dart       # Payment
│   │   └── response_models.dart     # API responses
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart     # Auth API calls
│   │   ├── customer_repository.dart # Customer API
│   │   ├── product_repository.dart  # Product API
│   │   └── order_repository.dart    # Order API
│   │
│   ├── providers/
│   │   ├── api_client_provider.dart # Dio instance
│   │   └── storage_provider.dart    # Local storage
│   │
│   └── services/
│       ├── api_service.dart         # Retrofit service
│       ├── auth_service.dart        # Auth logic
│       └── storage_service.dart     # Persistence
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── splash_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── login_form.dart
│   │   │   │   └── logo_widget.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   │
│   │   └── domain/
│   │       ├── entities/
│   │       └── usecases/
│   │
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── stats_card.dart
│   │   │       └── quick_actions.dart
│   │   └── providers/
│   │       └── dashboard_provider.dart
│   │
│   ├── customers/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── customer_list_screen.dart
│   │   │   │   ├── customer_detail_screen.dart
│   │   │   │   └── customer_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── customer_card.dart
│   │   │   │   └── customer_search.dart
│   │   │   └── providers/
│   │   │       ├── customer_list_provider.dart
│   │   │       └── customer_detail_provider.dart
│   │
│   ├── products/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── product_list_screen.dart
│   │   │   │   ├── product_detail_screen.dart
│   │   │   │   └── product_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── product_card.dart
│   │   │   │   ├── category_filter.dart
│   │   │   │   └── stock_indicator.dart
│   │   │   └── providers/
│   │   │       └── product_provider.dart
│   │
│   └── orders/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── order_list_screen.dart
│       │   │   ├── order_detail_screen.dart
│       │   │   ├── create_order_screen.dart
│       │   │   └── cart_screen.dart
│       │   ├── widgets/
│       │   │   ├── order_card.dart
│       │   │   ├── order_item_card.dart
│       │   │   ├── payment_form.dart
│       │   │   └── status_badge.dart
│       │   └── providers/
│       │       ├── order_provider.dart
│       │       └── cart_provider.dart
│
└── routes/
    └── app_router.dart              # GoRouter config
```

---

## Development Phases

### **Phase 1: Foundation (Week 1)**

#### Day 1-2: Project Setup
- [x] Create Flutter project
- [x] Add dependencies
- [x] Setup folder structure
- [x] Configure theme (colors, typography)
- [x] Setup constants

#### Day 3-4: Core Infrastructure
- [x] Setup Riverpod
- [x] Create API client with Dio
- [x] Add interceptors (auth token, logging)
- [x] Create base models (User, Tenant)
- [x] Setup secure storage for JWT
- [x] Create error handling

#### Day 5-7: Authentication
- [x] Login screen UI
- [x] Register screen UI
- [x] Auth provider (Riverpod)
- [x] Auth repository
- [x] JWT storage and retrieval
- [x] Auto-login check
- [x] Logout functionality

---

### **Phase 2: Customer Management (Week 2)**

#### Day 1-2: Customer Models & Repository
- [ ] Create Customer model
- [ ] Generate JSON serialization
- [ ] Create CustomerRepository
- [ ] Customer API service with Retrofit

#### Day 3-5: Customer UI
- [ ] Customer list screen
  - [ ] List view with pagination
  - [ ] Search functionality
  - [ ] Filter by status/type
  - [ ] Pull to refresh
- [ ] Customer detail screen
  - [ ] View customer info
  - [ ] Edit button
  - [ ] Delete action
- [ ] Customer form screen
  - [ ] Create new customer
  - [ ] Edit existing customer
  - [ ] Form validation
  - [ ] Address fields

#### Day 6-7: Customer Features
- [ ] Customer providers (Riverpod)
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states
- [ ] Success/error notifications

---

### **Phase 3: Product Catalog (Week 3)**

#### Day 1-2: Product Models & Repository
- [ ] Create Product, Category models
- [ ] ProductRepository
- [ ] Category filtering

#### Day 3-5: Product UI
- [ ] Product list screen
  - [ ] Grid/list view toggle
  - [ ] Category filter chips
  - [ ] Search by name/SKU
  - [ ] Stock indicators
  - [ ] Price display
- [ ] Product detail screen
  - [ ] Product info
  - [ ] Stock status
  - [ ] Edit/delete actions
- [ ] Product form screen
  - [ ] Category selection
  - [ ] Pricing fields
  - [ ] Inventory tracking
  - [ ] Image upload (placeholder)

#### Day 6-7: Product Features
- [ ] Product providers
- [ ] Low stock warnings
- [ ] Featured products
- [ ] Sorting options

---

### **Phase 4: Order Management (Week 4)**

#### Day 1-3: Order Creation Flow
- [ ] Order models (Order, OrderItem, Payment)
- [ ] Cart provider
- [ ] Cart screen
  - [ ] Add products to cart
  - [ ] Adjust quantities
  - [ ] Calculate totals
- [ ] Create order screen
  - [ ] Customer selection
  - [ ] Shipping address
  - [ ] Tax/discount/shipping
  - [ ] Order summary

#### Day 4-5: Order Management
- [ ] Order list screen
  - [ ] Filter by status
  - [ ] Date range filter
  - [ ] Status badges
- [ ] Order detail screen
  - [ ] Order info
  - [ ] Order items
  - [ ] Payment history
  - [ ] Status actions (confirm, ship, etc.)
- [ ] Payment screen
  - [ ] Record payment
  - [ ] Payment method selection

#### Day 6-7: Order Features & Polish
- [ ] Order providers
- [ ] Status transition logic
- [ ] Order workflow UI
- [ ] Payment tracking
- [ ] Testing & bug fixes

---

### **Phase 5: Dashboard & Polish (Days 1-3 of Week 5)**

#### Dashboard
- [ ] Dashboard screen
  - [ ] Stats cards (total orders, revenue, etc.)
  - [ ] Recent orders
  - [ ] Low stock alerts
  - [ ] Quick actions

#### Navigation & UX
- [ ] Bottom navigation bar
- [ ] Drawer menu
- [ ] App bar customization
- [ ] Search functionality
- [ ] Notifications

#### Polish
- [ ] Loading states everywhere
- [ ] Error handling improvements
- [ ] Form validation messages
- [ ] Smooth animations
- [ ] Responsive design
- [ ] Dark mode support

---

## UI/UX Design Guidelines

### Color Scheme
```dart
Primary: #2563EB (Blue)
Secondary: #10B981 (Green)
Error: #EF4444 (Red)
Warning: #F59E0B (Amber)
Background: #F9FAFB (Light Gray)
Surface: #FFFFFF (White)
Text: #111827 (Dark Gray)
```

### Typography
```dart
Heading 1: 32px, Bold
Heading 2: 24px, SemiBold
Heading 3: 20px, SemiBold
Body: 16px, Regular
Caption: 14px, Regular
```

### Spacing
- Padding: 8, 12, 16, 24, 32
- Border Radius: 8, 12, 16
- Elevation: 2, 4, 8

---

## API Integration Strategy

### Authentication Flow
1. User enters credentials
2. Call POST /api/v1/auth/login
3. Store JWT in secure storage
4. Add token to all requests via interceptor
5. Handle 401 (redirect to login)

### Error Handling
```dart
try {
  final response = await repository.getCustomers();
  return response;
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Logout and redirect to login
  } else if (e.response?.statusCode == 404) {
    throw NotFoundException();
  } else {
    throw ServerException();
  }
}
```

### State Management Pattern
```dart
// Provider
final customerListProvider = StateNotifierProvider<CustomerListNotifier, AsyncValue<List<Customer>>>((ref) {
  return CustomerListNotifier(ref.read(customerRepositoryProvider));
});

// Notifier
class CustomerListNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final CustomerRepository repository;
  
  CustomerListNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadCustomers();
  }
  
  Future<void> loadCustomers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getCustomers());
  }
}

// UI
ref.watch(customerListProvider).when(
  data: (customers) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(error: err),
)
```

---

## Testing Strategy

### Unit Tests
- [ ] Model serialization/deserialization
- [ ] Validators
- [ ] Formatters
- [ ] Utilities

### Widget Tests
- [ ] Form validation
- [ ] Button states
- [ ] Custom widgets

### Integration Tests
- [ ] Login flow
- [ ] Create customer flow
- [ ] Create order flow

---

## Success Criteria

### Functionality
- ✅ User can login/register
- ✅ User can manage customers (CRUD)
- ✅ User can manage products (CRUD)
- ✅ User can create orders
- ✅ User can record payments
- ✅ User can track order status

### UX
- ✅ Smooth animations
- ✅ Intuitive navigation
- ✅ Clear error messages
- ✅ Loading indicators
- ✅ Empty states
- ✅ Form validation

### Performance
- ✅ Fast API calls (<1s)
- ✅ Smooth scrolling
- ✅ Efficient state management
- ✅ Offline error handling

---

## Next Steps

1. **Create Flutter project**
2. **Setup dependencies**
3. **Create folder structure**
4. **Configure theme**
5. **Start with authentication screens**

Ready to start? Let me know and we'll begin with Phase 1! 🚀
