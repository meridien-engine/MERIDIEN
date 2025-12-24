import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String name,
    required String sku,
    String? description,
    String? category,
    String? brand,
    @JsonKey(name: 'unit_price') required String unitPrice,
    @JsonKey(name: 'cost_price') String? costPrice,
    @JsonKey(name: 'compare_at_price') String? compareAtPrice,
    required bool taxable,
    @JsonKey(name: 'tax_rate') String? taxRate,
    String? barcode,
    @JsonKey(name: 'track_inventory') required bool trackInventory,
    @JsonKey(name: 'stock_quantity') int? stockQuantity,
    @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
    String? unit,
    String? weight,
    String? dimensions,
    @JsonKey(name: 'image_url') String? imageUrl,
    List<String>? tags,
    required bool active,
    @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  String get stockStatus {
    if (!trackInventory) return 'Not tracked';
    if (stockQuantity == null || stockQuantity! <= 0) return 'Out of stock';
    if (lowStockThreshold != null && stockQuantity! <= lowStockThreshold!) {
      return 'Low stock';
    }
    return 'In stock';
  }

  bool get isLowStock {
    if (!trackInventory || stockQuantity == null) return false;
    if (lowStockThreshold == null) return stockQuantity! < 10;
    return stockQuantity! <= lowStockThreshold!;
  }

  bool get isOutOfStock {
    if (!trackInventory) return false;
    return stockQuantity == null || stockQuantity! <= 0;
  }
}

@freezed
class CreateProductRequest with _$CreateProductRequest {
  const factory CreateProductRequest({
    required String name,
    required String sku,
    String? description,
    String? category,
    String? brand,
    @JsonKey(name: 'unit_price') required String unitPrice,
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
    bool? active,
  }) = _CreateProductRequest;

  factory CreateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProductRequestFromJson(json);
}

@freezed
class UpdateProductRequest with _$UpdateProductRequest {
  const factory UpdateProductRequest({
    String? name,
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
    bool? active,
  }) = _UpdateProductRequest;

  factory UpdateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProductRequestFromJson(json);
}
