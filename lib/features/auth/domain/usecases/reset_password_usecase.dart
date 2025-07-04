import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<AppError, void>> requestCode(String username) async {
    try {
      await _repository.forgotPassword(username);
      return const Right(null);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppError.unknown(
        message: 'Error al solicitar código de reseteo',
        details: e.toString(),
      ));
    }
  }

  Future<Either<AppError, void>> confirmNewPassword({
    required String username,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _repository.resetPassword(username, code, newPassword);
      return const Right(null);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppError.unknown(
        message: 'Error al confirmar nueva contraseña',
        details: e.toString(),
      ));
    }
  }
}