import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_model.freezed.dart';
part 'business_model.g.dart';

@freezed
class BusinessModel with _$BusinessModel {
  const BusinessModel._();

  const factory BusinessModel({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'business_type') String? businessType,
    String? plan,
    String? status,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'owner_id') String? ownerId,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BusinessModel;

  factory BusinessModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessModelFromJson(json);

  bool get isActive => status == 'active';
  bool get isTrial => status == 'trial';
}

@freezed
class BusinessCategoryModel with _$BusinessCategoryModel {
  const factory BusinessCategoryModel({
    required String id,
    required String name,
    @JsonKey(name: 'name_ar') String? nameAr,
    required String slug,
  }) = _BusinessCategoryModel;

  factory BusinessCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessCategoryModelFromJson(json);
}
