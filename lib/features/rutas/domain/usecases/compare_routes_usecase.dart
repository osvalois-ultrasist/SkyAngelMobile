import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/route_entity.dart';
import '../repositories/routes_repository.dart';

@lazySingleton
class CompareRoutesUseCase
    implements UseCase<RouteComparison, CompareRoutesParams> {
  final RoutesRepository _repository;

  CompareRoutesUseCase(this._repository);

  @override
  Future<Either<AppError, RouteComparison>> call(
      CompareRoutesParams params) async {
    return await _repository.compareRoutes(
      origin: params.origin,
      destination: params.destination,
      routeTypes: params.routeTypes,
      preferences: params.preferences,
    );
  }
}

class CompareRoutesParams {
  final LatLng origin;
  final LatLng destination;
  final List<RouteType>? routeTypes;
  final RoutePreferences? preferences;

  CompareRoutesParams({
    required this.origin,
    required this.destination,
    this.routeTypes,
    this.preferences,
  });
}