import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../models/route_model.dart';

part 'routes_api_datasource.g.dart';

@RestApi(baseUrl: "")
abstract class RoutesApiDataSource {
  factory RoutesApiDataSource(Dio dio) = _RoutesApiDataSource;

  @POST('/routes/calculate')
  Future<RouteModel> calculateRoute(@Body() Map<String, dynamic> request);

  @POST('/routes/compare')
  Future<RouteComparisonModel> compareRoutes(@Body() Map<String, dynamic> request);

  @GET('/routes/recommendations')
  Future<List<SafeRouteRecommendationModel>> getRecommendations(
    @Query('origin') String origin,
    @Query('destination') String destination,
    @Query('departure_time') String? departureTime,
  );

  @GET('/routes/user/{userId}')
  Future<List<RouteModel>> getUserRoutes(@Path() String userId);

  @POST('/routes/save')
  Future<RouteModel> saveRoute(@Body() Map<String, dynamic> request);

  @DELETE('/routes/{routeId}')
  Future<void> deleteRoute(@Path() String routeId);
}

@LazySingleton()
class RoutesApiDataSourceImpl {
  final RoutesApiDataSource _apiService;

  RoutesApiDataSourceImpl(this._apiService);

  @factoryMethod
  static RoutesApiDataSourceImpl create(Dio dio) {
    final apiService = RoutesApiDataSource(dio);
    return RoutesApiDataSourceImpl(apiService);
  }

  Future<RouteModel> calculateRoute(Map<String, dynamic> request) async {
    try {
      AppLogger.info('Calculating route from API');
      final route = await _apiService.calculateRoute(request);
      AppLogger.info('Successfully calculated route');
      return route;
    } on DioException catch (e) {
      AppLogger.error('API error calculating route', error: e);
      throw AppError.network(
        message: 'Error de red al calcular ruta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error calculating route', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al calcular ruta',
        details: e.toString(),
      );
    }
  }

  Future<RouteComparisonModel> compareRoutes(Map<String, dynamic> request) async {
    try {
      AppLogger.info('Comparing routes from API');
      final comparison = await _apiService.compareRoutes(request);
      AppLogger.info('Successfully compared routes');
      return comparison;
    } on DioException catch (e) {
      AppLogger.error('API error comparing routes', error: e);
      throw AppError.network(
        message: 'Error de red al comparar rutas',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error comparing routes', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al comparar rutas',
        details: e.toString(),
      );
    }
  }

  Future<List<SafeRouteRecommendationModel>> getRecommendations({
    required String origin,
    required String destination,
    String? departureTime,
  }) async {
    try {
      AppLogger.info('Getting route recommendations from API');
      final recommendations = await _apiService.getRecommendations(
        origin,
        destination,
        departureTime,
      );
      AppLogger.info('Successfully got ${recommendations.length} recommendations');
      return recommendations;
    } on DioException catch (e) {
      AppLogger.error('API error getting recommendations', error: e);
      throw AppError.network(
        message: 'Error de red al obtener recomendaciones',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error getting recommendations', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener recomendaciones',
        details: e.toString(),
      );
    }
  }

  Future<List<RouteModel>> getUserRoutes(String userId) async {
    try {
      AppLogger.info('Getting user routes from API');
      final routes = await _apiService.getUserRoutes(userId);
      AppLogger.info('Successfully got ${routes.length} user routes');
      return routes;
    } on DioException catch (e) {
      AppLogger.error('API error getting user routes', error: e);
      throw AppError.network(
        message: 'Error de red al obtener rutas del usuario',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error getting user routes', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener rutas del usuario',
        details: e.toString(),
      );
    }
  }

  Future<RouteModel> saveRoute(Map<String, dynamic> request) async {
    try {
      AppLogger.info('Saving route to API');
      final route = await _apiService.saveRoute(request);
      AppLogger.info('Successfully saved route');
      return route;
    } on DioException catch (e) {
      AppLogger.error('API error saving route', error: e);
      throw AppError.network(
        message: 'Error de red al guardar ruta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error saving route', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al guardar ruta',
        details: e.toString(),
      );
    }
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      AppLogger.info('Deleting route from API');
      await _apiService.deleteRoute(routeId);
      AppLogger.info('Successfully deleted route');
    } on DioException catch (e) {
      AppLogger.error('API error deleting route', error: e);
      throw AppError.network(
        message: 'Error de red al eliminar ruta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error deleting route', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al eliminar ruta',
        details: e.toString(),
      );
    }
  }
}