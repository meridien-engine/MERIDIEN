import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/repositories/branch_repository.dart';
import '../../../data/providers/repository_providers.dart';

class BranchListState {
  final List<BranchModel> branches;
  final bool isLoading;
  final String? error;

  const BranchListState({
    this.branches = const [],
    this.isLoading = false,
    this.error,
  });

  BranchListState copyWith({
    List<BranchModel>? branches,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BranchListState(
      branches: branches ?? this.branches,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BranchNotifier extends StateNotifier<BranchListState> {
  final BranchRepository _repository;
  String? _currentBusinessId;

  BranchNotifier(this._repository) : super(const BranchListState());

  Future<void> listBranches(String businessId) async {
    _currentBusinessId = businessId;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.listBranches(businessId);
      state = state.copyWith(branches: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<BranchModel?> createBranch(String businessId, CreateBranchRequest request) async {
    try {
      final branch = await _repository.createBranch(businessId, request);
      await listBranches(businessId);
      return branch;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<BranchModel?> updateBranch(String id, UpdateBranchRequest request) async {
    try {
      final branch = await _repository.updateBranch(id, request);
      if (_currentBusinessId != null) await listBranches(_currentBusinessId!);
      return branch;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> deleteBranch(String id) async {
    try {
      await _repository.deleteBranch(id);
      if (_currentBusinessId != null) await listBranches(_currentBusinessId!);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final branchProvider =
    StateNotifierProvider<BranchNotifier, BranchListState>((ref) {
  final repository = ref.watch(branchRepositoryProvider);
  return BranchNotifier(repository);
});
