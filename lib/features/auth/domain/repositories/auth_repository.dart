import '../entities/auth_credentials.dart';
import '../entities/auth_tokens.dart';
import '../entities/register_request.dart';
import '../entities/user_entity.dart';

/// Repositorio de autenticación que maneja tanto Cognito como API mock
/// Las implementaciones lanzan AppError en caso de error
abstract class AuthRepository {
  /// Inicia sesión con credenciales y retorna información del usuario
  Future<UserEntity> signIn(AuthCredentials credentials);
  
  /// Registra un nuevo usuario
  Future<UserEntity> signUp(RegisterRequest request);
  
  /// Confirma el registro de un usuario (principalmente para Cognito)
  Future<bool> confirmUser(String username, String code);
  
  /// Solicita reset de contraseña
  Future<void> forgotPassword(String username);
  
  /// Confirma el reset de contraseña
  Future<void> resetPassword(String username, String code, String newPassword);
  
  /// Refresca los tokens de autenticación
  Future<AuthTokens> refreshTokens(String refreshToken);
  
  /// Obtiene el usuario actual autenticado
  Future<UserEntity?> getCurrentUser();
  
  /// Cierra sesión
  Future<void> signOut();
  
  /// Verifica si el usuario está autenticado
  Future<bool> isSignedIn();
}