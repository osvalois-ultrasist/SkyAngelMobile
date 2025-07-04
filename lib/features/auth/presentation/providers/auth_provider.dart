import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/usecases/confirm_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(
    signInUseCase: GetIt.I<SignInUseCase>(),
    signUpUseCase: GetIt.I<SignUpUseCase>(),
    confirmUserUseCase: GetIt.I<ConfirmUserUseCase>(),
    resetPasswordUseCase: GetIt.I<ResetPasswordUseCase>(),
    authRepository: GetIt.I<AuthRepository>(),
    secureStorage: GetIt.I<SecureStorage>(),
  );
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final ConfirmUserUseCase confirmUserUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository authRepository;
  final SecureStorage secureStorage;

  AuthStateNotifier({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.confirmUserUseCase,
    required this.resetPasswordUseCase,
    required this.authRepository,
    required this.secureStorage,
  }) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final accessToken = await secureStorage.read('access_token');
    if (accessToken != null && accessToken.isNotEmpty) {
      final userResult = await authRepository.getCurrentUser();
      userResult.fold(
        (error) => state = state.copyWith(isAuthenticated: false),
        (user) => state = state.copyWith(
          isAuthenticated: true,
          user: user,
        ),
      );
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final credentials = AuthCredentials(
      username: username,
      password: password,
    );

    final result = await signInUseCase(credentials);

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        error: error.message,
      ),
      (tokens) async {
        final userResult = await authRepository.getCurrentUser();
        userResult.fold(
          (error) => state = state.copyWith(
            isLoading: false,
            error: error.message,
          ),
          (user) => state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: user,
            tokens: tokens,
          ),
        );
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String familyName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final request = RegisterRequest(
      email: email,
      password: password,
      name: name,
      familyName: familyName,
    );

    final result = await signUpUseCase(request);

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        error: error.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
      ),
    );
  }

  Future<bool> confirmUser({
    required String username,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await confirmUserUseCase(
      username: username,
      code: code,
    );

    return result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(isLoading: false);
        return success;
      },
    );
  }

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await resetPasswordUseCase.requestCode(email);

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        error: error.message,
      ),
      (_) => state = state.copyWith(isLoading: false),
    );
  }

  Future<bool> confirmPasswordReset({
    required String username,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await resetPasswordUseCase.confirmNewPassword(
      username: username,
      code: code,
      newPassword: newPassword,
    );

    return result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}