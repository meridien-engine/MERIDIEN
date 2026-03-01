import 'package:dio/dio.dart';
import '../models/location_model.dart';

/// Location repository using Dio directly.
/// Calls GET/POST/PUT/DELETE /api/v1/locations
class LocationRepository {
  final Dio _dio;

  LocationRepository(this._dio);

  /// List locations with pagination
  Future<List<LocationModel>> listLocations({int page = 1, int pageSize = 50}) async {
    try {
      final response = await _dio.get(
        '/locations',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return (data as List)
          .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get a single location by ID
  Future<LocationModel> getLocation(String id) async {
    try {
      final response = await _dio.get('/locations/$id');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return LocationModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new location
  Future<LocationModel> createLocation(CreateLocationRequest request) async {
    try {
      final response = await _dio.post('/locations', data: request.toJson());

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return LocationModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update an existing location
  Future<LocationModel> updateLocation(
      String id, UpdateLocationRequest request) async {
    try {
      final response = await _dio.put('/locations/$id', data: request.toJson());

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return LocationModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a location
  Future<void> deleteLocation(String id) async {
    try {
      await _dio.delete('/locations/$id');
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
