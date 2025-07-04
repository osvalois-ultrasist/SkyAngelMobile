import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api_auth_datasource.dart';
import '../datasources/cognito_auth_datasource.dart';
import '../datasources/email_validation_datasource.dart';
import '../models/user_model.dart';

/// Implementación híbrida del repositorio de autenticación
/// Permite usar tanto Cognito como la API mock dependiendo de la configuración
@LazySingleton(as: AuthRepository)
class HybridAuthRepositoryImpl implements AuthRepository {
  final CognitoAuthDataSource _cognitoAuthDataSource;
  final ApiAuthDataSource _apiAuthDataSource;
  final EmailValidationDataSource _emailValidationDataSource;
  final SecureStorage _secureStorage;

  // Configuración para determinar qué datasource usar
  static const bool _useApiAuth = true; // Cambiar a false para usar Cognito

  HybridAuthRepositoryImpl(
    this._cognitoAuthDataSource,
    this._apiAuthDataSource,
    this._emailValidationDataSource,
    this._secureStorage,
  );

  @override
  Future<UserEntity> signIn(AuthCredentials credentials) async {
    try {
      AppLogger.info('Attempting sign in for user: ${credentials.username}');

      if (_useApiAuth) {
        // Usar API mock
        final response = await _apiAuthDataSource.signInWithToken(
          credentials.username,
          credentials.password,
        );

        // Guardar el token de forma segura
        await _secureStorage.write('access_token', response.token);
        await _secureStorage.write('user_id', response.user.id.toString());

        AppLogger.info('API authentication successful');
        return response.user.toEntity();
      } else {
        // Usar Cognito
        final cognitoResponse = await _cognitoAuthDataSource.signIn(
          credentials.username,
          credentials.password,
        );

        // Guardar tokens de Cognito
        await _secureStorage.write(
          'access_token',
          cognitoResponse.authenticationResult?.accessToken ?? '',
        );
        if (cognitoResponse.authenticationResult?.refreshToken != null) {
          await _secureStorage.write(
            'refresh_token',
            cognitoResponse.authenticationResult!.refreshToken!,
          );
        }

        // Obtener información del usuario
        final userModel = await _cognitoAuthDataSource.getCurrentUser();
        
        AppLogger.info('Cognito authentication successful');
        return userModel.toEntity();
      }
    } on AppError {
      rethrow;
    } catch (e) {
      AppLogger.error('Sign in error: $e');
      throw AppError.unknown(
        message: 'Error durante el inicio de sesión',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserEntity> signUp(RegisterRequest request) async {
    try {
      AppLogger.info('Attempting sign up for user: ${request.username}');

      // Validar email si es necesario
      if (request.email.isNotEmpty) {
        try {
          final isAuthorized = await _emailValidationDataSource
              .checkEmailAuthorization(request.email);
          if (!isAuthorized) {
            throw AppError.authorization(
              message: 'Correo no autorizado',
              details: 'El correo electrónico no está autorizado para registrarse',
            );
          }
        } catch (e) {
          AppLogger.warning('Email validation failed, continuing: $e');
          // Continuar si la validación falla (para desarrollo)
        }
      }

      if (_useApiAuth) {
        // Usar API mock
        final userModel = await _apiAuthDataSource.signUp(
          request.username,
          request.email,
          request.password,
          request.name,
        );

        AppLogger.info('API registration successful');
        return userModel.toEntity();
      } else {
        // Usar Cognito
        final cognitoUser = await _cognitoAuthDataSource.signUp(
          request.email,
          request.password,
          request.name,
          request.familyName ?? '',
        );

        // Para Cognito, necesitamos construir la entidad manualmente
        // ya que el usuario aún no está confirmado
        final userEntity = UserEntity(
          id: cognitoUser.username ?? request.username,
          email: request.email,
          name: request.name,
          familyName: request.familyName ?? '',
          username: request.username,
          emailVerified: null, // Pendiente de confirmación
          isActive: false, // Pendiente de confirmación
        );

        AppLogger.info('Cognito registration successful');
        return userEntity;
      }
    } on AppError {
      rethrow;
    } catch (e) {
      AppLogger.error('Sign up error: $e');
      throw AppError.unknown(
        message: 'Error durante el registro',
        details: e.toString(),
      );
    }
  }

  @override
  Future<bool> confirmUser(String username, String confirmationCode) async {
    try {
      if (_useApiAuth) {
        // La API mock no requiere confirmación
        AppLogger.info('API mock does not require user confirmation');
        return true;
      } else {
        // Usar Cognito
        return await _cognitoAuthDataSource.confirmUser(username, confirmationCode);
      }
    } on AppError {
      rethrow;
    } catch (e) {
      AppLogger.error('Confirm user error: $e');
      throw AppError.unknown(
        message: 'Error durante la confirmación',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> forgotPassword(String username) async {
    try {
      if (_useApiAuth) {
        // La API mock no tiene endpoint para forgot password aún
        throw AppError.server(
          message: 'Funcionalidad no disponible',
          details: 'Reset de contraseña no implementado en la API mock',
        );
      } else {
        // Usar Cognito
        await _cognitoAuthDataSource.forgotPassword(username);
      }
    } on AppError {
      rethrow;
    } catch (e) {
      AppLogger.error('Forgot password error: $e');
      throw AppError.unknown(
        message: 'Error al solicitar reset de contraseña',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> resetPassword(
    String username,
    String confirmationCode,
    String newPassword,
  ) async {
    try {
      if (_useApiAuth) {
        // La API mock no tiene endpoint para reset password aún
        throw AppError.server(
          message: 'Funcionalidad no disponible',
          details: 'Reset de contraseña no implementado en la API mock',
        );
      } else {
        // Usar Cognito
        await _cognitoAuthDataSource.confirmPassword(
          username,
          confirmationCode,
          newPassword,
        );
      }
    } on AppError {
      rethrow;
    } catch (e) {
      AppLogger.error('Reset password error: $e');
      throw AppError.unknown(
        message: 'Error al resetear contraseña',
        details: e.toString(),
      );
    }
  }

  @override
  Future<AuthTokens> refreshTokens(String refreshToken) async {
    try {
      if (_useApiAuth) {
        // Validar token actual
        final currentToken = await _secureStorage.read('access_token');
        if (currentToken == null) {
          throw AppError.authentication(
            message: 'No hay token para refrescar',
            details: 'Access token not found in secure storage',
          );
        }

        final isValid = await _apiAuthDataSource.validateToken(currentToken);
        if (!isValid) {
          throw AppError.authentication(
            message: 'Token expirado',
            details: 'Current token is no longer valid',
          );
        }

        // Para la API mock, retornamos el token actual si es válido
        return AuthTokens(
          accessToken: currentToken,
          refreshToken: refreshToken,
          expiresIn: 3600, // 1 hora
          tokenType: 'Bearer',
        );
      } else {
        // Usar Cognito
        final cognitoResponse = await _cognitoAuthDataSource.refreshToken(refreshToken);
        
        return AuthTokens(
          accessToken: cognitoResponse.authenticationResult?.accessToken ?? '',
          refreshToken: cognitoResponse.authenticationResult?.refreshToken ?? refreshToken,
          expiresIn: cognitoResponse.authenticationResult?.expiresIn ?? 3600,
          tokenType: cognitoResponse.authenticationResult?.tokenType ?? 'Bearer',
        );
      }
    } on AppError {
      rethrow;
    } catch (e) {
      AppLogger.error('Refresh tokens error: $e');
      throw AppError.unknown(
        message: 'Error al refrescar tokens',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      if (_useApiAuth) {
        // Verificar si hay un token guardado
        final token = await _secureStorage.read('access_token');
        if (token == null) {
          AppLogger.debug('No access token found');
          return null;
        }

        // Validar el token
        final isValid = await _apiAuthDataSource.validateToken(token);
        if (!isValid) {
          AppLogger.debug('Token is invalid');
          await signOut(); // Limpiar tokens inválidos
          return null;
        }

        // Obtener ID del usuario y buscar sus credenciales
        final userId = await _secureStorage.read('user_id');
        if (userId == null) {
          AppLogger.debug('No user ID found');
          return null;
        }

        // Para la API mock, podríamos usar el endpoint de credenciales
        // Por ahora, construimos el usuario básico desde el token
        return UserEntity(
          id: userId,
          email: 'admin@skyangel.com', // Temporal
          name: 'Usuario',
          familyName: 'Mock',
          username: 'admin',
          role: 'admin',
          isActive: true,
          emailVerified: DateTime.now(),
        );
      } else {
        // Usar Cognito
        final userModel = await _cognitoAuthDataSource.getCurrentUser();
        return userModel.toEntity();
      }
    } on AppError {
      rethrow;
    } catch (e) {
      AppLogger.error('Get current user error: $e');
      return null; // No lanzar error, simplemente retornar null
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out user');

      // Limpiar almacenamiento local
      await _secureStorage.delete('access_token');
      await _secureStorage.delete('refresh_token');
      await _secureStorage.delete('user_id');

      if (_useApiAuth) {
        AppLogger.info('API sign out completed');
        // La API mock no requiere llamada específica para sign out
      } else {
        // Usar Cognito
        await _cognitoAuthDataSource.signOut();
        AppLogger.info('Cognito sign out completed');
      }
    } catch (e) {
      AppLogger.error('Sign out error: $e');
      // No lanzar error en sign out, solo loggear
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      AppLogger.error('Is signed in check error: $e');
      return false;
    }
  }
}