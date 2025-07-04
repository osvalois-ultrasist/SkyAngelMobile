import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../error/app_error.dart';
import '../../utils/logger.dart';

@singleton
class ErrorInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add start time for duration calculation
    options.extra['start_time'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = _handleError(err);
    
    // Log the error
    AppLogger.error(
      'Network Error: ${appError.message}',
      error: err,
      extra: {
        'error_type': appError.type.toString(),
        'status_code': err.response?.statusCode,
        'url': err.requestOptions.uri.toString(),
        'method': err.requestOptions.method,
      },
    );
    
    // Transform DioException to AppError
    final transformedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: appError,
      message: appError.message,
    );
    
    handler.next(transformedError);
  }

  AppError _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppError(
          type: AppErrorType.network,
          message: 'Tiempo de conexión agotado',
          details: 'La conexión tardó demasiado tiempo en establecerse',
          statusCode: null,
        );
        
      case DioExceptionType.sendTimeout:
        return AppError(
          type: AppErrorType.network,
          message: 'Tiempo de envío agotado',
          details: 'El envío de datos tardó demasiado tiempo',
          statusCode: null,
        );
        
      case DioExceptionType.receiveTimeout:
        return AppError(
          type: AppErrorType.network,
          message: 'Tiempo de recepción agotado',
          details: 'La recepción de datos tardó demasiado tiempo',
          statusCode: null,
        );
        
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
        
      case DioExceptionType.cancel:
        return AppError(
          type: AppErrorType.cancelled,
          message: 'Solicitud cancelada',
          details: 'La solicitud fue cancelada por el usuario',
          statusCode: null,
        );
        
      case DioExceptionType.connectionError:
        return AppError(
          type: AppErrorType.network,
          message: 'Error de conexión',
          details: 'No se pudo establecer conexión con el servidor',
          statusCode: null,
        );
        
      case DioExceptionType.badCertificate:
        return AppError(
          type: AppErrorType.security,
          message: 'Certificado inválido',
          details: 'El certificado del servidor no es válido',
          statusCode: null,
        );
        
      case DioExceptionType.unknown:
      default:
        return AppError(
          type: AppErrorType.unknown,
          message: 'Error desconocido',
          details: error.message ?? 'Ha ocurrido un error inesperado',
          statusCode: null,
        );
    }
  }

  AppError _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    
    String message;
    String details;
    AppErrorType type;
    
    switch (statusCode) {
      case 400:
        type = AppErrorType.validation;
        message = 'Datos inválidos';
        details = _extractErrorMessage(responseData) ?? 
                 'Los datos enviados no son válidos';
        break;
        
      case 401:
        type = AppErrorType.authentication;
        message = 'No autorizado';
        details = _extractErrorMessage(responseData) ?? 
                 'Su sesión ha expirado. Por favor, inicie sesión nuevamente';
        break;
        
      case 403:
        type = AppErrorType.authorization;
        message = 'Acceso denegado';
        details = _extractErrorMessage(responseData) ?? 
                 'No tiene permisos para realizar esta acción';
        break;
        
      case 404:
        type = AppErrorType.notFound;
        message = 'Recurso no encontrado';
        details = _extractErrorMessage(responseData) ?? 
                 'El recurso solicitado no fue encontrado';
        break;
        
      case 409:
        type = AppErrorType.conflict;
        message = 'Conflicto';
        details = _extractErrorMessage(responseData) ?? 
                 'El recurso ya existe o está en conflicto';
        break;
        
      case 422:
        type = AppErrorType.validation;
        message = 'Datos no procesables';
        details = _extractErrorMessage(responseData) ?? 
                 'Los datos enviados no pueden ser procesados';
        break;
        
      case 429:
        type = AppErrorType.rateLimit;
        message = 'Demasiadas solicitudes';
        details = _extractErrorMessage(responseData) ?? 
                 'Ha excedido el límite de solicitudes. Intente más tarde';
        break;
        
      case 500:
        type = AppErrorType.server;
        message = 'Error del servidor';
        details = _extractErrorMessage(responseData) ?? 
                 'Ha ocurrido un error interno del servidor';
        break;
        
      case 502:
        type = AppErrorType.server;
        message = 'Puerta de enlace incorrecta';
        details = _extractErrorMessage(responseData) ?? 
                 'El servidor no está disponible temporalmente';
        break;
        
      case 503:
        type = AppErrorType.server;
        message = 'Servicio no disponible';
        details = _extractErrorMessage(responseData) ?? 
                 'El servicio no está disponible en este momento';
        break;
        
      case 504:
        type = AppErrorType.server;
        message = 'Tiempo de espera agotado';
        details = _extractErrorMessage(responseData) ?? 
                 'El servidor tardó demasiado en responder';
        break;
        
      default:
        type = AppErrorType.server;
        message = 'Error del servidor';
        details = _extractErrorMessage(responseData) ?? 
                 'Ha ocurrido un error en el servidor (${statusCode})';
    }
    
    return AppError(
      type: type,
      message: message,
      details: details,
      statusCode: statusCode,
    );
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;
    
    try {
      if (responseData is Map<String, dynamic>) {
        // Try different common error message keys
        final errorKeys = [
          'message',
          'error',
          'detail',
          'description',
          'msg',
          'error_description',
        ];
        
        for (final key in errorKeys) {
          if (responseData.containsKey(key)) {
            final value = responseData[key];
            if (value is String && value.isNotEmpty) {
              return value;
            }
          }
        }
        
        // Check for validation errors
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is Map<String, dynamic>) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
            if (firstError is String) {
              return firstError;
            }
          }
          if (errors is List && errors.isNotEmpty) {
            return errors.first.toString();
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
}