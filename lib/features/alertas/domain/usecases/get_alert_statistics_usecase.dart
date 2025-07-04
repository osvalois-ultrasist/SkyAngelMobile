import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../entities/alert_statistics_entity.dart';
import '../repositories/alert_repository.dart';

@LazySingleton()
class GetAlertStatisticsUseCase implements UseCase<AlertStatisticsEntity, NoParams> {
  final AlertRepository _repository;

  GetAlertStatisticsUseCase(this._repository);

  @override
  Future<Either<AppError, AlertStatisticsEntity>> call(NoParams params) async {
    try {
      AppLogger.info('Fetching alert statistics');
      
      final result = await _repository.getStatistics();
      
      return result.fold(
        (error) {
          AppLogger.error('Error fetching alert statistics', error: error);
          return Left(error);
        },
        (statistics) {
          AppLogger.info('Retrieved alert statistics: ${statistics.total} total alerts');
          return Right(statistics);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching alert statistics', error: e, stackTrace: stackTrace);
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener las estadísticas de alertas',
          details: e.toString(),
        ),
      );
    }
  }
}
