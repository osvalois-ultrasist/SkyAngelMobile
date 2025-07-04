import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/cognito_auth_datasource.dart';
import '../datasources/email_validation_datasource.dart';

// @LazySingleton(as: AuthRepository) // Desactivado en favor de HybridAuthRepositoryImpl
class AuthRepositoryImpl implements AuthRepository {
  final CognitoAuthDataSource _cognitoDataSource;
  final EmailValidationDataSource _emailValidationDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(
    this._cognitoDataSource,
    this._emailValidationDataSource,
    this._secureStorage,
  );

  @override
  Future<Either<AppError, AuthTokens>> signIn(
    AuthCredentials credentials,
  ) async {
    try {
      final response = await _cognitoDataSource.signIn(
        credentials.username,
        credentials.password,
      );

      final tokens = response.toAuthTokens();
      if (tokens == null) {
        return Left(
          AppError.unknown(
            message: 'Failed to parse authentication response',
            details: 'Unable to convert Cognito response to AuthTokens',
          ),
        );
      }

      await _saveTokens(tokens);
      return Right(tokens);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Sign in failed',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, UserEntity>> signUp(
    RegisterRequest request,
  ) async {
    try {
      final isAuthorized = await checkEmailAuthorization(request.email);
      
      return isAuthorized.fold(
        (error) => Left(error),
        (authorized) async {
          if (!authorized) {
            return Left(
              AppError.authorization(
                message: 'Usuario no autorizado',
                details: 'El correo electrónico no está autorizado para usar la aplicación',
              ),
            );
          }

          try {
            final cognitoUser = await _cognitoDataSource.signUp(
              request.email,
              request.password,
              request.name,
              request.familyName,
            );

            return Right(
              UserEntity(
                id: cognitoUser.username ?? '',
                email: request.email,
                name: request.name,
                familyName: request.familyName,
                username: cognitoUser.username,
              ),
            );
          } on AppError catch (e) {
            return Left(e);
          }
        },
      );
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Registration failed',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, bool>> confirmUser(
    String username,
    String code,
  ) async {
    try {
      final result = await _cognitoDataSource.confirmUser(username, code);
      return Right(result);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'User confirmation failed',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, void>> forgotPassword(String username) async {
    try {
      await _cognitoDataSource.forgotPassword(username);
      return const Right(null);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Password reset failed',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, void>> confirmPassword(
    String username,
    String code,
    String newPassword,
  ) async {
    try {
      await _cognitoDataSource.confirmPassword(username, code, newPassword);
      return const Right(null);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Password confirmation failed',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AuthTokens>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final response = await _cognitoDataSource.refreshToken(refreshToken);
      
      final tokens = response.toAuthTokens();
      if (tokens == null) {
        return Left(
          AppError.unknown(
            message: 'Failed to parse refresh response',
            details: 'Unable to convert Cognito response to AuthTokens',
          ),
        );
      }

      await _saveTokens(tokens);
      return Right(tokens);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Token refresh failed',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await _cognitoDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Failed to get current user',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, void>> signOut() async {
    try {
      await _cognitoDataSource.signOut();
      await _clearTokens();
      return const Right(null);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Sign out failed',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, bool>> checkEmailAuthorization(String email) async {
    try {
      final isAuthorized =
          await _emailValidationDataSource.checkEmailAuthorization(email);
      return Right(isAuthorized);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Email authorization check failed',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    await _secureStorage.write('access_token', tokens.accessToken);
    await _secureStorage.write('id_token', tokens.idToken);
    await _secureStorage.write('refresh_token', tokens.refreshToken);
    await _secureStorage.write(
      'expires_at',
      tokens.expiresAt?.toIso8601String() ?? '',
    );
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete('access_token');
    await _secureStorage.delete('id_token');
    await _secureStorage.delete('refresh_token');
    await _secureStorage.delete('expires_at');
  }
}