import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/route_entity.dart';

part 'route_model.freezed.dart';
part 'route_model.g.dart';

@freezed
class RouteModel with _$RouteModel {
  const factory RouteModel({
    required String id,
    required String name,
    @JsonKey(name: 'waypoints') required List<List<double>> waypointsRaw,
    @JsonKey(name: 'origin') required List<double> originRaw,
    @JsonKey(name: 'destination') required List<double> destinationRaw,
    @JsonKey(name: 'distance_km') required double distanceKm,
    @JsonKey(name: 'estimated_time_minutes') required int estimatedTimeMinutes,
    @JsonKey(name: 'risk_level') required String riskLevelRaw,
    @JsonKey(name: 'risk_score') required double riskScore,
    @JsonKey(name: 'risk_points') required List<RouteRiskPointModel> riskPoints,
    required List<RouteAlertModel> alerts,
    @JsonKey(name: 'route_type') required String typeRaw,
    @JsonKey(name: 'route_status') required String statusRaw,
    @JsonKey(name: 'created_at') required String createdAtRaw,
    @JsonKey(name: 'updated_at') required String updatedAtRaw,
    String? description,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'is_favorite') bool? isFavorite,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) = _RouteModel;

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);
}

@freezed
class RouteRiskPointModel with _$RouteRiskPointModel {
  const factory RouteRiskPointModel({
    required String id,
    @JsonKey(name: 'coordinates') required List<double> coordinatesRaw,
    @JsonKey(name: 'risk_level') required String riskLevelRaw,
    required String description,
    @JsonKey(name: 'risk_factors') required List<String> riskFactors,
    @JsonKey(name: 'category') required String categoryRaw,
    @JsonKey(name: 'detected_at') required String detectedAtRaw,
    double? severity,
    String? recommendation,
  }) = _RouteRiskPointModel;

  factory RouteRiskPointModel.fromJson(Map<String, dynamic> json) =>
      _$RouteRiskPointModelFromJson(json);
}

@freezed
class RouteAlertModel with _$RouteAlertModel {
  const factory RouteAlertModel({
    required String id,
    @JsonKey(name: 'coordinates') required List<double> coordinatesRaw,
    @JsonKey(name: 'alert_type') required String typeRaw,
    required String title,
    required String description,
    @JsonKey(name: 'severity') required String severityRaw,
    @JsonKey(name: 'timestamp') required String timestampRaw,
    @JsonKey(name: 'is_active') required bool isActive,
    String? source,
    @JsonKey(name: 'estimated_delay_minutes') int? estimatedDelayMinutes,
    @JsonKey(name: 'alternative_action') String? alternativeAction,
  }) = _RouteAlertModel;

  factory RouteAlertModel.fromJson(Map<String, dynamic> json) =>
      _$RouteAlertModelFromJson(json);
}

@freezed
class RouteComparisonModel with _$RouteComparisonModel {
  const factory RouteComparisonModel({
    @JsonKey(name: 'primary_route') required RouteModel primaryRoute,
    @JsonKey(name: 'alternative_routes') required List<RouteModel> alternativeRoutes,
    required RouteComparisonMetricsModel metrics,
    required SafeRouteRecommendationModel recommendation,
    @JsonKey(name: 'compared_at') required String comparedAtRaw,
  }) = _RouteComparisonModel;

  factory RouteComparisonModel.fromJson(Map<String, dynamic> json) =>
      _$RouteComparisonModelFromJson(json);
}

@freezed
class RouteComparisonMetricsModel with _$RouteComparisonMetricsModel {
  const factory RouteComparisonMetricsModel({
    @JsonKey(name: 'distance_difference') required double distanceDifference,
    @JsonKey(name: 'time_difference') required int timeDifference,
    @JsonKey(name: 'risk_difference') required double riskDifference,
    @JsonKey(name: 'risk_points_count') required int riskPointsCount,
    @JsonKey(name: 'alerts_count') required int alertsCount,
    @JsonKey(name: 'better_choice') required String betterChoice,
    required String reasoning,
  }) = _RouteComparisonMetricsModel;

  factory RouteComparisonMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$RouteComparisonMetricsModelFromJson(json);
}

@freezed
class SafeRouteRecommendationModel with _$SafeRouteRecommendationModel {
  const factory SafeRouteRecommendationModel({
    required String id,
    required RouteModel route,
    @JsonKey(name: 'safety_score') required double safetyScore,
    required String reason,
    required List<String> benefits,
    required List<String> warnings,
    @JsonKey(name: 'time_recommendation') required String timeRecommendationRaw,
    @JsonKey(name: 'best_departure_time') String? bestDepartureTimeRaw,
    @JsonKey(name: 'added_travel_time_minutes') int? addedTravelTimeMinutes,
  }) = _SafeRouteRecommendationModel;

  factory SafeRouteRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$SafeRouteRecommendationModelFromJson(json);
}

// Extension methods to convert models to entities
extension RouteModelExtension on RouteModel {
  RouteEntity toEntity() {
    return RouteEntity(
      id: id,
      name: name,
      waypoints: waypointsRaw.map((coords) => LatLng(coords[0], coords[1])).toList(),
      origin: LatLng(originRaw[0], originRaw[1]),
      destination: LatLng(destinationRaw[0], destinationRaw[1]),
      distanceKm: distanceKm,
      estimatedDurationMinutes: estimatedTimeMinutes,
      routeType: _parseRouteType(typeRaw),
      safetyAnalysis: RouteSafetyAnalysis(
        overallRiskScore: riskScore,
        riskLevel: _parseRouteRiskLevel(riskLevelRaw),
        riskPoints: riskPoints.map((rp) => rp.toEntity()).toList(),
        currentAlerts: alerts.map((alert) => alert.toEntity()).toList(),
        riskBySegment: {},
        recommendations: [],
      ),
      status: _parseRouteStatus(statusRaw),
      createdAt: DateTime.parse(createdAtRaw),
      updatedAt: DateTime.parse(updatedAtRaw),
      description: description,
      userId: userId,
      isFavorite: isFavorite,
      tags: tags,
      metadata: metadata,
    );
  }

  RouteRiskLevel _parseRouteRiskLevel(String value) {
    switch (value.toLowerCase()) {
      case 'very_low':
        return RouteRiskLevel.veryLow;
      case 'low':
        return RouteRiskLevel.low;
      case 'moderate':
        return RouteRiskLevel.moderate;
      case 'high':
        return RouteRiskLevel.high;
      case 'very_high':
        return RouteRiskLevel.veryHigh;
      case 'extreme':
        return RouteRiskLevel.extreme;
      default:
        return RouteRiskLevel.moderate;
    }
  }

  RouteType _parseRouteType(String value) {
    switch (value.toLowerCase()) {
      case 'fastest':
        return RouteType.fastest;
      case 'shortest':
        return RouteType.shortest;
      case 'safest':
        return RouteType.safest;
      case 'balanced':
        return RouteType.balanced;
      case 'custom':
        return RouteType.custom;
      default:
        return RouteType.balanced;
    }
  }

  RouteStatus _parseRouteStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return RouteStatus.active;
      case 'completed':
        return RouteStatus.completed;
      case 'cancelled':
        return RouteStatus.cancelled;
      case 'paused':
        return RouteStatus.paused;
      case 'planning':
        return RouteStatus.planning;
      default:
        return RouteStatus.planning;
    }
  }
}

extension RouteRiskPointModelExtension on RouteRiskPointModel {
  RouteRiskPoint toEntity() {
    return RouteRiskPoint(
      id: id,
      coordinates: LatLng(coordinatesRaw[0], coordinatesRaw[1]),
      riskLevel: _parseRouteRiskLevel(riskLevelRaw),
      description: description,
      riskFactors: riskFactors,
      category: _parseRiskCategory(categoryRaw),
      detectedAt: DateTime.parse(detectedAtRaw),
      severity: severity,
      recommendation: recommendation,
    );
  }

  RouteRiskLevel _parseRouteRiskLevel(String value) {
    switch (value.toLowerCase()) {
      case 'very_low':
        return RouteRiskLevel.veryLow;
      case 'low':
        return RouteRiskLevel.low;
      case 'moderate':
        return RouteRiskLevel.moderate;
      case 'high':
        return RouteRiskLevel.high;
      case 'very_high':
        return RouteRiskLevel.veryHigh;
      case 'extreme':
        return RouteRiskLevel.extreme;
      default:
        return RouteRiskLevel.moderate;
    }
  }

  RouteRiskCategory _parseRiskCategory(String value) {
    switch (value.toLowerCase()) {
      case 'crime':
        return RouteRiskCategory.crime;
      case 'traffic':
        return RouteRiskCategory.traffic;
      case 'weather':
        return RouteRiskCategory.weather;
      case 'infrastructure':
        return RouteRiskCategory.infrastructure;
      case 'time_of_day':
        return RouteRiskCategory.timeOfDay;
      case 'crowding':
        return RouteRiskCategory.crowding;
      case 'other':
        return RouteRiskCategory.other;
      default:
        return RouteRiskCategory.other;
    }
  }
}

extension RouteAlertModelExtension on RouteAlertModel {
  RouteAlert toEntity() {
    return RouteAlert(
      id: id,
      coordinates: LatLng(coordinatesRaw[0], coordinatesRaw[1]),
      type: _parseAlertType(typeRaw),
      title: title,
      description: description,
      severity: _parseAlertSeverity(severityRaw),
      timestamp: DateTime.parse(timestampRaw),
      isActive: isActive,
      source: source,
      estimatedDelay: estimatedDelayMinutes != null 
          ? Duration(minutes: estimatedDelayMinutes!) 
          : null,
      alternativeAction: alternativeAction,
    );
  }

  RouteAlertType _parseAlertType(String value) {
    switch (value.toLowerCase()) {
      case 'roadblock':
        return RouteAlertType.roadblock;
      case 'accident':
        return RouteAlertType.accident;
      case 'construction':
        return RouteAlertType.construction;
      case 'weather':
        return RouteAlertType.weather;
      case 'crime':
        return RouteAlertType.crime;
      case 'crowding':
        return RouteAlertType.crowding;
      case 'closure':
        return RouteAlertType.closure;
      case 'other':
        return RouteAlertType.other;
      default:
        return RouteAlertType.other;
    }
  }

  RouteAlertSeverity _parseAlertSeverity(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return RouteAlertSeverity.low;
      case 'medium':
        return RouteAlertSeverity.medium;
      case 'high':
        return RouteAlertSeverity.high;
      case 'critical':
        return RouteAlertSeverity.critical;
      default:
        return RouteAlertSeverity.medium;
    }
  }
}

extension RouteComparisonModelExtension on RouteComparisonModel {
  RouteComparison toEntity() {
    return RouteComparison(
      primaryRoute: primaryRoute.toEntity(),
      alternativeRoutes: alternativeRoutes.map((route) => route.toEntity()).toList(),
      metrics: metrics.toEntity(),
      recommendation: recommendation.toEntity(),
      comparedAt: DateTime.parse(comparedAtRaw),
    );
  }
}

extension RouteComparisonMetricsModelExtension on RouteComparisonMetricsModel {
  RouteComparisonMetrics toEntity() {
    return RouteComparisonMetrics(
      distanceDifference: distanceDifference,
      timeDifference: timeDifference,
      riskDifference: riskDifference,
      riskPointsCount: riskPointsCount,
      alertsCount: alertsCount,
      betterChoice: betterChoice,
      reasoning: reasoning,
    );
  }
}

extension SafeRouteRecommendationModelExtension on SafeRouteRecommendationModel {
  SafeRouteRecommendation toEntity() {
    return SafeRouteRecommendation(
      id: id,
      route: route.toEntity(),
      safetyScore: safetyScore,
      reason: reason,
      benefits: benefits,
      warnings: warnings,
      timeRecommendation: _parseTimeRecommendation(timeRecommendationRaw),
      bestDepartureTime: bestDepartureTimeRaw != null 
          ? DateTime.parse(bestDepartureTimeRaw!) 
          : null,
      addedTravelTime: addedTravelTimeMinutes != null 
          ? Duration(minutes: addedTravelTimeMinutes!) 
          : null,
    );
  }

  TimeOfDayRecommendation _parseTimeRecommendation(String value) {
    switch (value.toLowerCase()) {
      case 'morning':
        return TimeOfDayRecommendation.morning;
      case 'afternoon':
        return TimeOfDayRecommendation.afternoon;
      case 'evening':
        return TimeOfDayRecommendation.evening;
      case 'night':
        return TimeOfDayRecommendation.night;
      case 'avoid':
        return TimeOfDayRecommendation.avoid;
      case 'anytime':
        return TimeOfDayRecommendation.anytime;
      default:
        return TimeOfDayRecommendation.anytime;
    }
  }
}