import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/route_entity.dart';
import '../repositories/routes_repository.dart';

part 'save_route_usecase.freezed.dart';

@freezed
class SaveRouteParams with _$SaveRouteParams {
  const factory SaveRouteParams({
    required RouteEntity route,
    required String userId,
  }) = _SaveRouteParams;
}

@lazySingleton
class SaveRouteUseCase implements UseCase<RouteEntity, SaveRouteParams> {
  final RoutesRepository _repository;

  const SaveRouteUseCase(this._repository);

  @override
  Future<Either<AppError, RouteEntity>> call(SaveRouteParams params) {
    return _repository.saveRoute(
      route: params.route,
      userId: params.userId,
    );
  }
}