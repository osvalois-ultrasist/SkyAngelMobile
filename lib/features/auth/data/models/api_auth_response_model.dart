import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'api_auth_response_model.freezed.dart';
part 'api_auth_response_model.g.dart';

/// Modelo de respuesta para la autenticación con JWT token
/// Basado en el contrato de la API mock: POST /api/auth/login_user
@freezed
class ApiAuthResponseModel with _$ApiAuthResponseModel {
  const factory ApiAuthResponseModel({
    required String token,
    required UserModel user,
  }) = _ApiAuthResponseModel;

  factory ApiAuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ApiAuthResponseModelFromJson(json);
}

/// Modelo para la validación de token
/// Basado en el contrato de la API mock: GET /api/auth/check_token
@freezed
class TokenValidationResponseModel with _$TokenValidationResponseModel {
  const factory TokenValidationResponseModel({
    required bool valid,
    required TokenUserModel user,
  }) = _TokenValidationResponseModel;

  factory TokenValidationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenValidationResponseModelFromJson(json);
}

/// Modelo simplificado del usuario en la respuesta de validación de token
@freezed
class TokenUserModel with _$TokenUserModel {
  const factory TokenUserModel({
    required int id,
    required String usuario,
    required String rol,
    required int iat,
    required int exp,
  }) = _TokenUserModel;

  factory TokenUserModel.fromJson(Map<String, dynamic> json) =>
      _$TokenUserModelFromJson(json);
}

/// Modelo de respuesta para el registro de usuario
/// Basado en el contrato de la API mock: POST /api/auth/registro_user
@freezed
class RegistrationResponseModel with _$RegistrationResponseModel {
  const factory RegistrationResponseModel({
    required String message,
    required UserModel user,
  }) = _RegistrationResponseModel;

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationResponseModelFromJson(json);
}

/// Modelo de respuesta para errores de la API
@freezed
class ApiErrorResponseModel with _$ApiErrorResponseModel {
  const factory ApiErrorResponseModel({
    required String error,
  }) = _ApiErrorResponseModel;

  factory ApiErrorResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseModelFromJson(json);
}