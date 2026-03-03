import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Response from POST /auth/login and POST /auth/register (step 1 — generic token)
@freezed
class GenericAuthResponse with _$GenericAuthResponse {
  const factory GenericAuthResponse({
    required String token,
    required UserModel user,
    @Default('generic') String type,
  }) = _GenericAuthResponse;

  factory GenericAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$GenericAuthResponseFromJson(json);
}

/// Response from POST /auth/use-business/:id (step 2 — scoped token)
@freezed
class ScopedAuthResponse with _$ScopedAuthResponse {
  const factory ScopedAuthResponse({
    required String token,
    required String role,
    @Default('scoped') String type,
  }) = _ScopedAuthResponse;

  factory ScopedAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$ScopedAuthResponseFromJson(json);
}

// Keep backward compat alias
typedef AuthResponseModel = GenericAuthResponse;
