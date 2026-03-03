import 'package:dio/dio.dart';
import '../models/branch_inventory_model.dart';
import '../../core/constants/api_endpoints.dart';

class BranchInventoryRepository {
  final Dio _dio;

  BranchInventoryRepository(this._dio);

  Future<List<BranchInventoryModel>> listByBranch(
    String branchId, {
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.branchProducts(branchId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) =>
              BranchInventoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BranchInventoryModel> activate(
    String branchId,
    String productId,
    ActivateProductRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.branchProductById(branchId, productId),
        data: request.toJson(),
      );
      return BranchInventoryModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BranchInventoryModel> update(
    String branchId,
    String productId,
    UpdateInventoryRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.branchProductById(branchId, productId),
        data: request.toJson(),
      );
      return BranchInventoryModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deactivate(String branchId, String productId) async {
    try {
      await _dio.delete(ApiEndpoints.branchProductById(branchId, productId));
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
