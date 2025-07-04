import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../entities/alert_category_entity.dart';
import '../repositories/alert_repository.dart';

@LazySingleton()
class GetAlertCategoriesUseCase implements UseCase<List<AlertCategoryEntity>, NoParams> {
  final AlertRepository _repository;

  GetAlertCategoriesUseCase(this._repository);

  @override
  Future<Either<AppError, List<AlertCategoryEntity>>> call(NoParams params) async {
    try {
      AppLogger.info('Fetching alert categories');
      
      final result = await _repository.getCategories();
      
      return result.fold(
        (error) {
          AppLogger.error('Error fetching alert categories', error: error);
          return Left(error);
        },
        (categories) {
          AppLogger.info('Retrieved ${categories.length} alert categories');
          return Right(categories);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching alert categories', error: e, stackTrace: stackTrace);
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener las categorías de alerta',
          details: e.toString(),
        ),
      );
    }
  }
}

@LazySingleton()
class GetAlertSubcategoriesUseCase implements UseCase<List<AlertSubcategoryEntity>, int?> {
  final AlertRepository _repository;

  GetAlertSubcategoriesUseCase(this._repository);

  @override
  Future<Either<AppError, List<AlertSubcategoryEntity>>> call(int? categoryId) async {
    try {
      AppLogger.info('Fetching alert subcategories${categoryId != null ? ' for category $categoryId' : ''}');
      
      final result = await _repository.getSubcategories(categoryId: categoryId);
      
      return result.fold(
        (error) {
          AppLogger.error('Error fetching alert subcategories', error: error);
          return Left(error);
        },
        (subcategories) {
          AppLogger.info('Retrieved ${subcategories.length} alert subcategories');
          return Right(subcategories);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching alert subcategories', error: e, stackTrace: stackTrace);
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener las subcategorías de alerta',
          details: e.toString(),
        ),
      );
    }
  }
}
