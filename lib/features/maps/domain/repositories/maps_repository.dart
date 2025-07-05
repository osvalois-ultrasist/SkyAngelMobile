import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../entities/risk_polygon.dart';
import '../entities/poi_entity.dart';
import '../entities/risk_level.dart';

abstract class MapsRepository {
  /// Get risk polygons for a specific area
  Future<Either<AppError, List<RiskPolygon>>> getRiskPolygons({
    required LatLng center,
    required double radiusKm,
    RiskFilter? filter,
  });

  /// Get all risk polygons (for full map view)
  Future<Either<AppError, List<RiskPolygon>>> getAllRiskPolygons({
    RiskFilter? filter,
  });

  /// Get points of interest in an area
  Future<Either<AppError, List<POIEntity>>> getPOIsInArea({
    required LatLng center,
    required double radiusKm,
    POIFilter? filter,
  });

  /// Get all POIs for a specific type
  Future<Either<AppError, List<POIEntity>>> getPOIsByType({
    required POIType type,
    POIFilter? filter,
  });

  /// Search POIs by name or description
  Future<Either<AppError, List<POIEntity>>> searchPOIs({
    required String query,
    LatLng? center,
    double? radiusKm,
  });

  /// Get risk analysis for a specific route
  Future<Either<AppError, RouteRiskAnalysis>> getRouteRiskAnalysis({
    required List<LatLng> routePoints,
    RiskFilter? filter,
  });

  /// Get municipality boundaries
  Future<Either<AppError, List<MunicipalityBoundary>>> getMunicipalityBoundaries({
    String? estado,
  });

  /// Get state boundaries
  Future<Either<AppError, List<StateBoundary>>> getStateBoundaries();

  /// Geocode an address to coordinates
  Future<Either<AppError, LatLng>> geocodeAddress(String address);

  /// Reverse geocode coordinates to address
  Future<Either<AppError, String>> reverseGeocode(LatLng coordinates);
}

// Additional entities for the repository
class RouteRiskAnalysis {
  final List<LatLng> routePoints;
  final List<RiskPolygon> riskPolygonsOnRoute;
  final double overallRiskScore;
  final List<RouteRiskPoint> riskPoints;
  final String riskLevel;
  final List<String> recommendations;

  RouteRiskAnalysis({
    required this.routePoints,
    required this.riskPolygonsOnRoute,
    required this.overallRiskScore,
    required this.riskPoints,
    required this.riskLevel,
    required this.recommendations,
  });
}

class RouteRiskPoint {
  final LatLng coordinates;
  final RiskLevelType riskLevel;
  final String description;
  final List<CrimeType> crimeTypes;

  RouteRiskPoint({
    required this.coordinates,
    required this.riskLevel,
    required this.description,
    required this.crimeTypes,
  });
}

class MunicipalityBoundary {
  final String id;
  final String name;
  final String estado;
  final List<List<LatLng>> boundaries;
  final LatLng centroid;
  final Map<String, dynamic>? metadata;

  MunicipalityBoundary({
    required this.id,
    required this.name,
    required this.estado,
    required this.boundaries,
    required this.centroid,
    this.metadata,
  });
}

class StateBoundary {
  final String id;
  final String name;
  final List<List<LatLng>> boundaries;
  final LatLng centroid;
  final Map<String, dynamic>? metadata;

  StateBoundary({
    required this.id,
    required this.name,
    required this.boundaries,
    required this.centroid,
    this.metadata,
  });
}