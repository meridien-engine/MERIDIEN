import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/store_model.dart';
import '../../../data/repositories/store_repository.dart';
import '../../../data/providers/repository_providers.dart';

class StoreListState {
  final List<StoreModel> stores;
  final bool isLoading;
  final String? error;

  const StoreListState({
    this.stores = const [],
    this.isLoading = false,
    this.error,
  });

  StoreListState copyWith({
    List<StoreModel>? stores,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StoreListState(
      stores: stores ?? this.stores,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StoreNotifier extends StateNotifier<StoreListState> {
  final StoreRepository _repository;

  StoreNotifier(this._repository) : super(const StoreListState());

  Future<void> listStores() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.listStores();
      state = state.copyWith(stores: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<StoreModel?> createStore(CreateStoreRequest request) async {
    try {
      final store = await _repository.createStore(request);
      await listStores();
      return store;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<StoreModel?> updateStore(String id, UpdateStoreRequest request) async {
    try {
      final store = await _repository.updateStore(id, request);
      await listStores();
      return store;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> deleteStore(String id) async {
    try {
      await _repository.deleteStore(id);
      await listStores();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final storeProvider =
    StateNotifierProvider<StoreNotifier, StoreListState>((ref) {
  final repository = ref.watch(storeRepositoryProvider);
  return StoreNotifier(repository);
});
