import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app_error.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';

@singleton
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Global error handler for uncaught exceptions
  void setupGlobalErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _handleFlutterError(details);
    };

    // Handle errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Handle async errors
    runZonedGuarded<Future<void>>(() async {
      // App initialization code here
    }, (error, stack) {
      _handleAsyncError(error, stack);
    });
  }

  // Convert any error to AppError
  AppError handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is SocketException) {
      return AppError.network(
        message: 'Error de conexión',
        details: 'No se pudo conectar al servidor. Verifique su conexión a internet.',
      );
    }

    if (error is TimeoutException) {
      return AppError.network(
        message: 'Tiempo de espera agotado',
        details: 'La operación tardó demasiado tiempo en completarse.',
      );
    }

    if (error is FormatException) {
      return AppError.validation(
        message: 'Formato inválido',
        details: 'Los datos recibidos tienen un formato inválido.',
      );
    }

    if (error is ArgumentError) {
      return AppError.validation(
        message: 'Argumento inválido',
        details: error.message?.toString() ?? 'Se proporcionó un argumento inválido.',
      );
    }

    if (error is StateError) {
      return AppError.unknown(
        message: 'Estado inválido',
        details: error.message?.toString() ?? 'El estado de la aplicación es inválido.',
      );
    }

    if (error is UnsupportedError) {
      return AppError.unknown(
        message: 'Operación no soportada',
        details: error.message?.toString() ?? 'La operación solicitada no está soportada.',
      );
    }

    // Generic error
    return AppError.unknown(
      message: 'Error inesperado',
      details: error.toString(),
    );
  }

  // Handle DioException specifically
  AppError _handleDioError(DioException error) {
    // If DioException already contains an AppError, return it
    if (error.error is AppError) {
      return error.error as AppError;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return AppError.network(
          message: 'Tiempo de espera agotado',
          details: 'La conexión tardó demasiado tiempo.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return AppError.cancelled(
          message: 'Solicitud cancelada',
          details: 'La solicitud fue cancelada.',
        );

      case DioExceptionType.connectionError:
        return AppError.network(
          message: 'Error de conexión',
          details: 'No se pudo conectar al servidor.',
        );

      case DioExceptionType.badCertificate:
        return AppError.security(
          message: 'Certificado inválido',
          details: 'El certificado del servidor no es válido.',
        );

      case DioExceptionType.unknown:
      default:
        return AppError.unknown(
          message: 'Error de red',
          details: error.message ?? 'Ha ocurrido un error de red.',
        );
    }
  }

  // Handle bad response from DioException
  AppError _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    switch (statusCode) {
      case 400:
        return AppError.validation(
          message: 'Solicitud inválida',
          details: _extractErrorMessage(responseData) ?? 'Los datos enviados no son válidos.',
        );

      case 401:
        return AppError.authentication(
          message: 'No autorizado',
          details: _extractErrorMessage(responseData) ?? 'Su sesión ha expirado.',
        );

      case 403:
        return AppError.authorization(
          message: 'Acceso denegado',
          details: _extractErrorMessage(responseData) ?? 'No tiene permisos para esta acción.',
        );

      case 404:
        return AppError.notFound(
          message: 'No encontrado',
          details: _extractErrorMessage(responseData) ?? 'El recurso solicitado no fue encontrado.',
        );

      case 409:
        return AppError.conflict(
          message: 'Conflicto',
          details: _extractErrorMessage(responseData) ?? 'El recurso ya existe.',
        );

      case 422:
        return AppError.validation(
          message: 'Datos no procesables',
          details: _extractErrorMessage(responseData) ?? 'Los datos no pueden ser procesados.',
        );

      case 429:
        return AppError.rateLimit(
          message: 'Demasiadas solicitudes',
          details: _extractErrorMessage(responseData) ?? 'Ha excedido el límite de solicitudes.',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return AppError.server(
          message: 'Error del servidor',
          details: _extractErrorMessage(responseData) ?? 'Ha ocurrido un error en el servidor.',
          statusCode: statusCode,
        );

      default:
        return AppError.server(
          message: 'Error del servidor',
          details: _extractErrorMessage(responseData) ?? 'Ha ocurrido un error desconocido.',
          statusCode: statusCode,
        );
    }
  }

  // Extract error message from response data
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    try {
      if (responseData is Map<String, dynamic>) {
        final possibleKeys = ['message', 'error', 'detail', 'msg'];
        for (final key in possibleKeys) {
          if (responseData.containsKey(key)) {
            final value = responseData[key];
            if (value is String && value.isNotEmpty) {
              return value;
            }
          }
        }
      }

      if (responseData is String && responseData.isNotEmpty) {
        return responseData;
      }
    } catch (e) {
      AppLogger.warning('Error extracting error message', error: e);
    }

    return null;
  }

  // Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
      extra: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );

    // Report to Crashlytics if not in debug mode
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  }

  // Handle platform errors
  void _handlePlatformError(Object error, StackTrace stack) {
    AppLogger.error(
      'Platform Error: $error',
      error: error,
      stackTrace: stack,
    );

    // Report to Crashlytics if not in debug mode
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: true,
      );
    }
  }

  // Handle async errors
  void _handleAsyncError(Object error, StackTrace stack) {
    AppLogger.error(
      'Async Error: $error',
      error: error,
      stackTrace: stack,
    );

    // Report to Crashlytics if not in debug mode
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: false,
      );
    }
  }

  // Log error for analytics
  void logError(AppError error, {
    Map<String, dynamic>? context,
    bool fatal = false,
  }) {
    AppLogger.error(
      'App Error: ${error.message}',
      error: error,
      extra: {
        'type': error.type.toString(),
        'details': error.details,
        'status_code': error.statusCode,
        'context': context,
        'fatal': fatal,
      },
    );

    // Report to Crashlytics if not in debug mode
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        null,
        fatal: fatal,
        information: [
          'Type: ${error.type}',
          'Message: ${error.message}',
          'Details: ${error.details}',
          if (error.statusCode != null) 'Status Code: ${error.statusCode}',
          if (context != null) 'Context: $context',
        ],
      );
    }
  }

  // Show user-friendly error message
  void showErrorToUser(AppError error) {
    // This method should be implemented to show error to user
    // It could use a snackbar, dialog, or toast message
    AppLogger.info('Showing error to user: ${error.userMessage}');
  }

  // Check if error should be retried
  bool shouldRetry(AppError error) {
    return error.isRecoverable && error.type == AppErrorType.network;
  }

  // Get retry delay based on error type
  Duration getRetryDelay(AppError error, int attemptNumber) {
    switch (error.type) {
      case AppErrorType.network:
        return Duration(seconds: 2 * attemptNumber);
      case AppErrorType.server:
        return Duration(seconds: 5 * attemptNumber);
      case AppErrorType.rateLimit:
        return Duration(minutes: 1 * attemptNumber);
      default:
        return Duration(seconds: 1);
    }
  }
}