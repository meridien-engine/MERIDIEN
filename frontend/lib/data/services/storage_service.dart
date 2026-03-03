import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _scopedTokenKey = 'jwt_scoped_token';
  static const String _genericTokenKey = 'jwt_generic_token';
  static const String _businessIdKey = 'business_id';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'role';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  // ── Scoped JWT (used for protected business routes) ──────────────────────
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _scopedTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _scopedTokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _scopedTokenKey);
  }

  // ── Generic JWT (issued on login before business selection) ───────────────
  Future<void> saveGenericToken(String token) async {
    await _secureStorage.write(key: _genericTokenKey, value: token);
  }

  Future<String?> getGenericToken() async {
    return await _secureStorage.read(key: _genericTokenKey);
  }

  Future<void> deleteGenericToken() async {
    await _secureStorage.delete(key: _genericTokenKey);
  }

  // ── Business ID (SharedPreferences) ──────────────────────────────────────
  Future<void> saveBusinessId(String businessId) async {
    await _prefs.setString(_businessIdKey, businessId);
  }

  String? getBusinessId() {
    return _prefs.getString(_businessIdKey);
  }

  Future<void> deleteBusinessId() async {
    await _prefs.remove(_businessIdKey);
  }

  // ── Role (SharedPreferences) ──────────────────────────────────────────────
  Future<void> saveRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  String? getRole() {
    return _prefs.getString(_roleKey);
  }

  Future<void> deleteRole() async {
    await _prefs.remove(_roleKey);
  }

  // ── User ID (SharedPreferences) ───────────────────────────────────────────
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  Future<void> deleteUserId() async {
    await _prefs.remove(_userIdKey);
  }

  // ── Clear all auth data ───────────────────────────────────────────────────
  Future<void> clearAll() async {
    await deleteToken();
    await deleteGenericToken();
    await deleteBusinessId();
    await deleteRole();
    await deleteUserId();
  }

  // ── Auth status checks ────────────────────────────────────────────────────
  Future<bool> hasScopedToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasGenericToken() async {
    final token = await getGenericToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isLoggedIn() async {
    return await hasScopedToken();
  }

  // Legacy alias kept for backward compat
  Future<void> saveTenantSlug(String slug) async {}
  String? getTenantSlug() => null;
}
