import 'package:dio/dio.dart';
import '../models/product_model.dart';

/// Product repository using Dio directly (without Retrofit)
class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  /// Get products with optional filters
  Future<List<ProductModel>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? category,
    bool? active,
    bool? inStock,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (page != null) queryParameters['page'] = page;
      if (limit != null) queryParameters['limit'] = limit;
      if (search != null) queryParameters['search'] = search;
      if (category != null) queryParameters['category'] = category;
      if (active != null) queryParameters['active'] = active;
      if (inStock != null) queryParameters['in_stock'] = inStock;

      final response = await _dio.get(
        '/products',
        queryParameters: queryParameters,
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return (data as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get product by ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return ProductModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create new product
  Future<ProductModel> createProduct(CreateProductRequest request) async {
    try {
      final response = await _dio.post(
        '/products',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return ProductModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update product
  Future<ProductModel> updateProduct(
    String id,
    UpdateProductRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/products/$id',
        data: request.toJson(),
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return ProductModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
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
