import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'sub')
  final String id;
  final String email;
  final String name;
  @JsonKey(name: 'family_name')
  final String familyName;
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
    required this.id,
    required this.email,
    required this.name,
    required this.familyName,
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
    return UserEntity(
      id: id,
      email: email,
      name: name,
      familyName: familyName,
      username: username,
      phoneNumber: phoneNumber,
      emailVerified: emailVerified == true ? DateTime.now() : null,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      familyName: entity.familyName,
      username: entity.username,
      phoneNumber: entity.phoneNumber,
      emailVerified: entity.emailVerified != null,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}