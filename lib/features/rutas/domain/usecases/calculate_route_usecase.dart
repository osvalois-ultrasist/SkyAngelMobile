import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/route_entity.dart';
import '../repositories/routes_repository.dart';

part 'calculate_route_usecase.freezed.dart';

@freezed
class CalculateRouteParams with _$CalculateRouteParams {
  const factory CalculateRouteParams({
    required LatLng origin,
    required LatLng destination,
    required RouteType routeType,
    List<LatLng>? waypoints,
    RoutePreferences? preferences,
  }) = _CalculateRouteParams;
}

@lazySingleton
class CalculateRouteUseCase implements UseCase<RouteEntity, CalculateRouteParams> {
  final RoutesRepository _repository;

  const CalculateRouteUseCase(this._repository);

  @override
  Future<Either<AppError, RouteEntity>> call(CalculateRouteParams params) {
    return _repository.calculateRoute(
      origin: params.origin,
      destination: params.destination,
      routeType: params.routeType,
      waypoints: params.waypoints,
      preferences: params.preferences,
    );
  }
}