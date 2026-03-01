import 'package:freezed_annotation/freezed_annotation.dart';

part 'courier_model.freezed.dart';
part 'courier_model.g.dart';

@freezed
class CourierModel with _$CourierModel {
  const factory CourierModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String name,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CourierModel;

  factory CourierModel.fromJson(Map<String, dynamic> json) =>
      _$CourierModelFromJson(json);
}

// Courier Reconciliation
@freezed
class CourierReconciliationModel with _$CourierReconciliationModel {
  const factory CourierReconciliationModel({
    @JsonKey(name: 'courier_id') required String courierId,
    @JsonKey(name: 'courier_name') required String courierName,
    @JsonKey(name: 'delivered_amount') required String deliveredAmount,
    @JsonKey(name: 'collected_amount') required String collectedAmount,
    @JsonKey(name: 'pending_amount') required String pendingAmount,
  }) = _CourierReconciliationModel;

  const CourierReconciliationModel._();

  factory CourierReconciliationModel.fromJson(Map<String, dynamic> json) =>
      _$CourierReconciliationModelFromJson(json);

  double get deliveredAmountValue => double.tryParse(deliveredAmount) ?? 0.0;
  double get collectedAmountValue => double.tryParse(collectedAmount) ?? 0.0;
  double get pendingAmountValue => double.tryParse(pendingAmount) ?? 0.0;
}

// Create Courier Request
@freezed
class CreateCourierRequest with _$CreateCourierRequest {
  const factory CreateCourierRequest({required String name}) =
      _CreateCourierRequest;

  factory CreateCourierRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCourierRequestFromJson(json);
}

// Update Courier Request
@freezed
class UpdateCourierRequest with _$UpdateCourierRequest {
  const factory UpdateCourierRequest({String? name}) = _UpdateCourierRequest;

  factory UpdateCourierRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCourierRequestFromJson(json);
}
