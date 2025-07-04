import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

@LazySingleton()
class GetActiveAlertsUseCase implements UseCase<List<AlertEntity>, NoParams> {
  final AlertRepository _repository;

  GetActiveAlertsUseCase(this._repository);

  @override
  Future<Either<AppError, List<AlertEntity>>> call(NoParams params) async {
    try {
      AppLogger.info('Fetching active alerts');
      
      final result = await _repository.getActiveAlerts();
      
      return result.fold(
        (error) {
          AppLogger.error('Error fetching active alerts', error: error);
          return Left(error);
        },
        (alerts) {
          AppLogger.info('Retrieved ${alerts.length} active alerts');
          return Right(alerts);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching active alerts', error: e, stackTrace: stackTrace);
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener las alertas activas',
          details: e.toString(),
        ),
      );
    }
  }
}
