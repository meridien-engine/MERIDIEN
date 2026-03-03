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
  static const String userBusinesses = '/auth/businesses';
  static String useBusiness(String id) => '/auth/use-business/$id';

  // Business Endpoints
  static const String createBusiness = '/businesses';
  static String businessById(String id) => '/businesses/$id';
  static const String businessCategories = '/business-categories';

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

  // Store Endpoints
  static const String stores = '/stores';
  static String storeById(String id) => '/stores/$id';

  // Location Endpoints
  static const String locations = '/locations';
  static String locationById(String id) => '/locations/$id';

  // Courier Endpoints
  static const String couriers = '/couriers';
  static String courierById(String id) => '/couriers/$id';

  // Report Endpoints
  static const String courierReconciliation = '/reports/courier-reconciliation';

  // Membership Endpoints
  static const String joinRequests = '/join-requests';
  static String businessJoinRequests(String id) => '/businesses/$id/join-requests';
  static String approveJoinRequest(String id, String reqId) =>
      '/businesses/$id/join-requests/$reqId/approve';
  static String rejectJoinRequest(String id, String reqId) =>
      '/businesses/$id/join-requests/$reqId/reject';
  static String businessInvitations(String id) => '/businesses/$id/invitations';
  static String invitationByToken(String token) => '/invitations/$token';
  static String acceptInvitation(String token) => '/invitations/$token/accept';
  static String businessMembers(String id) => '/businesses/$id/members';
  static String memberById(String businessId, String userId) =>
      '/businesses/$businessId/members/$userId';
  static String businessBySlug(String slug) => '/businesses/slug/$slug';

  // Branch Endpoints
  static const String branches = '/branches';
  static String branchById(String id) => '/branches/$id';
  static String businessBranches(String businessId) => '/businesses/$businessId/branches';
  static String branchUsers(String branchId) => '/branches/$branchId/users';
  static String branchUserById(String branchId, String userId) => '/branches/$branchId/users/$userId';

  // POS Endpoints
  static const String posSessions = '/pos/sessions';
  static const String posCurrentSession = '/pos/sessions/current';
  static String posSessionById(String id) => '/pos/sessions/$id';
  static String closePosSession(String id) => '/pos/sessions/$id/close';
  static const String posCheckout = '/pos/checkout';
  static const String productLookup = '/products/lookup';
}
