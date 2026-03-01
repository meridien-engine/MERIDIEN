import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String city,
    @JsonKey(defaultValue: '') String? zone,
    @JsonKey(name: 'shipping_fee') required String shippingFee,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _LocationModel;

  const LocationModel._();

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  double get shippingFeeValue => double.tryParse(shippingFee) ?? 0.0;

  String get displayName {
    if (zone != null && zone!.isNotEmpty) {
      return '$city – $zone';
    }
    return city;
  }
}

// Create Location Request
@freezed
class CreateLocationRequest with _$CreateLocationRequest {
  const factory CreateLocationRequest({
    required String city,
    String? zone,
    @JsonKey(name: 'shipping_fee') required String shippingFee,
  }) = _CreateLocationRequest;

  factory CreateLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLocationRequestFromJson(json);
}

// Update Location Request
@freezed
class UpdateLocationRequest with _$UpdateLocationRequest {
  const factory UpdateLocationRequest({
    String? city,
    String? zone,
    @JsonKey(name: 'shipping_fee') String? shippingFee,
  }) = _UpdateLocationRequest;

  factory UpdateLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateLocationRequestFromJson(json);
}
