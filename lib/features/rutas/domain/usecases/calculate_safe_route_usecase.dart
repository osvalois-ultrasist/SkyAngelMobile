import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/route_entity.dart';
import '../repositories/routes_repository.dart';

@lazySingleton
class CalculateSafeRouteUseCase
    implements UseCase<RouteEntity, CalculateSafeRouteParams> {
  final RoutesRepository _repository;

  CalculateSafeRouteUseCase(this._repository);

  @override
  Future<Either<AppError, RouteEntity>> call(
      CalculateSafeRouteParams params) async {
    return await _repository.calculateRoute(
      origin: params.origin,
      destination: params.destination,
      routeType: params.routeType,
      waypoints: params.waypoints,
      preferences: params.preferences,
    );
  }
}

class CalculateSafeRouteParams {
  final LatLng origin;
  final LatLng destination;
  final RouteType routeType;
  final List<LatLng>? waypoints;
  final RoutePreferences? preferences;

  CalculateSafeRouteParams({
    required this.origin,
    required this.destination,
    required this.routeType,
    this.waypoints,
    this.preferences,
  });
}