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
  }) = _UserEntity;

  const UserEntity._();
}