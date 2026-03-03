import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../../../data/models/business_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/providers/dio_provider.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final BusinessRepository _businessRepository;
  final StorageService _storageService;

  AuthNotifier(
      this._authRepository, this._businessRepository, this._storageService)
      : super(const AuthState.initial());

  /// Check if user is already logged in (auto-login on app start)
  Future<void> checkAuthStatus() async {
    try {
      // Prefer scoped token (fully authenticated)
      final hasScopedToken = await _storageService.hasScopedToken();
      if (hasScopedToken) {
        state = const AuthState.loading();
        final user = await _authRepository.getCurrentUser();
        final businessId = _storageService.getBusinessId();
        final role = _storageService.getRole() ?? 'user';

        if (businessId == null) {
          // Scoped token but no business id — shouldn't happen, recover
          await logout();
          return;
        }

        // Fetch business details
        final scopedToken = await _storageService.getToken();
        final businesses = await _authRepository.getUserBusinesses(
            scopedToken ?? '');

        final business = businesses.isNotEmpty
            ? businesses.firstWhere((b) => b.id == businessId,
                orElse: () => businesses.first)
            : null;

        if (business == null) {
          state = AuthState.noBusiness(user: user);
          return;
        }

        state = AuthState.authenticated(
            user: user, business: business, role: role);
        return;
      }

      // Check generic token (logged in but no business selected)
      final hasGenericToken = await _storageService.hasGenericToken();
      if (hasGenericToken) {
        state = const AuthState.loading();
        final genericToken = await _storageService.getGenericToken();
        final user = await _authRepository.getCurrentUser();
        final businesses =
            await _authRepository.getUserBusinesses(genericToken ?? '');

        if (businesses.isEmpty) {
          state = AuthState.noBusiness(user: user);
        } else {
          state = AuthState.selectingBusiness(
              user: user, businesses: businesses);
        }
        return;
      }

      state = const AuthState.unauthenticated();
    } catch (e) {
      await logout();
    }
  }

  /// Step 1: Login with email/password → get generic token → show business list
  Future<void> login(String email, String password) async {
    try {
      state = const AuthState.loading();

      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      await _storageService.saveGenericToken(response.token);
      await _storageService.saveUserId(response.user.id);

      // Fetch user's businesses
      final businesses =
          await _authRepository.getUserBusinesses(response.token);

      if (businesses.isEmpty) {
        state = AuthState.noBusiness(user: response.user);
      } else if (businesses.length == 1) {
        // Auto-select if only one business
        await _selectBusinessWithToken(
            response.user, businesses.first, response.token);
      } else {
        state = AuthState.selectingBusiness(
          user: response.user,
          businesses: businesses,
        );
      }
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Step 2: Select a business → get scoped token → authenticated
  Future<void> selectBusiness(BusinessModel business) async {
    try {
      state = const AuthState.loading();

      final genericToken = await _storageService.getGenericToken();
      if (genericToken == null) {
        state = const AuthState.error('Please log in again');
        return;
      }

      final scoped =
          await _authRepository.useBusiness(genericToken, business.id);

      await _storageService.saveToken(scoped.token);
      await _storageService.saveBusinessId(business.id);
      await _storageService.saveRole(scoped.role);

      final user = await _authRepository.getCurrentUser();

      state = AuthState.authenticated(
        user: user,
        business: business,
        role: scoped.role,
      );
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Register new user — auto-logs in with generic token, lands on no-business
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();

      final response = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      await _storageService.saveGenericToken(response.token);
      await _storageService.saveUserId(response.user.id);

      state = AuthState.noBusiness(user: response.user);
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// After creating a new business, auto-select it
  Future<void> afterCreateBusiness(BusinessModel business) async {
    try {
      state = const AuthState.loading();
      final genericToken = await _storageService.getGenericToken();
      if (genericToken == null) {
        state = const AuthState.error('Please log in again');
        return;
      }
      await _selectBusinessWithToken(
          null, business, genericToken);
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    state = const AuthState.unauthenticated();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<void> _selectBusinessWithToken(
    dynamic user,
    BusinessModel business,
    String genericToken,
  ) async {
    final scoped =
        await _authRepository.useBusiness(genericToken, business.id);

    await _storageService.saveToken(scoped.token);
    await _storageService.saveBusinessId(business.id);
    await _storageService.saveRole(scoped.role);

    final currentUser = await _authRepository.getCurrentUser();

    state = AuthState.authenticated(
      user: currentUser,
      business: business,
      role: scoped.role,
    );
  }

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
  final businessRepository = ref.watch(businessRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authRepository, businessRepository, storageService);
});
