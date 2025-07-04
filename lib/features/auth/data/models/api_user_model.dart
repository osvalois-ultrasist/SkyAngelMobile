import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'api_user_model.freezed.dart';
part 'api_user_model.g.dart';

/// Modelo de usuario que coincide exactamente con el contrato de la API mock
/// Basado en las respuestas de los endpoints de autenticación
@freezed
class ApiUserModel with _$ApiUserModel {
  const factory ApiUserModel({
    required int id,
    required String usuario,
    required String email,
    required String nombre,
    required String rol,
    required bool activo,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
    @JsonKey(name: 'ultimo_acceso') DateTime? ultimoAcceso,
    @JsonKey(name: 'session_id') String? sessionId,
  }) = _ApiUserModel;

  factory ApiUserModel.fromJson(Map<String, dynamic> json) =>
      _$ApiUserModelFromJson(json);
}

extension ApiUserModelX on ApiUserModel {
  /// Convierte el modelo de API a la entidad de dominio
  UserEntity toEntity() {
    return UserEntity(
      id: id.toString(),
      email: email,
      name: nombre,
      familyName: '', // La API mock no tiene apellido separado
      username: usuario,
      phoneNumber: null,
      emailVerified: activo ? DateTime.now() : null,
      createdAt: fechaCreacion,
      updatedAt: ultimoAcceso,
      role: rol,
      isActive: activo,
    );
  }

  /// Convierte de entidad de dominio a modelo de API
  static ApiUserModel fromEntity(UserEntity entity) {
    return ApiUserModel(
      id: int.tryParse(entity.id) ?? 0,
      usuario: entity.username ?? entity.email,
      email: entity.email,
      nombre: entity.name,
      rol: entity.role ?? 'user',
      activo: entity.isActive ?? true,
      fechaCreacion: entity.createdAt,
      ultimoAcceso: entity.updatedAt,
    );
  }
}