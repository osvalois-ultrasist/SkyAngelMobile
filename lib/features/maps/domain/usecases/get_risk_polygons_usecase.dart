import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/risk_polygon.dart';
import '../repositories/maps_repository.dart';

@injectable
class GetRiskPolygonsUseCase implements UseCase<List<RiskPolygon>, GetRiskPolygonsParams> {
  final MapsRepository _repository;

  GetRiskPolygonsUseCase(this._repository);

  @override
  Future<Either<AppError, List<RiskPolygon>>> call(GetRiskPolygonsParams params) async {
    if (params.getAllPolygons) {
      return await _repository.getAllRiskPolygons(filter: params.filter);
    } else {
      return await _repository.getRiskPolygons(
        center: params.center!,
        radiusKm: params.radiusKm!,
        filter: params.filter,
      );
    }
  }
}

class GetRiskPolygonsParams {
  final bool getAllPolygons;
  final LatLng? center;
  final double? radiusKm;
  final RiskFilter? filter;

  GetRiskPolygonsParams({
    this.getAllPolygons = false,
    this.center,
    this.radiusKm,
    this.filter,
  });

  GetRiskPolygonsParams.all({RiskFilter? filter})
      : getAllPolygons = true,
        center = null,
        radiusKm = null,
        filter = filter;

  GetRiskPolygonsParams.inArea({
    required LatLng center,
    required double radiusKm,
    RiskFilter? filter,
  })  : getAllPolygons = false,
        center = center,
        radiusKm = radiusKm,
        filter = filter;
}