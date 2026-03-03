import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';

part 'branch_inventory_model.freezed.dart';
part 'branch_inventory_model.g.dart';

@freezed
class BranchInventoryModel with _$BranchInventoryModel {
  const BranchInventoryModel._();

  const factory BranchInventoryModel({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'stock_quantity') @Default(0) int stockQuantity,
    @JsonKey(name: 'price_override') String? priceOverride,
    @JsonKey(name: 'low_stock_threshold') @Default(5) int lowStockThreshold,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    ProductModel? product,
  }) = _BranchInventoryModel;

  factory BranchInventoryModel.fromJson(Map<String, dynamic> json) =>
      _$BranchInventoryModelFromJson(json);

  bool get isLowStock => stockQuantity <= lowStockThreshold;
  bool get isOutOfStock => stockQuantity == 0;

  /// Returns price_override if set, otherwise the product's selling_price
  String get effectivePrice {
    if (priceOverride != null && priceOverride!.isNotEmpty) {
      return priceOverride!;
    }
    return product?.sellingPrice ?? '0';
  }
}

@freezed
class ActivateProductRequest with _$ActivateProductRequest {
  const factory ActivateProductRequest({
    @JsonKey(name: 'stock_quantity') @Default(0) int stockQuantity,
    @JsonKey(name: 'price_override') String? priceOverride,
    @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
  }) = _ActivateProductRequest;

  factory ActivateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$ActivateProductRequestFromJson(json);
}

@freezed
class UpdateInventoryRequest with _$UpdateInventoryRequest {
  const factory UpdateInventoryRequest({
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'stock_quantity') int? stockQuantity,
    @JsonKey(name: 'price_override') @Default('') String priceOverride,
    @JsonKey(name: 'low_stock_threshold') int? lowStockThreshold,
  }) = _UpdateInventoryRequest;

  factory UpdateInventoryRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateInventoryRequestFromJson(json);
}
