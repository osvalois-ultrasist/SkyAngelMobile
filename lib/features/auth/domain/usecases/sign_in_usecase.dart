import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../entities/auth_credentials.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Either<AppError, UserEntity>> call(AuthCredentials credentials) async {
    try {
      final user = await _repository.signIn(credentials);
      return Right(user);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppError.unknown(
        message: 'Error durante el inicio de sesión',
        details: e.toString(),
      ));
    }
  }
}