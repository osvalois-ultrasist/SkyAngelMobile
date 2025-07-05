import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/route_entity.dart';
import '../repositories/routes_repository.dart';

part 'get_saved_routes_usecase.freezed.dart';

@freezed
class GetSavedRoutesParams with _$GetSavedRoutesParams {
  const factory GetSavedRoutesParams({
    required String userId,
    RouteStatus? status,
  }) = _GetSavedRoutesParams;
}

@lazySingleton
class GetSavedRoutesUseCase implements UseCase<List<RouteEntity>, GetSavedRoutesParams> {
  final RoutesRepository _repository;

  const GetSavedRoutesUseCase(this._repository);

  @override
  Future<Either<AppError, List<RouteEntity>>> call(GetSavedRoutesParams params) {
    return _repository.getSavedRoutes(
      userId: params.userId,
      status: params.status,
    );
  }
}