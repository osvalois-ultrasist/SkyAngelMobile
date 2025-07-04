import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../entities/alert_entity.dart';
import '../entities/create_alert_request.dart';
import '../repositories/alert_repository.dart';

@LazySingleton()
class CreateAlertUseCase implements UseCase<AlertEntity, CreateAlertRequest> {
  final AlertRepository _repository;

  CreateAlertUseCase(this._repository);

  @override
  Future<Either<AppError, AlertEntity>> call(CreateAlertRequest params) async {
    try {
      AppLogger.info('Creating alert: ${params.tipo} - ${params.incidencia}');
      
      if (!params.isValid) {
        return Left(
          AppError.validation(
            message: 'Datos de alerta inválidos',
            details: 'Los datos proporcionados no son válidos para crear la alerta',
          ),
        );
      }

      final result = await _repository.createAlert(params);
      
      return result.fold(
        (error) {
          AppLogger.error('Error creating alert', error: error);
          return Left(error);
        },
        (alert) {
          AppLogger.info('Alert created successfully: ${alert.id}');
          return Right(alert);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating alert', error: e, stackTrace: stackTrace);
      return Left(
        AppError.unknown(
          message: 'Error inesperado al crear la alerta',
          details: e.toString(),
        ),
      );
    }
  }
}
