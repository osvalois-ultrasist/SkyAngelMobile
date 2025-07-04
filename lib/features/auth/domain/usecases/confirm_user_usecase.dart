import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class ConfirmUserUseCase {
  final AuthRepository _repository;

  ConfirmUserUseCase(this._repository);

  Future<Either<AppError, bool>> call({
    required String username,
    required String code,
  }) async {
    try {
      final result = await _repository.confirmUser(username, code);
      return Right(result);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppError.unknown(
        message: 'Error durante la confirmación',
        details: e.toString(),
      ));
    }
  }
}