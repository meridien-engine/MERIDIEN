import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/branch_inventory_model.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/repositories/branch_inventory_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class BranchInventoryState {
  final List<BranchInventoryModel> items;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const BranchInventoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  BranchInventoryState copyWith({
    List<BranchInventoryModel>? items,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BranchInventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BranchInventoryNotifier extends StateNotifier<BranchInventoryState> {
  final BranchInventoryRepository _repo;
  String? _currentBranchId;

  BranchInventoryNotifier(this._repo) : super(const BranchInventoryState());

  Future<void> loadInventory(String branchId) async {
    _currentBranchId = branchId;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repo.listByBranch(branchId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> activate(
    String branchId,
    String productId,
    ActivateProductRequest request,
  ) async {
    try {
      await _repo.activate(branchId, productId, request);
      await loadInventory(branchId);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> update(
    String branchId,
    String productId,
    UpdateInventoryRequest request,
  ) async {
    try {
      await _repo.update(branchId, productId, request);
      await loadInventory(branchId);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deactivate(String branchId, String productId) async {
    try {
      await _repo.deactivate(branchId, productId);
      if (_currentBranchId != null) await loadInventory(_currentBranchId!);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ── Provider ──────────────────────────────────────────────────────────────────

final branchInventoryProvider =
    StateNotifierProvider<BranchInventoryNotifier, BranchInventoryState>((ref) {
  final repo = ref.watch(branchInventoryRepositoryProvider);
  return BranchInventoryNotifier(repo);
});
