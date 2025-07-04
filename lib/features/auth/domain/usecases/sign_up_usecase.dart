import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../entities/register_request.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Either<AppError, UserEntity>> call(RegisterRequest request) async {
    try {
      final user = await _repository.signUp(request);
      return Right(user);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppError.unknown(
        message: 'Error durante el registro',
        details: e.toString(),
      ));
    }
  }
}