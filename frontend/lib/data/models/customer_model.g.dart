// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerModelImpl _$$CustomerModelImplFromJson(Map<String, dynamic> json) =>
    _$CustomerModelImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      customerType: json['customer_type'] as String?,
      status: json['status'] as String?,
      billingAddress: json['billing_address'] as String?,
      billingCity: json['billing_city'] as String?,
      billingState: json['billing_state'] as String?,
      billingPostalCode: json['billing_postal_code'] as String?,
      billingCountry: json['billing_country'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingState: json['shipping_state'] as String?,
      shippingPostalCode: json['shipping_postal_code'] as String?,
      shippingCountry: json['shipping_country'] as String?,
      notes: json['notes'] as String?,
      tags: json['tags'] as Map<String, dynamic>?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CustomerModelImplToJson(_$CustomerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'company': instance.company,
      'customer_type': instance.customerType,
      'status': instance.status,
      'billing_address': instance.billingAddress,
      'billing_city': instance.billingCity,
      'billing_state': instance.billingState,
      'billing_postal_code': instance.billingPostalCode,
      'billing_country': instance.billingCountry,
      'shipping_address': instance.shippingAddress,
      'shipping_city': instance.shippingCity,
      'shipping_state': instance.shippingState,
      'shipping_postal_code': instance.shippingPostalCode,
      'shipping_country': instance.shippingCountry,
      'notes': instance.notes,
      'tags': instance.tags,
      'custom_fields': instance.customFields,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$CreateCustomerRequestImpl _$$CreateCustomerRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateCustomerRequestImpl(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      customerType: json['customer_type'] as String?,
      status: json['status'] as String?,
      billingAddress: json['billing_address'] as String?,
      billingCity: json['billing_city'] as String?,
      billingState: json['billing_state'] as String?,
      billingPostalCode: json['billing_postal_code'] as String?,
      billingCountry: json['billing_country'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingState: json['shipping_state'] as String?,
      shippingPostalCode: json['shipping_postal_code'] as String?,
      shippingCountry: json['shipping_country'] as String?,
      notes: json['notes'] as String?,
      tags: json['tags'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CreateCustomerRequestImplToJson(
        _$CreateCustomerRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'company': instance.company,
      'customer_type': instance.customerType,
      'status': instance.status,
      'billing_address': instance.billingAddress,
      'billing_city': instance.billingCity,
      'billing_state': instance.billingState,
      'billing_postal_code': instance.billingPostalCode,
      'billing_country': instance.billingCountry,
      'shipping_address': instance.shippingAddress,
      'shipping_city': instance.shippingCity,
      'shipping_state': instance.shippingState,
      'shipping_postal_code': instance.shippingPostalCode,
      'shipping_country': instance.shippingCountry,
      'notes': instance.notes,
      'tags': instance.tags,
    };

_$UpdateCustomerRequestImpl _$$UpdateCustomerRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateCustomerRequestImpl(
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      customerType: json['customer_type'] as String?,
      status: json['status'] as String?,
      billingAddress: json['billing_address'] as String?,
      billingCity: json['billing_city'] as String?,
      billingState: json['billing_state'] as String?,
      billingPostalCode: json['billing_postal_code'] as String?,
      billingCountry: json['billing_country'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingState: json['shipping_state'] as String?,
      shippingPostalCode: json['shipping_postal_code'] as String?,
      shippingCountry: json['shipping_country'] as String?,
      notes: json['notes'] as String?,
      tags: json['tags'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$UpdateCustomerRequestImplToJson(
        _$UpdateCustomerRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'company': instance.company,
      'customer_type': instance.customerType,
      'status': instance.status,
      'billing_address': instance.billingAddress,
      'billing_city': instance.billingCity,
      'billing_state': instance.billingState,
      'billing_postal_code': instance.billingPostalCode,
      'billing_country': instance.billingCountry,
      'shipping_address': instance.shippingAddress,
      'shipping_city': instance.shippingCity,
      'shipping_state': instance.shippingState,
      'shipping_postal_code': instance.shippingPostalCode,
      'shipping_country': instance.shippingCountry,
      'notes': instance.notes,
      'tags': instance.tags,
    };
