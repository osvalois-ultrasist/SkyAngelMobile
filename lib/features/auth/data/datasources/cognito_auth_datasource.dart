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
        throw const AppError(
          message: 'Authentication failed',
          code: 'AUTH_FAILED',
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
      throw AppError(
        message: e.message ?? 'Authentication failed',
        code: e.code ?? 'AUTH_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
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
        throw const AppError(
          message: 'Registration failed',
          code: 'SIGNUP_FAILED',
        );
      }

      return result.user;
    } on CognitoUserException catch (e) {
      throw AppError(
        message: e.message ?? 'Registration failed',
        code: e.code ?? 'SIGNUP_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
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
      throw AppError(
        message: e.message ?? 'Confirmation failed',
        code: e.code ?? 'CONFIRM_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> forgotPassword(String username) async {
    try {
      final cognitoUser = CognitoUser(username, _userPool);
      await cognitoUser.forgotPassword();
    } on CognitoUserException catch (e) {
      throw AppError(
        message: e.message ?? 'Failed to send reset code',
        code: e.code ?? 'FORGOT_PASSWORD_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
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
        throw const AppError(
          message: 'Failed to reset password',
          code: 'CONFIRM_PASSWORD_FAILED',
        );
      }
    } on CognitoUserException catch (e) {
      throw AppError(
        message: e.message ?? 'Failed to reset password',
        code: e.code ?? 'CONFIRM_PASSWORD_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<CognitoResponseModel> refreshToken(String refreshToken) async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser == null) {
        throw const AppError(
          message: 'No current user',
          code: 'NO_USER',
        );
      }

      final session = await cognitoUser.getSession();
      if (session == null) {
        throw const AppError(
          message: 'Failed to refresh token',
          code: 'REFRESH_FAILED',
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
      throw AppError(
        message: e.message ?? 'Failed to refresh token',
        code: e.code ?? 'REFRESH_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser == null) {
        throw const AppError(
          message: 'No current user',
          code: 'NO_USER',
        );
      }

      final attributes = await cognitoUser.getUserAttributes();
      if (attributes == null) {
        throw const AppError(
          message: 'Failed to get user attributes',
          code: 'NO_ATTRIBUTES',
        );
      }

      final attributeMap = <String, String>{};
      for (final attr in attributes) {
        attributeMap[attr.getName() ?? ''] = attr.getValue() ?? '';
      }

      return UserModel(
        id: attributeMap['sub'] ?? '',
        email: attributeMap['email'] ?? '',
        name: attributeMap['name'] ?? '',
        familyName: attributeMap['family_name'] ?? '',
        username: attributeMap['preferred_username'],
        phoneNumber: attributeMap['phone_number'],
        emailVerified: attributeMap['email_verified'] == 'true',
      );
    } on CognitoUserException catch (e) {
      throw AppError(
        message: e.message ?? 'Failed to get current user',
        code: e.code ?? 'GET_USER_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
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
      throw AppError(
        message: e.toString(),
        code: 'SIGNOUT_ERROR',
      );
    }
  }
}