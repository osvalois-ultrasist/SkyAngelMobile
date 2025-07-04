import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

part 'update_alert_status_usecase.freezed.dart';

@freezed
class UpdateAlertStatusParams with _$UpdateAlertStatusParams {
  const factory UpdateAlertStatusParams({
    required int alertId,
    required AlertStatus newStatus,
  }) = _UpdateAlertStatusParams;
}

@LazySingleton()
class UpdateAlertStatusUseCase implements UseCase<AlertEntity, UpdateAlertStatusParams> {
  final AlertRepository _repository;

  UpdateAlertStatusUseCase(this._repository);

  @override
  Future<Either<AppError, AlertEntity>> call(UpdateAlertStatusParams params) async {
    try {
      AppLogger.info('Updating alert ${params.alertId} status to ${params.newStatus}');
      
      final result = await _repository.updateAlertStatus(params.alertId, params.newStatus);
      
      return result.fold(
        (error) {
          AppLogger.error('Error updating alert status', error: error);
          return Left(error);
        },
        (alert) {
          AppLogger.info('Alert ${alert.id} status updated successfully to ${alert.estado}');
          return Right(alert);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating alert status', error: e, stackTrace: stackTrace);
      return Left(
        AppError.unknown(
          message: 'Error inesperado al actualizar el estado de la alerta',
          details: e.toString(),
        ),
      );
    }
  }
}
