import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/cognito_response_model.dart';
import '../models/user_model.dart';

abstract class CognitoAuthDataSource {
  Future<CognitoResponseModel> signIn(String username, String password);
  Future<CognitoUser> signUp(
    String email,
    String password,
    String name,
    String familyName,
  );
  Future<bool> confirmUser(String username, String code);
  Future<void> forgotPassword(String username);
  Future<void> confirmPassword(String username, String code, String newPassword);
  Future<CognitoResponseModel> refreshToken(String refreshToken);
  Future<UserModel> getCurrentUser();
  Future<void> signOut();
}

@LazySingleton(as: CognitoAuthDataSource)
class CognitoAuthDataSourceImpl implements CognitoAuthDataSource {
  late final CognitoUserPool _userPool;

  CognitoAuthDataSourceImpl() {
    _initializeUserPool();
  }

  Future<void> _initializeUserPool() async {
    // Por ahora usamos valores hardcoded, en producción se deberían obtener de configuración
    const userPoolId = 'us-east-1_XXXXXXXXX'; // Reemplazar con el pool ID real
    const clientId = 'XXXXXXXXXXXXXXXXXXXXXXXXXX'; // Reemplazar con el client ID real
    
    _userPool = CognitoUserPool(userPoolId, clientId);
  }

  @override
  Future<CognitoResponseModel> signIn(String username, String password) async {
    try {
      final cognitoUser = CognitoUser(username, _userPool);
      final authDetails = AuthenticationDetails(
        username: username,
        password: password,
      );

      final session = await cognitoUser.authenticateUser(authDetails);
      
      if (session == null) {
        throw AppError.authentication(
          message: 'Authentication failed',
          details: 'No session returned from Cognito',
        );
      }

      return CognitoResponseModel(
        authenticationResult: AuthenticationResult(
          accessToken: session.getAccessToken().getJwtToken(),
          idToken: session.getIdToken().getJwtToken(),
          refreshToken: session.getRefreshToken()?.getToken(),
          expiresIn: 3600,
          tokenType: 'Bearer',
        ),
      );
    } on CognitoUserException catch (e) {
      throw AppError.authentication(
        message: e.message ?? 'Authentication failed',
        details: 'Cognito authentication error: ${e.message ?? 'AUTH_ERROR'}',
      );
    } catch (e) {
      throw AppError.unknown(
        message: 'Authentication failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<CognitoUser> signUp(
    String email,
    String password,
    String name,
    String familyName,
  ) async {
    try {
      final userAttributes = [
        AttributeArg(name: 'email', value: email),
        AttributeArg(name: 'name', value: name),
        AttributeArg(name: 'family_name', value: familyName),
      ];

      final result = await _userPool.signUp(
        email,
        password,
        userAttributes: userAttributes,
      );

      if (result.userSub == null) {
        throw AppError.validation(
          message: 'Registration failed',
          details: 'User sub ID is null',
        );
      }

      return result.user;
    } on CognitoUserException catch (e) {
      throw AppError.validation(
        message: e.message ?? 'Registration failed',
        details: 'Cognito signup error: ${e.message ?? 'SIGNUP_ERROR'}',
      );
    } catch (e) {
      throw AppError.unknown(
        message: 'Registration failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<bool> confirmUser(String username, String code) async {
    try {
      final cognitoUser = CognitoUser(username, _userPool);
      final result = await cognitoUser.confirmRegistration(code);
      return result;
    } on CognitoUserException catch (e) {
      throw AppError.validation(
        message: e.message ?? 'Confirmation failed',
        details: 'Cognito confirmation error: ${e.message ?? 'CONFIRM_ERROR'}',
      );
    } catch (e) {
      throw AppError.unknown(
        message: 'Confirmation failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> forgotPassword(String username) async {
    try {
      final cognitoUser = CognitoUser(username, _userPool);
      await cognitoUser.forgotPassword();
    } on CognitoUserException catch (e) {
      throw AppError.server(
        message: e.message ?? 'Failed to send reset code',
        details: 'Cognito forgot password error: ${e.message ?? 'FORGOT_PASSWORD_ERROR'}',
      );
    } catch (e) {
      throw AppError.unknown(
        message: 'Failed to send reset code',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> confirmPassword(
    String username,
    String code,
    String newPassword,
  ) async {
    try {
      final cognitoUser = CognitoUser(username, _userPool);
      final result = await cognitoUser.confirmPassword(code, newPassword);
      if (!result) {
        throw AppError.validation(
          message: 'Failed to reset password',
          details: 'Password confirmation returned false',
        );
      }
    } on CognitoUserException catch (e) {
      throw AppError.validation(
        message: e.message ?? 'Failed to reset password',
        details: 'Cognito confirm password error: ${e.message ?? 'CONFIRM_PASSWORD_ERROR'}',
      );
    } catch (e) {
      throw AppError.unknown(
        message: 'Failed to reset password',
        details: e.toString(),
      );
    }
  }

  @override
  Future<CognitoResponseModel> refreshToken(String refreshToken) async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser == null) {
        throw AppError.authentication(
          message: 'No current user',
          details: 'No authenticated user found in Cognito',
        );
      }

      final session = await cognitoUser.getSession();
      if (session == null) {
        throw AppError.authentication(
          message: 'Failed to refresh token',
          details: 'No session returned from Cognito',
        );
      }

      return CognitoResponseModel(
        authenticationResult: AuthenticationResult(
          accessToken: session.getAccessToken().getJwtToken(),
          idToken: session.getIdToken().getJwtToken(),
          refreshToken: session.getRefreshToken()?.getToken(),
          expiresIn: 3600,
          tokenType: 'Bearer',
        ),
      );
    } on CognitoUserException catch (e) {
      throw AppError.authentication(
        message: e.message ?? 'Failed to refresh token',
        details: 'Cognito refresh token error: ${e.message ?? 'REFRESH_ERROR'}',
      );
    } catch (e) {
      throw AppError.unknown(
        message: 'Failed to refresh token',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser == null) {
        throw AppError.authentication(
          message: 'No current user',
          details: 'No authenticated user found in Cognito',
        );
      }

      final attributes = await cognitoUser.getUserAttributes();
      if (attributes == null) {
        throw AppError.server(
          message: 'Failed to get user attributes',
          details: 'Cognito returned null attributes',
        );
      }

      final attributeMap = <String, String>{};
      for (final attr in attributes) {
        attributeMap[attr.getName() ?? ''] = attr.getValue() ?? '';
      }

      return UserModel(
        cognitoId: attributeMap['sub'] ?? '',
        email: attributeMap['email'] ?? '',
        name: attributeMap['name'] ?? '',
        familyName: attributeMap['family_name'] ?? '',
        username: attributeMap['preferred_username'],
        phoneNumber: attributeMap['phone_number'],
        emailVerified: attributeMap['email_verified'] == 'true',
      );
    } on CognitoUserException catch (e) {
      throw AppError.authentication(
        message: e.message ?? 'Failed to get current user',
        details: 'Cognito get user error: ${e.message ?? 'GET_USER_ERROR'}',
      );
    } catch (e) {
      throw AppError.unknown(
        message: 'Failed to get current user',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser != null) {
        await cognitoUser.signOut();
      }
    } catch (e) {
      throw AppError.unknown(
        message: 'Failed to sign out',
        details: e.toString(),
      );
    }
  }
}