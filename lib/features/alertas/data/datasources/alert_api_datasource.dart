import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../models/alert_model.dart';
import '../models/alert_category_model.dart';
import '../models/alert_statistics_model.dart';

part 'alert_api_datasource.g.dart';

@RestApi(baseUrl: "")
abstract class AlertApiDataSource {
  factory AlertApiDataSource(Dio dio) = _AlertApiDataSource;

  @GET('/alerts/alertas_activas')
  Future<dynamic> getActiveAlerts();
  
  @POST('/alerts/alerta')
  Future<dynamic> createAlert(@Body() Map<String, dynamic> request);
  
  @GET('/alerts/alertas/{id}')
  Future<dynamic> getAlert(@Path() int id);
  
  @PUT('/alerts/alertas/{id}/estado')
  Future<dynamic> updateAlertStatus(
    @Path() int id,
    @Body() Map<String, String> status,
  );
  
  @GET('/alerts/categorias')
  Future<dynamic> getCategories();
  
  @GET('/alerts/subcategorias')
  Future<dynamic> getSubcategories({
    @Query('categoria_id') int? categoryId,
  });
  
  @GET('/alerts/estadisticas')
  Future<dynamic> getStatistics();
}

@LazySingleton()
class AlertApiDataSourceImpl {
  final AlertApiDataSource _apiService;

  AlertApiDataSourceImpl(this._apiService);

  @factoryMethod
  static AlertApiDataSourceImpl create(Dio dio) {
    final apiService = AlertApiDataSource(dio);
    return AlertApiDataSourceImpl(apiService);
  }

  Future<List<AlertModel>> getActiveAlerts() async {
    try {
      AppLogger.info('Fetching active alerts from API');
      
      final response = await _apiService.getActiveAlerts();
      
      if (response['features'] != null) {
        final features = response['features'] as List;
        final alerts = features.map((feature) {
          final properties = feature['properties'] as Map<String, dynamic>;
          final geometry = feature['geometry'] as Map<String, dynamic>;
          final coordinates = geometry['coordinates'] as List;
          
          return AlertModel.fromJson({
            ...properties,
            'lat': coordinates[1],
            'lng': coordinates[0],
            'coordenadas': '${coordinates[1]},${coordinates[0]}',
          });
        }).toList();
        
        AppLogger.info('Successfully fetched ${alerts.length} active alerts');
        return alerts;
      }
      
      return [];
    } on DioException catch (e) {
      AppLogger.error('API error fetching active alerts', error: e);
      throw AppError.network(
        message: 'Error de red al obtener alertas activas',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching active alerts', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener alertas activas',
        details: e.toString(),
      );
    }
  }
  
  Future<AlertModel> createAlert(Map<String, dynamic> request) async {
    try {
      AppLogger.info('Creating alert via API');
      
      final response = await _apiService.createAlert(request);
      
      if (response['alerta'] != null) {
        final alertData = response['alerta'] as Map<String, dynamic>;
        final alert = AlertModel.fromJson(alertData);
        
        AppLogger.info('Successfully created alert: ${alert.id}');
        return alert;
      }
      
      throw AppError.unknown(
        message: 'Respuesta inválida del servidor',
        details: 'No se recibió información de la alerta creada',
      );
    } on DioException catch (e) {
      AppLogger.error('API error creating alert', error: e);
      throw AppError.network(
        message: 'Error de red al crear la alerta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error creating alert', error: e);
      if (e is AppError) rethrow;
      throw AppError.unknown(
        message: 'Error inesperado al crear la alerta',
        details: e.toString(),
      );
    }
  }
  
  Future<AlertModel> getAlert(int id) async {
    try {
      AppLogger.info('Fetching alert $id from API');
      
      final response = await _apiService.getAlert(id);
      final alert = AlertModel.fromJson(response as Map<String, dynamic>);
      
      AppLogger.info('Successfully fetched alert: ${alert.id}');
      return alert;
    } on DioException catch (e) {
      AppLogger.error('API error fetching alert', error: e);
      if (e.response?.statusCode == 404) {
        throw AppError.notFound(
          message: 'Alerta no encontrada',
          details: 'La alerta con ID $id no existe',
        );
      }
      throw AppError.network(
        message: 'Error de red al obtener la alerta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching alert', error: e);
      if (e is AppError) rethrow;
      throw AppError.unknown(
        message: 'Error inesperado al obtener la alerta',
        details: e.toString(),
      );
    }
  }
  
  Future<AlertModel> updateAlertStatus(int id, String status) async {
    try {
      AppLogger.info('Updating alert $id status to $status via API');
      
      final response = await _apiService.updateAlertStatus(id, {'estado': status});
      
      if (response['alerta'] != null) {
        final alertData = response['alerta'] as Map<String, dynamic>;
        final alert = AlertModel.fromJson(alertData);
        
        AppLogger.info('Successfully updated alert status: ${alert.id}');
        return alert;
      }
      
      throw AppError.unknown(
        message: 'Respuesta inválida del servidor',
        details: 'No se recibió información de la alerta actualizada',
      );
    } on DioException catch (e) {
      AppLogger.error('API error updating alert status', error: e);
      if (e.response?.statusCode == 404) {
        throw AppError.notFound(
          message: 'Alerta no encontrada',
          details: 'La alerta con ID $id no existe',
        );
      }
      throw AppError.network(
        message: 'Error de red al actualizar el estado de la alerta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error updating alert status', error: e);
      if (e is AppError) rethrow;
      throw AppError.unknown(
        message: 'Error inesperado al actualizar el estado de la alerta',
        details: e.toString(),
      );
    }
  }
  
  Future<List<AlertCategoryModel>> getCategories() async {
    try {
      AppLogger.info('Fetching alert categories from API');
      
      final response = await _apiService.getCategories();
      final categoriesJson = response as List<dynamic>;
      final categories = categoriesJson.map((json) => AlertCategoryModel.fromJson(json as Map<String, dynamic>)).toList();
      
      AppLogger.info('Successfully fetched ${categories.length} alert categories');
      return categories;
    } on DioException catch (e) {
      AppLogger.error('API error fetching alert categories', error: e);
      throw AppError.network(
        message: 'Error de red al obtener categorías de alerta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching alert categories', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener categorías de alerta',
        details: e.toString(),
      );
    }
  }
  
  Future<List<AlertSubcategoryModel>> getSubcategories({int? categoryId}) async {
    try {
      AppLogger.info('Fetching alert subcategories from API${categoryId != null ? ' for category $categoryId' : ''}');
      
      final response = await _apiService.getSubcategories(categoryId: categoryId);
      final subcategoriesJson = response as List<dynamic>;
      final subcategories = subcategoriesJson.map((json) => AlertSubcategoryModel.fromJson(json as Map<String, dynamic>)).toList();
      
      AppLogger.info('Successfully fetched ${subcategories.length} alert subcategories');
      return subcategories;
    } on DioException catch (e) {
      AppLogger.error('API error fetching alert subcategories', error: e);
      throw AppError.network(
        message: 'Error de red al obtener subcategorías de alerta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching alert subcategories', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener subcategorías de alerta',
        details: e.toString(),
      );
    }
  }
  
  Future<AlertStatisticsModel> getStatistics() async {
    try {
      AppLogger.info('Fetching alert statistics from API');
      
      final response = await _apiService.getStatistics();
      final statistics = AlertStatisticsModel.fromJson(response as Map<String, dynamic>);
      
      AppLogger.info('Successfully fetched alert statistics');
      return statistics;
    } on DioException catch (e) {
      AppLogger.error('API error fetching alert statistics', error: e);
      throw AppError.network(
        message: 'Error de red al obtener estadísticas de alertas',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching alert statistics', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener estadísticas de alertas',
        details: e.toString(),
      );
    }
  }
}
