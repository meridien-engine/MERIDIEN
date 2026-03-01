import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../../../data/models/tenant_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/providers/dio_provider.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthNotifier(this._authRepository, this._storageService)
      : super(const AuthState.initial());

  // Check if user is already logged in (auto-login)
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();

      if (isLoggedIn) {
        state = const AuthState.loading();
        final user = await _authRepository.getCurrentUser();

        final tenantSlug = _storageService.getTenantSlug();
        if (tenantSlug == null) {
          await logout();
          return;
        }

        final tenant = TenantModel(
          id: user.tenantId,
          name: tenantSlug,
          slug: tenantSlug,
          isActive: true,
        );

        state = AuthState.authenticated(user: user, tenant: tenant);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      await logout();
    }
  }

  // Step 1: discover workspaces for the given email + password
  Future<void> discoverWorkspaces(String email, String password) async {
    try {
      state = const AuthState.loading();
      final workspaces = await _authRepository.discoverWorkspaces(
        email: email,
        password: password,
      );
      state = AuthState.workspaceSelection(
        email: email,
        password: password,
        workspaces: workspaces,
      );
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  // Step 2: login with the selected workspace
  Future<void> selectWorkspace(
      String tenantSlug, String email, String password) async {
    try {
      state = const AuthState.loading();

      final response = await _authRepository.login(
        tenantSlug: tenantSlug,
        email: email,
        password: password,
      );

      await _storageService.saveToken(response.token);
      await _storageService.saveTenantSlug(tenantSlug);
      await _storageService.saveUserId(response.user.id);

      state = AuthState.authenticated(
        user: response.user,
        tenant: response.tenant,
      );
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  // Register
  Future<void> register({
    required String tenantSlug,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();

      final response = await _authRepository.register(
        tenantSlug: tenantSlug,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      await _storageService.saveToken(response.token);
      await _storageService.saveTenantSlug(tenantSlug);
      await _storageService.saveUserId(response.user.id);

      state = AuthState.authenticated(
        user: response.user,
        tenant: response.tenant,
      );
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    state = const AuthState.unauthenticated();
  }

  // Extract error message from exception
  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response!.data as Map<String, dynamic>;
        return data['error'] ?? data['message'] ?? 'An error occurred';
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authRepository, storageService);
});
