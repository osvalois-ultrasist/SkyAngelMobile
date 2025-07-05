import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/routes_repository.dart';

part 'delete_route_usecase.freezed.dart';

@freezed
class DeleteRouteParams with _$DeleteRouteParams {
  const factory DeleteRouteParams({
    required String routeId,
    required String userId,
  }) = _DeleteRouteParams;
}

@lazySingleton
class DeleteRouteUseCase implements UseCase<bool, DeleteRouteParams> {
  final RoutesRepository _repository;

  const DeleteRouteUseCase(this._repository);

  @override
  Future<Either<AppError, bool>> call(DeleteRouteParams params) {
    return _repository.deleteRoute(
      routeId: params.routeId,
      userId: params.userId,
    );
  }
}