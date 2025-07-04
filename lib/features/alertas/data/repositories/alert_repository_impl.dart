import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/alert_category_entity.dart';
import '../../domain/entities/alert_statistics_entity.dart';
import '../../domain/entities/create_alert_request.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_api_datasource.dart';
import '../datasources/alert_websocket_datasource.dart';
import '../models/alert_model.dart';
import '../models/alert_category_model.dart';
import '../models/alert_statistics_model.dart';

@LazySingleton(as: AlertRepository)
class AlertRepositoryImpl implements AlertRepository {
  final AlertApiDataSourceImpl _apiDataSource;
  final AlertWebSocketDataSource _webSocketDataSource;
  
  late final StreamController<AlertEntity> _alertStreamController;
  late final StreamController<AlertEntity> _alertUpdatesStreamController;

  AlertRepositoryImpl(
    this._apiDataSource,
    this._webSocketDataSource,
  ) {
    _alertStreamController = StreamController<AlertEntity>.broadcast();
    _alertUpdatesStreamController = StreamController<AlertEntity>.broadcast();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // Connect to WebSocket for real-time updates
    _webSocketDataSource.connect();
    
    // Listen to new alerts from WebSocket
    _webSocketDataSource.newAlertStream.listen(
      (alertModel) {
        final alertEntity = alertModel.toEntity();
        _alertStreamController.add(alertEntity);
        AppLogger.info('New alert received via WebSocket: ${alertEntity.id}');
      },
      onError: (error) {
        AppLogger.error('Error in WebSocket new alert stream', error: error);
      },
    );
    
    // Listen to alert updates from WebSocket
    _webSocketDataSource.alertUpdateStream.listen(
      (alertModel) {
        final alertEntity = alertModel.toEntity();
        _alertUpdatesStreamController.add(alertEntity);
        AppLogger.info('Alert update received via WebSocket: ${alertEntity.id}');
      },
      onError: (error) {
        AppLogger.error('Error in WebSocket alert update stream', error: error);
      },
    );
  }

  @override
  Future<Either<AppError, List<AlertEntity>>> getActiveAlerts() async {
    try {
      final alertModels = await _apiDataSource.getActiveAlerts();
      final alertEntities = alertModels.map((model) => model.toEntity()).toList();
      
      return Right(alertEntities);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener alertas activas',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AlertEntity>> createAlert(CreateAlertRequest request) async {
    try {
      final alertModel = await _apiDataSource.createAlert(request.toJson());
      final alertEntity = alertModel.toEntity();
      
      return Right(alertEntity);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al crear la alerta',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AlertEntity>> getAlert(int id) async {
    try {
      final alertModel = await _apiDataSource.getAlert(id);
      final alertEntity = alertModel.toEntity();
      
      return Right(alertEntity);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener la alerta',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AlertEntity>> updateAlertStatus(int id, AlertStatus status) async {
    try {
      final alertModel = await _apiDataSource.updateAlertStatus(id, status.name);
      final alertEntity = alertModel.toEntity();
      
      return Right(alertEntity);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al actualizar el estado de la alerta',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<AlertCategoryEntity>>> getCategories() async {
    try {
      final categoryModels = await _apiDataSource.getCategories();
      final categoryEntities = categoryModels.map((model) => model.toEntity()).toList();
      
      return Right(categoryEntities);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener categorías de alerta',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<AlertSubcategoryEntity>>> getSubcategories({int? categoryId}) async {
    try {
      final subcategoryModels = await _apiDataSource.getSubcategories(categoryId: categoryId);
      final subcategoryEntities = subcategoryModels.map((model) => model.toEntity()).toList();
      
      return Right(subcategoryEntities);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener subcategorías de alerta',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AlertStatisticsEntity>> getStatistics() async {
    try {
      final statisticsModel = await _apiDataSource.getStatistics();
      final statisticsEntity = statisticsModel.toEntity();
      
      return Right(statisticsEntity);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener estadísticas de alertas',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<AlertEntity> get alertStream => _alertStreamController.stream;

  @override
  Stream<AlertEntity> get alertUpdatesStream => _alertUpdatesStreamController.stream;

  void dispose() {
    _alertStreamController.close();
    _alertUpdatesStreamController.close();
    _webSocketDataSource.dispose();
  }
}
