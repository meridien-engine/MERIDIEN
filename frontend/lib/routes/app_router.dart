import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/business_selector_screen.dart';
import '../features/auth/screens/no_business_screen.dart';
import '../features/business/screens/create_business_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/customers/screens/customer_list_screen.dart';
import '../features/customers/screens/customer_detail_screen.dart';
import '../features/customers/screens/customer_form_screen.dart';
import '../features/products/screens/product_list_screen.dart';
import '../features/products/screens/product_detail_screen.dart';
import '../features/products/screens/product_form_screen.dart';
import '../features/orders/screens/order_list_screen.dart';
import '../features/orders/screens/order_detail_screen.dart';
import '../features/orders/screens/create_order_screen.dart';
import '../features/locations/screens/location_management_screen.dart';
import '../features/branches/screens/branch_management_screen.dart';
import '../features/branches/screens/branch_access_screen.dart';
import '../features/branches/screens/branch_inventory_screen.dart';
import '../features/branches/screens/activate_product_screen.dart';
import '../features/couriers/screens/courier_management_screen.dart';
import '../features/couriers/screens/courier_reconciliation_screen.dart';
import '../features/pos/screens/pos_session_gate_screen.dart';
import '../features/pos/screens/pos_sessions_screen.dart';
import '../features/membership/screens/find_business_screen.dart';
import '../features/membership/screens/my_join_requests_screen.dart';
import '../features/membership/screens/join_requests_screen.dart';
import '../features/membership/screens/members_screen.dart';
import '../features/membership/screens/invite_user_screen.dart';
import '../features/membership/screens/accept_invitation_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/providers/role_provider.dart';
import '../data/models/customer_model.dart';
import '../data/models/product_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final location = state.matchedLocation;

      final isAuthenticated = authState.maybeWhen(
        authenticated: (_, __, ___) => true,
        orElse: () => false,
      );

      final isSelectingBusiness = authState.maybeWhen(
        selectingBusiness: (_, __) => true,
        orElse: () => false,
      );

      final isNoBusiness = authState.maybeWhen(
        noBusiness: (_) => true,
        orElse: () => false,
      );

      final isLoading = authState.maybeWhen(
        initial: () => true,
        loading: () => true,
        orElse: () => false,
      );

      // While loading, don't redirect
      if (isLoading) return null;

      final authRoutes = ['/login', '/register'];
      final isAuthRoute = authRoutes.contains(location);
      final isBusinessSelectRoute = location == '/business-select';
      final isNoBusinessRoute = location == '/no-business';
      final isBusinessCreateRoute = location == '/business/create';

      // Authenticated with business → redirect away from auth screens
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      if (isAuthenticated && isBusinessSelectRoute) return '/dashboard';
      if (isAuthenticated && isNoBusinessRoute) return '/dashboard';

      // Selecting business → go to selector
      if (isSelectingBusiness && !isBusinessSelectRoute &&
          !isBusinessCreateRoute) {
        return '/business-select';
      }

      // No business → go to no-business screen
      if (isNoBusiness &&
          !isNoBusinessRoute &&
          !isBusinessCreateRoute) {
        return '/no-business';
      }

      // Unauthenticated → redirect to login
      final unauthenticated = authState.maybeWhen(
        unauthenticated: () => true,
        orElse: () => false,
      );
      if (unauthenticated && !isAuthRoute) return '/login';

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/business-select',
        name: 'business-select',
        builder: (context, state) => const BusinessSelectorScreen(),
      ),
      GoRoute(
        path: '/no-business',
        name: 'no-business',
        builder: (context, state) => const NoBusinessScreen(),
      ),

      // ── Business ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/business/create',
        name: 'create-business',
        builder: (context, state) => const CreateBusinessScreen(),
      ),

      // ── Dashboard ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // ── Customers ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customers/new',
        name: 'create-customer',
        builder: (context, state) => const CustomerFormScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        name: 'customer-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerDetailScreen(customerId: id);
        },
      ),
      GoRoute(
        path: '/customers/:id/edit',
        name: 'edit-customer',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final customer = state.extra as CustomerModel?;
          return CustomerFormScreen(customerId: id, customer: customer);
        },
      ),

      // ── Products ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/products/new',
        name: 'create-product',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/products/:id',
        name: 'product-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/products/:id/edit',
        name: 'edit-product',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final product = state.extra as ProductModel?;
          return ProductFormScreen(productId: id, product: product);
        },
      ),

      // ── Orders ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/orders/new',
        name: 'create-order',
        builder: (context, state) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'order-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),

      // ── Branches ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/branches',
        name: 'branches',
        builder: (context, state) => const BranchManagementScreen(),
      ),
      GoRoute(
        path: '/branches/:id/access',
        name: 'branch-access',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BranchAccessScreen(branchId: id);
        },
      ),
      GoRoute(
        path: '/branches/:id/inventory',
        name: 'branch-inventory',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final branchName = state.extra as String? ?? '';
          return BranchInventoryScreen(branchId: id, branchName: branchName);
        },
      ),
      GoRoute(
        path: '/branches/:id/inventory/activate',
        name: 'activate-product',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final branchName = state.extra as String? ?? '';
          return ActivateProductScreen(branchId: id, branchName: branchName);
        },
      ),

      // ── Settings ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/settings/locations',
        name: 'locations',
        builder: (context, state) => const LocationManagementScreen(),
      ),
      GoRoute(
        path: '/settings/couriers',
        name: 'couriers',
        builder: (context, state) => const CourierManagementScreen(),
      ),

      // ── Reports ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/reports/courier-reconciliation',
        name: 'courier-reconciliation',
        redirect: (context, state) {
          final role = ref.read(currentUserRoleProvider);
          if (role != MeridienRole.owner) return '/dashboard';
          return null;
        },
        builder: (context, state) => const CourierReconciliationScreen(),
      ),

      // ── POS ───────────────────────────────────────────────────────────────
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const PosSessionGateScreen(),
      ),
      GoRoute(
        path: '/pos/sessions',
        name: 'pos-sessions',
        builder: (context, state) => const PosSessionsScreen(),
      ),

      // ── Membership ────────────────────────────────────────────────────────
      GoRoute(
        path: '/membership/find',
        name: 'find-business',
        builder: (context, state) => const FindBusinessScreen(),
      ),
      GoRoute(
        path: '/membership/requests',
        name: 'my-join-requests',
        builder: (context, state) => const MyJoinRequestsScreen(),
      ),
      GoRoute(
        path: '/businesses/:id/join-requests',
        name: 'business-join-requests',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return JoinRequestsScreen(businessId: id);
        },
      ),
      GoRoute(
        path: '/businesses/:id/members',
        name: 'members',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MembersScreen(businessId: id);
        },
      ),
      GoRoute(
        path: '/businesses/:id/invite',
        name: 'invite-user',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return InviteUserScreen(businessId: id);
        },
      ),
      GoRoute(
        path: '/invitations/:token',
        name: 'accept-invitation',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return AcceptInvitationScreen(token: token);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('404 - Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
