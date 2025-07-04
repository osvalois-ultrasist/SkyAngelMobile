import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../../utils/logger.dart';
import '../../di/injection.dart';

@singleton
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage = locate<SecureStorage>();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip authentication for certain endpoints
      if (_shouldSkipAuth(options.path)) {
        return handler.next(options);
      }

      // Get token from secure storage
      final token = await _secureStorage.getToken();
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('Added authorization header to request');
      } else {
        AppLogger.warning('No token found for authenticated request');
      }

      handler.next(options);
    } catch (e) {
      AppLogger.error('Error in auth interceptor', error: e);
      handler.next(options);
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized responses
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Received 401 Unauthorized response');
      
      try {
        // Try to refresh the token
        final refreshed = await _refreshToken();
        
        if (refreshed) {
          // Retry the original request
          final newToken = await _secureStorage.getToken();
          if (newToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            
            // Create a new Dio instance to avoid interceptor loops
            final dio = Dio();
            final response = await dio.fetch(err.requestOptions);
            
            AppLogger.info('Request retried successfully after token refresh');
            return handler.resolve(response);
          }
        }
        
        // If token refresh failed, clear stored credentials
        await _clearCredentials();
        
        // Redirect to login or show authentication error
        await _handleAuthenticationError();
        
      } catch (e) {
        AppLogger.error('Error handling 401 response', error: e);
        await _clearCredentials();
        await _handleAuthenticationError();
      }
    }

    handler.next(err);
  }

  bool _shouldSkipAuth(String path) {
    final unauthenticatedPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/health',
      '/version',
    ];

    return unauthenticatedPaths.any((p) => path.contains(p));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('No refresh token available');
        return false;
      }

      // Create a new Dio instance to avoid interceptor loops
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newToken != null) {
          await _secureStorage.setToken(newToken);
          
          if (newRefreshToken != null) {
            await _secureStorage.setRefreshToken(newRefreshToken);
          }
          
          AppLogger.info('Token refreshed successfully');
          return true;
        }
      }

      AppLogger.warning('Token refresh failed: Invalid response');
      return false;
    } catch (e) {
      AppLogger.error('Token refresh failed', error: e);
      return false;
    }
  }

  Future<void> _clearCredentials() async {
    try {
      await _secureStorage.deleteToken();
      await _secureStorage.deleteRefreshToken();
      await _secureStorage.deleteUserId();
      AppLogger.info('Credentials cleared');
    } catch (e) {
      AppLogger.error('Error clearing credentials', error: e);
    }
  }

  Future<void> _handleAuthenticationError() async {
    // This could trigger a navigation to login screen
    // or show an authentication error dialog
    // Implementation depends on your app's navigation system
    AppLogger.warning('Authentication error - user needs to login again');
    
    // You might want to use a navigation service or event bus here
    // For now, we'll just log the event
  }

  // Method to manually set token (useful for testing)
  Future<void> setToken(String token) async {
    await _secureStorage.setToken(token);
  }

  // Method to manually clear token
  Future<void> clearToken() async {
    await _secureStorage.deleteToken();
  }

  // Method to check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  // Method to get current token
  Future<String?> getCurrentToken() async {
    return await _secureStorage.getToken();
  }
}