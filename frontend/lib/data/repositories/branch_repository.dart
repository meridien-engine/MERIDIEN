import 'package:dio/dio.dart';
import '../models/branch_model.dart';
import '../../core/constants/api_endpoints.dart';

class BranchRepository {
  final Dio _dio;

  BranchRepository(this._dio);

  Future<List<BranchModel>> listBranches(String businessId) async {
    try {
      final response = await _dio.get(ApiEndpoints.businessBranches(businessId));
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => BranchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BranchModel> getBranch(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.branchById(id));
      return BranchModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BranchModel> createBranch(
      String businessId, CreateBranchRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.businessBranches(businessId),
        data: request.toJson(),
      );
      return BranchModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BranchModel> updateBranch(String id, UpdateBranchRequest request) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.branchById(id),
        data: request.toJson(),
      );
      return BranchModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteBranch(String id) async {
    try {
      await _dio.delete(ApiEndpoints.branchById(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<BranchUserModel>> listAccess(String branchId) async {
    try {
      final response = await _dio.get(ApiEndpoints.branchUsers(branchId));
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => BranchUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> grantAccess(String branchId, String userId) async {
    try {
      await _dio.post(
        ApiEndpoints.branchUsers(branchId),
        data: {'user_id': userId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> revokeAccess(String branchId, String userId) async {
    try {
      await _dio.delete(ApiEndpoints.branchUserById(branchId, userId));
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
