/// API endpoint constants for MERIDIEN backend
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change this to your backend URL
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';

  // Customer Endpoints
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';

  // Product Endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // Category Endpoints
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // Order Endpoints
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String confirmOrder(String id) => '/orders/$id/confirm';
  static String shipOrder(String id) => '/orders/$id/ship';
  static String deliverOrder(String id) => '/orders/$id/deliver';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  // Payment Endpoints
  static String orderPayments(String orderId) => '/orders/$orderId/payments';
  static String paymentById(String id) => '/payments/$id';

  // Location Endpoints
  static const String locations = '/locations';
  static String locationById(String id) => '/locations/$id';

  // Courier Endpoints
  static const String couriers = '/couriers';
  static String courierById(String id) => '/couriers/$id';

  // Report Endpoints
  static const String courierReconciliation = '/reports/courier-reconciliation';
}
