import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/poi_entity.dart';
import '../repositories/maps_repository.dart';

@injectable
class GetPOIsUseCase implements UseCase<List<POIEntity>, GetPOIsParams> {
  final MapsRepository _repository;

  GetPOIsUseCase(this._repository);

  @override
  Future<Either<AppError, List<POIEntity>>> call(GetPOIsParams params) async {
    if (params.searchQuery != null) {
      return await _repository.searchPOIs(
        query: params.searchQuery!,
        center: params.center,
        radiusKm: params.radiusKm,
      );
    } else if (params.type != null) {
      return await _repository.getPOIsByType(
        type: params.type!,
        filter: params.filter,
      );
    } else {
      return await _repository.getPOIsInArea(
        center: params.center!,
        radiusKm: params.radiusKm!,
        filter: params.filter,
      );
    }
  }
}

class GetPOIsParams {
  final LatLng? center;
  final double? radiusKm;
  final POIType? type;
  final String? searchQuery;
  final POIFilter? filter;

  GetPOIsParams({
    this.center,
    this.radiusKm,
    this.type,
    this.searchQuery,
    this.filter,
  });

  GetPOIsParams.inArea({
    required LatLng center,
    required double radiusKm,
    POIFilter? filter,
  })  : center = center,
        radiusKm = radiusKm,
        type = null,
        searchQuery = null,
        filter = filter;

  GetPOIsParams.byType({
    required POIType type,
    POIFilter? filter,
  })  : center = null,
        radiusKm = null,
        type = type,
        searchQuery = null,
        filter = filter;

  GetPOIsParams.search({
    required String query,
    LatLng? center,
    double? radiusKm,
  })  : center = center,
        radiusKm = radiusKm,
        type = null,
        searchQuery = query,
        filter = null;
}