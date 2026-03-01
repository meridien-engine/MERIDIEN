import 'package:dio/dio.dart';
import '../models/courier_model.dart';

/// Courier repository using Dio directly.
/// Calls GET/POST/PUT/DELETE /api/v1/couriers
class CourierRepository {
  final Dio _dio;

  CourierRepository(this._dio);

  /// List all couriers
  Future<List<CourierModel>> listCouriers({int page = 1, int pageSize = 50}) async {
    try {
      final response = await _dio.get(
        '/couriers',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return (data as List)
          .map((json) => CourierModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get a single courier by ID
  Future<CourierModel> getCourier(String id) async {
    try {
      final response = await _dio.get('/couriers/$id');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return CourierModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new courier
  Future<CourierModel> createCourier(CreateCourierRequest request) async {
    try {
      final response = await _dio.post('/couriers', data: request.toJson());

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return CourierModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update an existing courier
  Future<CourierModel> updateCourier(
      String id, UpdateCourierRequest request) async {
    try {
      final response = await _dio.put('/couriers/$id', data: request.toJson());

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return CourierModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a courier
  Future<void> deleteCourier(String id) async {
    try {
      await _dio.delete('/couriers/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get courier reconciliation report
  Future<List<CourierReconciliationModel>> getReconciliation({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (fromDate != null) queryParameters['from_date'] = fromDate;
      if (toDate != null) queryParameters['to_date'] = toDate;

      final response = await _dio.get(
        '/reports/courier-reconciliation',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return (data as List)
          .map((json) =>
              CourierReconciliationModel.fromJson(json as Map<String, dynamic>))
          .toList();
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
            return Exception('Forbidden: Only owners can access this resource');
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
