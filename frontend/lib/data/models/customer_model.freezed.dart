// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) {
  return _CustomerModel.fromJson(json);
}

/// @nodoc
mixin _$CustomerModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_type')
  String? get customerType => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_address')
  String? get billingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_city')
  String? get billingCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_state')
  String? get billingState => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_postal_code')
  String? get billingPostalCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_country')
  String? get billingCountry => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_city')
  String? get shippingCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_state')
  String? get shippingState => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_postal_code')
  String? get shippingPostalCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_country')
  String? get shippingCountry => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_fields')
  Map<String, dynamic>? get customFields => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomerModelCopyWith<CustomerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerModelCopyWith<$Res> {
  factory $CustomerModelCopyWith(
          CustomerModel value, $Res Function(CustomerModel) then) =
      _$CustomerModelCopyWithImpl<$Res, CustomerModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
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
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$CustomerModelCopyWithImpl<$Res, $Val extends CustomerModel>
    implements $CustomerModelCopyWith<$Res> {
  _$CustomerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phone = freezed,
    Object? company = freezed,
    Object? customerType = freezed,
    Object? status = freezed,
    Object? billingAddress = freezed,
    Object? billingCity = freezed,
    Object? billingState = freezed,
    Object? billingPostalCode = freezed,
    Object? billingCountry = freezed,
    Object? shippingAddress = freezed,
    Object? shippingCity = freezed,
    Object? shippingState = freezed,
    Object? shippingPostalCode = freezed,
    Object? shippingCountry = freezed,
    Object? notes = freezed,
    Object? tags = freezed,
    Object? customFields = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCity: freezed == billingCity
          ? _value.billingCity
          : billingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      billingState: freezed == billingState
          ? _value.billingState
          : billingState // ignore: cast_nullable_to_non_nullable
              as String?,
      billingPostalCode: freezed == billingPostalCode
          ? _value.billingPostalCode
          : billingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCountry: freezed == billingCountry
          ? _value.billingCountry
          : billingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCity: freezed == shippingCity
          ? _value.shippingCity
          : shippingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingState: freezed == shippingState
          ? _value.shippingState
          : shippingState // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingPostalCode: freezed == shippingPostalCode
          ? _value.shippingPostalCode
          : shippingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCountry: freezed == shippingCountry
          ? _value.shippingCountry
          : shippingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      customFields: freezed == customFields
          ? _value.customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerModelImplCopyWith<$Res>
    implements $CustomerModelCopyWith<$Res> {
  factory _$$CustomerModelImplCopyWith(
          _$CustomerModelImpl value, $Res Function(_$CustomerModelImpl) then) =
      __$$CustomerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
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
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$CustomerModelImplCopyWithImpl<$Res>
    extends _$CustomerModelCopyWithImpl<$Res, _$CustomerModelImpl>
    implements _$$CustomerModelImplCopyWith<$Res> {
  __$$CustomerModelImplCopyWithImpl(
      _$CustomerModelImpl _value, $Res Function(_$CustomerModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phone = freezed,
    Object? company = freezed,
    Object? customerType = freezed,
    Object? status = freezed,
    Object? billingAddress = freezed,
    Object? billingCity = freezed,
    Object? billingState = freezed,
    Object? billingPostalCode = freezed,
    Object? billingCountry = freezed,
    Object? shippingAddress = freezed,
    Object? shippingCity = freezed,
    Object? shippingState = freezed,
    Object? shippingPostalCode = freezed,
    Object? shippingCountry = freezed,
    Object? notes = freezed,
    Object? tags = freezed,
    Object? customFields = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CustomerModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCity: freezed == billingCity
          ? _value.billingCity
          : billingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      billingState: freezed == billingState
          ? _value.billingState
          : billingState // ignore: cast_nullable_to_non_nullable
              as String?,
      billingPostalCode: freezed == billingPostalCode
          ? _value.billingPostalCode
          : billingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCountry: freezed == billingCountry
          ? _value.billingCountry
          : billingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCity: freezed == shippingCity
          ? _value.shippingCity
          : shippingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingState: freezed == shippingState
          ? _value.shippingState
          : shippingState // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingPostalCode: freezed == shippingPostalCode
          ? _value.shippingPostalCode
          : shippingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCountry: freezed == shippingCountry
          ? _value.shippingCountry
          : shippingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      customFields: freezed == customFields
          ? _value._customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerModelImpl extends _CustomerModel {
  const _$CustomerModelImpl(
      {required this.id,
      @JsonKey(name: 'tenant_id') required this.tenantId,
      required this.email,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      this.phone,
      this.company,
      @JsonKey(name: 'customer_type') this.customerType,
      this.status,
      @JsonKey(name: 'billing_address') this.billingAddress,
      @JsonKey(name: 'billing_city') this.billingCity,
      @JsonKey(name: 'billing_state') this.billingState,
      @JsonKey(name: 'billing_postal_code') this.billingPostalCode,
      @JsonKey(name: 'billing_country') this.billingCountry,
      @JsonKey(name: 'shipping_address') this.shippingAddress,
      @JsonKey(name: 'shipping_city') this.shippingCity,
      @JsonKey(name: 'shipping_state') this.shippingState,
      @JsonKey(name: 'shipping_postal_code') this.shippingPostalCode,
      @JsonKey(name: 'shipping_country') this.shippingCountry,
      this.notes,
      final Map<String, dynamic>? tags,
      @JsonKey(name: 'custom_fields') final Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _tags = tags,
        _customFields = customFields,
        super._();

  factory _$CustomerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  final String email;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  final String? phone;
  @override
  final String? company;
  @override
  @JsonKey(name: 'customer_type')
  final String? customerType;
  @override
  final String? status;
  @override
  @JsonKey(name: 'billing_address')
  final String? billingAddress;
  @override
  @JsonKey(name: 'billing_city')
  final String? billingCity;
  @override
  @JsonKey(name: 'billing_state')
  final String? billingState;
  @override
  @JsonKey(name: 'billing_postal_code')
  final String? billingPostalCode;
  @override
  @JsonKey(name: 'billing_country')
  final String? billingCountry;
  @override
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;
  @override
  @JsonKey(name: 'shipping_city')
  final String? shippingCity;
  @override
  @JsonKey(name: 'shipping_state')
  final String? shippingState;
  @override
  @JsonKey(name: 'shipping_postal_code')
  final String? shippingPostalCode;
  @override
  @JsonKey(name: 'shipping_country')
  final String? shippingCountry;
  @override
  final String? notes;
  final Map<String, dynamic>? _tags;
  @override
  Map<String, dynamic>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableMapView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _customFields;
  @override
  @JsonKey(name: 'custom_fields')
  Map<String, dynamic>? get customFields {
    final value = _customFields;
    if (value == null) return null;
    if (_customFields is EqualUnmodifiableMapView) return _customFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CustomerModel(id: $id, tenantId: $tenantId, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, company: $company, customerType: $customerType, status: $status, billingAddress: $billingAddress, billingCity: $billingCity, billingState: $billingState, billingPostalCode: $billingPostalCode, billingCountry: $billingCountry, shippingAddress: $shippingAddress, shippingCity: $shippingCity, shippingState: $shippingState, shippingPostalCode: $shippingPostalCode, shippingCountry: $shippingCountry, notes: $notes, tags: $tags, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.customerType, customerType) ||
                other.customerType == customerType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.billingAddress, billingAddress) ||
                other.billingAddress == billingAddress) &&
            (identical(other.billingCity, billingCity) ||
                other.billingCity == billingCity) &&
            (identical(other.billingState, billingState) ||
                other.billingState == billingState) &&
            (identical(other.billingPostalCode, billingPostalCode) ||
                other.billingPostalCode == billingPostalCode) &&
            (identical(other.billingCountry, billingCountry) ||
                other.billingCountry == billingCountry) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            (identical(other.shippingCity, shippingCity) ||
                other.shippingCity == shippingCity) &&
            (identical(other.shippingState, shippingState) ||
                other.shippingState == shippingState) &&
            (identical(other.shippingPostalCode, shippingPostalCode) ||
                other.shippingPostalCode == shippingPostalCode) &&
            (identical(other.shippingCountry, shippingCountry) ||
                other.shippingCountry == shippingCountry) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._customFields, _customFields) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tenantId,
        email,
        firstName,
        lastName,
        phone,
        company,
        customerType,
        status,
        billingAddress,
        billingCity,
        billingState,
        billingPostalCode,
        billingCountry,
        shippingAddress,
        shippingCity,
        shippingState,
        shippingPostalCode,
        shippingCountry,
        notes,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_customFields),
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerModelImplCopyWith<_$CustomerModelImpl> get copyWith =>
      __$$CustomerModelImplCopyWithImpl<_$CustomerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerModelImplToJson(
      this,
    );
  }
}

abstract class _CustomerModel extends CustomerModel {
  const factory _CustomerModel(
      {required final String id,
      @JsonKey(name: 'tenant_id') required final String tenantId,
      required final String email,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'last_name') required final String lastName,
      final String? phone,
      final String? company,
      @JsonKey(name: 'customer_type') final String? customerType,
      final String? status,
      @JsonKey(name: 'billing_address') final String? billingAddress,
      @JsonKey(name: 'billing_city') final String? billingCity,
      @JsonKey(name: 'billing_state') final String? billingState,
      @JsonKey(name: 'billing_postal_code') final String? billingPostalCode,
      @JsonKey(name: 'billing_country') final String? billingCountry,
      @JsonKey(name: 'shipping_address') final String? shippingAddress,
      @JsonKey(name: 'shipping_city') final String? shippingCity,
      @JsonKey(name: 'shipping_state') final String? shippingState,
      @JsonKey(name: 'shipping_postal_code') final String? shippingPostalCode,
      @JsonKey(name: 'shipping_country') final String? shippingCountry,
      final String? notes,
      final Map<String, dynamic>? tags,
      @JsonKey(name: 'custom_fields') final Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$CustomerModelImpl;
  const _CustomerModel._() : super._();

  factory _CustomerModel.fromJson(Map<String, dynamic> json) =
      _$CustomerModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  String get email;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  String? get phone;
  @override
  String? get company;
  @override
  @JsonKey(name: 'customer_type')
  String? get customerType;
  @override
  String? get status;
  @override
  @JsonKey(name: 'billing_address')
  String? get billingAddress;
  @override
  @JsonKey(name: 'billing_city')
  String? get billingCity;
  @override
  @JsonKey(name: 'billing_state')
  String? get billingState;
  @override
  @JsonKey(name: 'billing_postal_code')
  String? get billingPostalCode;
  @override
  @JsonKey(name: 'billing_country')
  String? get billingCountry;
  @override
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress;
  @override
  @JsonKey(name: 'shipping_city')
  String? get shippingCity;
  @override
  @JsonKey(name: 'shipping_state')
  String? get shippingState;
  @override
  @JsonKey(name: 'shipping_postal_code')
  String? get shippingPostalCode;
  @override
  @JsonKey(name: 'shipping_country')
  String? get shippingCountry;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get tags;
  @override
  @JsonKey(name: 'custom_fields')
  Map<String, dynamic>? get customFields;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$CustomerModelImplCopyWith<_$CustomerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateCustomerRequest _$CreateCustomerRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateCustomerRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateCustomerRequest {
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_type')
  String? get customerType => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_address')
  String? get billingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_city')
  String? get billingCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_state')
  String? get billingState => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_postal_code')
  String? get billingPostalCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_country')
  String? get billingCountry => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_city')
  String? get shippingCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_state')
  String? get shippingState => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_postal_code')
  String? get shippingPostalCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_country')
  String? get shippingCountry => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateCustomerRequestCopyWith<CreateCustomerRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCustomerRequestCopyWith<$Res> {
  factory $CreateCustomerRequestCopyWith(CreateCustomerRequest value,
          $Res Function(CreateCustomerRequest) then) =
      _$CreateCustomerRequestCopyWithImpl<$Res, CreateCustomerRequest>;
  @useResult
  $Res call(
      {String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
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
      Map<String, dynamic>? tags});
}

/// @nodoc
class _$CreateCustomerRequestCopyWithImpl<$Res,
        $Val extends CreateCustomerRequest>
    implements $CreateCustomerRequestCopyWith<$Res> {
  _$CreateCustomerRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phone = freezed,
    Object? company = freezed,
    Object? customerType = freezed,
    Object? status = freezed,
    Object? billingAddress = freezed,
    Object? billingCity = freezed,
    Object? billingState = freezed,
    Object? billingPostalCode = freezed,
    Object? billingCountry = freezed,
    Object? shippingAddress = freezed,
    Object? shippingCity = freezed,
    Object? shippingState = freezed,
    Object? shippingPostalCode = freezed,
    Object? shippingCountry = freezed,
    Object? notes = freezed,
    Object? tags = freezed,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCity: freezed == billingCity
          ? _value.billingCity
          : billingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      billingState: freezed == billingState
          ? _value.billingState
          : billingState // ignore: cast_nullable_to_non_nullable
              as String?,
      billingPostalCode: freezed == billingPostalCode
          ? _value.billingPostalCode
          : billingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCountry: freezed == billingCountry
          ? _value.billingCountry
          : billingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCity: freezed == shippingCity
          ? _value.shippingCity
          : shippingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingState: freezed == shippingState
          ? _value.shippingState
          : shippingState // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingPostalCode: freezed == shippingPostalCode
          ? _value.shippingPostalCode
          : shippingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCountry: freezed == shippingCountry
          ? _value.shippingCountry
          : shippingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateCustomerRequestImplCopyWith<$Res>
    implements $CreateCustomerRequestCopyWith<$Res> {
  factory _$$CreateCustomerRequestImplCopyWith(
          _$CreateCustomerRequestImpl value,
          $Res Function(_$CreateCustomerRequestImpl) then) =
      __$$CreateCustomerRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
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
      Map<String, dynamic>? tags});
}

/// @nodoc
class __$$CreateCustomerRequestImplCopyWithImpl<$Res>
    extends _$CreateCustomerRequestCopyWithImpl<$Res,
        _$CreateCustomerRequestImpl>
    implements _$$CreateCustomerRequestImplCopyWith<$Res> {
  __$$CreateCustomerRequestImplCopyWithImpl(_$CreateCustomerRequestImpl _value,
      $Res Function(_$CreateCustomerRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phone = freezed,
    Object? company = freezed,
    Object? customerType = freezed,
    Object? status = freezed,
    Object? billingAddress = freezed,
    Object? billingCity = freezed,
    Object? billingState = freezed,
    Object? billingPostalCode = freezed,
    Object? billingCountry = freezed,
    Object? shippingAddress = freezed,
    Object? shippingCity = freezed,
    Object? shippingState = freezed,
    Object? shippingPostalCode = freezed,
    Object? shippingCountry = freezed,
    Object? notes = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$CreateCustomerRequestImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCity: freezed == billingCity
          ? _value.billingCity
          : billingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      billingState: freezed == billingState
          ? _value.billingState
          : billingState // ignore: cast_nullable_to_non_nullable
              as String?,
      billingPostalCode: freezed == billingPostalCode
          ? _value.billingPostalCode
          : billingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCountry: freezed == billingCountry
          ? _value.billingCountry
          : billingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCity: freezed == shippingCity
          ? _value.shippingCity
          : shippingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingState: freezed == shippingState
          ? _value.shippingState
          : shippingState // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingPostalCode: freezed == shippingPostalCode
          ? _value.shippingPostalCode
          : shippingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCountry: freezed == shippingCountry
          ? _value.shippingCountry
          : shippingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateCustomerRequestImpl implements _CreateCustomerRequest {
  const _$CreateCustomerRequestImpl(
      {required this.email,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      this.phone,
      this.company,
      @JsonKey(name: 'customer_type') this.customerType,
      this.status,
      @JsonKey(name: 'billing_address') this.billingAddress,
      @JsonKey(name: 'billing_city') this.billingCity,
      @JsonKey(name: 'billing_state') this.billingState,
      @JsonKey(name: 'billing_postal_code') this.billingPostalCode,
      @JsonKey(name: 'billing_country') this.billingCountry,
      @JsonKey(name: 'shipping_address') this.shippingAddress,
      @JsonKey(name: 'shipping_city') this.shippingCity,
      @JsonKey(name: 'shipping_state') this.shippingState,
      @JsonKey(name: 'shipping_postal_code') this.shippingPostalCode,
      @JsonKey(name: 'shipping_country') this.shippingCountry,
      this.notes,
      final Map<String, dynamic>? tags})
      : _tags = tags;

  factory _$CreateCustomerRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateCustomerRequestImplFromJson(json);

  @override
  final String email;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  final String? phone;
  @override
  final String? company;
  @override
  @JsonKey(name: 'customer_type')
  final String? customerType;
  @override
  final String? status;
  @override
  @JsonKey(name: 'billing_address')
  final String? billingAddress;
  @override
  @JsonKey(name: 'billing_city')
  final String? billingCity;
  @override
  @JsonKey(name: 'billing_state')
  final String? billingState;
  @override
  @JsonKey(name: 'billing_postal_code')
  final String? billingPostalCode;
  @override
  @JsonKey(name: 'billing_country')
  final String? billingCountry;
  @override
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;
  @override
  @JsonKey(name: 'shipping_city')
  final String? shippingCity;
  @override
  @JsonKey(name: 'shipping_state')
  final String? shippingState;
  @override
  @JsonKey(name: 'shipping_postal_code')
  final String? shippingPostalCode;
  @override
  @JsonKey(name: 'shipping_country')
  final String? shippingCountry;
  @override
  final String? notes;
  final Map<String, dynamic>? _tags;
  @override
  Map<String, dynamic>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableMapView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CreateCustomerRequest(email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, company: $company, customerType: $customerType, status: $status, billingAddress: $billingAddress, billingCity: $billingCity, billingState: $billingState, billingPostalCode: $billingPostalCode, billingCountry: $billingCountry, shippingAddress: $shippingAddress, shippingCity: $shippingCity, shippingState: $shippingState, shippingPostalCode: $shippingPostalCode, shippingCountry: $shippingCountry, notes: $notes, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCustomerRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.customerType, customerType) ||
                other.customerType == customerType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.billingAddress, billingAddress) ||
                other.billingAddress == billingAddress) &&
            (identical(other.billingCity, billingCity) ||
                other.billingCity == billingCity) &&
            (identical(other.billingState, billingState) ||
                other.billingState == billingState) &&
            (identical(other.billingPostalCode, billingPostalCode) ||
                other.billingPostalCode == billingPostalCode) &&
            (identical(other.billingCountry, billingCountry) ||
                other.billingCountry == billingCountry) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            (identical(other.shippingCity, shippingCity) ||
                other.shippingCity == shippingCity) &&
            (identical(other.shippingState, shippingState) ||
                other.shippingState == shippingState) &&
            (identical(other.shippingPostalCode, shippingPostalCode) ||
                other.shippingPostalCode == shippingPostalCode) &&
            (identical(other.shippingCountry, shippingCountry) ||
                other.shippingCountry == shippingCountry) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        email,
        firstName,
        lastName,
        phone,
        company,
        customerType,
        status,
        billingAddress,
        billingCity,
        billingState,
        billingPostalCode,
        billingCountry,
        shippingAddress,
        shippingCity,
        shippingState,
        shippingPostalCode,
        shippingCountry,
        notes,
        const DeepCollectionEquality().hash(_tags)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCustomerRequestImplCopyWith<_$CreateCustomerRequestImpl>
      get copyWith => __$$CreateCustomerRequestImplCopyWithImpl<
          _$CreateCustomerRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateCustomerRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateCustomerRequest implements CreateCustomerRequest {
  const factory _CreateCustomerRequest(
      {required final String email,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'last_name') required final String lastName,
      final String? phone,
      final String? company,
      @JsonKey(name: 'customer_type') final String? customerType,
      final String? status,
      @JsonKey(name: 'billing_address') final String? billingAddress,
      @JsonKey(name: 'billing_city') final String? billingCity,
      @JsonKey(name: 'billing_state') final String? billingState,
      @JsonKey(name: 'billing_postal_code') final String? billingPostalCode,
      @JsonKey(name: 'billing_country') final String? billingCountry,
      @JsonKey(name: 'shipping_address') final String? shippingAddress,
      @JsonKey(name: 'shipping_city') final String? shippingCity,
      @JsonKey(name: 'shipping_state') final String? shippingState,
      @JsonKey(name: 'shipping_postal_code') final String? shippingPostalCode,
      @JsonKey(name: 'shipping_country') final String? shippingCountry,
      final String? notes,
      final Map<String, dynamic>? tags}) = _$CreateCustomerRequestImpl;

  factory _CreateCustomerRequest.fromJson(Map<String, dynamic> json) =
      _$CreateCustomerRequestImpl.fromJson;

  @override
  String get email;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  String? get phone;
  @override
  String? get company;
  @override
  @JsonKey(name: 'customer_type')
  String? get customerType;
  @override
  String? get status;
  @override
  @JsonKey(name: 'billing_address')
  String? get billingAddress;
  @override
  @JsonKey(name: 'billing_city')
  String? get billingCity;
  @override
  @JsonKey(name: 'billing_state')
  String? get billingState;
  @override
  @JsonKey(name: 'billing_postal_code')
  String? get billingPostalCode;
  @override
  @JsonKey(name: 'billing_country')
  String? get billingCountry;
  @override
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress;
  @override
  @JsonKey(name: 'shipping_city')
  String? get shippingCity;
  @override
  @JsonKey(name: 'shipping_state')
  String? get shippingState;
  @override
  @JsonKey(name: 'shipping_postal_code')
  String? get shippingPostalCode;
  @override
  @JsonKey(name: 'shipping_country')
  String? get shippingCountry;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get tags;
  @override
  @JsonKey(ignore: true)
  _$$CreateCustomerRequestImplCopyWith<_$CreateCustomerRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateCustomerRequest _$UpdateCustomerRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateCustomerRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateCustomerRequest {
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_type')
  String? get customerType => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_address')
  String? get billingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_city')
  String? get billingCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_state')
  String? get billingState => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_postal_code')
  String? get billingPostalCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_country')
  String? get billingCountry => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_city')
  String? get shippingCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_state')
  String? get shippingState => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_postal_code')
  String? get shippingPostalCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_country')
  String? get shippingCountry => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateCustomerRequestCopyWith<UpdateCustomerRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateCustomerRequestCopyWith<$Res> {
  factory $UpdateCustomerRequestCopyWith(UpdateCustomerRequest value,
          $Res Function(UpdateCustomerRequest) then) =
      _$UpdateCustomerRequestCopyWithImpl<$Res, UpdateCustomerRequest>;
  @useResult
  $Res call(
      {String? email,
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
      Map<String, dynamic>? tags});
}

/// @nodoc
class _$UpdateCustomerRequestCopyWithImpl<$Res,
        $Val extends UpdateCustomerRequest>
    implements $UpdateCustomerRequestCopyWith<$Res> {
  _$UpdateCustomerRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? customerType = freezed,
    Object? status = freezed,
    Object? billingAddress = freezed,
    Object? billingCity = freezed,
    Object? billingState = freezed,
    Object? billingPostalCode = freezed,
    Object? billingCountry = freezed,
    Object? shippingAddress = freezed,
    Object? shippingCity = freezed,
    Object? shippingState = freezed,
    Object? shippingPostalCode = freezed,
    Object? shippingCountry = freezed,
    Object? notes = freezed,
    Object? tags = freezed,
  }) {
    return _then(_value.copyWith(
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCity: freezed == billingCity
          ? _value.billingCity
          : billingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      billingState: freezed == billingState
          ? _value.billingState
          : billingState // ignore: cast_nullable_to_non_nullable
              as String?,
      billingPostalCode: freezed == billingPostalCode
          ? _value.billingPostalCode
          : billingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCountry: freezed == billingCountry
          ? _value.billingCountry
          : billingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCity: freezed == shippingCity
          ? _value.shippingCity
          : shippingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingState: freezed == shippingState
          ? _value.shippingState
          : shippingState // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingPostalCode: freezed == shippingPostalCode
          ? _value.shippingPostalCode
          : shippingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCountry: freezed == shippingCountry
          ? _value.shippingCountry
          : shippingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateCustomerRequestImplCopyWith<$Res>
    implements $UpdateCustomerRequestCopyWith<$Res> {
  factory _$$UpdateCustomerRequestImplCopyWith(
          _$UpdateCustomerRequestImpl value,
          $Res Function(_$UpdateCustomerRequestImpl) then) =
      __$$UpdateCustomerRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? email,
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
      Map<String, dynamic>? tags});
}

/// @nodoc
class __$$UpdateCustomerRequestImplCopyWithImpl<$Res>
    extends _$UpdateCustomerRequestCopyWithImpl<$Res,
        _$UpdateCustomerRequestImpl>
    implements _$$UpdateCustomerRequestImplCopyWith<$Res> {
  __$$UpdateCustomerRequestImplCopyWithImpl(_$UpdateCustomerRequestImpl _value,
      $Res Function(_$UpdateCustomerRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? customerType = freezed,
    Object? status = freezed,
    Object? billingAddress = freezed,
    Object? billingCity = freezed,
    Object? billingState = freezed,
    Object? billingPostalCode = freezed,
    Object? billingCountry = freezed,
    Object? shippingAddress = freezed,
    Object? shippingCity = freezed,
    Object? shippingState = freezed,
    Object? shippingPostalCode = freezed,
    Object? shippingCountry = freezed,
    Object? notes = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$UpdateCustomerRequestImpl(
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCity: freezed == billingCity
          ? _value.billingCity
          : billingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      billingState: freezed == billingState
          ? _value.billingState
          : billingState // ignore: cast_nullable_to_non_nullable
              as String?,
      billingPostalCode: freezed == billingPostalCode
          ? _value.billingPostalCode
          : billingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      billingCountry: freezed == billingCountry
          ? _value.billingCountry
          : billingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCity: freezed == shippingCity
          ? _value.shippingCity
          : shippingCity // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingState: freezed == shippingState
          ? _value.shippingState
          : shippingState // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingPostalCode: freezed == shippingPostalCode
          ? _value.shippingPostalCode
          : shippingPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCountry: freezed == shippingCountry
          ? _value.shippingCountry
          : shippingCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateCustomerRequestImpl implements _UpdateCustomerRequest {
  const _$UpdateCustomerRequestImpl(
      {this.email,
      @JsonKey(name: 'first_name') this.firstName,
      @JsonKey(name: 'last_name') this.lastName,
      this.phone,
      this.company,
      @JsonKey(name: 'customer_type') this.customerType,
      this.status,
      @JsonKey(name: 'billing_address') this.billingAddress,
      @JsonKey(name: 'billing_city') this.billingCity,
      @JsonKey(name: 'billing_state') this.billingState,
      @JsonKey(name: 'billing_postal_code') this.billingPostalCode,
      @JsonKey(name: 'billing_country') this.billingCountry,
      @JsonKey(name: 'shipping_address') this.shippingAddress,
      @JsonKey(name: 'shipping_city') this.shippingCity,
      @JsonKey(name: 'shipping_state') this.shippingState,
      @JsonKey(name: 'shipping_postal_code') this.shippingPostalCode,
      @JsonKey(name: 'shipping_country') this.shippingCountry,
      this.notes,
      final Map<String, dynamic>? tags})
      : _tags = tags;

  factory _$UpdateCustomerRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateCustomerRequestImplFromJson(json);

  @override
  final String? email;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  final String? phone;
  @override
  final String? company;
  @override
  @JsonKey(name: 'customer_type')
  final String? customerType;
  @override
  final String? status;
  @override
  @JsonKey(name: 'billing_address')
  final String? billingAddress;
  @override
  @JsonKey(name: 'billing_city')
  final String? billingCity;
  @override
  @JsonKey(name: 'billing_state')
  final String? billingState;
  @override
  @JsonKey(name: 'billing_postal_code')
  final String? billingPostalCode;
  @override
  @JsonKey(name: 'billing_country')
  final String? billingCountry;
  @override
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;
  @override
  @JsonKey(name: 'shipping_city')
  final String? shippingCity;
  @override
  @JsonKey(name: 'shipping_state')
  final String? shippingState;
  @override
  @JsonKey(name: 'shipping_postal_code')
  final String? shippingPostalCode;
  @override
  @JsonKey(name: 'shipping_country')
  final String? shippingCountry;
  @override
  final String? notes;
  final Map<String, dynamic>? _tags;
  @override
  Map<String, dynamic>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableMapView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'UpdateCustomerRequest(email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, company: $company, customerType: $customerType, status: $status, billingAddress: $billingAddress, billingCity: $billingCity, billingState: $billingState, billingPostalCode: $billingPostalCode, billingCountry: $billingCountry, shippingAddress: $shippingAddress, shippingCity: $shippingCity, shippingState: $shippingState, shippingPostalCode: $shippingPostalCode, shippingCountry: $shippingCountry, notes: $notes, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateCustomerRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.customerType, customerType) ||
                other.customerType == customerType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.billingAddress, billingAddress) ||
                other.billingAddress == billingAddress) &&
            (identical(other.billingCity, billingCity) ||
                other.billingCity == billingCity) &&
            (identical(other.billingState, billingState) ||
                other.billingState == billingState) &&
            (identical(other.billingPostalCode, billingPostalCode) ||
                other.billingPostalCode == billingPostalCode) &&
            (identical(other.billingCountry, billingCountry) ||
                other.billingCountry == billingCountry) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            (identical(other.shippingCity, shippingCity) ||
                other.shippingCity == shippingCity) &&
            (identical(other.shippingState, shippingState) ||
                other.shippingState == shippingState) &&
            (identical(other.shippingPostalCode, shippingPostalCode) ||
                other.shippingPostalCode == shippingPostalCode) &&
            (identical(other.shippingCountry, shippingCountry) ||
                other.shippingCountry == shippingCountry) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        email,
        firstName,
        lastName,
        phone,
        company,
        customerType,
        status,
        billingAddress,
        billingCity,
        billingState,
        billingPostalCode,
        billingCountry,
        shippingAddress,
        shippingCity,
        shippingState,
        shippingPostalCode,
        shippingCountry,
        notes,
        const DeepCollectionEquality().hash(_tags)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateCustomerRequestImplCopyWith<_$UpdateCustomerRequestImpl>
      get copyWith => __$$UpdateCustomerRequestImplCopyWithImpl<
          _$UpdateCustomerRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateCustomerRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateCustomerRequest implements UpdateCustomerRequest {
  const factory _UpdateCustomerRequest(
      {final String? email,
      @JsonKey(name: 'first_name') final String? firstName,
      @JsonKey(name: 'last_name') final String? lastName,
      final String? phone,
      final String? company,
      @JsonKey(name: 'customer_type') final String? customerType,
      final String? status,
      @JsonKey(name: 'billing_address') final String? billingAddress,
      @JsonKey(name: 'billing_city') final String? billingCity,
      @JsonKey(name: 'billing_state') final String? billingState,
      @JsonKey(name: 'billing_postal_code') final String? billingPostalCode,
      @JsonKey(name: 'billing_country') final String? billingCountry,
      @JsonKey(name: 'shipping_address') final String? shippingAddress,
      @JsonKey(name: 'shipping_city') final String? shippingCity,
      @JsonKey(name: 'shipping_state') final String? shippingState,
      @JsonKey(name: 'shipping_postal_code') final String? shippingPostalCode,
      @JsonKey(name: 'shipping_country') final String? shippingCountry,
      final String? notes,
      final Map<String, dynamic>? tags}) = _$UpdateCustomerRequestImpl;

  factory _UpdateCustomerRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateCustomerRequestImpl.fromJson;

  @override
  String? get email;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  String? get phone;
  @override
  String? get company;
  @override
  @JsonKey(name: 'customer_type')
  String? get customerType;
  @override
  String? get status;
  @override
  @JsonKey(name: 'billing_address')
  String? get billingAddress;
  @override
  @JsonKey(name: 'billing_city')
  String? get billingCity;
  @override
  @JsonKey(name: 'billing_state')
  String? get billingState;
  @override
  @JsonKey(name: 'billing_postal_code')
  String? get billingPostalCode;
  @override
  @JsonKey(name: 'billing_country')
  String? get billingCountry;
  @override
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress;
  @override
  @JsonKey(name: 'shipping_city')
  String? get shippingCity;
  @override
  @JsonKey(name: 'shipping_state')
  String? get shippingState;
  @override
  @JsonKey(name: 'shipping_postal_code')
  String? get shippingPostalCode;
  @override
  @JsonKey(name: 'shipping_country')
  String? get shippingCountry;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get tags;
  @override
  @JsonKey(ignore: true)
  _$$UpdateCustomerRequestImplCopyWith<_$UpdateCustomerRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
