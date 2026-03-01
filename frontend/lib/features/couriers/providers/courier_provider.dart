import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/courier_model.dart';
import '../../../data/repositories/courier_repository.dart';
import '../../../data/providers/repository_providers.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class CourierListState {
  final List<CourierModel> couriers;
  final bool isLoading;
  final String? error;

  const CourierListState({
    this.couriers = const [],
    this.isLoading = false,
    this.error,
  });

  CourierListState copyWith({
    List<CourierModel>? couriers,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CourierListState(
      couriers: couriers ?? this.couriers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CourierReconciliationState {
  final List<CourierReconciliationModel> items;
  final bool isLoading;
  final String? error;
  final String? fromDate;
  final String? toDate;

  const CourierReconciliationState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.fromDate,
    this.toDate,
  });

  CourierReconciliationState copyWith({
    List<CourierReconciliationModel>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? fromDate,
    String? toDate,
  }) {
    return CourierReconciliationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

// ─── Courier Notifier ─────────────────────────────────────────────────────────

class CourierNotifier extends StateNotifier<CourierListState> {
  final CourierRepository _repository;

  CourierNotifier(this._repository) : super(const CourierListState());

  Future<void> listCouriers({int page = 1, int pageSize = 50}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items =
          await _repository.listCouriers(page: page, pageSize: pageSize);
      state = state.copyWith(couriers: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<CourierModel?> createCourier(CreateCourierRequest request) async {
    try {
      final courier = await _repository.createCourier(request);
      await listCouriers();
      return courier;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<CourierModel?> updateCourier(
      String id, UpdateCourierRequest request) async {
    try {
      final courier = await _repository.updateCourier(id, request);
      await listCouriers();
      return courier;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> deleteCourier(String id) async {
    try {
      await _repository.deleteCourier(id);
      await listCouriers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearCache() {
    state = const CourierListState();
  }
}

// ─── Reconciliation Notifier ──────────────────────────────────────────────────

class CourierReconciliationNotifier
    extends StateNotifier<CourierReconciliationState> {
  final CourierRepository _repository;

  CourierReconciliationNotifier(this._repository)
      : super(const CourierReconciliationState());

  Future<void> loadReconciliation({String? fromDate, String? toDate}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      fromDate: fromDate,
      toDate: toDate,
    );
    try {
      final items = await _repository.getReconciliation(
        fromDate: fromDate,
        toDate: toDate,
      );
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final courierProvider =
    StateNotifierProvider<CourierNotifier, CourierListState>((ref) {
  final repository = ref.watch(courierRepositoryProvider);
  return CourierNotifier(repository);
});

final courierReconciliationProvider = StateNotifierProvider<
    CourierReconciliationNotifier, CourierReconciliationState>((ref) {
  final repository = ref.watch(courierRepositoryProvider);
  return CourierReconciliationNotifier(repository);
});
