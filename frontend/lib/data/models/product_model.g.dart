// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      costPrice: json['cost_price'] as String,
      sellingPrice: json['selling_price'] as String,
      discountPrice: json['discount_price'] as String?,
      stockQuantity: (json['stock_quantity'] as num).toInt(),
      lowStockThreshold: (json['low_stock_threshold'] as num).toInt(),
      trackInventory: json['track_inventory'] as bool,
      status: json['status'] as String,
      isFeatured: json['is_featured'] as bool,
      weight: json['weight'] as String?,
      weightUnit: json['weight_unit'] as String,
      notes: json['notes'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'category_id': instance.categoryId,
      'category': instance.category,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'cost_price': instance.costPrice,
      'selling_price': instance.sellingPrice,
      'discount_price': instance.discountPrice,
      'stock_quantity': instance.stockQuantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'track_inventory': instance.trackInventory,
      'status': instance.status,
      'is_featured': instance.isFeatured,
      'weight': instance.weight,
      'weight_unit': instance.weightUnit,
      'notes': instance.notes,
      'custom_fields': instance.customFields,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$CreateProductRequestImpl _$$CreateProductRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateProductRequestImpl(
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      costPrice: json['cost_price'] as String?,
      sellingPrice: json['selling_price'] as String,
      discountPrice: json['discount_price'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt(),
      trackInventory: json['track_inventory'] as bool?,
      weight: json['weight'] as String?,
      weightUnit: json['weight_unit'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CreateProductRequestImplToJson(
        _$CreateProductRequestImpl instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'cost_price': instance.costPrice,
      'selling_price': instance.sellingPrice,
      'discount_price': instance.discountPrice,
      'stock_quantity': instance.stockQuantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'track_inventory': instance.trackInventory,
      'weight': instance.weight,
      'weight_unit': instance.weightUnit,
      'notes': instance.notes,
    };

_$UpdateProductRequestImpl _$$UpdateProductRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateProductRequestImpl(
      categoryId: json['category_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      costPrice: json['cost_price'] as String?,
      sellingPrice: json['selling_price'] as String?,
      discountPrice: json['discount_price'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt(),
      trackInventory: json['track_inventory'] as bool?,
      status: json['status'] as String?,
      isFeatured: json['is_featured'] as bool?,
      weight: json['weight'] as String?,
      weightUnit: json['weight_unit'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$UpdateProductRequestImplToJson(
        _$UpdateProductRequestImpl instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'cost_price': instance.costPrice,
      'selling_price': instance.sellingPrice,
      'discount_price': instance.discountPrice,
      'stock_quantity': instance.stockQuantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'track_inventory': instance.trackInventory,
      'status': instance.status,
      'is_featured': instance.isFeatured,
      'weight': instance.weight,
      'weight_unit': instance.weightUnit,
      'notes': instance.notes,
    };
