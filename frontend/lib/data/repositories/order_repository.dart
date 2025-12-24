import 'package:dio/dio.dart';
import '../models/order_model.dart';

/// Order repository using Dio directly (without Retrofit)
/// This eliminates code generation compatibility issues
class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  /// Get orders with optional filters
  Future<List<OrderModel>> getOrders({
    int? page,
    int? perPage,
    String? customerId,
    String? status,
    String? paymentStatus,
    String? fromDate,
    String? toDate,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (page != null) queryParameters['page'] = page;
      if (perPage != null) queryParameters['per_page'] = perPage;
      if (customerId != null) queryParameters['customer_id'] = customerId;
      if (status != null) queryParameters['status'] = status;
      if (paymentStatus != null) queryParameters['payment_status'] = paymentStatus;
      if (fromDate != null) queryParameters['from_date'] = fromDate;
      if (toDate != null) queryParameters['to_date'] = toDate;
      if (search != null) queryParameters['search'] = search;
      if (sortBy != null) queryParameters['sort_by'] = sortBy;
      if (sortOrder != null) queryParameters['sort_order'] = sortOrder;

      final response = await _dio.get(
        '/orders',
        queryParameters: queryParameters,
      );

      // Handle both data: [...] and data: {data: [...]} response formats
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return (data as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get order by ID
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _dio.get('/orders/$id');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create new order
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update order
  Future<OrderModel> updateOrder(String id, UpdateOrderRequest request) async {
    try {
      final response = await _dio.put(
        '/orders/$id',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete order
  Future<void> deleteOrder(String id) async {
    try {
      await _dio.delete('/orders/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Confirm order (status transition)
  Future<OrderModel> confirmOrder(String id) async {
    try {
      final response = await _dio.post('/orders/$id/confirm');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Ship order (status transition)
  Future<OrderModel> shipOrder(String id) async {
    try {
      final response = await _dio.post('/orders/$id/ship');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Deliver order (status transition)
  Future<OrderModel> deliverOrder(String id) async {
    try {
      final response = await _dio.post('/orders/$id/deliver');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Cancel order (status transition)
  Future<OrderModel> cancelOrder(String id) async {
    try {
      final response = await _dio.post('/orders/$id/cancel');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Record payment for order
  Future<PaymentModel> recordPayment(
    String orderId,
    RecordPaymentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/orders/$orderId/payments',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return PaymentModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get payments for order
  Future<List<PaymentModel>> getOrderPayments(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId/payments');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return (data as List)
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to meaningful exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized: Please login again');
          case 403:
            return Exception('Forbidden: You don\'t have permission');
          case 404:
            return Exception('Not found: $message');
          case 500:
            return Exception('Server error: $message');
          default:
            return Exception('Error ($statusCode): $message');
        }

      case DioExceptionType.cancel:
        return Exception('Request cancelled');

      case DioExceptionType.connectionError:
        return Exception('No internet connection');

      default:
        return Exception('Unexpected error: ${error.message}');
    }
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error';

    if (data is Map) {
      // Try common error message fields
      if (data['error'] != null) return data['error'].toString();
      if (data['message'] != null) return data['message'].toString();
      if (data['detail'] != null) return data['detail'].toString();
    }

    return data.toString();
  }
}
