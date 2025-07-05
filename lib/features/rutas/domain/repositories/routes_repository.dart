import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/app_error.dart';
import '../entities/route_entity.dart';

part 'routes_repository.freezed.dart';

abstract class RoutesRepository {
  /// Calculate route between two points with safety analysis
  Future<Either<AppError, RouteEntity>> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    required RouteType routeType,
    List<LatLng>? waypoints,
    RoutePreferences? preferences,
  });

  /// Get multiple route alternatives with safety comparison
  Future<Either<AppError, RouteComparison>> compareRoutes({
    required LatLng origin,
    required LatLng destination,
    List<RouteType>? routeTypes,
    RoutePreferences? preferences,
  });

  /// Get safe route recommendations based on current conditions
  Future<Either<AppError, List<SafeRouteRecommendation>>> getSafeRouteRecommendations({
    required LatLng origin,
    required LatLng destination,
    DateTime? departureTime,
    RoutePreferences? preferences,
  });

  /// Analyze existing route for safety risks
  Future<Either<AppError, RouteRiskAnalysis>> analyzeRouteSafety({
    required RouteEntity route,
    DateTime? analysisTime,
  });

  /// Get real-time alerts for a specific route
  Future<Either<AppError, List<RouteAlert>>> getRouteAlerts({
    required String routeId,
    bool activeOnly = true,
  });

  /// Save user route as favorite
  Future<Either<AppError, RouteEntity>> saveRoute({
    required RouteEntity route,
    required String userId,
  });

  /// Get user's saved routes
  Future<Either<AppError, List<RouteEntity>>> getSavedRoutes({
    required String userId,
    RouteStatus? status,
  });

  /// Delete saved route
  Future<Either<AppError, bool>> deleteRoute({
    required String routeId,
    required String userId,
  });

  /// Get route history for user
  Future<Either<AppError, List<RouteEntity>>> getRouteHistory({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Start route navigation with safety monitoring
  Future<Either<AppError, RouteNavigationSession>> startNavigation({
    required RouteEntity route,
    required String userId,
    bool enableSafetyMonitoring = true,
  });

  /// Update route navigation status
  Future<Either<AppError, RouteNavigationSession>> updateNavigationStatus({
    required String sessionId,
    required LatLng currentLocation,
    RouteNavigationStatus? status,
  });

  /// Get optimal departure time based on safety analysis
  Future<Either<AppError, DepartureTimeAnalysis>> getOptimalDepartureTime({
    required LatLng origin,
    required LatLng destination,
    DateTime? preferredTime,
    Duration? timeWindow,
  });

  /// Report route issue or safety concern
  Future<Either<AppError, bool>> reportRouteIssue({
    required String routeId,
    required LatLng location,
    required RouteIssueType issueType,
    required String description,
    String? userId,
  });

  /// Get nearby safe places along route
  Future<Either<AppError, List<SafePlace>>> getNearbyPlacesOnRoute({
    required RouteEntity route,
    SafePlaceType? placeType,
    double radiusKm = 2.0,
  });
}

// Additional classes for the repository
@freezed
class RoutePreferences with _$RoutePreferences {
  const factory RoutePreferences({
    @Default(false) bool avoidTolls,
    @Default(false) bool avoidHighways,
    @Default(true) bool prioritizeSafety,
    @Default(1.0) double safetyWeight,
    @Default(1.0) double timeWeight,
    @Default(1.0) double distanceWeight,
    List<RouteRiskCategory>? avoidRiskCategories,
    List<RouteAlertType>? avoidAlertTypes,
    TimeOfDay? preferredDepartureTime,
    TimeOfDay? preferredArrivalTime,
  }) = _RoutePreferences;
}

@freezed
class RouteRiskAnalysis with _$RouteRiskAnalysis {
  const factory RouteRiskAnalysis({
    required String routeId,
    required double overallRiskScore,
    required RouteRiskLevel riskLevel,
    required List<RouteRiskPoint> riskPoints,
    required List<RouteAlert> currentAlerts,
    required Map<RouteRiskCategory, double> riskByCategory,
    required List<String> recommendations,
    required DateTime analyzedAt,
    String? summary,
  }) = _RouteRiskAnalysis;
}

@freezed
class RouteNavigationSession with _$RouteNavigationSession {
  const factory RouteNavigationSession({
    required String sessionId,
    required String routeId,
    required String userId,
    required RouteNavigationStatus status,
    required DateTime startedAt,
    required LatLng currentLocation,
    required double progressPercentage,
    required int remainingTimeMinutes,
    required double remainingDistanceKm,
    DateTime? expectedArrivalTime,
    DateTime? completedAt,
    List<RouteAlert>? activeAlerts,
    List<String>? deviations,
  }) = _RouteNavigationSession;
}

@freezed
class DepartureTimeAnalysis with _$DepartureTimeAnalysis {
  const factory DepartureTimeAnalysis({
    required DateTime recommendedDepartureTime,
    required String reasoning,
    required Map<DateTime, double> safetyScoreByTime,
    required List<TimeWindow> unsafeTimeWindows,
    required List<String> recommendations,
  }) = _DepartureTimeAnalysis;
}

@freezed
class TimeWindow with _$TimeWindow {
  const factory TimeWindow({
    required DateTime start,
    required DateTime end,
    required String reason,
    required double riskScore,
  }) = _TimeWindow;
}

@freezed
class SafePlace with _$SafePlace {
  const factory SafePlace({
    required String id,
    required String name,
    required LatLng coordinates,
    required SafePlaceType type,
    required double distanceFromRouteKm,
    required bool isOpen24Hours,
    String? address,
    String? phoneNumber,
    double? rating,
    List<String>? services,
  }) = _SafePlace;
}

enum RouteNavigationStatus {
  planning,
  started,
  inProgress,
  paused,
  completed,
  cancelled,
  emergency,
}

enum RouteIssueType {
  roadClosure,
  safetyHazard,
  poorConditions,
  incorrectRoute,
  missingFacility,
  other,
}

enum SafePlaceType {
  policeStation,
  hospital,
  gasStation,
  restaurant,
  hotel,
  mall,
  bank,
  publicBuilding,
  other,
}