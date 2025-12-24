import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

@freezed
class CustomerModel with _$CustomerModel {
  const factory CustomerModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    String? phone,
    String? company,
    @JsonKey(name: 'customer_type') String? customerType,
    String? status,
    @JsonKey(name: 'billing_address') String? billingAddress,
    @JsonKey(name: 'billing_city') String? billingCity,
    @JsonKey(name: 'billing_state') String? billingState,
    @JsonKey(name: 'billing_postal_code') String? billingPostalCode,
    @JsonKey(name: 'billing_country') String? billingCountry,
    @JsonKey(name: 'shipping_address') String? shippingAddress,
    @JsonKey(name: 'shipping_city') String? shippingCity,
    @JsonKey(name: 'shipping_state') String? shippingState,
    @JsonKey(name: 'shipping_postal_code') String? shippingPostalCode,
    @JsonKey(name: 'shipping_country') String? shippingCountry,
    String? notes,
    Map<String, dynamic>? tags,
    @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CustomerModel;

  const CustomerModel._();

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  String get fullName => '$firstName $lastName';

  String get displayName => company?.isNotEmpty == true ? company! : fullName;

  String get billingAddressFull {
    final parts = [
      billingAddress,
      billingCity,
      billingState,
      billingPostalCode,
      billingCountry,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }

  String get shippingAddressFull {
    final parts = [
      shippingAddress,
      shippingCity,
      shippingState,
      shippingPostalCode,
      shippingCountry,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }
}

@freezed
class CreateCustomerRequest with _$CreateCustomerRequest {
  const factory CreateCustomerRequest({
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    String? phone,
    String? company,
    @JsonKey(name: 'customer_type') String? customerType,
    String? status,
    @JsonKey(name: 'billing_address') String? billingAddress,
    @JsonKey(name: 'billing_city') String? billingCity,
    @JsonKey(name: 'billing_state') String? billingState,
    @JsonKey(name: 'billing_postal_code') String? billingPostalCode,
    @JsonKey(name: 'billing_country') String? billingCountry,
    @JsonKey(name: 'shipping_address') String? shippingAddress,
    @JsonKey(name: 'shipping_city') String? shippingCity,
    @JsonKey(name: 'shipping_state') String? shippingState,
    @JsonKey(name: 'shipping_postal_code') String? shippingPostalCode,
    @JsonKey(name: 'shipping_country') String? shippingCountry,
    String? notes,
    Map<String, dynamic>? tags,
  }) = _CreateCustomerRequest;

  factory CreateCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCustomerRequestFromJson(json);
}

@freezed
class UpdateCustomerRequest with _$UpdateCustomerRequest {
  const factory UpdateCustomerRequest({
    String? email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? phone,
    String? company,
    @JsonKey(name: 'customer_type') String? customerType,
    String? status,
    @JsonKey(name: 'billing_address') String? billingAddress,
    @JsonKey(name: 'billing_city') String? billingCity,
    @JsonKey(name: 'billing_state') String? billingState,
    @JsonKey(name: 'billing_postal_code') String? billingPostalCode,
    @JsonKey(name: 'billing_country') String? billingCountry,
    @JsonKey(name: 'shipping_address') String? shippingAddress,
    @JsonKey(name: 'shipping_city') String? shippingCity,
    @JsonKey(name: 'shipping_state') String? shippingState,
    @JsonKey(name: 'shipping_postal_code') String? shippingPostalCode,
    @JsonKey(name: 'shipping_country') String? shippingCountry,
    String? notes,
    Map<String, dynamic>? tags,
  }) = _UpdateCustomerRequest;

  factory UpdateCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCustomerRequestFromJson(json);
}
