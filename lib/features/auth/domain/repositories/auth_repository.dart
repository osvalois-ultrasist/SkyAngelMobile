import 'package:dartz/dartz.dart';
import '../../../../core/error/app_error.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_tokens.dart';
import '../entities/register_request.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<AppError, AuthTokens>> signIn(AuthCredentials credentials);
  
  Future<Either<AppError, UserEntity>> signUp(RegisterRequest request);
  
  Future<Either<AppError, bool>> confirmUser(String username, String code);
  
  Future<Either<AppError, void>> forgotPassword(String username);
  
  Future<Either<AppError, void>> confirmPassword(
    String username,
    String code,
    String newPassword,
  );
  
  Future<Either<AppError, AuthTokens>> refreshToken(String refreshToken);
  
  Future<Either<AppError, UserEntity>> getCurrentUser();
  
  Future<Either<AppError, void>> signOut();
  
  Future<Either<AppError, bool>> checkEmailAuthorization(String email);
}