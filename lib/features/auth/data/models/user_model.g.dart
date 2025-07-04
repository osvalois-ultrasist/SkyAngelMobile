// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      cognitoId: json['sub'] as String?,
      id: (json['id'] as num?)?.toInt(),
      usuario: json['usuario'] as String?,
      nombre: json['nombre'] as String?,
      rol: json['rol'] as String?,
      activo: json['activo'] as bool?,
      fechaCreacion: json['fecha_creacion'] as String?,
      ultimoAcceso: json['ultimo_acceso'] as String?,
      sessionId: json['session_id'] as String?,
      email: json['email'] as String,
      name: json['name'] as String?,
      familyName: json['family_name'] as String?,
      username: json['username'] as String?,
      phoneNumber: json['phone_number'] as String?,
      emailVerified: json['email_verified'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'sub': instance.cognitoId,
      'id': instance.id,
      'usuario': instance.usuario,
      'nombre': instance.nombre,
      'rol': instance.rol,
      'activo': instance.activo,
      'fecha_creacion': instance.fechaCreacion,
      'ultimo_acceso': instance.ultimoAcceso,
      'session_id': instance.sessionId,
      'email': instance.email,
      'name': instance.name,
      'family_name': instance.familyName,
      'username': instance.username,
      'phone_number': instance.phoneNumber,
      'email_verified': instance.emailVerified,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
