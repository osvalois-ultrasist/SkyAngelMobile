import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/risk_polygon.dart';
import '../repositories/maps_repository.dart';

@injectable
class GetRouteRiskAnalysisUseCase implements UseCase<RouteRiskAnalysis, GetRouteRiskAnalysisParams> {
  final MapsRepository _repository;

  GetRouteRiskAnalysisUseCase(this._repository);

  @override
  Future<Either<AppError, RouteRiskAnalysis>> call(GetRouteRiskAnalysisParams params) async {
    return await _repository.getRouteRiskAnalysis(
      routePoints: params.routePoints,
      filter: params.filter,
    );
  }
}

class GetRouteRiskAnalysisParams {
  final List<LatLng> routePoints;
  final RiskFilter? filter;

  GetRouteRiskAnalysisParams({
    required this.routePoints,
    this.filter,
  });
}