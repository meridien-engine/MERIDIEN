import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/customer_model.dart';

part 'customer_state.freezed.dart';

@freezed
class CustomerListState with _$CustomerListState {
  const factory CustomerListState.initial() = _Initial;
  const factory CustomerListState.loading() = _Loading;
  const factory CustomerListState.loaded({
    required List<CustomerModel> customers,
    required int total,
    required int page,
    required bool hasMore,
  }) = _Loaded;
  const factory CustomerListState.error(String message) = _Error;
}

@freezed
class CustomerDetailState with _$CustomerDetailState {
  const factory CustomerDetailState.initial() = _DetailInitial;
  const factory CustomerDetailState.loading() = _DetailLoading;
  const factory CustomerDetailState.loaded(CustomerModel customer) = _DetailLoaded;
  const factory CustomerDetailState.error(String message) = _DetailError;
}
