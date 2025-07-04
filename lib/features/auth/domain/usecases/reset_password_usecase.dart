import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/app_error.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<AppError, void>> requestCode(String username) {
    return _repository.forgotPassword(username);
  }

  Future<Either<AppError, void>> confirmNewPassword({
    required String username,
    required String code,
    required String newPassword,
  }) {
    return _repository.confirmPassword(username, code, newPassword);
  }
}