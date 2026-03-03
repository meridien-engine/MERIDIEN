import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/business_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required UserModel user,
    required BusinessModel business,
    required String role,
  }) = _Authenticated;
  const factory AuthState.selectingBusiness({
    required UserModel user,
    required List<BusinessModel> businesses,
  }) = _SelectingBusiness;
  const factory AuthState.noBusiness({
    required UserModel user,
  }) = _NoBusiness;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
