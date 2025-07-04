import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

@singleton
class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Dio get dio => _dio;

  // Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      AppLogger.error('GET request failed', error: e);
      rethrow;
    }
  }

  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      AppLogger.error('POST request failed', error: e);
      rethrow;
    }
  }

  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      AppLogger.error('PUT request failed', error: e);
      rethrow;
    }
  }

  // Generic PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      AppLogger.error('PATCH request failed', error: e);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      AppLogger.error('DELETE request failed', error: e);
      rethrow;
    }
  }

  // File upload request
  Future<Response<T>> uploadFile<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      AppLogger.error('File upload failed', error: e);
      rethrow;
    }
  }

  // File download request
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      AppLogger.error('File download failed', error: e);
      rethrow;
    }
  }

  // Request with retry logic
  Future<Response<T>> requestWithRetry<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        Response<T> response;
        
        switch (method.toLowerCase()) {
          case 'get':
            response = await get<T>(
              path,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          case 'post':
            response = await post<T>(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          case 'put':
            response = await put<T>(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          case 'patch':
            response = await patch<T>(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          case 'delete':
            response = await delete<T>(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          default:
            throw ArgumentError('Unsupported HTTP method: $method');
        }
        
        return response;
      } on DioException catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          rethrow;
        }
        
        // Only retry on specific error types
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          AppLogger.warning(
            'Request failed, retrying... (${retryCount}/$maxRetries)',
            error: e,
          );
          
          await Future.delayed(retryDelay * retryCount);
          continue;
        }
        
        rethrow;
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  // Batch requests
  Future<List<Response>> batchRequests(
    List<RequestOptions> requests, {
    bool continueOnError = false,
  }) async {
    final List<Response> responses = [];
    
    for (final request in requests) {
      try {
        final response = await _dio.fetch(request);
        responses.add(response);
      } catch (e) {
        if (!continueOnError) {
          rethrow;
        }
        AppLogger.error('Batch request failed', error: e);
      }
    }
    
    return responses;
  }

  // Add request interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  // Remove request interceptor
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  // Clear all interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
  }

  // Update base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // Update headers
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  // Set bearer token
  void setBearerToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove bearer token
  void removeBearerToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Cancel all pending requests
  void cancelAllRequests([String? reason]) {
    _dio.close(force: true);
  }
}