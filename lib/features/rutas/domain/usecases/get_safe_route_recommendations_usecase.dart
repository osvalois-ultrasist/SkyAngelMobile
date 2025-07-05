import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/route_entity.dart';
import '../repositories/routes_repository.dart';

@lazySingleton
class GetSafeRouteRecommendationsUseCase
    implements UseCase<List<SafeRouteRecommendation>, GetSafeRouteRecommendationsParams> {
  final RoutesRepository _repository;

  GetSafeRouteRecommendationsUseCase(this._repository);

  @override
  Future<Either<AppError, List<SafeRouteRecommendation>>> call(
      GetSafeRouteRecommendationsParams params) async {
    return await _repository.getSafeRouteRecommendations(
      origin: params.origin,
      destination: params.destination,
      departureTime: params.departureTime,
      preferences: params.preferences,
    );
  }
}

class GetSafeRouteRecommendationsParams {
  final LatLng origin;
  final LatLng destination;
  final DateTime? departureTime;
  final RoutePreferences? preferences;

  GetSafeRouteRecommendationsParams({
    required this.origin,
    required this.destination,
    this.departureTime,
    this.preferences,
  });
}