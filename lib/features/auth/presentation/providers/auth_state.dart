import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    UserEntity? user,
    AuthTokens? tokens,
    String? error,
  }) = _AuthState;

  const AuthState._();
}