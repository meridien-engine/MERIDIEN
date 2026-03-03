import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

/// MERIDIEN RBAC roles as defined in the backend
enum MeridienRole {
  operator,
  collector,
  owner,
}

extension MeridienRoleExt on MeridienRole {
  String get value {
    switch (this) {
      case MeridienRole.operator:
        return 'operator';
      case MeridienRole.collector:
        return 'collector';
      case MeridienRole.owner:
        return 'owner';
    }
  }
}

MeridienRole? _parseRole(String? raw) {
  if (raw == null) return null;
  switch (raw.toLowerCase()) {
    case 'operator':
      return MeridienRole.operator;
    case 'collector':
      return MeridienRole.collector;
    case 'owner':
      return MeridienRole.owner;
    default:
      return null;
  }
}

/// Provider that exposes the current user's RBAC role (or null if unauthenticated)
final currentUserRoleProvider = Provider<MeridienRole?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user, _, role) => _parseRole(role),
    orElse: () => null,
  );
});

/// Provider that exposes the full role string
final currentUserRoleStringProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user, _, role) => role,
    orElse: () => null,
  );
});

/// Helper to check if the current user has a given role
extension RoleCheck on WidgetRef {
  MeridienRole? get userRole => watch(currentUserRoleProvider);

  bool get isOwner => userRole == MeridienRole.owner;
  bool get isOperator => userRole == MeridienRole.operator;
  bool get isCollector => userRole == MeridienRole.collector;

  /// Returns true if user has at least one of the given roles
  bool hasAnyRole(List<MeridienRole> roles) {
    final role = userRole;
    if (role == null) return false;
    return roles.contains(role);
  }
}
