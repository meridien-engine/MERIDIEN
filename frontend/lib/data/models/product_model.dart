import 'package:freezed_annotation/freezed_annotation.dart';
import 'category_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String name,
    String? slug,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    CategoryModel? category,
    String? sku,
    String? barcode,
    @JsonKey(name: 'cost_price') required String costPrice,
    @JsonKey(name: 'selling_price') required String sellingPrice,
    @JsonKey(name: 'discount_price') String? discountPrice,
    @JsonKey(name: 'stock_quantity') required int stockQuantity,
    @JsonKey(name: 'low_stock_threshold') required int lowStockThreshold,
    @JsonKey(name: 'track_inventory') required bool trackInventory,
    required String status,
    @JsonKey(name: 'is_featured') required bool isFeatured,
    String? weight,
    @JsonKey(name: 'weight_unit') required String weightUnit,
    String? notes,
    @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  bool get isActive => status == 'active';

  String get stockStatus {
    if (!trackInventory) return 'Not tracked';
    if (stockQuantity <= 0) return 'Out of stock';
    if (stockQuantity <= lowStockThreshold) {
      return 'Low stock';
    }
    return 'In stock';
  }

  bool get isLowStock {
    if (!trackInventory) return false;
    return stockQuantity <= lowStockThreshold && stockQuantity > 0;
  }

  bool get isOutOfStock {
    if (!trackInventory) return false;
    return stockQuantity <= 0;
  }

  String get displayPrice {
    if (discountPrice != null && discountPrice!.isNotEmpty) {
      return discountPrice!;
    }
    return sellingPrice;
  }
}

@freezed
class CreateProductRequest with _$CreateProductRequest {
  const factory CreateProductRequest({
    @JsonKey(name: 'category_id') String? categoryId,
    required String name,
    String? description,
    String? sku,
    String? barcode,
    @JsonKey(name: 'cost_price') String? costPrice,
    @JsonKey(name: 'selling_price') required String sellingPrice,
    @JsonKey(name: 'discount_price') String? discountPrice,
    @JsonKey(name: 'stock_quantity') int? stockQuantity,
    @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
    @JsonKey(name: 'track_inventory') bool? trackInventory,
    String? weight,
    @JsonKey(name: 'weight_unit') String? weightUnit,
    String? notes,
  }) = _CreateProductRequest;

  factory CreateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProductRequestFromJson(json);
}

@freezed
class UpdateProductRequest with _$UpdateProductRequest {
  const factory UpdateProductRequest({
    @JsonKey(name: 'category_id') String? categoryId,
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
    String? notes,
  }) = _UpdateProductRequest;

  factory UpdateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProductRequestFromJson(json);
}
