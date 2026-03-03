import 'package:dio/dio.dart';
import '../models/store_model.dart';
import '../../core/constants/api_endpoints.dart';

class StoreRepository {
  final Dio _dio;

  StoreRepository(this._dio);

  Future<List<StoreModel>> listStores({int page = 1, int pageSize = 50}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.stores,
        queryParameters: {'page': page, 'limit': pageSize},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StoreModel> createStore(CreateStoreRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.stores,
        data: request.toJson(),
      );
      return StoreModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StoreModel> updateStore(String id, UpdateStoreRequest request) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.storeById(id),
        data: request.toJson(),
      );
      return StoreModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteStore(String id) async {
    try {
      await _dio.delete(ApiEndpoints.storeById(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['error'] ?? data['message'];
      if (msg != null) return Exception(msg.toString());
    }
    return Exception(e.message ?? 'Network error');
  }
}
