import 'package:dio/dio.dart';
import '../models/pos_model.dart';
import '../models/product_model.dart';
import '../../core/constants/api_endpoints.dart';

class PosRepository {
  final Dio _dio;
  PosRepository(this._dio);

  Future<PosSessionModel> openSession(String openingFloat) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.posSessions,
        data: {'opening_float': openingFloat},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return PosSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PosSessionModel> closeSession(String id, String closingCash) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.closePosSession(id),
        data: {'closing_cash': closingCash},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return PosSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PosSessionModel?> getCurrentSession() async {
    try {
      final response = await _dio.get(ApiEndpoints.posCurrentSession);
      final data = response.data['data'] as Map<String, dynamic>;
      return PosSessionModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  Future<PosSessionModel> getSession(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.posSessionById(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return PosSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<PosSessionModel>> listSessions({
    String? status,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null) params['status'] = status;
      final response = await _dio.get(
        ApiEndpoints.posSessions,
        queryParameters: params,
      );
      final rawData = response.data['data'] ?? [];
      return (rawData as List)
          .map((e) => PosSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ProductModel> lookupProduct(String query) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.productLookup,
        queryParameters: {'q': query},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PosCheckoutResult> checkout(PosCheckoutRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.posCheckout,
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return PosCheckoutResult.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      return e.response!.data['error'] as String? ??
          e.response!.data['message'] as String? ??
          'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}
