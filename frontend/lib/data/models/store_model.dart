import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
class StoreModel with _$StoreModel {
  const StoreModel._();

  const factory StoreModel({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String name,
    String? address,
    String? city,
    String? phone,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  String get displayLocation {
    if (city != null && city!.isNotEmpty) return city!;
    return 'No location';
  }
}

@freezed
class CreateStoreRequest with _$CreateStoreRequest {
  const factory CreateStoreRequest({
    required String name,
    String? address,
    String? city,
    String? phone,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _CreateStoreRequest;

  factory CreateStoreRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStoreRequestFromJson(json);
}

@freezed
class UpdateStoreRequest with _$UpdateStoreRequest {
  const factory UpdateStoreRequest({
    String? name,
    String? address,
    String? city,
    String? phone,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _UpdateStoreRequest;

  factory UpdateStoreRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateStoreRequestFromJson(json);
}
