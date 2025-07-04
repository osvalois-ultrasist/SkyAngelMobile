import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

enum AppErrorType {
  network,
  server,
  authentication,
  authorization,
  validation,
  notFound,
  conflict,
  rateLimit,
  cancelled,
  security,
  unknown,
}

@freezed
class AppError with _$AppError implements Exception {
  const factory AppError({
    required AppErrorType type,
    required String message,
    required String details,
    required int? statusCode,
    String? code,
    Map<String, dynamic>? data,
  }) = _AppError;

  const AppError._();

  // Factory constructors for common error types
  factory AppError.network({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.network,
        message: message ?? 'Error de red',
        details: details ?? 'Verifique su conexión a internet',
        statusCode: null,
      );

  factory AppError.server({
    String? message,
    String? details,
    int? statusCode,
  }) =>
      AppError(
        type: AppErrorType.server,
        message: message ?? 'Error del servidor',
        details: details ?? 'Ha ocurrido un error en el servidor',
        statusCode: statusCode,
      );

  factory AppError.authentication({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.authentication,
        message: message ?? 'Error de autenticación',
        details: details ?? 'Su sesión ha expirado. Por favor, inicie sesión nuevamente',
        statusCode: 401,
      );

  factory AppError.authorization({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.authorization,
        message: message ?? 'Acceso denegado',
        details: details ?? 'No tiene permisos para realizar esta acción',
        statusCode: 403,
      );

  factory AppError.validation({
    String? message,
    String? details,
    Map<String, dynamic>? data,
  }) =>
      AppError(
        type: AppErrorType.validation,
        message: message ?? 'Datos inválidos',
        details: details ?? 'Los datos proporcionados no son válidos',
        statusCode: 400,
        data: data,
      );

  factory AppError.notFound({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.notFound,
        message: message ?? 'Recurso no encontrado',
        details: details ?? 'El recurso solicitado no fue encontrado',
        statusCode: 404,
      );

  factory AppError.conflict({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.conflict,
        message: message ?? 'Conflicto',
        details: details ?? 'El recurso ya existe o está en conflicto',
        statusCode: 409,
      );

  factory AppError.rateLimit({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.rateLimit,
        message: message ?? 'Demasiadas solicitudes',
        details: details ?? 'Ha excedido el límite de solicitudes. Intente más tarde',
        statusCode: 429,
      );

  factory AppError.cancelled({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.cancelled,
        message: message ?? 'Operación cancelada',
        details: details ?? 'La operación fue cancelada por el usuario',
        statusCode: null,
      );

  factory AppError.security({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.security,
        message: message ?? 'Error de seguridad',
        details: details ?? 'Ha ocurrido un error de seguridad',
        statusCode: null,
      );

  factory AppError.unknown({
    String? message,
    String? details,
  }) =>
      AppError(
        type: AppErrorType.unknown,
        message: message ?? 'Error desconocido',
        details: details ?? 'Ha ocurrido un error inesperado',
        statusCode: null,
      );

  // Getters for common checks
  bool get isNetworkError => type == AppErrorType.network;
  bool get isServerError => type == AppErrorType.server;
  bool get isAuthenticationError => type == AppErrorType.authentication;
  bool get isAuthorizationError => type == AppErrorType.authorization;
  bool get isValidationError => type == AppErrorType.validation;
  bool get isNotFoundError => type == AppErrorType.notFound;
  bool get isConflictError => type == AppErrorType.conflict;
  bool get isRateLimitError => type == AppErrorType.rateLimit;
  bool get isCancelledError => type == AppErrorType.cancelled;
  bool get isSecurityError => type == AppErrorType.security;
  bool get isUnknownError => type == AppErrorType.unknown;

  // Check if error is recoverable
  bool get isRecoverable {
    switch (type) {
      case AppErrorType.network:
      case AppErrorType.server:
      case AppErrorType.rateLimit:
        return true;
      case AppErrorType.authentication:
      case AppErrorType.authorization:
      case AppErrorType.validation:
      case AppErrorType.notFound:
      case AppErrorType.conflict:
      case AppErrorType.cancelled:
      case AppErrorType.security:
      case AppErrorType.unknown:
        return false;
    }
  }

  // Get user-friendly message based on error type
  String get userMessage {
    switch (type) {
      case AppErrorType.network:
        return 'Por favor, verifique su conexión a internet e intente nuevamente';
      case AppErrorType.server:
        return 'El servidor no está disponible en este momento. Intente más tarde';
      case AppErrorType.authentication:
        return 'Su sesión ha expirado. Por favor, inicie sesión nuevamente';
      case AppErrorType.authorization:
        return 'No tiene permisos para realizar esta acción';
      case AppErrorType.validation:
        return 'Los datos proporcionados no son válidos';
      case AppErrorType.notFound:
        return 'El recurso solicitado no fue encontrado';
      case AppErrorType.conflict:
        return 'Ya existe un recurso con estos datos';
      case AppErrorType.rateLimit:
        return 'Ha excedido el límite de solicitudes. Intente más tarde';
      case AppErrorType.cancelled:
        return 'La operación fue cancelada';
      case AppErrorType.security:
        return 'Ha ocurrido un error de seguridad';
      case AppErrorType.unknown:
        return 'Ha ocurrido un error inesperado';
    }
  }

  // Get icon based on error type
  String get iconName {
    switch (type) {
      case AppErrorType.network:
        return 'wifi_off';
      case AppErrorType.server:
        return 'cloud_off';
      case AppErrorType.authentication:
        return 'lock';
      case AppErrorType.authorization:
        return 'block';
      case AppErrorType.validation:
        return 'warning';
      case AppErrorType.notFound:
        return 'search_off';
      case AppErrorType.conflict:
        return 'content_copy';
      case AppErrorType.rateLimit:
        return 'hourglass_empty';
      case AppErrorType.cancelled:
        return 'cancel';
      case AppErrorType.security:
        return 'security';
      case AppErrorType.unknown:
        return 'error';
    }
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, details: $details, statusCode: $statusCode)';
  }
}