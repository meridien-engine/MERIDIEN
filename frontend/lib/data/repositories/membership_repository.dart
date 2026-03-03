import 'package:dio/dio.dart';
import '../models/membership_model.dart';
import '../models/business_model.dart';
import '../../core/constants/api_endpoints.dart';

class MembershipRepository {
  final Dio _dio;

  MembershipRepository(this._dio);

  // ─── Business Lookup ───────────────────────────────────────────────────────

  Future<BusinessModel> lookupBySlug(String slug) async {
    try {
      final response = await _dio.get(ApiEndpoints.businessBySlug(slug));
      return BusinessModel.fromJson(_extractData(response.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ─── Join Requests ─────────────────────────────────────────────────────────

  Future<JoinRequestModel> submitJoinRequest({
    required String businessSlug,
    String? message,
    String? role,
  }) async {
    try {
      final body = SubmitJoinRequestBody(
        businessSlug: businessSlug,
        message: message,
        role: role,
      );
      final response = await _dio.post(
        ApiEndpoints.joinRequests,
        data: body.toJson(),
      );
      return JoinRequestModel.fromJson(_extractData(response.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<JoinRequestModel>> listMyJoinRequests() async {
    try {
      final response = await _dio.get(ApiEndpoints.joinRequests);
      final data = _extractData(response.data) as List<dynamic>? ?? [];
      return data
          .map((j) => JoinRequestModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<JoinRequestModel>> listBusinessJoinRequests(String businessId) async {
    try {
      final response = await _dio.get(ApiEndpoints.businessJoinRequests(businessId));
      final data = _extractData(response.data) as List<dynamic>? ?? [];
      return data
          .map((j) => JoinRequestModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> approveJoinRequest(String businessId, String requestId, {String? role}) async {
    try {
      await _dio.post(
        ApiEndpoints.approveJoinRequest(businessId, requestId),
        data: role != null ? {'role': role} : {},
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> rejectJoinRequest(String businessId, String requestId) async {
    try {
      await _dio.post(ApiEndpoints.rejectJoinRequest(businessId, requestId));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ─── Invitations ───────────────────────────────────────────────────────────

  Future<InvitationModel> sendInvitation({
    required String businessId,
    required String email,
    required String role,
  }) async {
    try {
      final body = SendInvitationBody(email: email, role: role);
      final response = await _dio.post(
        ApiEndpoints.businessInvitations(businessId),
        data: body.toJson(),
      );
      return InvitationModel.fromJson(_extractData(response.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<InvitationModel>> listInvitations(String businessId) async {
    try {
      final response = await _dio.get(ApiEndpoints.businessInvitations(businessId));
      final data = _extractData(response.data) as List<dynamic>? ?? [];
      return data
          .map((j) => InvitationModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<InvitationModel> validateInvitation(String token) async {
    try {
      final response = await _dio.get(ApiEndpoints.invitationByToken(token));
      return InvitationModel.fromJson(_extractData(response.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<MemberModel> acceptInvitation(String token) async {
    try {
      final response = await _dio.post(ApiEndpoints.acceptInvitation(token));
      return MemberModel.fromJson(_extractData(response.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ─── Members ───────────────────────────────────────────────────────────────

  Future<List<MemberModel>> listMembers(String businessId) async {
    try {
      final response = await _dio.get(ApiEndpoints.businessMembers(businessId));
      final data = _extractData(response.data) as List<dynamic>? ?? [];
      return data
          .map((j) => MemberModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateMemberRole(String businessId, String userId, String role) async {
    try {
      final body = UpdateRoleBody(role: role);
      await _dio.patch(
        ApiEndpoints.memberById(businessId, userId),
        data: body.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> removeMember(String businessId, String userId) async {
    try {
      await _dio.delete(ApiEndpoints.memberById(businessId, userId));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData['data'] != null) {
      return responseData['data'];
    }
    return responseData;
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.badResponse) {
      final data = error.response?.data;
      if (data is Map) {
        return data['error']?.toString() ??
            data['message']?.toString() ??
            'An error occurred';
      }
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection';
    }
    return error.message ?? 'Unexpected error';
  }
}
