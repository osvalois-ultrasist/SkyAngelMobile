import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Either<AppError, AuthTokens>> call(AuthCredentials credentials) {
    return _repository.signIn(credentials);
  }
}