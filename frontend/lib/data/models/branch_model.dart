import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'branch_model.freezed.dart';
part 'branch_model.g.dart';

@freezed
class BranchModel with _$BranchModel {
  const BranchModel._();

  const factory BranchModel({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String name,
    String? address,
    String? city,
    String? phone,
    @JsonKey(name: 'is_main') @Default(false) bool isMain,
    @Default('active') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BranchModel;

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);

  bool get isActive => status == 'active';
}

@freezed
class CreateBranchRequest with _$CreateBranchRequest {
  const factory CreateBranchRequest({
    required String name,
    String? address,
    String? city,
    String? phone,
  }) = _CreateBranchRequest;

  factory CreateBranchRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBranchRequestFromJson(json);
}

@freezed
class UpdateBranchRequest with _$UpdateBranchRequest {
  const factory UpdateBranchRequest({
    String? name,
    String? address,
    String? city,
    String? phone,
    String? status,
  }) = _UpdateBranchRequest;

  factory UpdateBranchRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBranchRequestFromJson(json);
}

@freezed
class BranchUserModel with _$BranchUserModel {
  const factory BranchUserModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'granted_by') String? grantedBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    UserModel? user,
  }) = _BranchUserModel;

  factory BranchUserModel.fromJson(Map<String, dynamic> json) =>
      _$BranchUserModelFromJson(json);
}
