import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/api_auth_response_model.dart';
import '../models/user_model.dart';

/// DataSource para autenticación usando la API REST mock
/// Este datasource implementa los contratos exactos definidos en los mocks
abstract class ApiAuthDataSource {
  /// Login con JWT token - endpoint: POST /api/auth/login_user
  Future<ApiAuthResponseModel> signInWithToken(String usuario, String password);
  
  /// Login básico sin JWT - endpoint: POST /api/auth/login  
  Future<UserModel> signIn(String usuario, String password);
  
  /// Registro de usuario - endpoint: POST /api/auth/registro_user
  Future<UserModel> signUp(String usuario, String email, String password, String nombre);
  
  /// Validación de token - endpoint: GET /api/auth/check_token
  Future<bool> validateToken(String token);
  
  /// Obtener credenciales - endpoint: POST /api/auth/credenciales
  Future<UserModel> getCredentials(String usuario);
}

@LazySingleton(as: ApiAuthDataSource)
class ApiAuthDataSourceImpl implements ApiAuthDataSource {
  final DioClient _dioClient;

  ApiAuthDataSourceImpl(this._dioClient);

  @override
  Future<ApiAuthResponseModel> signInWithToken(String usuario, String password) async {
    try {
      AppLogger.debug('Attempting login with token for user: $usuario');
      
      final response = await _dioClient.dio.post(
        ApiEndpoints.loginUser,
        data: {
          'usuario': usuario,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        AppLogger.info('Login successful for user: $usuario');
        
        return ApiAuthResponseModel.fromJson(data);
      }

      throw AppError.authentication(
        message: 'Authentication failed',
        details: 'Invalid response status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      AppLogger.error('API Auth error: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw AppError.authentication(
          message: errorData?['error'] ?? 'Credenciales inválidas',
          details: 'Authentication failed with status 401',
        );
      }
      
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw AppError.validation(
          message: errorData?['error'] ?? 'Datos inválidos',
          details: 'Bad request with status 400',
        );
      }
      
      throw AppError.network(
        message: 'Error de conexión',
        details: 'Network error during authentication: ${e.message}',
      );
    } catch (e) {
      AppLogger.error('Unexpected auth error: $e');
      throw AppError.unknown(
        message: 'Error de autenticación',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> signIn(String usuario, String password) async {
    try {
      AppLogger.debug('Attempting basic login for user: $usuario');
      
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'usuario': usuario,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        AppLogger.info('Basic login successful for user: $usuario');
        
        return UserModel.fromJson(data);
      }

      throw AppError.authentication(
        message: 'Authentication failed',
        details: 'Invalid response status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      AppLogger.error('API Auth error: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw AppError.authentication(
          message: errorData?['error'] ?? 'Usuario no encontrado',
          details: 'Authentication failed with status 401',
        );
      }
      
      throw AppError.network(
        message: 'Error de conexión',
        details: 'Network error during authentication: ${e.message}',
      );
    } catch (e) {
      AppLogger.error('Unexpected auth error: $e');
      throw AppError.unknown(
        message: 'Error de autenticación',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> signUp(String usuario, String email, String password, String nombre) async {
    try {
      AppLogger.debug('Attempting registration for user: $usuario');
      
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {
          'usuario': usuario,
          'email': email,
          'password': password,
          'nombre': nombre,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        AppLogger.info('Registration successful for user: $usuario');
        
        // La respuesta incluye el usuario creado
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }

      throw AppError.validation(
        message: 'Registration failed',
        details: 'Invalid response status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      AppLogger.error('API Registration error: ${e.response?.data}');
      
      if (e.response?.statusCode == 409) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw AppError.validation(
          message: errorData?['error'] ?? 'El usuario o email ya existe',
          details: 'User or email already exists',
        );
      }
      
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw AppError.validation(
          message: errorData?['error'] ?? 'Todos los campos son requeridos',
          details: 'Bad request with status 400',
        );
      }
      
      throw AppError.network(
        message: 'Error de conexión',
        details: 'Network error during registration: ${e.message}',
      );
    } catch (e) {
      AppLogger.error('Unexpected registration error: $e');
      throw AppError.unknown(
        message: 'Error de registro',
        details: e.toString(),
      );
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      AppLogger.debug('Validating token');
      
      final response = await _dioClient.dio.get(
        ApiEndpoints.checkToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final isValid = data['valid'] as bool? ?? false;
        
        AppLogger.info('Token validation result: $isValid');
        return isValid;
      }

      return false;
    } on DioException catch (e) {
      AppLogger.error('Token validation error: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        return false; // Token inválido
      }
      
      throw AppError.network(
        message: 'Error de conexión',
        details: 'Network error during token validation: ${e.message}',
      );
    } catch (e) {
      AppLogger.error('Unexpected token validation error: $e');
      throw AppError.unknown(
        message: 'Error de validación',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> getCredentials(String usuario) async {
    try {
      AppLogger.debug('Getting credentials for user: $usuario');
      
      final response = await _dioClient.dio.post(
        ApiEndpoints.credenciales,
        data: {
          'usuario': usuario,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        AppLogger.info('Credentials retrieved for user: $usuario');
        
        return UserModel.fromJson(data);
      }

      throw AppError.server(
        message: 'Failed to get credentials',
        details: 'Invalid response status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      AppLogger.error('Get credentials error: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw AppError.validation(
          message: errorData?['error'] ?? 'Usuario no encontrado',
          details: 'User not found',
        );
      }
      
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw AppError.validation(
          message: errorData?['error'] ?? 'Usuario requerido',
          details: 'Bad request with status 400',
        );
      }
      
      throw AppError.network(
        message: 'Error de conexión',
        details: 'Network error during credentials retrieval: ${e.message}',
      );
    } catch (e) {
      AppLogger.error('Unexpected credentials error: $e');
      throw AppError.unknown(
        message: 'Error al obtener credenciales',
        details: e.toString(),
      );
    }
  }
}