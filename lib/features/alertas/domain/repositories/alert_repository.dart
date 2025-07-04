import 'package:dartz/dartz.dart';

import '../../../../core/error/app_error.dart';
import '../entities/alert_entity.dart';
import '../entities/alert_category_entity.dart';
import '../entities/alert_statistics_entity.dart';
import '../entities/create_alert_request.dart';

abstract class AlertRepository {
  Future<Either<AppError, List<AlertEntity>>> getActiveAlerts();
  
  Future<Either<AppError, AlertEntity>> createAlert(CreateAlertRequest request);
  
  Future<Either<AppError, AlertEntity>> getAlert(int id);
  
  Future<Either<AppError, AlertEntity>> updateAlertStatus(int id, AlertStatus status);
  
  Future<Either<AppError, List<AlertCategoryEntity>>> getCategories();
  
  Future<Either<AppError, List<AlertSubcategoryEntity>>> getSubcategories({int? categoryId});
  
  Future<Either<AppError, AlertStatisticsEntity>> getStatistics();
  
  Stream<AlertEntity> get alertStream;
  
  Stream<AlertEntity> get alertUpdatesStream;
}
