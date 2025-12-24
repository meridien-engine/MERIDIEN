import 'package:dio/dio.dart';
import '../models/customer_model.dart';

/// Customer repository using Dio directly (without Retrofit)
class CustomerRepository {
  final Dio _dio;

  CustomerRepository(this._dio);

  /// Get customers with optional filters
  Future<List<CustomerModel>> getCustomers({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? customerType,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (page != null) queryParameters['page'] = page;
      if (limit != null) queryParameters['limit'] = limit;
      if (search != null) queryParameters['search'] = search;
      if (status != null) queryParameters['status'] = status;
      if (customerType != null) queryParameters['customer_type'] = customerType;

      final response = await _dio.get(
        '/customers',
        queryParameters: queryParameters,
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return (data as List)
          .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get customer by ID
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final response = await _dio.get('/customers/$id');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return CustomerModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create new customer
  Future<CustomerModel> createCustomer(CreateCustomerRequest request) async {
    try {
      final response = await _dio.post(
        '/customers',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return CustomerModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update customer
  Future<CustomerModel> updateCustomer(
    String id,
    UpdateCustomerRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/customers/$id',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return CustomerModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete customer
  Future<void> deleteCustomer(String id) async {
    try {
      await _dio.delete('/customers/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

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

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error';

    if (data is Map) {
      if (data['error'] != null) return data['error'].toString();
      if (data['message'] != null) return data['message'].toString();
      if (data['detail'] != null) return data['detail'].toString();
    }

    return data.toString();
  }
}
