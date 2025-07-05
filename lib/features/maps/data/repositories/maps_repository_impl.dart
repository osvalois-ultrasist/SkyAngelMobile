import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/risk_level.dart';
import '../../domain/repositories/maps_repository.dart';
import '../datasources/maps_api_datasource.dart';
import '../models/risk_polygon_model.dart';
import '../models/poi_model.dart';

@LazySingleton(as: MapsRepository)
class MapsRepositoryImpl implements MapsRepository {
  final MapsApiDataSourceImpl _apiDataSource;
  final Distance _distance = const Distance();

  MapsRepositoryImpl(this._apiDataSource);

  @override
  Future<Either<AppError, List<RiskPolygon>>> getRiskPolygons({
    required LatLng center,
    required double radiusKm,
    RiskFilter? filter,
  }) async {
    try {
      final polygonModels = await _apiDataSource.getRiskPolygons();
      final polygonEntities = polygonModels.map((model) => model.toEntity()).toList();
      
      // Filter by area
      final filteredPolygons = polygonEntities.where((polygon) {
        if (polygon.coordinates.isEmpty) return false;
        
        // Check if polygon center is within radius
        final polygonCenter = _calculatePolygonCenter(polygon.coordinates);
        final distanceKm = _distance.as(LengthUnit.Kilometer, center, polygonCenter);
        
        return distanceKm <= radiusKm;
      }).toList();
      
      // Apply additional filters
      final finalPolygons = _applyRiskFilter(filteredPolygons, filter);
      
      return Right(finalPolygons);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener polígonos de riesgo',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<RiskPolygon>>> getAllRiskPolygons({
    RiskFilter? filter,
  }) async {
    try {
      final polygonModels = await _apiDataSource.getRiskPolygons();
      final polygonEntities = polygonModels.map((model) => model.toEntity()).toList();
      
      // Apply filters
      final filteredPolygons = _applyRiskFilter(polygonEntities, filter);
      
      return Right(filteredPolygons);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener todos los polígonos de riesgo',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<POIEntity>>> getPOIsInArea({
    required LatLng center,
    required double radiusKm,
    POIFilter? filter,
  }) async {
    try {
      // Get POIs for all types if no specific types in filter
      final types = filter?.types.isNotEmpty == true
          ? filter!.types
          : POIType.values;

      List<POIEntity> allPOIs = [];
      
      for (final type in types) {
        try {
          final typeString = _poiTypeToString(type);
          final poiModels = await _apiDataSource.getPOIsByType(typeString);
          final poiEntities = poiModels.map((model) => model.toEntity()).toList();
          allPOIs.addAll(poiEntities);
        } catch (e) {
          AppLogger.warning('Failed to fetch POIs for type $type: $e');
          // Continue with other types
        }
      }

      // Filter by area
      final filteredPOIs = allPOIs.where((poi) {
        final distanceKm = _distance.as(LengthUnit.Kilometer, center, poi.coordinates);
        return distanceKm <= radiusKm;
      }).toList();

      // Apply additional filters
      final finalPOIs = _applyPOIFilter(filteredPOIs, filter);

      return Right(finalPOIs);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener puntos de interés',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<POIEntity>>> getPOIsByType({
    required POIType type,
    POIFilter? filter,
  }) async {
    try {
      final typeString = _poiTypeToString(type);
      final poiModels = await _apiDataSource.getPOIsByType(typeString);
      final poiEntities = poiModels.map((model) => model.toEntity()).toList();
      
      // Apply filters
      final filteredPOIs = _applyPOIFilter(poiEntities, filter);
      
      return Right(filteredPOIs);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener puntos de interés por tipo',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<POIEntity>>> searchPOIs({
    required String query,
    LatLng? center,
    double? radiusKm,
  }) async {
    try {
      // Get all POIs and filter by search query
      List<POIEntity> allPOIs = [];
      
      for (final type in POIType.values) {
        try {
          final typeString = _poiTypeToString(type);
          final poiModels = await _apiDataSource.getPOIsByType(typeString);
          final poiEntities = poiModels.map((model) => model.toEntity()).toList();
          allPOIs.addAll(poiEntities);
        } catch (e) {
          // Continue with other types
        }
      }

      // Filter by search query
      final searchResults = allPOIs.where((poi) {
        final searchLower = query.toLowerCase();
        return poi.name.toLowerCase().contains(searchLower) ||
               poi.description.toLowerCase().contains(searchLower) ||
               (poi.address?.toLowerCase().contains(searchLower) ?? false) ||
               (poi.tags?.any((tag) => tag.toLowerCase().contains(searchLower)) ?? false);
      }).toList();

      // Filter by area if specified
      if (center != null && radiusKm != null) {
        final areaFiltered = searchResults.where((poi) {
          final distanceKm = _distance.as(LengthUnit.Kilometer, center, poi.coordinates);
          return distanceKm <= radiusKm;
        }).toList();
        return Right(areaFiltered);
      }

      return Right(searchResults);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al buscar puntos de interés',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, RouteRiskAnalysis>> getRouteRiskAnalysis({
    required List<LatLng> routePoints,
    RiskFilter? filter,
  }) async {
    try {
      // Convert route points to string format for API
      final routeString = routePoints
          .map((point) => '${point.latitude},${point.longitude}')
          .join(';');

      final response = await _apiDataSource.getRouteRiskAnalysis(routeString);
      
      // Parse the response and create RouteRiskAnalysis
      final analysis = _parseRouteRiskAnalysis(response, routePoints);
      
      return Right(analysis);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al analizar riesgo de ruta',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<MunicipalityBoundary>>> getMunicipalityBoundaries({
    String? estado,
  }) async {
    try {
      final response = await _apiDataSource.getMunicipalityBoundaries();
      final boundaries = _parseMunicipalityBoundaries(response, estado);
      
      return Right(boundaries);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener límites municipales',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<StateBoundary>>> getStateBoundaries() async {
    try {
      final response = await _apiDataSource.getStateBoundaries();
      final boundaries = _parseStateBoundaries(response);
      
      return Right(boundaries);
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener límites estatales',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, LatLng>> geocodeAddress(String address) async {
    try {
      final response = await _apiDataSource.geocodeAddress(address);
      
      if (response['lat'] != null && response['lng'] != null) {
        final coordinates = LatLng(
          response['lat'].toDouble(),
          response['lng'].toDouble(),
        );
        return Right(coordinates);
      }
      
      return Left(
        AppError.notFound(
          message: 'No se encontró la dirección',
          details: 'La dirección "$address" no pudo ser geocodificada',
        ),
      );
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al geocodificar dirección',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> reverseGeocode(LatLng coordinates) async {
    try {
      final response = await _apiDataSource.reverseGeocode(
        coordinates.latitude,
        coordinates.longitude,
      );
      
      if (response['address'] != null) {
        return Right(response['address'].toString());
      }
      
      return Left(
        AppError.notFound(
          message: 'No se encontró la dirección',
          details: 'No se pudo obtener la dirección para las coordenadas especificadas',
        ),
      );
    } on AppError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AppError.unknown(
          message: 'Error inesperado al obtener dirección',
          details: e.toString(),
        ),
      );
    }
  }

  // Helper methods
  LatLng _calculatePolygonCenter(List<LatLng> coordinates) {
    if (coordinates.isEmpty) return const LatLng(0, 0);
    
    double totalLat = 0;
    double totalLng = 0;
    
    for (final coord in coordinates) {
      totalLat += coord.latitude;
      totalLng += coord.longitude;
    }
    
    return LatLng(
      totalLat / coordinates.length,
      totalLng / coordinates.length,
    );
  }

  List<RiskPolygon> _applyRiskFilter(List<RiskPolygon> polygons, RiskFilter? filter) {
    if (filter == null) return polygons;
    
    return polygons.where((polygon) {
      // Filter by data sources
      if (filter.dataSources.isNotEmpty &&
          !filter.dataSources.contains(polygon.dataSource)) {
        return false;
      }
      
      // Filter by crime types
      if (filter.crimeTypes.isNotEmpty &&
          !polygon.crimeTypes.any((type) => filter.crimeTypes.contains(type))) {
        return false;
      }
      
      // Filter by risk levels
      if (filter.riskLevels.isNotEmpty &&
          !filter.riskLevels.contains(polygon.riskLevel)) {
        return false;
      }
      
      // Filter by date range
      if (filter.startDate != null &&
          polygon.lastUpdate.isBefore(filter.startDate!)) {
        return false;
      }
      
      if (filter.endDate != null &&
          polygon.lastUpdate.isAfter(filter.endDate!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  List<POIEntity> _applyPOIFilter(List<POIEntity> pois, POIFilter? filter) {
    if (filter == null) return pois;
    
    return pois.where((poi) {
      // Filter by types
      if (filter.types.isNotEmpty &&
          !filter.types.contains(poi.type)) {
        return false;
      }
      
      // Filter by statuses
      if (filter.statuses.isNotEmpty &&
          !filter.statuses.contains(poi.status)) {
        return false;
      }
      
      // Filter by search query
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final searchLower = filter.searchQuery!.toLowerCase();
        if (!poi.name.toLowerCase().contains(searchLower) &&
            !poi.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }
      
      // Filter by rating
      if (filter.minRating != null &&
          (poi.rating ?? 0) < filter.minRating!) {
        return false;
      }
      
      return true;
    }).toList();
  }

  String _poiTypeToString(POIType type) {
    switch (type) {
      case POIType.accidenteTransito:
        return 'accidente_transito';
      case POIType.incidenciaFerroviaria:
        return 'incidencia_ferroviaria';
      case POIType.agenciaMinisterioPublico:
        return 'agencia_ministerio_publico';
      case POIType.guardiaNacional:
        return 'guardia_nacional';
      case POIType.caseta:
        return 'caseta';
      case POIType.corralon:
        return 'corralon';
      case POIType.paradero:
        return 'paradero';
      case POIType.pension:
        return 'pension';
      case POIType.coberturaCelular:
        return 'cobertura_celular';
      case POIType.hospital:
        return 'hospital';
      case POIType.gasolinera:
        return 'gasolinera';
      case POIType.banco:
        return 'banco';
      case POIType.policia:
        return 'policia';
      case POIType.otro:
        return 'otro';
    }
  }

  RouteRiskAnalysis _parseRouteRiskAnalysis(Map<String, dynamic> response, List<LatLng> routePoints) {
    // This is a simplified implementation - in a real app, you'd parse the actual API response
    final riskScore = (response['risk_score'] ?? 0.5).toDouble();
    final riskLevel = RiskLevelExtension.fromValue(riskScore);
    
    return RouteRiskAnalysis(
      routePoints: routePoints,
      riskPolygonsOnRoute: [],
      overallRiskScore: riskScore,
      riskPoints: [],
      riskLevel: riskLevel.label,
      recommendations: _generateRecommendations(riskLevel),
    );
  }

  List<String> _generateRecommendations(RiskLevelType riskLevel) {
    switch (riskLevel) {
      case RiskLevelType.veryLow:
      case RiskLevelType.low:
        return ['Ruta segura', 'Mantén precauciones normales'];
      case RiskLevelType.moderate:
        return ['Mantén alerta', 'Evita detenerte en zonas oscuras'];
      case RiskLevelType.high:
      case RiskLevelType.veryHigh:
        return ['Alta precaución recomendada', 'Considera ruta alternativa', 'Viaja en horarios seguros'];
      case RiskLevelType.extreme:
        return ['Ruta muy peligrosa', 'Se recomienda evitar completamente', 'Busca ruta alternativa'];
    }
  }

  List<MunicipalityBoundary> _parseMunicipalityBoundaries(Map<String, dynamic> response, String? estado) {
    // Simplified implementation - parse GeoJSON features
    if (response['features'] == null) return [];
    
    final features = response['features'] as List;
    return features.map((feature) {
      final properties = feature['properties'] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      
      // Parse coordinates (simplified)
      final coordinates = geometry['coordinates'] as List;
      final boundaries = <List<LatLng>>[];
      
      // This would need proper GeoJSON parsing in a real implementation
      
      return MunicipalityBoundary(
        id: properties['id']?.toString() ?? '',
        name: properties['name']?.toString() ?? '',
        estado: properties['estado']?.toString() ?? '',
        boundaries: boundaries,
        centroid: const LatLng(0, 0), // Calculate actual centroid
      );
    }).where((boundary) => estado == null || boundary.estado == estado).toList();
  }

  List<StateBoundary> _parseStateBoundaries(Map<String, dynamic> response) {
    // Simplified implementation - similar to municipality parsing
    if (response['features'] == null) return [];
    
    final features = response['features'] as List;
    return features.map((feature) {
      final properties = feature['properties'] as Map<String, dynamic>;
      
      return StateBoundary(
        id: properties['id']?.toString() ?? '',
        name: properties['name']?.toString() ?? '',
        boundaries: <List<LatLng>>[],
        centroid: const LatLng(0, 0),
      );
    }).toList();
  }
}