import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_credentials.freezed.dart';

@freezed
class AuthCredentials with _$AuthCredentials {
  const factory AuthCredentials({
    required String username,
    required String password,
  }) = _AuthCredentials;

  const AuthCredentials._();
}