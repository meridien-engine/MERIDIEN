import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/membership_model.dart';
import '../../../data/models/business_model.dart';
import '../../../data/repositories/membership_repository.dart';
import '../../../data/providers/repository_providers.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class MembershipState {
  final List<JoinRequestModel> myRequests;
  final List<JoinRequestModel> businessRequests;
  final List<InvitationModel> invitations;
  final List<MemberModel> members;
  final BusinessModel? lookedUpBusiness;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const MembershipState({
    this.myRequests = const [],
    this.businessRequests = const [],
    this.invitations = const [],
    this.members = const [],
    this.lookedUpBusiness,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  MembershipState copyWith({
    List<JoinRequestModel>? myRequests,
    List<JoinRequestModel>? businessRequests,
    List<InvitationModel>? invitations,
    List<MemberModel>? members,
    BusinessModel? lookedUpBusiness,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearBusiness = false,
  }) {
    return MembershipState(
      myRequests: myRequests ?? this.myRequests,
      businessRequests: businessRequests ?? this.businessRequests,
      invitations: invitations ?? this.invitations,
      members: members ?? this.members,
      lookedUpBusiness: clearBusiness ? null : (lookedUpBusiness ?? this.lookedUpBusiness),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class MembershipNotifier extends StateNotifier<MembershipState> {
  final MembershipRepository _repo;

  MembershipNotifier(this._repo) : super(const MembershipState());

  // ── Business lookup ────────────────────────────────────────────────────────

  Future<void> lookupBusiness(String slug) async {
    state = state.copyWith(isLoading: true, clearError: true, clearBusiness: true);
    try {
      final business = await _repo.lookupBySlug(slug);
      state = state.copyWith(isLoading: false, lookedUpBusiness: business);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearLookedUpBusiness() {
    state = state.copyWith(clearBusiness: true);
  }

  // ── My join requests ───────────────────────────────────────────────────────

  Future<void> loadMyJoinRequests() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final requests = await _repo.listMyJoinRequests();
      state = state.copyWith(myRequests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> submitJoinRequest({
    required String businessSlug,
    String? message,
    String? role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.submitJoinRequest(
        businessSlug: businessSlug,
        message: message,
        role: role,
      );
      await loadMyJoinRequests();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Join request submitted successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Business join requests (admin) ─────────────────────────────────────────

  Future<void> loadBusinessJoinRequests(String businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final requests = await _repo.listBusinessJoinRequests(businessId);
      state = state.copyWith(businessRequests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> approveJoinRequest(
      String businessId, String requestId, {String? role}) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.approveJoinRequest(businessId, requestId, role: role);
      await loadBusinessJoinRequests(businessId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Join request approved',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> rejectJoinRequest(String businessId, String requestId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.rejectJoinRequest(businessId, requestId);
      await loadBusinessJoinRequests(businessId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Join request rejected',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Invitations ────────────────────────────────────────────────────────────

  Future<void> loadInvitations(String businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final invitations = await _repo.listInvitations(businessId);
      state = state.copyWith(invitations: invitations, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> sendInvitation({
    required String businessId,
    required String email,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.sendInvitation(businessId: businessId, email: email, role: role);
      await loadInvitations(businessId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Invitation sent to $email',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Members ────────────────────────────────────────────────────────────────

  Future<void> loadMembers(String businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final members = await _repo.listMembers(businessId);
      state = state.copyWith(members: members, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> updateMemberRole(
      String businessId, String userId, String role) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.updateMemberRole(businessId, userId, role);
      await loadMembers(businessId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Role updated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> removeMember(String businessId, String userId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.removeMember(businessId, userId);
      await loadMembers(businessId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Member removed',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final membershipProvider =
    StateNotifierProvider<MembershipNotifier, MembershipState>((ref) {
  final repo = ref.watch(membershipRepositoryProvider);
  return MembershipNotifier(repo);
});
