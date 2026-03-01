import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/tenant_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required UserModel user,
    TenantModel? tenant,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.workspaceSelection({
    required String email,
    required String password,
    required List<TenantModel> workspaces,
  }) = _WorkspaceSelection;
  const factory AuthState.error(String message) = _Error;
}
