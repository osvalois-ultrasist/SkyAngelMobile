import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../models/risk_polygon_model.dart';
import '../models/poi_model.dart';
import '../fallback/mock_maps_data.dart';
import '../../domain/entities/poi_entity.dart';

part 'maps_api_datasource.g.dart';

@RestApi(baseUrl: "")
abstract class MapsApiDataSource {
  factory MapsApiDataSource(Dio dio) = _MapsApiDataSource;

  @GET('/maps/get-poligono')
  Future<dynamic> getRiskPolygons();

  @GET('/maps/get-riesgo-ruta')
  Future<dynamic> getRouteRiskAnalysis(
    @Query('points') String routePoints,
  );

  @GET('/maps/municipio')
  Future<dynamic> getMunicipalityBoundaries();

  @GET('/maps/estado')
  Future<dynamic> getStateBoundaries();

  @GET('/puntos-interes/{type}')
  Future<dynamic> getPOIsByType(@Path() String type);

  @GET('/points/filtros')
  Future<dynamic> getPOIFilters();

  @POST('/maps/geocode')
  Future<dynamic> geocodeAddress(@Body() Map<String, String> request);

  @POST('/maps/reverse-geocode')
  Future<dynamic> reverseGeocode(@Body() Map<String, dynamic> coordinates);
}

@LazySingleton()
class MapsApiDataSourceImpl {
  final MapsApiDataSource _apiService;

  MapsApiDataSourceImpl(this._apiService);

  // Helper methods para fallback
  Future<List<POIModel>> _loadMockPOIs(String type) async {
    try {
      AppLogger.info('Loading mock POIs for type $type as fallback');
      
      final mockPOIs = MockMapsData.getMockPOIsBySpecificType(type);
      final poiModels = mockPOIs.map((poi) => POIModel.fromEntity(poi)).cast<POIModel>().toList();
      
      AppLogger.info('Loaded ${poiModels.length} mock POIs of type $type');
      return poiModels;
    } catch (e) {
      AppLogger.error('Error loading mock POIs for type $type', error: e);
      return [];
    }
  }

  Future<List<RiskPolygonModel>> _loadMockRiskPolygons() async {
    try {
      AppLogger.info('Loading mock risk polygons as fallback');
      
      final mockPolygons = MockMapsData.getMockRiskPolygons();
      final polygonModels = mockPolygons.map((polygon) => RiskPolygonModel.fromEntity(polygon)).cast<RiskPolygonModel>().toList();
      
      AppLogger.info('Loaded ${polygonModels.length} mock risk polygons');
      return polygonModels;
    } catch (e) {
      AppLogger.error('Error loading mock risk polygons', error: e);
      return [];
    }
  }

  @factoryMethod
  static MapsApiDataSourceImpl create(Dio dio) {
    final apiService = MapsApiDataSource(dio);
    return MapsApiDataSourceImpl(apiService);
  }

  Future<List<RiskPolygonModel>> getRiskPolygons() async {
    try {
      AppLogger.info('Fetching risk polygons from API');
      
      final response = await _apiService.getRiskPolygons();
      
      if (response is Map<String, dynamic> && response['features'] != null) {
        final features = response['features'] as List;
        final polygons = features.map((feature) {
          return RiskPolygonModel.fromGeoJson(feature as Map<String, dynamic>);
        }).toList();
        
        AppLogger.info('Successfully fetched ${polygons.length} risk polygons');
        return polygons;
      }
      
      return [];
    } on DioException catch (e) {
      AppLogger.warning('API error fetching risk polygons: ${e.message}');
      
      // Fallback: usar datos mock
      return _loadMockRiskPolygons();
    } catch (e) {
      AppLogger.error('Unexpected error fetching risk polygons', error: e);
      
      // Fallback: usar datos mock
      return _loadMockRiskPolygons();
    }
  }

  Future<Map<String, dynamic>> getRouteRiskAnalysis(String routePoints) async {
    try {
      AppLogger.info('Fetching route risk analysis from API');
      
      final response = await _apiService.getRouteRiskAnalysis(routePoints);
      
      if (response is Map<String, dynamic>) {
        AppLogger.info('Successfully fetched route risk analysis');
        return response;
      }
      
      throw AppError.unknown(
        message: 'Respuesta inválida del servidor',
        details: 'No se recibió análisis de riesgo de ruta válido',
      );
    } on DioException catch (e) {
      AppLogger.error('API error fetching route risk analysis', error: e);
      throw AppError.network(
        message: 'Error de red al obtener análisis de riesgo de ruta',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching route risk analysis', error: e);
      if (e is AppError) rethrow;
      throw AppError.unknown(
        message: 'Error inesperado al obtener análisis de riesgo de ruta',
        details: e.toString(),
      );
    }
  }

  Future<List<POIModel>> getPOIsByType(String type) async {
    try {
      AppLogger.info('Fetching POIs of type $type from API');
      
      final response = await _apiService.getPOIsByType(type);
      
      if (response is Map<String, dynamic> && response['features'] != null) {
        final features = response['features'] as List;
        final pois = features.map((feature) {
          return POIModel.fromGeoJson(feature as Map<String, dynamic>);
        }).toList();
        
        AppLogger.info('Successfully fetched ${pois.length} POIs of type $type');
        return pois;
      }
      
      return [];
    } on DioException catch (e) {
      AppLogger.warning('API error fetching POIs for type $type: ${e.message}');
      
      // Fallback: usar datos mock si están disponibles
      return _loadMockPOIs(type);
    } catch (e) {
      AppLogger.error('Unexpected error fetching POIs for type $type', error: e);
      
      // Fallback: usar datos mock
      return _loadMockPOIs(type);
    }
  }

  Future<Map<String, dynamic>> getMunicipalityBoundaries() async {
    try {
      AppLogger.info('Fetching municipality boundaries from API');
      
      final response = await _apiService.getMunicipalityBoundaries();
      
      if (response is Map<String, dynamic>) {
        AppLogger.info('Successfully fetched municipality boundaries');
        return response;
      }
      
      throw AppError.unknown(
        message: 'Respuesta inválida del servidor',
        details: 'No se recibieron límites municipales válidos',
      );
    } on DioException catch (e) {
      AppLogger.error('API error fetching municipality boundaries', error: e);
      throw AppError.network(
        message: 'Error de red al obtener límites municipales',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching municipality boundaries', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener límites municipales',
        details: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> getStateBoundaries() async {
    try {
      AppLogger.info('Fetching state boundaries from API');
      
      final response = await _apiService.getStateBoundaries();
      
      if (response is Map<String, dynamic>) {
        AppLogger.info('Successfully fetched state boundaries');
        return response;
      }
      
      throw AppError.unknown(
        message: 'Respuesta inválida del servidor',
        details: 'No se recibieron límites estatales válidos',
      );
    } on DioException catch (e) {
      AppLogger.error('API error fetching state boundaries', error: e);
      throw AppError.network(
        message: 'Error de red al obtener límites estatales',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching state boundaries', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener límites estatales',
        details: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> geocodeAddress(String address) async {
    try {
      AppLogger.info('Geocoding address: $address');
      
      final response = await _apiService.geocodeAddress({'address': address});
      
      if (response is Map<String, dynamic>) {
        AppLogger.info('Successfully geocoded address');
        return response;
      }
      
      throw AppError.unknown(
        message: 'Respuesta inválida del servidor',
        details: 'No se recibió geocodificación válida',
      );
    } on DioException catch (e) {
      AppLogger.error('API error geocoding address', error: e);
      throw AppError.network(
        message: 'Error de red al geocodificar dirección',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error geocoding address', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al geocodificar dirección',
        details: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> reverseGeocode(double lat, double lng) async {
    try {
      AppLogger.info('Reverse geocoding coordinates: $lat, $lng');
      
      final response = await _apiService.reverseGeocode({
        'lat': lat,
        'lng': lng,
      });
      
      if (response is Map<String, dynamic>) {
        AppLogger.info('Successfully reverse geocoded coordinates');
        return response;
      }
      
      throw AppError.unknown(
        message: 'Respuesta inválida del servidor',
        details: 'No se recibió geocodificación inversa válida',
      );
    } on DioException catch (e) {
      AppLogger.error('API error reverse geocoding', error: e);
      throw AppError.network(
        message: 'Error de red al obtener dirección',
        details: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      AppLogger.error('Unexpected error reverse geocoding', error: e);
      throw AppError.unknown(
        message: 'Error inesperado al obtener dirección',
        details: e.toString(),
      );
    }
  }
}