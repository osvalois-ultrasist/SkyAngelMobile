import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      _logger.d(
        message,
        error: error,
        stackTrace: stackTrace,
      );
      
      if (extra != null) {
        _logger.d('Extra data: $extra');
      }
      
      dev.log(
        message,
        name: 'SkyAngel',
        level: 500,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void info(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _logger.i(
      message,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (extra != null) {
      _logger.i('Extra data: $extra');
    }
    
    dev.log(
      message,
      name: 'SkyAngel',
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _logger.w(
      message,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (extra != null) {
      _logger.w('Extra data: $extra');
    }
    
    dev.log(
      message,
      name: 'SkyAngel',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (extra != null) {
      _logger.e('Extra data: $extra');
    }
    
    dev.log(
      message,
      name: 'SkyAngel',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _logger.f(
      message,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (extra != null) {
      _logger.f('Extra data: $extra');
    }
    
    dev.log(
      message,
      name: 'SkyAngel',
      level: 1200,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void wtf(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _logger.wtf(
      message,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (extra != null) {
      _logger.wtf('Extra data: $extra');
    }
    
    dev.log(
      message,
      name: 'SkyAngel',
      level: 1500,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void api(
    String message, {
    String? method,
    String? url,
    int? statusCode,
    Map<String, dynamic>? headers,
    dynamic body,
    Duration? duration,
  }) {
    final logMessage = StringBuffer();
    logMessage.write('API Call: $message');
    
    if (method != null) logMessage.write(' | Method: $method');
    if (url != null) logMessage.write(' | URL: $url');
    if (statusCode != null) logMessage.write(' | Status: $statusCode');
    if (duration != null) logMessage.write(' | Duration: ${duration.inMilliseconds}ms');
    
    _logger.i(logMessage.toString());
    
    if (headers != null && kDebugMode) {
      _logger.d('Headers: $headers');
    }
    
    if (body != null && kDebugMode) {
      _logger.d('Body: $body');
    }
  }

  static void navigation(
    String message, {
    String? from,
    String? to,
    Map<String, dynamic>? arguments,
  }) {
    final logMessage = StringBuffer();
    logMessage.write('Navigation: $message');
    
    if (from != null) logMessage.write(' | From: $from');
    if (to != null) logMessage.write(' | To: $to');
    
    _logger.i(logMessage.toString());
    
    if (arguments != null && kDebugMode) {
      _logger.d('Arguments: $arguments');
    }
  }

  static void performance(
    String message, {
    Duration? duration,
    Map<String, dynamic>? metrics,
  }) {
    final logMessage = StringBuffer();
    logMessage.write('Performance: $message');
    
    if (duration != null) {
      logMessage.write(' | Duration: ${duration.inMilliseconds}ms');
    }
    
    _logger.i(logMessage.toString());
    
    if (metrics != null && kDebugMode) {
      _logger.d('Metrics: $metrics');
    }
  }

  static void security(
    String message, {
    String? action,
    String? userId,
    Map<String, dynamic>? context,
  }) {
    final logMessage = StringBuffer();
    logMessage.write('Security: $message');
    
    if (action != null) logMessage.write(' | Action: $action');
    if (userId != null) logMessage.write(' | User: $userId');
    
    _logger.w(logMessage.toString());
    
    if (context != null) {
      _logger.w('Context: $context');
    }
  }

  static void analytics(
    String event, {
    Map<String, dynamic>? parameters,
  }) {
    _logger.i('Analytics Event: $event');
    
    if (parameters != null && kDebugMode) {
      _logger.d('Parameters: $parameters');
    }
  }
}