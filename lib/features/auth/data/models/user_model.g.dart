// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['sub'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      familyName: json['family_name'] as String,
      username: json['username'] as String?,
      phoneNumber: json['phone_number'] as String?,
      emailVerified: json['email_verified'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'sub': instance.id,
      'email': instance.email,
      'name': instance.name,
      'family_name': instance.familyName,
      'username': instance.username,
      'phone_number': instance.phoneNumber,
      'email_verified': instance.emailVerified,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
