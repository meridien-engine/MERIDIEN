import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'order_number') required String orderNumber,
    @JsonKey(name: 'customer_id') required String customerId,
    required String status,
    @JsonKey(name: 'payment_status') required String paymentStatus,
    @JsonKey(name: 'order_date') required DateTime orderDate,

    // Financial fields - match backend exactly
    required String subtotal,
    @JsonKey(name: 'tax_amount') required String taxAmount,
    @JsonKey(name: 'discount_amount') required String discountAmount,
    @JsonKey(name: 'shipping_amount') required String shippingAmount,
    @JsonKey(name: 'total_amount') required String totalAmount,
    @JsonKey(name: 'paid_amount') required String paidAmount,

    // Shipping address fields - match backend exactly
    @JsonKey(name: 'shipping_address_line1') String? shippingAddressLine1,
    @JsonKey(name: 'shipping_address_line2') String? shippingAddressLine2,
    @JsonKey(name: 'shipping_city') String? shippingCity,
    @JsonKey(name: 'shipping_state') String? shippingState,
    @JsonKey(name: 'shipping_postal_code') String? shippingPostalCode,
    @JsonKey(name: 'shipping_country') String? shippingCountry,

    // Notes
    String? notes,
    @JsonKey(name: 'internal_notes') String? internalNotes,

    // Relationships
    List<OrderItemModel>? items,
    List<PaymentModel>? payments,
    CustomerModel? customer,

    // Additional fields
    @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _OrderModel;

  const OrderModel._();

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  String get shippingAddressFull {
    final parts = [
      shippingAddressLine1,
      shippingAddressLine2,
      shippingCity,
      shippingState,
      shippingPostalCode,
      shippingCountry,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }

  double get subtotalAmount => double.tryParse(subtotal) ?? 0.0;
  double get taxAmountValue => double.tryParse(taxAmount) ?? 0.0;
  double get discountAmountValue => double.tryParse(discountAmount) ?? 0.0;
  double get shippingAmountValue => double.tryParse(shippingAmount) ?? 0.0;
  double get totalAmountValue => double.tryParse(totalAmount) ?? 0.0;
  double get paidAmountValue => double.tryParse(paidAmount) ?? 0.0;

  int get itemCount => items?.length ?? 0;

  double get balanceDue => totalAmountValue - paidAmountValue;

  bool get isPaid => paymentStatus == 'paid';
  bool get isPartiallyPaid => paymentStatus == 'partial';
  bool get isUnpaid => paymentStatus == 'unpaid';
  bool get isOverdue => paymentStatus == 'overdue';

  bool get isDraft => status == 'draft';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
}

// Simple CustomerModel for order relationship
@freezed
class CustomerModel with _$CustomerModel {
  const factory CustomerModel({
    required String id,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? email,
    String? phone,
    String? company,
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);
}

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'product_sku') String? productSku,
    required int quantity,
    @JsonKey(name: 'unit_price') required String unitPrice,
    @JsonKey(name: 'tax_amount') required String taxAmount,
    @JsonKey(name: 'discount_amount') required String discountAmount,
    @JsonKey(name: 'line_total') required String lineTotal,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _OrderItemModel;

  const OrderItemModel._();

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  double get unitPriceValue => double.tryParse(unitPrice) ?? 0.0;
  double get taxAmountValue => double.tryParse(taxAmount) ?? 0.0;
  double get discountAmountValue => double.tryParse(discountAmount) ?? 0.0;
  double get lineTotalValue => double.tryParse(lineTotal) ?? 0.0;
}

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'payment_date') required DateTime paymentDate,
    required String amount,
    @JsonKey(name: 'payment_method') required String paymentMethod,
    @JsonKey(name: 'transaction_reference') String? transactionReference,
    required String status,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PaymentModel;

  const PaymentModel._();

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  double get amountValue => double.tryParse(amount) ?? 0.0;
}

// Create Order Request - matches backend API exactly
@freezed
class CreateOrderRequest with _$CreateOrderRequest {
  const factory CreateOrderRequest({
    @JsonKey(name: 'customer_id') required String customerId,
    required List<CreateOrderItemRequest> items,
    @JsonKey(name: 'tax_amount') String? taxAmount,
    @JsonKey(name: 'discount_amount') String? discountAmount,
    @JsonKey(name: 'shipping_amount') String? shippingAmount,
    @JsonKey(name: 'shipping_address') ShippingAddressRequest? shippingAddress,
    String? notes,
    @JsonKey(name: 'internal_notes') String? internalNotes,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);
}

@freezed
class CreateOrderItemRequest with _$CreateOrderItemRequest {
  const factory CreateOrderItemRequest({
    @JsonKey(name: 'product_id') required String productId,
    required int quantity,
    @JsonKey(name: 'discount_amount') String? discountAmount,
    @JsonKey(name: 'tax_amount') String? taxAmount,
    String? notes,
  }) = _CreateOrderItemRequest;

  factory CreateOrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderItemRequestFromJson(json);
}

@freezed
class ShippingAddressRequest with _$ShippingAddressRequest {
  const factory ShippingAddressRequest({
    @JsonKey(name: 'address_line1') String? addressLine1,
    @JsonKey(name: 'address_line2') String? addressLine2,
    String? city,
    String? state,
    @JsonKey(name: 'postal_code') String? postalCode,
    String? country,
  }) = _ShippingAddressRequest;

  factory ShippingAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressRequestFromJson(json);
}

// Update Order Request - matches backend API exactly
@freezed
class UpdateOrderRequest with _$UpdateOrderRequest {
  const factory UpdateOrderRequest({
    @JsonKey(name: 'tax_amount') String? taxAmount,
    @JsonKey(name: 'discount_amount') String? discountAmount,
    @JsonKey(name: 'shipping_amount') String? shippingAmount,
    @JsonKey(name: 'shipping_address') ShippingAddressRequest? shippingAddress,
    String? notes,
    @JsonKey(name: 'internal_notes') String? internalNotes,
  }) = _UpdateOrderRequest;

  factory UpdateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderRequestFromJson(json);
}

// Record Payment Request - matches backend API exactly
@freezed
class RecordPaymentRequest with _$RecordPaymentRequest {
  const factory RecordPaymentRequest({
    @JsonKey(name: 'payment_method') required String paymentMethod,
    required String amount,
    @JsonKey(name: 'transaction_reference') String? transactionReference,
    String? notes,
  }) = _RecordPaymentRequest;

  factory RecordPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$RecordPaymentRequestFromJson(json);
}
