import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String name,
    required String familyName,
    String? username,
    String? phoneNumber,
    DateTime? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Campos adicionales para compatibilidad con API mock
    String? role,
    bool? isActive,
    String? sessionId,
  }) = _UserEntity;

  const UserEntity._();

  /// Obtiene el nombre completo del usuario
  String get fullName => '$name $familyName'.trim();

  /// Verifica si el usuario tiene un rol específico
  bool hasRole(String targetRole) => role?.toLowerCase() == targetRole.toLowerCase();

  /// Verifica si el usuario es administrador
  bool get isAdmin => hasRole('admin');

  /// Verifica si el usuario está activo y verificado
  bool get isVerifiedAndActive => (isActive ?? true) && emailVerified != null;
}