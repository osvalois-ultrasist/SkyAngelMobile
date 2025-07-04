import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_tokens.dart';

part 'cognito_response_model.g.dart';

@JsonSerializable()
class CognitoResponseModel {
  @JsonKey(name: 'AuthenticationResult')
  final AuthenticationResult? authenticationResult;
  @JsonKey(name: 'ChallengeName')
  final String? challengeName;
  @JsonKey(name: 'Session')
  final String? session;
  @JsonKey(name: 'ChallengeParameters')
  final Map<String, dynamic>? challengeParameters;

  const CognitoResponseModel({
    this.authenticationResult,
    this.challengeName,
    this.session,
    this.challengeParameters,
  });

  factory CognitoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CognitoResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CognitoResponseModelToJson(this);

  AuthTokens? toAuthTokens() {
    if (authenticationResult == null) return null;
    
    final expiresIn = authenticationResult!.expiresIn ?? 3600;
    return AuthTokens(
      accessToken: authenticationResult!.accessToken ?? '',
      idToken: authenticationResult!.idToken ?? '',
      refreshToken: authenticationResult!.refreshToken ?? '',
      expiresIn: expiresIn,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }
}

@JsonSerializable()
class AuthenticationResult {
  @JsonKey(name: 'AccessToken')
  final String? accessToken;
  @JsonKey(name: 'IdToken')
  final String? idToken;
  @JsonKey(name: 'RefreshToken')
  final String? refreshToken;
  @JsonKey(name: 'ExpiresIn')
  final int? expiresIn;
  @JsonKey(name: 'TokenType')
  final String? tokenType;

  const AuthenticationResult({
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.expiresIn,
    this.tokenType,
  });

  factory AuthenticationResult.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationResultFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticationResultToJson(this);
}