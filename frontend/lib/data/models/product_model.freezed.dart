// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_price')
  String get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  String? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'compare_at_price')
  String? get compareAtPrice => throw _privateConstructorUsedError;
  bool get taxable => throw _privateConstructorUsedError;
  @JsonKey(name: 'tax_rate')
  String? get taxRate => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool get trackInventory => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get weight => throw _privateConstructorUsedError;
  String? get dimensions => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_fields')
  Map<String, dynamic>? get customFields => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
          ProductModel value, $Res Function(ProductModel) then) =
      _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      String name,
      String sku,
      String? description,
      String? category,
      String? brand,
      @JsonKey(name: 'unit_price') String unitPrice,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'compare_at_price') String? compareAtPrice,
      bool taxable,
      @JsonKey(name: 'tax_rate') String? taxRate,
      String? barcode,
      @JsonKey(name: 'track_inventory') bool trackInventory,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      String? unit,
      String? weight,
      String? dimensions,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String>? tags,
      bool active,
      @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? sku = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? brand = freezed,
    Object? unitPrice = null,
    Object? costPrice = freezed,
    Object? compareAtPrice = freezed,
    Object? taxable = null,
    Object? taxRate = freezed,
    Object? barcode = freezed,
    Object? trackInventory = null,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
    Object? weight = freezed,
    Object? dimensions = freezed,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? active = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      taxable: null == taxable
          ? _value.taxable
          : taxable // ignore: cast_nullable_to_non_nullable
              as bool,
      taxRate: freezed == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackInventory: null == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
          _$ProductModelImpl value, $Res Function(_$ProductModelImpl) then) =
      __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      String name,
      String sku,
      String? description,
      String? category,
      String? brand,
      @JsonKey(name: 'unit_price') String unitPrice,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'compare_at_price') String? compareAtPrice,
      bool taxable,
      @JsonKey(name: 'tax_rate') String? taxRate,
      String? barcode,
      @JsonKey(name: 'track_inventory') bool trackInventory,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      String? unit,
      String? weight,
      String? dimensions,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String>? tags,
      bool active,
      @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
      _$ProductModelImpl _value, $Res Function(_$ProductModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? sku = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? brand = freezed,
    Object? unitPrice = null,
    Object? costPrice = freezed,
    Object? compareAtPrice = freezed,
    Object? taxable = null,
    Object? taxRate = freezed,
    Object? barcode = freezed,
    Object? trackInventory = null,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
    Object? weight = freezed,
    Object? dimensions = freezed,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? active = null,
    Object? customFields = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ProductModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      taxable: null == taxable
          ? _value.taxable
          : taxable // ignore: cast_nullable_to_non_nullable
              as bool,
      taxRate: freezed == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackInventory: null == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$ProductModelImpl extends _ProductModel {
  const _$ProductModelImpl(
      {required this.id,
      @JsonKey(name: 'tenant_id') required this.tenantId,
      required this.name,
      required this.sku,
      this.description,
      this.category,
      this.brand,
      @JsonKey(name: 'unit_price') required this.unitPrice,
      @JsonKey(name: 'cost_price') this.costPrice,
      @JsonKey(name: 'compare_at_price') this.compareAtPrice,
      required this.taxable,
      @JsonKey(name: 'tax_rate') this.taxRate,
      this.barcode,
      @JsonKey(name: 'track_inventory') required this.trackInventory,
      @JsonKey(name: 'stock_quantity') this.stockQuantity,
      @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
      this.unit,
      this.weight,
      this.dimensions,
      @JsonKey(name: 'image_url') this.imageUrl,
      final List<String>? tags,
      required this.active,
      @JsonKey(name: 'custom_fields') final Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _tags = tags,
        _customFields = customFields,
        super._();

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  final String name;
  @override
  final String sku;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final String? brand;
  @override
  @JsonKey(name: 'unit_price')
  final String unitPrice;
  @override
  @JsonKey(name: 'cost_price')
  final String? costPrice;
  @override
  @JsonKey(name: 'compare_at_price')
  final String? compareAtPrice;
  @override
  final bool taxable;
  @override
  @JsonKey(name: 'tax_rate')
  final String? taxRate;
  @override
  final String? barcode;
  @override
  @JsonKey(name: 'track_inventory')
  final bool trackInventory;
  @override
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int? lowStockThreshold;
  @override
  final String? unit;
  @override
  final String? weight;
  @override
  final String? dimensions;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool active;
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
    return 'ProductModel(id: $id, tenantId: $tenantId, name: $name, sku: $sku, description: $description, category: $category, brand: $brand, unitPrice: $unitPrice, costPrice: $costPrice, compareAtPrice: $compareAtPrice, taxable: $taxable, taxRate: $taxRate, barcode: $barcode, trackInventory: $trackInventory, stockQuantity: $stockQuantity, lowStockThreshold: $lowStockThreshold, unit: $unit, weight: $weight, dimensions: $dimensions, imageUrl: $imageUrl, tags: $tags, active: $active, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.compareAtPrice, compareAtPrice) ||
                other.compareAtPrice == compareAtPrice) &&
            (identical(other.taxable, taxable) || other.taxable == taxable) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.dimensions, dimensions) ||
                other.dimensions == dimensions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.active, active) || other.active == active) &&
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
        name,
        sku,
        description,
        category,
        brand,
        unitPrice,
        costPrice,
        compareAtPrice,
        taxable,
        taxRate,
        barcode,
        trackInventory,
        stockQuantity,
        lowStockThreshold,
        unit,
        weight,
        dimensions,
        imageUrl,
        const DeepCollectionEquality().hash(_tags),
        active,
        const DeepCollectionEquality().hash(_customFields),
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(
      this,
    );
  }
}

abstract class _ProductModel extends ProductModel {
  const factory _ProductModel(
      {required final String id,
      @JsonKey(name: 'tenant_id') required final String tenantId,
      required final String name,
      required final String sku,
      final String? description,
      final String? category,
      final String? brand,
      @JsonKey(name: 'unit_price') required final String unitPrice,
      @JsonKey(name: 'cost_price') final String? costPrice,
      @JsonKey(name: 'compare_at_price') final String? compareAtPrice,
      required final bool taxable,
      @JsonKey(name: 'tax_rate') final String? taxRate,
      final String? barcode,
      @JsonKey(name: 'track_inventory') required final bool trackInventory,
      @JsonKey(name: 'stock_quantity') final int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') final int? lowStockThreshold,
      final String? unit,
      final String? weight,
      final String? dimensions,
      @JsonKey(name: 'image_url') final String? imageUrl,
      final List<String>? tags,
      required final bool active,
      @JsonKey(name: 'custom_fields') final Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$ProductModelImpl;
  const _ProductModel._() : super._();

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  String get name;
  @override
  String get sku;
  @override
  String? get description;
  @override
  String? get category;
  @override
  String? get brand;
  @override
  @JsonKey(name: 'unit_price')
  String get unitPrice;
  @override
  @JsonKey(name: 'cost_price')
  String? get costPrice;
  @override
  @JsonKey(name: 'compare_at_price')
  String? get compareAtPrice;
  @override
  bool get taxable;
  @override
  @JsonKey(name: 'tax_rate')
  String? get taxRate;
  @override
  String? get barcode;
  @override
  @JsonKey(name: 'track_inventory')
  bool get trackInventory;
  @override
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold;
  @override
  String? get unit;
  @override
  String? get weight;
  @override
  String? get dimensions;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  List<String>? get tags;
  @override
  bool get active;
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
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateProductRequest _$CreateProductRequestFromJson(Map<String, dynamic> json) {
  return _CreateProductRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateProductRequest {
  String get name => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_price')
  String get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  String? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'compare_at_price')
  String? get compareAtPrice => throw _privateConstructorUsedError;
  bool? get taxable => throw _privateConstructorUsedError;
  @JsonKey(name: 'tax_rate')
  String? get taxRate => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get weight => throw _privateConstructorUsedError;
  String? get dimensions => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  bool? get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateProductRequestCopyWith<CreateProductRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateProductRequestCopyWith<$Res> {
  factory $CreateProductRequestCopyWith(CreateProductRequest value,
          $Res Function(CreateProductRequest) then) =
      _$CreateProductRequestCopyWithImpl<$Res, CreateProductRequest>;
  @useResult
  $Res call(
      {String name,
      String sku,
      String? description,
      String? category,
      String? brand,
      @JsonKey(name: 'unit_price') String unitPrice,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'compare_at_price') String? compareAtPrice,
      bool? taxable,
      @JsonKey(name: 'tax_rate') String? taxRate,
      String? barcode,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      String? unit,
      String? weight,
      String? dimensions,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String>? tags,
      bool? active});
}

/// @nodoc
class _$CreateProductRequestCopyWithImpl<$Res,
        $Val extends CreateProductRequest>
    implements $CreateProductRequestCopyWith<$Res> {
  _$CreateProductRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? sku = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? brand = freezed,
    Object? unitPrice = null,
    Object? costPrice = freezed,
    Object? compareAtPrice = freezed,
    Object? taxable = freezed,
    Object? taxRate = freezed,
    Object? barcode = freezed,
    Object? trackInventory = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
    Object? weight = freezed,
    Object? dimensions = freezed,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? active = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      taxable: freezed == taxable
          ? _value.taxable
          : taxable // ignore: cast_nullable_to_non_nullable
              as bool?,
      taxRate: freezed == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      active: freezed == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateProductRequestImplCopyWith<$Res>
    implements $CreateProductRequestCopyWith<$Res> {
  factory _$$CreateProductRequestImplCopyWith(_$CreateProductRequestImpl value,
          $Res Function(_$CreateProductRequestImpl) then) =
      __$$CreateProductRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String sku,
      String? description,
      String? category,
      String? brand,
      @JsonKey(name: 'unit_price') String unitPrice,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'compare_at_price') String? compareAtPrice,
      bool? taxable,
      @JsonKey(name: 'tax_rate') String? taxRate,
      String? barcode,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      String? unit,
      String? weight,
      String? dimensions,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String>? tags,
      bool? active});
}

/// @nodoc
class __$$CreateProductRequestImplCopyWithImpl<$Res>
    extends _$CreateProductRequestCopyWithImpl<$Res, _$CreateProductRequestImpl>
    implements _$$CreateProductRequestImplCopyWith<$Res> {
  __$$CreateProductRequestImplCopyWithImpl(_$CreateProductRequestImpl _value,
      $Res Function(_$CreateProductRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? sku = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? brand = freezed,
    Object? unitPrice = null,
    Object? costPrice = freezed,
    Object? compareAtPrice = freezed,
    Object? taxable = freezed,
    Object? taxRate = freezed,
    Object? barcode = freezed,
    Object? trackInventory = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
    Object? weight = freezed,
    Object? dimensions = freezed,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? active = freezed,
  }) {
    return _then(_$CreateProductRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      taxable: freezed == taxable
          ? _value.taxable
          : taxable // ignore: cast_nullable_to_non_nullable
              as bool?,
      taxRate: freezed == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      active: freezed == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateProductRequestImpl implements _CreateProductRequest {
  const _$CreateProductRequestImpl(
      {required this.name,
      required this.sku,
      this.description,
      this.category,
      this.brand,
      @JsonKey(name: 'unit_price') required this.unitPrice,
      @JsonKey(name: 'cost_price') this.costPrice,
      @JsonKey(name: 'compare_at_price') this.compareAtPrice,
      this.taxable,
      @JsonKey(name: 'tax_rate') this.taxRate,
      this.barcode,
      @JsonKey(name: 'track_inventory') this.trackInventory,
      @JsonKey(name: 'stock_quantity') this.stockQuantity,
      @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
      this.unit,
      this.weight,
      this.dimensions,
      @JsonKey(name: 'image_url') this.imageUrl,
      final List<String>? tags,
      this.active})
      : _tags = tags;

  factory _$CreateProductRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateProductRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String sku;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final String? brand;
  @override
  @JsonKey(name: 'unit_price')
  final String unitPrice;
  @override
  @JsonKey(name: 'cost_price')
  final String? costPrice;
  @override
  @JsonKey(name: 'compare_at_price')
  final String? compareAtPrice;
  @override
  final bool? taxable;
  @override
  @JsonKey(name: 'tax_rate')
  final String? taxRate;
  @override
  final String? barcode;
  @override
  @JsonKey(name: 'track_inventory')
  final bool? trackInventory;
  @override
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int? lowStockThreshold;
  @override
  final String? unit;
  @override
  final String? weight;
  @override
  final String? dimensions;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? active;

  @override
  String toString() {
    return 'CreateProductRequest(name: $name, sku: $sku, description: $description, category: $category, brand: $brand, unitPrice: $unitPrice, costPrice: $costPrice, compareAtPrice: $compareAtPrice, taxable: $taxable, taxRate: $taxRate, barcode: $barcode, trackInventory: $trackInventory, stockQuantity: $stockQuantity, lowStockThreshold: $lowStockThreshold, unit: $unit, weight: $weight, dimensions: $dimensions, imageUrl: $imageUrl, tags: $tags, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateProductRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.compareAtPrice, compareAtPrice) ||
                other.compareAtPrice == compareAtPrice) &&
            (identical(other.taxable, taxable) || other.taxable == taxable) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.dimensions, dimensions) ||
                other.dimensions == dimensions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        sku,
        description,
        category,
        brand,
        unitPrice,
        costPrice,
        compareAtPrice,
        taxable,
        taxRate,
        barcode,
        trackInventory,
        stockQuantity,
        lowStockThreshold,
        unit,
        weight,
        dimensions,
        imageUrl,
        const DeepCollectionEquality().hash(_tags),
        active
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateProductRequestImplCopyWith<_$CreateProductRequestImpl>
      get copyWith =>
          __$$CreateProductRequestImplCopyWithImpl<_$CreateProductRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateProductRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateProductRequest implements CreateProductRequest {
  const factory _CreateProductRequest(
      {required final String name,
      required final String sku,
      final String? description,
      final String? category,
      final String? brand,
      @JsonKey(name: 'unit_price') required final String unitPrice,
      @JsonKey(name: 'cost_price') final String? costPrice,
      @JsonKey(name: 'compare_at_price') final String? compareAtPrice,
      final bool? taxable,
      @JsonKey(name: 'tax_rate') final String? taxRate,
      final String? barcode,
      @JsonKey(name: 'track_inventory') final bool? trackInventory,
      @JsonKey(name: 'stock_quantity') final int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') final int? lowStockThreshold,
      final String? unit,
      final String? weight,
      final String? dimensions,
      @JsonKey(name: 'image_url') final String? imageUrl,
      final List<String>? tags,
      final bool? active}) = _$CreateProductRequestImpl;

  factory _CreateProductRequest.fromJson(Map<String, dynamic> json) =
      _$CreateProductRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get sku;
  @override
  String? get description;
  @override
  String? get category;
  @override
  String? get brand;
  @override
  @JsonKey(name: 'unit_price')
  String get unitPrice;
  @override
  @JsonKey(name: 'cost_price')
  String? get costPrice;
  @override
  @JsonKey(name: 'compare_at_price')
  String? get compareAtPrice;
  @override
  bool? get taxable;
  @override
  @JsonKey(name: 'tax_rate')
  String? get taxRate;
  @override
  String? get barcode;
  @override
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory;
  @override
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold;
  @override
  String? get unit;
  @override
  String? get weight;
  @override
  String? get dimensions;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  List<String>? get tags;
  @override
  bool? get active;
  @override
  @JsonKey(ignore: true)
  _$$CreateProductRequestImplCopyWith<_$CreateProductRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateProductRequest _$UpdateProductRequestFromJson(Map<String, dynamic> json) {
  return _UpdateProductRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateProductRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_price')
  String? get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  String? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'compare_at_price')
  String? get compareAtPrice => throw _privateConstructorUsedError;
  bool? get taxable => throw _privateConstructorUsedError;
  @JsonKey(name: 'tax_rate')
  String? get taxRate => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get weight => throw _privateConstructorUsedError;
  String? get dimensions => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  bool? get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateProductRequestCopyWith<UpdateProductRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateProductRequestCopyWith<$Res> {
  factory $UpdateProductRequestCopyWith(UpdateProductRequest value,
          $Res Function(UpdateProductRequest) then) =
      _$UpdateProductRequestCopyWithImpl<$Res, UpdateProductRequest>;
  @useResult
  $Res call(
      {String? name,
      String? sku,
      String? description,
      String? category,
      String? brand,
      @JsonKey(name: 'unit_price') String? unitPrice,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'compare_at_price') String? compareAtPrice,
      bool? taxable,
      @JsonKey(name: 'tax_rate') String? taxRate,
      String? barcode,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      String? unit,
      String? weight,
      String? dimensions,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String>? tags,
      bool? active});
}

/// @nodoc
class _$UpdateProductRequestCopyWithImpl<$Res,
        $Val extends UpdateProductRequest>
    implements $UpdateProductRequestCopyWith<$Res> {
  _$UpdateProductRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? sku = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? brand = freezed,
    Object? unitPrice = freezed,
    Object? costPrice = freezed,
    Object? compareAtPrice = freezed,
    Object? taxable = freezed,
    Object? taxRate = freezed,
    Object? barcode = freezed,
    Object? trackInventory = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
    Object? weight = freezed,
    Object? dimensions = freezed,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? active = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: freezed == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      taxable: freezed == taxable
          ? _value.taxable
          : taxable // ignore: cast_nullable_to_non_nullable
              as bool?,
      taxRate: freezed == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      active: freezed == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateProductRequestImplCopyWith<$Res>
    implements $UpdateProductRequestCopyWith<$Res> {
  factory _$$UpdateProductRequestImplCopyWith(_$UpdateProductRequestImpl value,
          $Res Function(_$UpdateProductRequestImpl) then) =
      __$$UpdateProductRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? sku,
      String? description,
      String? category,
      String? brand,
      @JsonKey(name: 'unit_price') String? unitPrice,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'compare_at_price') String? compareAtPrice,
      bool? taxable,
      @JsonKey(name: 'tax_rate') String? taxRate,
      String? barcode,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      String? unit,
      String? weight,
      String? dimensions,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String>? tags,
      bool? active});
}

/// @nodoc
class __$$UpdateProductRequestImplCopyWithImpl<$Res>
    extends _$UpdateProductRequestCopyWithImpl<$Res, _$UpdateProductRequestImpl>
    implements _$$UpdateProductRequestImplCopyWith<$Res> {
  __$$UpdateProductRequestImplCopyWithImpl(_$UpdateProductRequestImpl _value,
      $Res Function(_$UpdateProductRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? sku = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? brand = freezed,
    Object? unitPrice = freezed,
    Object? costPrice = freezed,
    Object? compareAtPrice = freezed,
    Object? taxable = freezed,
    Object? taxRate = freezed,
    Object? barcode = freezed,
    Object? trackInventory = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
    Object? weight = freezed,
    Object? dimensions = freezed,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? active = freezed,
  }) {
    return _then(_$UpdateProductRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: freezed == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      taxable: freezed == taxable
          ? _value.taxable
          : taxable // ignore: cast_nullable_to_non_nullable
              as bool?,
      taxRate: freezed == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      active: freezed == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateProductRequestImpl implements _UpdateProductRequest {
  const _$UpdateProductRequestImpl(
      {this.name,
      this.sku,
      this.description,
      this.category,
      this.brand,
      @JsonKey(name: 'unit_price') this.unitPrice,
      @JsonKey(name: 'cost_price') this.costPrice,
      @JsonKey(name: 'compare_at_price') this.compareAtPrice,
      this.taxable,
      @JsonKey(name: 'tax_rate') this.taxRate,
      this.barcode,
      @JsonKey(name: 'track_inventory') this.trackInventory,
      @JsonKey(name: 'stock_quantity') this.stockQuantity,
      @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
      this.unit,
      this.weight,
      this.dimensions,
      @JsonKey(name: 'image_url') this.imageUrl,
      final List<String>? tags,
      this.active})
      : _tags = tags;

  factory _$UpdateProductRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateProductRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? sku;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final String? brand;
  @override
  @JsonKey(name: 'unit_price')
  final String? unitPrice;
  @override
  @JsonKey(name: 'cost_price')
  final String? costPrice;
  @override
  @JsonKey(name: 'compare_at_price')
  final String? compareAtPrice;
  @override
  final bool? taxable;
  @override
  @JsonKey(name: 'tax_rate')
  final String? taxRate;
  @override
  final String? barcode;
  @override
  @JsonKey(name: 'track_inventory')
  final bool? trackInventory;
  @override
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int? lowStockThreshold;
  @override
  final String? unit;
  @override
  final String? weight;
  @override
  final String? dimensions;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? active;

  @override
  String toString() {
    return 'UpdateProductRequest(name: $name, sku: $sku, description: $description, category: $category, brand: $brand, unitPrice: $unitPrice, costPrice: $costPrice, compareAtPrice: $compareAtPrice, taxable: $taxable, taxRate: $taxRate, barcode: $barcode, trackInventory: $trackInventory, stockQuantity: $stockQuantity, lowStockThreshold: $lowStockThreshold, unit: $unit, weight: $weight, dimensions: $dimensions, imageUrl: $imageUrl, tags: $tags, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateProductRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.compareAtPrice, compareAtPrice) ||
                other.compareAtPrice == compareAtPrice) &&
            (identical(other.taxable, taxable) || other.taxable == taxable) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.dimensions, dimensions) ||
                other.dimensions == dimensions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        sku,
        description,
        category,
        brand,
        unitPrice,
        costPrice,
        compareAtPrice,
        taxable,
        taxRate,
        barcode,
        trackInventory,
        stockQuantity,
        lowStockThreshold,
        unit,
        weight,
        dimensions,
        imageUrl,
        const DeepCollectionEquality().hash(_tags),
        active
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateProductRequestImplCopyWith<_$UpdateProductRequestImpl>
      get copyWith =>
          __$$UpdateProductRequestImplCopyWithImpl<_$UpdateProductRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateProductRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateProductRequest implements UpdateProductRequest {
  const factory _UpdateProductRequest(
      {final String? name,
      final String? sku,
      final String? description,
      final String? category,
      final String? brand,
      @JsonKey(name: 'unit_price') final String? unitPrice,
      @JsonKey(name: 'cost_price') final String? costPrice,
      @JsonKey(name: 'compare_at_price') final String? compareAtPrice,
      final bool? taxable,
      @JsonKey(name: 'tax_rate') final String? taxRate,
      final String? barcode,
      @JsonKey(name: 'track_inventory') final bool? trackInventory,
      @JsonKey(name: 'stock_quantity') final int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') final int? lowStockThreshold,
      final String? unit,
      final String? weight,
      final String? dimensions,
      @JsonKey(name: 'image_url') final String? imageUrl,
      final List<String>? tags,
      final bool? active}) = _$UpdateProductRequestImpl;

  factory _UpdateProductRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateProductRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get sku;
  @override
  String? get description;
  @override
  String? get category;
  @override
  String? get brand;
  @override
  @JsonKey(name: 'unit_price')
  String? get unitPrice;
  @override
  @JsonKey(name: 'cost_price')
  String? get costPrice;
  @override
  @JsonKey(name: 'compare_at_price')
  String? get compareAtPrice;
  @override
  bool? get taxable;
  @override
  @JsonKey(name: 'tax_rate')
  String? get taxRate;
  @override
  String? get barcode;
  @override
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory;
  @override
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold;
  @override
  String? get unit;
  @override
  String? get weight;
  @override
  String? get dimensions;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  List<String>? get tags;
  @override
  bool? get active;
  @override
  @JsonKey(ignore: true)
  _$$UpdateProductRequestImplCopyWith<_$UpdateProductRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
