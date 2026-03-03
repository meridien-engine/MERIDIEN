import 'package:dio/dio.dart';
import '../models/business_model.dart';

/// Business repository using Dio directly
class BusinessRepository {
  final Dio _dio;

  BusinessRepository(this._dio);

  /// Create a new business (caller passes generic token explicitly)
  Future<BusinessModel> createBusiness({
    required String token,
    required String name,
    String? slug,
    String? businessType,
    String? categoryId,
    String? contactPhone,
    String? contactEmail,
  }) async {
    try {
      final response = await _dio.post(
        '/businesses',
        data: {
          'name': name,
          if (slug != null && slug.isNotEmpty) 'slug': slug,
          if (businessType != null && businessType.isNotEmpty)
            'business_type': businessType,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
          if (contactPhone != null && contactPhone.isNotEmpty)
            'contact_phone': contactPhone,
          if (contactEmail != null && contactEmail.isNotEmpty)
            'contact_email': contactEmail,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = _extractData(response.data);
      return BusinessModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all business categories
  Future<List<BusinessCategoryModel>> getCategories({String? token}) async {
    try {
      final response = await _dio.get(
        '/business-categories',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final data = _extractData(response.data);
      final List<dynamic> list = data as List<dynamic>? ?? [];
      return list
          .map((json) =>
              BusinessCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData['data'] != null) {
      return responseData['data'];
    }
    return responseData;
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.badResponse) {
      final message = _extractErrorMessage(error.response?.data);
      return Exception(message);
    }
    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection');
    }
    return Exception('Unexpected error: ${error.message}');
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error';
    if (data is Map) {
      if (data['error'] != null) return data['error'].toString();
      if (data['message'] != null) return data['message'].toString();
    }
    return data.toString();
  }
}
