// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cognito_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CognitoResponseModel _$CognitoResponseModelFromJson(
        Map<String, dynamic> json) =>
    CognitoResponseModel(
      authenticationResult: json['AuthenticationResult'] == null
          ? null
          : AuthenticationResult.fromJson(
              json['AuthenticationResult'] as Map<String, dynamic>),
      challengeName: json['ChallengeName'] as String?,
      session: json['Session'] as String?,
      challengeParameters: json['ChallengeParameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CognitoResponseModelToJson(
        CognitoResponseModel instance) =>
    <String, dynamic>{
      'AuthenticationResult': instance.authenticationResult,
      'ChallengeName': instance.challengeName,
      'Session': instance.session,
      'ChallengeParameters': instance.challengeParameters,
    };

AuthenticationResult _$AuthenticationResultFromJson(
        Map<String, dynamic> json) =>
    AuthenticationResult(
      accessToken: json['AccessToken'] as String?,
      idToken: json['IdToken'] as String?,
      refreshToken: json['RefreshToken'] as String?,
      expiresIn: (json['ExpiresIn'] as num?)?.toInt(),
      tokenType: json['TokenType'] as String?,
    );

Map<String, dynamic> _$AuthenticationResultToJson(
        AuthenticationResult instance) =>
    <String, dynamic>{
      'AccessToken': instance.accessToken,
      'IdToken': instance.idToken,
      'RefreshToken': instance.refreshToken,
      'ExpiresIn': instance.expiresIn,
      'TokenType': instance.tokenType,
    };
