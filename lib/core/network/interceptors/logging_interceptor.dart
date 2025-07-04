import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../utils/logger.dart';

@singleton
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.api(
      'Request',
      method: options.method,
      url: '${options.baseUrl}${options.path}',
      headers: _sanitizeHeaders(options.headers),
      body: _sanitizeBody(options.data),
    );
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final duration = _calculateDuration(response.requestOptions.extra);
    
    AppLogger.api(
      'Response',
      method: response.requestOptions.method,
      url: '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      statusCode: response.statusCode,
      duration: duration,
      body: _sanitizeBody(response.data),
    );
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final duration = _calculateDuration(err.requestOptions.extra);
    
    AppLogger.api(
      'Error',
      method: err.requestOptions.method,
      url: '${err.requestOptions.baseUrl}${err.requestOptions.path}',
      statusCode: err.response?.statusCode,
      duration: duration,
      body: _sanitizeBody(err.response?.data),
    );
    
    AppLogger.error(
      'API Error: ${err.message}',
      error: err,
      extra: {
        'type': err.type.toString(),
        'response': err.response?.toString(),
      },
    );
    
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    
    // Remove sensitive headers
    final sensitiveHeaders = [
      'authorization',
      'cookie',
      'x-api-key',
      'x-auth-token',
    ];
    
    for (final header in sensitiveHeaders) {
      if (sanitized.containsKey(header)) {
        sanitized[header] = '***';
      }
      if (sanitized.containsKey(header.toLowerCase())) {
        sanitized[header.toLowerCase()] = '***';
      }
    }
    
    return sanitized;
  }

  dynamic _sanitizeBody(dynamic body) {
    if (body == null) return null;
    
    // If body is a string, check if it contains sensitive data
    if (body is String) {
      return _sanitizeString(body);
    }
    
    // If body is a map, sanitize sensitive fields
    if (body is Map<String, dynamic>) {
      return _sanitizeMap(body);
    }
    
    // If body is a list, sanitize each item
    if (body is List) {
      return body.map((item) => _sanitizeBody(item)).toList();
    }
    
    return body;
  }

  String _sanitizeString(String str) {
    // Check if string contains sensitive patterns
    final sensitivePatterns = [
      RegExp(r'"password"\s*:\s*"[^"]*"', caseSensitive: false),
      RegExp(r'"token"\s*:\s*"[^"]*"', caseSensitive: false),
      RegExp(r'"secret"\s*:\s*"[^"]*"', caseSensitive: false),
      RegExp(r'"key"\s*:\s*"[^"]*"', caseSensitive: false),
    ];
    
    String sanitized = str;
    for (final pattern in sensitivePatterns) {
      sanitized = sanitized.replaceAll(pattern, '"***"');
    }
    
    return sanitized;
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    final sanitized = Map<String, dynamic>.from(map);
    
    // List of sensitive keys to sanitize
    final sensitiveKeys = [
      'password',
      'token',
      'secret',
      'key',
      'authorization',
      'auth',
      'credential',
      'pin',
      'otp',
      'biometric',
      'fingerprint',
      'face_id',
    ];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '***';
      }
      
      // Check case-insensitive
      final lowerKey = key.toLowerCase();
      final matchingKey = sanitized.keys.firstWhere(
        (k) => k.toLowerCase() == lowerKey,
        orElse: () => '',
      );
      
      if (matchingKey.isNotEmpty) {
        sanitized[matchingKey] = '***';
      }
    }
    
    // Recursively sanitize nested maps
    for (final entry in sanitized.entries) {
      if (entry.value is Map<String, dynamic>) {
        sanitized[entry.key] = _sanitizeMap(entry.value);
      } else if (entry.value is List) {
        sanitized[entry.key] = entry.value
            .map((item) => _sanitizeBody(item))
            .toList();
      }
    }
    
    return sanitized;
  }

  Duration? _calculateDuration(Map<String, dynamic> extra) {
    final startTime = extra['start_time'] as DateTime?;
    if (startTime != null) {
      return DateTime.now().difference(startTime);
    }
    return null;
  }
}