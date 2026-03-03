import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/business_model.dart';

/// Auth repository using Dio directly (without Retrofit)
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Step 1: Login — returns a generic JWT
  Future<GenericAuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = _extractData(response.data);
      return GenericAuthResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register new user — returns a generic JWT
  Future<GenericAuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      final data = _extractData(response.data);
      return GenericAuthResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get list of businesses the user belongs to (requires generic token)
  Future<List<BusinessModel>> getUserBusinesses(String genericToken) async {
    try {
      final response = await _dio.get(
        '/auth/businesses',
        options: Options(headers: {'Authorization': 'Bearer $genericToken'}),
      );

      final data = _extractData(response.data);
      final List<dynamic> list = data as List<dynamic>? ?? [];
      return list
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Step 2: Select a business — returns a scoped JWT
  Future<ScopedAuthResponse> useBusiness(
      String genericToken, String businessId) async {
    try {
      final response = await _dio.post(
        '/auth/use-business/$businessId',
        options: Options(headers: {'Authorization': 'Bearer $genericToken'}),
      );

      final data = _extractData(response.data);
      return ScopedAuthResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get current authenticated user (works with generic or scoped token)
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      final data = _extractData(response.data);
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData['data'] != null) {
      return responseData['data'];
    }
    return responseData;
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        switch (statusCode) {
          case 400:
            return Exception(message);
          case 401:
            return Exception('Invalid credentials');
          case 403:
            return Exception("You don't have permission");
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
