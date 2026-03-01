import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_model.dart';

part 'pos_model.freezed.dart';
part 'pos_model.g.dart';

@freezed
class PosSessionModel with _$PosSessionModel {
  const factory PosSessionModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'cashier_id') required String cashierId,
    required String status,
    @JsonKey(name: 'opening_float') required String openingFloat,
    @JsonKey(name: 'closing_cash') String? closingCash,
    @JsonKey(name: 'expected_cash') String? expectedCash,
    @JsonKey(name: 'cash_difference') String? cashDifference,
    @JsonKey(name: 'opened_at') required DateTime openedAt,
    @JsonKey(name: 'closed_at') DateTime? closedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PosSessionModel;

  const PosSessionModel._();

  factory PosSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PosSessionModelFromJson(json);

  bool get isOpen => status == 'open';
}

// Plain Dart class - in-memory cart item (no Freezed needed)
class PosCartItem {
  final String productId;
  final String productName;
  final String sku;
  final double unitPrice;
  int quantity;

  PosCartItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;
}

// Plain Dart classes for checkout request/response
class PosCheckoutItem {
  final String productId;
  final int quantity;

  PosCheckoutItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}

class PosCheckoutRequest {
  final String sessionId;
  final String customerName;
  final List<PosCheckoutItem> items;
  final String cashTendered;
  final String discountAmount;

  PosCheckoutRequest({
    required this.sessionId,
    required this.customerName,
    required this.items,
    required this.cashTendered,
    required this.discountAmount,
  });

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'customer_name': customerName,
        'items': items.map((e) => e.toJson()).toList(),
        'cash_tendered': cashTendered,
        'discount_amount': discountAmount,
      };
}

class PosCheckoutResult {
  final OrderModel order;
  final String change;

  PosCheckoutResult({required this.order, required this.change});

  factory PosCheckoutResult.fromJson(Map<String, dynamic> json) {
    return PosCheckoutResult(
      order: OrderModel.fromJson(json['order'] as Map<String, dynamic>),
      change: json['change'] as String? ?? '0.00',
    );
  }
}
