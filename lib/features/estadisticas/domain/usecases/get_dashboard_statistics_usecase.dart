import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/statistics_entity.dart';
import '../repositories/statistics_repository.dart';

@lazySingleton
class GetDashboardStatisticsUseCase
    implements UseCase<DashboardStatistics, GetDashboardStatisticsParams> {
  final StatisticsRepository _repository;

  GetDashboardStatisticsUseCase(this._repository);

  @override
  Future<Either<AppError, DashboardStatistics>> call(
      GetDashboardStatisticsParams params) async {
    return await _repository.getDashboardStatistics(
      userId: params.userId,
      filter: params.filter,
    );
  }
}

class GetDashboardStatisticsParams {
  final String? userId;
  final StatisticsFilter? filter;

  GetDashboardStatisticsParams({
    this.userId,
    this.filter,
  });
}