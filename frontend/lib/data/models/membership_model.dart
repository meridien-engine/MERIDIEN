import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';
import 'business_model.dart';

part 'membership_model.freezed.dart';
part 'membership_model.g.dart';

// ─── Join Request ─────────────────────────────────────────────────────────────

@freezed
class JoinRequestModel with _$JoinRequestModel {
  const JoinRequestModel._();

  const factory JoinRequestModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'business_id') required String businessId,
    @Default('pending') String status,
    String? message,
    String? role,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    UserModel? user,
    BusinessModel? business,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _JoinRequestModel;

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestModelFromJson(json);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get displayName => user?.fullName ?? userId;
  String get displayBusiness => business?.name ?? businessId;
}

// ─── Invitation ───────────────────────────────────────────────────────────────

@freezed
class InvitationModel with _$InvitationModel {
  const InvitationModel._();

  const factory InvitationModel({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String email,
    @Default('viewer') String role,
    required String token,
    @JsonKey(name: 'invited_by') String? invitedBy,
    @Default('pending') String status,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'accepted_at') DateTime? acceptedAt,
    BusinessModel? business,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _InvitationModel;

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isExpired =>
      status == 'expired' ||
      (expiresAt != null && DateTime.now().isAfter(expiresAt!));
  String get displayBusiness => business?.name ?? businessId;
}

// ─── Member (UserBusinessMembership) ─────────────────────────────────────────

@freezed
class MemberModel with _$MemberModel {
  const MemberModel._();

  const factory MemberModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'business_id') required String businessId,
    @Default('viewer') String role,
    @Default('active') String status,
    @JsonKey(name: 'invited_by') String? invitedBy,
    UserModel? user,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  bool get isOwner => role == 'owner';
  bool get isActive => status == 'active';
  String get displayName => user?.fullName ?? userId;
  String get displayEmail => user?.email ?? '';
}

// ─── Request bodies ───────────────────────────────────────────────────────────

@freezed
class SubmitJoinRequestBody with _$SubmitJoinRequestBody {
  const factory SubmitJoinRequestBody({
    @JsonKey(name: 'business_slug') required String businessSlug,
    String? message,
    String? role,
  }) = _SubmitJoinRequestBody;

  factory SubmitJoinRequestBody.fromJson(Map<String, dynamic> json) =>
      _$SubmitJoinRequestBodyFromJson(json);
}

@freezed
class SendInvitationBody with _$SendInvitationBody {
  const factory SendInvitationBody({
    required String email,
    required String role,
  }) = _SendInvitationBody;

  factory SendInvitationBody.fromJson(Map<String, dynamic> json) =>
      _$SendInvitationBodyFromJson(json);
}

@freezed
class UpdateRoleBody with _$UpdateRoleBody {
  const factory UpdateRoleBody({
    required String role,
  }) = _UpdateRoleBody;

  factory UpdateRoleBody.fromJson(Map<String, dynamic> json) =>
      _$UpdateRoleBodyFromJson(json);
}
