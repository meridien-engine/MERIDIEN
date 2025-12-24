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
      sku: json['sku'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      unitPrice: json['unit_price'] as String,
      costPrice: json['cost_price'] as String?,
      compareAtPrice: json['compare_at_price'] as String?,
      taxable: json['taxable'] as bool,
      taxRate: json['tax_rate'] as String?,
      barcode: json['barcode'] as String?,
      trackInventory: json['track_inventory'] as bool,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      weight: json['weight'] as String?,
      dimensions: json['dimensions'] as String?,
      imageUrl: json['image_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      active: json['active'] as bool,
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
      'sku': instance.sku,
      'description': instance.description,
      'category': instance.category,
      'brand': instance.brand,
      'unit_price': instance.unitPrice,
      'cost_price': instance.costPrice,
      'compare_at_price': instance.compareAtPrice,
      'taxable': instance.taxable,
      'tax_rate': instance.taxRate,
      'barcode': instance.barcode,
      'track_inventory': instance.trackInventory,
      'stock_quantity': instance.stockQuantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'unit': instance.unit,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'image_url': instance.imageUrl,
      'tags': instance.tags,
      'active': instance.active,
      'custom_fields': instance.customFields,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$CreateProductRequestImpl _$$CreateProductRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateProductRequestImpl(
      name: json['name'] as String,
      sku: json['sku'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      unitPrice: json['unit_price'] as String,
      costPrice: json['cost_price'] as String?,
      compareAtPrice: json['compare_at_price'] as String?,
      taxable: json['taxable'] as bool?,
      taxRate: json['tax_rate'] as String?,
      barcode: json['barcode'] as String?,
      trackInventory: json['track_inventory'] as bool?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      weight: json['weight'] as String?,
      dimensions: json['dimensions'] as String?,
      imageUrl: json['image_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      active: json['active'] as bool?,
    );

Map<String, dynamic> _$$CreateProductRequestImplToJson(
        _$CreateProductRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sku': instance.sku,
      'description': instance.description,
      'category': instance.category,
      'brand': instance.brand,
      'unit_price': instance.unitPrice,
      'cost_price': instance.costPrice,
      'compare_at_price': instance.compareAtPrice,
      'taxable': instance.taxable,
      'tax_rate': instance.taxRate,
      'barcode': instance.barcode,
      'track_inventory': instance.trackInventory,
      'stock_quantity': instance.stockQuantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'unit': instance.unit,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'image_url': instance.imageUrl,
      'tags': instance.tags,
      'active': instance.active,
    };

_$UpdateProductRequestImpl _$$UpdateProductRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateProductRequestImpl(
      name: json['name'] as String?,
      sku: json['sku'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      unitPrice: json['unit_price'] as String?,
      costPrice: json['cost_price'] as String?,
      compareAtPrice: json['compare_at_price'] as String?,
      taxable: json['taxable'] as bool?,
      taxRate: json['tax_rate'] as String?,
      barcode: json['barcode'] as String?,
      trackInventory: json['track_inventory'] as bool?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      weight: json['weight'] as String?,
      dimensions: json['dimensions'] as String?,
      imageUrl: json['image_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      active: json['active'] as bool?,
    );

Map<String, dynamic> _$$UpdateProductRequestImplToJson(
        _$UpdateProductRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sku': instance.sku,
      'description': instance.description,
      'category': instance.category,
      'brand': instance.brand,
      'unit_price': instance.unitPrice,
      'cost_price': instance.costPrice,
      'compare_at_price': instance.compareAtPrice,
      'taxable': instance.taxable,
      'tax_rate': instance.taxRate,
      'barcode': instance.barcode,
      'track_inventory': instance.trackInventory,
      'stock_quantity': instance.stockQuantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'unit': instance.unit,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'image_url': instance.imageUrl,
      'tags': instance.tags,
      'active': instance.active,
    };
