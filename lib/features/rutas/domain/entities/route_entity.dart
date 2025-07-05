import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'route_entity.freezed.dart';

@freezed
class RouteEntity with _$RouteEntity {
  const factory RouteEntity({
    required String id,
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> waypoints,
    required double distanceKm,
    required int estimatedDurationMinutes,
    required RouteType routeType,
    required RouteSafetyAnalysis safetyAnalysis,
    required RouteStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? name,
    String? description,
    String? userId,
    bool? isFavorite,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) = _RouteEntity;
}

@freezed
class RouteSafetyAnalysis with _$RouteSafetyAnalysis {
  const factory RouteSafetyAnalysis({
    required double overallRiskScore,
    required RouteRiskLevel riskLevel,
    required List<RouteRiskPoint> riskPoints,
    required List<RouteAlert> currentAlerts,
    required Map<String, double> riskBySegment,
    required List<String> recommendations,
  }) = _RouteSafetyAnalysis;
}

@freezed
class RouteRiskPoint with _$RouteRiskPoint {
  const factory RouteRiskPoint({
    required String id,
    required LatLng coordinates,
    required RouteRiskLevel riskLevel,
    required String description,
    required List<String> riskFactors,
    required RouteRiskCategory category,
    required DateTime detectedAt,
    double? severity,
    String? recommendation,
  }) = _RouteRiskPoint;
}

@freezed
class RouteAlert with _$RouteAlert {
  const factory RouteAlert({
    required String id,
    required LatLng coordinates,
    required RouteAlertType type,
    required String title,
    required String description,
    required RouteAlertSeverity severity,
    required DateTime timestamp,
    required bool isActive,
    String? source,
    Duration? estimatedDelay,
    String? alternativeAction,
  }) = _RouteAlert;
}

@freezed
class SafeRouteRecommendation with _$SafeRouteRecommendation {
  const factory SafeRouteRecommendation({
    required String id,
    required RouteEntity route,
    required double safetyScore,
    required String reason,
    required List<String> benefits,
    required List<String> warnings,
    required TimeOfDayRecommendation timeRecommendation,
    DateTime? bestDepartureTime,
    Duration? addedTravelTime,
  }) = _SafeRouteRecommendation;
}

@freezed
class RouteComparison with _$RouteComparison {
  const factory RouteComparison({
    required RouteEntity primaryRoute,
    required List<RouteEntity> alternativeRoutes,
    required RouteComparisonMetrics metrics,
    required SafeRouteRecommendation recommendation,
    required DateTime comparedAt,
  }) = _RouteComparison;
}

@freezed
class RouteComparisonMetrics with _$RouteComparisonMetrics {
  const factory RouteComparisonMetrics({
    required double distanceDifference,
    required int timeDifference,
    required double riskDifference,
    required int riskPointsCount,
    required int alertsCount,
    required String betterChoice,
    required String reasoning,
  }) = _RouteComparisonMetrics;
}

enum RouteRiskLevel {
  veryLow,
  low,
  moderate,
  high,
  veryHigh,
  extreme,
}

enum RouteType {
  fastest,
  shortest,
  safest,
  mostEconomical,
  balanced,
  custom,
}

enum RouteStatus {
  active,
  completed,
  cancelled,
  paused,
  planning,
}

enum RouteRiskCategory {
  crime,
  traffic,
  weather,
  infrastructure,
  timeOfDay,
  crowding,
  other,
}

enum RouteAlertType {
  roadblock,
  accident,
  construction,
  weather,
  crime,
  crowding,
  closure,
  other,
}

enum RouteAlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum TimeOfDayRecommendation {
  morning,
  afternoon,
  evening,
  night,
  avoid,
  anytime,
}

// Extensions for enum helpers
extension RouteRiskLevelExtension on RouteRiskLevel {
  String get label {
    switch (this) {
      case RouteRiskLevel.veryLow:
        return 'Muy Segura';
      case RouteRiskLevel.low:
        return 'Segura';
      case RouteRiskLevel.moderate:
        return 'Moderada';
      case RouteRiskLevel.high:
        return 'Riesgosa';
      case RouteRiskLevel.veryHigh:
        return 'Muy Riesgosa';
      case RouteRiskLevel.extreme:
        return 'Extremadamente Peligrosa';
    }
  }

  String get description {
    switch (this) {
      case RouteRiskLevel.veryLow:
        return 'Ruta muy segura, sin incidencias reportadas';
      case RouteRiskLevel.low:
        return 'Ruta segura con mínimos riesgos';
      case RouteRiskLevel.moderate:
        return 'Ruta con algunos riesgos, precaución recomendada';
      case RouteRiskLevel.high:
        return 'Ruta con varios riesgos, considerar alternativas';
      case RouteRiskLevel.veryHigh:
        return 'Ruta peligrosa, buscar ruta alternativa';
      case RouteRiskLevel.extreme:
        return 'Ruta extremadamente peligrosa, evitar completamente';
    }
  }

  int get priority {
    switch (this) {
      case RouteRiskLevel.veryLow:
        return 0;
      case RouteRiskLevel.low:
        return 1;
      case RouteRiskLevel.moderate:
        return 2;
      case RouteRiskLevel.high:
        return 3;
      case RouteRiskLevel.veryHigh:
        return 4;
      case RouteRiskLevel.extreme:
        return 5;
    }
  }
}

extension RouteTypeExtension on RouteType {
  String get label {
    switch (this) {
      case RouteType.fastest:
        return 'Más Rápida';
      case RouteType.shortest:
        return 'Más Corta';
      case RouteType.safest:
        return 'Más Segura';
      case RouteType.mostEconomical:
        return 'Más Económica';
      case RouteType.balanced:
        return 'Balanceada';
      case RouteType.custom:
        return 'Personalizada';
    }
  }

  String get description {
    switch (this) {
      case RouteType.fastest:
        return 'Prioriza el tiempo de viaje mínimo';
      case RouteType.shortest:
        return 'Prioriza la distancia más corta';
      case RouteType.safest:
        return 'Prioriza la seguridad sobre tiempo y distancia';
      case RouteType.mostEconomical:
        return 'Optimiza el consumo de combustible y costos';
      case RouteType.balanced:
        return 'Balance entre tiempo, distancia y seguridad';
      case RouteType.custom:
        return 'Configuración personalizada por el usuario';
    }
  }
}

extension RouteAlertTypeExtension on RouteAlertType {
  String get label {
    switch (this) {
      case RouteAlertType.roadblock:
        return 'Bloqueo de Carretera';
      case RouteAlertType.accident:
        return 'Accidente';
      case RouteAlertType.construction:
        return 'Construcción';
      case RouteAlertType.weather:
        return 'Clima';
      case RouteAlertType.crime:
        return 'Incidente de Seguridad';
      case RouteAlertType.crowding:
        return 'Multitud';
      case RouteAlertType.closure:
        return 'Cierre de Vía';
      case RouteAlertType.other:
        return 'Otro';
    }
  }
}

extension TimeOfDayRecommendationExtension on TimeOfDayRecommendation {
  String get label {
    switch (this) {
      case TimeOfDayRecommendation.morning:
        return 'Recomendado en la Mañana';
      case TimeOfDayRecommendation.afternoon:
        return 'Recomendado en la Tarde';
      case TimeOfDayRecommendation.evening:
        return 'Recomendado al Atardecer';
      case TimeOfDayRecommendation.night:
        return 'Recomendado en la Noche';
      case TimeOfDayRecommendation.avoid:
        return 'Evitar Esta Ruta';
      case TimeOfDayRecommendation.anytime:
        return 'Segura en Cualquier Momento';
    }
  }
}