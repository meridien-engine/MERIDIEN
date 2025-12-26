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
  String? get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  CategoryModel? get category => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  String get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'selling_price')
  String get sellingPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_price')
  String? get discountPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int get lowStockThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool get trackInventory => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;
  String? get weight => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_unit')
  String get weightUnit => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
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
      String? slug,
      String? description,
      @JsonKey(name: 'category_id') String? categoryId,
      CategoryModel? category,
      String? sku,
      String? barcode,
      @JsonKey(name: 'cost_price') String costPrice,
      @JsonKey(name: 'selling_price') String sellingPrice,
      @JsonKey(name: 'discount_price') String? discountPrice,
      @JsonKey(name: 'stock_quantity') int stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int lowStockThreshold,
      @JsonKey(name: 'track_inventory') bool trackInventory,
      String status,
      @JsonKey(name: 'is_featured') bool isFeatured,
      String? weight,
      @JsonKey(name: 'weight_unit') String weightUnit,
      String? notes,
      @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});

  $CategoryModelCopyWith<$Res>? get category;
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
    Object? slug = freezed,
    Object? description = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? costPrice = null,
    Object? sellingPrice = null,
    Object? discountPrice = freezed,
    Object? stockQuantity = null,
    Object? lowStockThreshold = null,
    Object? trackInventory = null,
    Object? status = null,
    Object? isFeatured = null,
    Object? weight = freezed,
    Object? weightUnit = null,
    Object? notes = freezed,
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
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: null == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String,
      sellingPrice: null == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as String,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      lowStockThreshold: null == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      trackInventory: null == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      weightUnit: null == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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

  @override
  @pragma('vm:prefer-inline')
  $CategoryModelCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryModelCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
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
      String? slug,
      String? description,
      @JsonKey(name: 'category_id') String? categoryId,
      CategoryModel? category,
      String? sku,
      String? barcode,
      @JsonKey(name: 'cost_price') String costPrice,
      @JsonKey(name: 'selling_price') String sellingPrice,
      @JsonKey(name: 'discount_price') String? discountPrice,
      @JsonKey(name: 'stock_quantity') int stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int lowStockThreshold,
      @JsonKey(name: 'track_inventory') bool trackInventory,
      String status,
      @JsonKey(name: 'is_featured') bool isFeatured,
      String? weight,
      @JsonKey(name: 'weight_unit') String weightUnit,
      String? notes,
      @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});

  @override
  $CategoryModelCopyWith<$Res>? get category;
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
    Object? slug = freezed,
    Object? description = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? costPrice = null,
    Object? sellingPrice = null,
    Object? discountPrice = freezed,
    Object? stockQuantity = null,
    Object? lowStockThreshold = null,
    Object? trackInventory = null,
    Object? status = null,
    Object? isFeatured = null,
    Object? weight = freezed,
    Object? weightUnit = null,
    Object? notes = freezed,
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
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: null == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String,
      sellingPrice: null == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as String,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      lowStockThreshold: null == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      trackInventory: null == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      weightUnit: null == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
      this.slug,
      this.description,
      @JsonKey(name: 'category_id') this.categoryId,
      this.category,
      this.sku,
      this.barcode,
      @JsonKey(name: 'cost_price') required this.costPrice,
      @JsonKey(name: 'selling_price') required this.sellingPrice,
      @JsonKey(name: 'discount_price') this.discountPrice,
      @JsonKey(name: 'stock_quantity') required this.stockQuantity,
      @JsonKey(name: 'low_stock_threshold') required this.lowStockThreshold,
      @JsonKey(name: 'track_inventory') required this.trackInventory,
      required this.status,
      @JsonKey(name: 'is_featured') required this.isFeatured,
      this.weight,
      @JsonKey(name: 'weight_unit') required this.weightUnit,
      this.notes,
      @JsonKey(name: 'custom_fields') final Map<String, dynamic>? customFields,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _customFields = customFields,
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
  final String? slug;
  @override
  final String? description;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  final CategoryModel? category;
  @override
  final String? sku;
  @override
  final String? barcode;
  @override
  @JsonKey(name: 'cost_price')
  final String costPrice;
  @override
  @JsonKey(name: 'selling_price')
  final String sellingPrice;
  @override
  @JsonKey(name: 'discount_price')
  final String? discountPrice;
  @override
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int lowStockThreshold;
  @override
  @JsonKey(name: 'track_inventory')
  final bool trackInventory;
  @override
  final String status;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @override
  final String? weight;
  @override
  @JsonKey(name: 'weight_unit')
  final String weightUnit;
  @override
  final String? notes;
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
    return 'ProductModel(id: $id, tenantId: $tenantId, name: $name, slug: $slug, description: $description, categoryId: $categoryId, category: $category, sku: $sku, barcode: $barcode, costPrice: $costPrice, sellingPrice: $sellingPrice, discountPrice: $discountPrice, stockQuantity: $stockQuantity, lowStockThreshold: $lowStockThreshold, trackInventory: $trackInventory, status: $status, isFeatured: $isFeatured, weight: $weight, weightUnit: $weightUnit, notes: $notes, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.discountPrice, discountPrice) ||
                other.discountPrice == discountPrice) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
        slug,
        description,
        categoryId,
        category,
        sku,
        barcode,
        costPrice,
        sellingPrice,
        discountPrice,
        stockQuantity,
        lowStockThreshold,
        trackInventory,
        status,
        isFeatured,
        weight,
        weightUnit,
        notes,
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
      final String? slug,
      final String? description,
      @JsonKey(name: 'category_id') final String? categoryId,
      final CategoryModel? category,
      final String? sku,
      final String? barcode,
      @JsonKey(name: 'cost_price') required final String costPrice,
      @JsonKey(name: 'selling_price') required final String sellingPrice,
      @JsonKey(name: 'discount_price') final String? discountPrice,
      @JsonKey(name: 'stock_quantity') required final int stockQuantity,
      @JsonKey(name: 'low_stock_threshold')
      required final int lowStockThreshold,
      @JsonKey(name: 'track_inventory') required final bool trackInventory,
      required final String status,
      @JsonKey(name: 'is_featured') required final bool isFeatured,
      final String? weight,
      @JsonKey(name: 'weight_unit') required final String weightUnit,
      final String? notes,
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
  String? get slug;
  @override
  String? get description;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  CategoryModel? get category;
  @override
  String? get sku;
  @override
  String? get barcode;
  @override
  @JsonKey(name: 'cost_price')
  String get costPrice;
  @override
  @JsonKey(name: 'selling_price')
  String get sellingPrice;
  @override
  @JsonKey(name: 'discount_price')
  String? get discountPrice;
  @override
  @JsonKey(name: 'stock_quantity')
  int get stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int get lowStockThreshold;
  @override
  @JsonKey(name: 'track_inventory')
  bool get trackInventory;
  @override
  String get status;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;
  @override
  String? get weight;
  @override
  @JsonKey(name: 'weight_unit')
  String get weightUnit;
  @override
  String? get notes;
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
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  String? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'selling_price')
  String get sellingPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_price')
  String? get discountPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory => throw _privateConstructorUsedError;
  String? get weight => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_unit')
  String? get weightUnit => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

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
      {@JsonKey(name: 'category_id') String? categoryId,
      String name,
      String? description,
      String? sku,
      String? barcode,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'selling_price') String sellingPrice,
      @JsonKey(name: 'discount_price') String? discountPrice,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      String? weight,
      @JsonKey(name: 'weight_unit') String? weightUnit,
      String? notes});
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
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? costPrice = freezed,
    Object? sellingPrice = null,
    Object? discountPrice = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? trackInventory = freezed,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      sellingPrice: null == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as String,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      weightUnit: freezed == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
      {@JsonKey(name: 'category_id') String? categoryId,
      String name,
      String? description,
      String? sku,
      String? barcode,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'selling_price') String sellingPrice,
      @JsonKey(name: 'discount_price') String? discountPrice,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      String? weight,
      @JsonKey(name: 'weight_unit') String? weightUnit,
      String? notes});
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
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? costPrice = freezed,
    Object? sellingPrice = null,
    Object? discountPrice = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? trackInventory = freezed,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$CreateProductRequestImpl(
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      sellingPrice: null == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as String,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      weightUnit: freezed == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateProductRequestImpl implements _CreateProductRequest {
  const _$CreateProductRequestImpl(
      {@JsonKey(name: 'category_id') this.categoryId,
      required this.name,
      this.description,
      this.sku,
      this.barcode,
      @JsonKey(name: 'cost_price') this.costPrice,
      @JsonKey(name: 'selling_price') required this.sellingPrice,
      @JsonKey(name: 'discount_price') this.discountPrice,
      @JsonKey(name: 'stock_quantity') this.stockQuantity,
      @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
      @JsonKey(name: 'track_inventory') this.trackInventory,
      this.weight,
      @JsonKey(name: 'weight_unit') this.weightUnit,
      this.notes});

  factory _$CreateProductRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateProductRequestImplFromJson(json);

  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? sku;
  @override
  final String? barcode;
  @override
  @JsonKey(name: 'cost_price')
  final String? costPrice;
  @override
  @JsonKey(name: 'selling_price')
  final String sellingPrice;
  @override
  @JsonKey(name: 'discount_price')
  final String? discountPrice;
  @override
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int? lowStockThreshold;
  @override
  @JsonKey(name: 'track_inventory')
  final bool? trackInventory;
  @override
  final String? weight;
  @override
  @JsonKey(name: 'weight_unit')
  final String? weightUnit;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CreateProductRequest(categoryId: $categoryId, name: $name, description: $description, sku: $sku, barcode: $barcode, costPrice: $costPrice, sellingPrice: $sellingPrice, discountPrice: $discountPrice, stockQuantity: $stockQuantity, lowStockThreshold: $lowStockThreshold, trackInventory: $trackInventory, weight: $weight, weightUnit: $weightUnit, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateProductRequestImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.discountPrice, discountPrice) ||
                other.discountPrice == discountPrice) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      categoryId,
      name,
      description,
      sku,
      barcode,
      costPrice,
      sellingPrice,
      discountPrice,
      stockQuantity,
      lowStockThreshold,
      trackInventory,
      weight,
      weightUnit,
      notes);

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
      {@JsonKey(name: 'category_id') final String? categoryId,
      required final String name,
      final String? description,
      final String? sku,
      final String? barcode,
      @JsonKey(name: 'cost_price') final String? costPrice,
      @JsonKey(name: 'selling_price') required final String sellingPrice,
      @JsonKey(name: 'discount_price') final String? discountPrice,
      @JsonKey(name: 'stock_quantity') final int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') final int? lowStockThreshold,
      @JsonKey(name: 'track_inventory') final bool? trackInventory,
      final String? weight,
      @JsonKey(name: 'weight_unit') final String? weightUnit,
      final String? notes}) = _$CreateProductRequestImpl;

  factory _CreateProductRequest.fromJson(Map<String, dynamic> json) =
      _$CreateProductRequestImpl.fromJson;

  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get sku;
  @override
  String? get barcode;
  @override
  @JsonKey(name: 'cost_price')
  String? get costPrice;
  @override
  @JsonKey(name: 'selling_price')
  String get sellingPrice;
  @override
  @JsonKey(name: 'discount_price')
  String? get discountPrice;
  @override
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold;
  @override
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory;
  @override
  String? get weight;
  @override
  @JsonKey(name: 'weight_unit')
  String? get weightUnit;
  @override
  String? get notes;
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
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  String? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'selling_price')
  String? get sellingPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_price')
  String? get discountPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool? get isFeatured => throw _privateConstructorUsedError;
  String? get weight => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_unit')
  String? get weightUnit => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

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
      {@JsonKey(name: 'category_id') String? categoryId,
      String? name,
      String? description,
      String? sku,
      String? barcode,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'selling_price') String? sellingPrice,
      @JsonKey(name: 'discount_price') String? discountPrice,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      String? status,
      @JsonKey(name: 'is_featured') bool? isFeatured,
      String? weight,
      @JsonKey(name: 'weight_unit') String? weightUnit,
      String? notes});
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
    Object? categoryId = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? costPrice = freezed,
    Object? sellingPrice = freezed,
    Object? discountPrice = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? trackInventory = freezed,
    Object? status = freezed,
    Object? isFeatured = freezed,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      sellingPrice: freezed == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: freezed == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      weightUnit: freezed == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
      {@JsonKey(name: 'category_id') String? categoryId,
      String? name,
      String? description,
      String? sku,
      String? barcode,
      @JsonKey(name: 'cost_price') String? costPrice,
      @JsonKey(name: 'selling_price') String? sellingPrice,
      @JsonKey(name: 'discount_price') String? discountPrice,
      @JsonKey(name: 'stock_quantity') int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
      @JsonKey(name: 'track_inventory') bool? trackInventory,
      String? status,
      @JsonKey(name: 'is_featured') bool? isFeatured,
      String? weight,
      @JsonKey(name: 'weight_unit') String? weightUnit,
      String? notes});
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
    Object? categoryId = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? costPrice = freezed,
    Object? sellingPrice = freezed,
    Object? discountPrice = freezed,
    Object? stockQuantity = freezed,
    Object? lowStockThreshold = freezed,
    Object? trackInventory = freezed,
    Object? status = freezed,
    Object? isFeatured = freezed,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$UpdateProductRequestImpl(
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      sellingPrice: freezed == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: freezed == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      trackInventory: freezed == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: freezed == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      weightUnit: freezed == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateProductRequestImpl implements _UpdateProductRequest {
  const _$UpdateProductRequestImpl(
      {@JsonKey(name: 'category_id') this.categoryId,
      this.name,
      this.description,
      this.sku,
      this.barcode,
      @JsonKey(name: 'cost_price') this.costPrice,
      @JsonKey(name: 'selling_price') this.sellingPrice,
      @JsonKey(name: 'discount_price') this.discountPrice,
      @JsonKey(name: 'stock_quantity') this.stockQuantity,
      @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
      @JsonKey(name: 'track_inventory') this.trackInventory,
      this.status,
      @JsonKey(name: 'is_featured') this.isFeatured,
      this.weight,
      @JsonKey(name: 'weight_unit') this.weightUnit,
      this.notes});

  factory _$UpdateProductRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateProductRequestImplFromJson(json);

  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? sku;
  @override
  final String? barcode;
  @override
  @JsonKey(name: 'cost_price')
  final String? costPrice;
  @override
  @JsonKey(name: 'selling_price')
  final String? sellingPrice;
  @override
  @JsonKey(name: 'discount_price')
  final String? discountPrice;
  @override
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final int? lowStockThreshold;
  @override
  @JsonKey(name: 'track_inventory')
  final bool? trackInventory;
  @override
  final String? status;
  @override
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;
  @override
  final String? weight;
  @override
  @JsonKey(name: 'weight_unit')
  final String? weightUnit;
  @override
  final String? notes;

  @override
  String toString() {
    return 'UpdateProductRequest(categoryId: $categoryId, name: $name, description: $description, sku: $sku, barcode: $barcode, costPrice: $costPrice, sellingPrice: $sellingPrice, discountPrice: $discountPrice, stockQuantity: $stockQuantity, lowStockThreshold: $lowStockThreshold, trackInventory: $trackInventory, status: $status, isFeatured: $isFeatured, weight: $weight, weightUnit: $weightUnit, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateProductRequestImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.discountPrice, discountPrice) ||
                other.discountPrice == discountPrice) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      categoryId,
      name,
      description,
      sku,
      barcode,
      costPrice,
      sellingPrice,
      discountPrice,
      stockQuantity,
      lowStockThreshold,
      trackInventory,
      status,
      isFeatured,
      weight,
      weightUnit,
      notes);

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
      {@JsonKey(name: 'category_id') final String? categoryId,
      final String? name,
      final String? description,
      final String? sku,
      final String? barcode,
      @JsonKey(name: 'cost_price') final String? costPrice,
      @JsonKey(name: 'selling_price') final String? sellingPrice,
      @JsonKey(name: 'discount_price') final String? discountPrice,
      @JsonKey(name: 'stock_quantity') final int? stockQuantity,
      @JsonKey(name: 'low_stock_threshold') final int? lowStockThreshold,
      @JsonKey(name: 'track_inventory') final bool? trackInventory,
      final String? status,
      @JsonKey(name: 'is_featured') final bool? isFeatured,
      final String? weight,
      @JsonKey(name: 'weight_unit') final String? weightUnit,
      final String? notes}) = _$UpdateProductRequestImpl;

  factory _UpdateProductRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateProductRequestImpl.fromJson;

  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get sku;
  @override
  String? get barcode;
  @override
  @JsonKey(name: 'cost_price')
  String? get costPrice;
  @override
  @JsonKey(name: 'selling_price')
  String? get sellingPrice;
  @override
  @JsonKey(name: 'discount_price')
  String? get discountPrice;
  @override
  @JsonKey(name: 'stock_quantity')
  int? get stockQuantity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  int? get lowStockThreshold;
  @override
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory;
  @override
  String? get status;
  @override
  @JsonKey(name: 'is_featured')
  bool? get isFeatured;
  @override
  String? get weight;
  @override
  @JsonKey(name: 'weight_unit')
  String? get weightUnit;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$UpdateProductRequestImplCopyWith<_$UpdateProductRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
