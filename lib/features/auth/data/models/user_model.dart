import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  // Campos para Cognito
  @JsonKey(name: 'sub')
  final String? cognitoId;
  
  // Campos para API mock
  final int? id;
  final String? usuario;
  final String? nombre;
  final String? rol;
  final bool? activo;
  @JsonKey(name: 'fecha_creacion')
  final String? fechaCreacion;
  @JsonKey(name: 'ultimo_acceso')  
  final String? ultimoAcceso;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  
  // Campos comunes
  final String email;
  final String? name;
  @JsonKey(name: 'family_name')
  final String? familyName;
  final String? username;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const UserModel({
    // Cognito fields
    this.cognitoId,
    
    // API mock fields
    this.id,
    this.usuario,
    this.nombre,
    this.rol,
    this.activo,
    this.fechaCreacion,
    this.ultimoAcceso,
    this.sessionId,
    
    // Common fields
    required this.email,
    this.name,
    this.familyName,
    this.username,
    this.phoneNumber,
    this.emailVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    // Determinar si es respuesta de Cognito o API mock
    final isApiResponse = id != null && usuario != null;
    
    return UserEntity(
      id: isApiResponse ? id.toString() : (cognitoId ?? email),
      email: email,
      name: isApiResponse ? (nombre ?? name ?? '') : (name ?? ''),
      familyName: familyName ?? '',
      username: isApiResponse ? usuario : username,
      phoneNumber: phoneNumber,
      emailVerified: emailVerified == true ? DateTime.now() : null,
      createdAt: isApiResponse 
          ? (fechaCreacion != null ? DateTime.tryParse(fechaCreacion!) : null)
          : (createdAt != null ? DateTime.tryParse(createdAt!) : null),
      updatedAt: isApiResponse
          ? (ultimoAcceso != null ? DateTime.tryParse(ultimoAcceso!) : null)
          : (updatedAt != null ? DateTime.tryParse(updatedAt!) : null),
      role: rol,
      isActive: activo,
      sessionId: sessionId,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      cognitoId: entity.id,
      id: int.tryParse(entity.id),
      usuario: entity.username,
      nombre: entity.name,
      rol: entity.role,
      activo: entity.isActive,
      sessionId: entity.sessionId,
      email: entity.email,
      name: entity.name.isNotEmpty ? entity.name : null,
      familyName: entity.familyName.isNotEmpty ? entity.familyName : null,
      username: entity.username,
      phoneNumber: entity.phoneNumber,
      emailVerified: entity.emailVerified != null,
      fechaCreacion: entity.createdAt?.toIso8601String(),
      ultimoAcceso: entity.updatedAt?.toIso8601String(),
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}