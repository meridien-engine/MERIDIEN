import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';

/// Auth repository using Dio directly (without Retrofit)
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Login user
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required String tenantSlug,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'tenant_slug': tenantSlug,
        },
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return AuthResponseModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String tenantSlug,
    String? role,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'tenant_slug': tenantSlug,
          if (role != null) 'role': role,
        },
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return AuthResponseModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get current authenticated user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return UserModel.fromJson(data as Map<String, dynamic>);
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
            return Exception('Invalid credentials');
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
