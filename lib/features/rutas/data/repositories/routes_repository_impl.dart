import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/routes_repository.dart';

@LazySingleton(as: RoutesRepository)
class RoutesRepositoryImpl implements RoutesRepository {
  @override
  Future<Either<AppError, RouteEntity>> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    required RouteType routeType,
    List<LatLng>? waypoints,
    RoutePreferences? preferences,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return Right(RouteEntity(
      id: 'route_${DateTime.now().millisecondsSinceEpoch}',
      origin: origin,
      destination: destination,
      waypoints: waypoints ?? [origin, destination],
      distanceKm: 15.5,
      estimatedDurationMinutes: 25,
      routeType: routeType,
      safetyAnalysis: RouteSafetyAnalysis(
        overallRiskScore: 0.3,
        riskLevel: RouteRiskLevel.low,
        riskPoints: [
          RouteRiskPoint(
            id: 'risk_1',
            coordinates: origin,
            riskLevel: RouteRiskLevel.low,
            description: 'Zona con actividad delictiva moderada',
            riskFactors: ['Hora nocturna', 'Zona comercial'],
            category: RouteRiskCategory.crime,
            detectedAt: DateTime.now(),
            severity: 0.3,
          ),
        ],
        currentAlerts: [],
        riskBySegment: {'segment_1': 0.2, 'segment_2': 0.4},
        recommendations: [
          'Mantener precaución en zona centro',
          'Usar rutas principales durante la noche',
        ],
      ),
      status: RouteStatus.planning,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      name: _getRouteNameByType(routeType),
      description: 'Ruta calculada por ${routeType.label}',
    ));
  }

  @override
  Future<Either<AppError, RouteComparison>> compareRoutes({
    required LatLng origin,
    required LatLng destination,
    List<RouteType>? routeTypes,
    RoutePreferences? preferences,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final types = routeTypes ?? [RouteType.fastest, RouteType.safest, RouteType.shortest];
    final routes = <RouteEntity>[];
    
    for (int i = 0; i < types.length; i++) {
      final type = types[i];
      routes.add(RouteEntity(
        id: 'route_compare_$i',
        origin: origin,
        destination: destination,
        waypoints: [origin, destination],
        distanceKm: 14.2 + i * 2.0,
        estimatedDurationMinutes: 20 + i * 5,
        routeType: type,
        safetyAnalysis: RouteSafetyAnalysis(
          overallRiskScore: 0.2 + (i * 0.1),
          riskLevel: i == 0 ? RouteRiskLevel.low : (i == 1 ? RouteRiskLevel.veryLow : RouteRiskLevel.moderate),
          riskPoints: [],
          currentAlerts: [],
          riskBySegment: {},
          recommendations: [],
        ),
        status: RouteStatus.planning,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: _getRouteNameByType(type),
        description: 'Ruta ${type.label}',
      ));
    }
    
    final primaryRoute = routes.first;
    return Right(RouteComparison(
      primaryRoute: primaryRoute,
      alternativeRoutes: routes.skip(1).toList(),
      metrics: RouteComparisonMetrics(
        distanceDifference: 2.0,
        timeDifference: 5,
        riskDifference: 0.1,
        riskPointsCount: 0,
        alertsCount: 0,
        betterChoice: primaryRoute.name ?? 'Ruta principal',
        reasoning: 'Mejor balance entre tiempo y seguridad',
      ),
      recommendation: SafeRouteRecommendation(
        id: 'rec_1',
        route: primaryRoute,
        safetyScore: 0.9,
        reason: 'Ruta más segura disponible',
        benefits: ['Menos tráfico', 'Mejor iluminación'],
        warnings: ['Puede ser más lenta'],
        timeRecommendation: TimeOfDayRecommendation.anytime,
      ),
      comparedAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<AppError, List<SafeRouteRecommendation>>> getSafeRouteRecommendations({
    required LatLng origin,
    required LatLng destination,
    DateTime? departureTime,
    RoutePreferences? preferences,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final route = RouteEntity(
      id: 'safe_route_1',
      origin: origin,
      destination: destination,
      waypoints: [origin, destination],
      distanceKm: 18.2,
      estimatedDurationMinutes: 32,
      routeType: RouteType.safest,
      safetyAnalysis: RouteSafetyAnalysis(
        overallRiskScore: 0.1,
        riskLevel: RouteRiskLevel.veryLow,
        riskPoints: [],
        currentAlerts: [],
        riskBySegment: {},
        recommendations: [],
      ),
      status: RouteStatus.planning,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      name: 'Ruta Segura',
      description: 'Ruta optimizada para seguridad',
    );
    
    return Right([
      SafeRouteRecommendation(
        id: 'rec_1',
        route: route,
        safetyScore: 0.95,
        reason: 'Evita zonas de alto riesgo',
        benefits: ['Alta seguridad', 'Presencia policial', 'Buena iluminación'],
        warnings: ['Tiempo de viaje ligeramente mayor'],
        timeRecommendation: TimeOfDayRecommendation.anytime,
        bestDepartureTime: departureTime ?? DateTime.now().add(const Duration(minutes: 15)),
        addedTravelTime: const Duration(minutes: 7),
      ),
    ]);
  }

  @override
  Future<Either<AppError, RouteRiskAnalysis>> analyzeRouteSafety({
    required RouteEntity route,
    DateTime? analysisTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return Right(RouteRiskAnalysis(
      routeId: route.id,
      overallRiskScore: route.safetyAnalysis.overallRiskScore,
      riskLevel: route.safetyAnalysis.riskLevel,
      riskPoints: route.safetyAnalysis.riskPoints,
      currentAlerts: route.safetyAnalysis.currentAlerts,
      riskByCategory: {
        RouteRiskCategory.crime: 0.3,
        RouteRiskCategory.traffic: 0.2,
        RouteRiskCategory.timeOfDay: 0.1,
      },
      recommendations: route.safetyAnalysis.recommendations,
      analyzedAt: analysisTime ?? DateTime.now(),
      summary: 'Ruta con riesgo ${route.safetyAnalysis.riskLevel.label.toLowerCase()}',
    ));
  }

  @override
  Future<Either<AppError, List<RouteAlert>>> getRouteAlerts({
    required String routeId,
    bool activeOnly = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return Right([
      RouteAlert(
        id: 'alert_1',
        coordinates: const LatLng(19.4326, -99.1332),
        type: RouteAlertType.construction,
        title: 'Trabajos de construcción',
        description: 'Trabajos de mantenimiento hasta las 18:00',
        severity: RouteAlertSeverity.medium,
        timestamp: DateTime.now(),
        isActive: true,
        source: 'Sistema de monitoreo',
        estimatedDelay: const Duration(minutes: 10),
        alternativeAction: 'Usar ruta alternativa por Av. Principal',
      ),
    ]);
  }

  @override
  Future<Either<AppError, RouteEntity>> saveRoute({
    required RouteEntity route,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final savedRoute = route.copyWith(
      updatedAt: DateTime.now(),
      userId: userId,
      isFavorite: true,
    );
    
    return Right(savedRoute);
  }

  @override
  Future<Either<AppError, List<RouteEntity>>> getSavedRoutes({
    required String userId,
    RouteStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return Right([
      RouteEntity(
        id: 'saved_1',
        origin: const LatLng(19.4326, -99.1332),
        destination: const LatLng(19.4420, -99.1281),
        waypoints: [
          const LatLng(19.4326, -99.1332),
          const LatLng(19.4420, -99.1281),
        ],
        distanceKm: 12.8,
        estimatedDurationMinutes: 22,
        routeType: RouteType.fastest,
        safetyAnalysis: RouteSafetyAnalysis(
          overallRiskScore: 0.4,
          riskLevel: RouteRiskLevel.moderate,
          riskPoints: [],
          currentAlerts: [],
          riskBySegment: {},
          recommendations: [],
        ),
        status: RouteStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        name: 'Casa - Trabajo',
        description: 'Ruta diaria al trabajo',
        userId: userId,
        isFavorite: true,
      ),
    ]);
  }

  @override
  Future<Either<AppError, bool>> deleteRoute({
    required String routeId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const Right(true);
  }

  @override
  Future<Either<AppError, List<RouteEntity>>> getRouteHistory({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return Right([
      RouteEntity(
        id: 'history_1',
        origin: const LatLng(19.4326, -99.1332),
        destination: const LatLng(19.4420, -99.1281),
        waypoints: [
          const LatLng(19.4326, -99.1332),
          const LatLng(19.4420, -99.1281),
        ],
        distanceKm: 14.5,
        estimatedDurationMinutes: 28,
        routeType: RouteType.safest,
        safetyAnalysis: RouteSafetyAnalysis(
          overallRiskScore: 0.15,
          riskLevel: RouteRiskLevel.veryLow,
          riskPoints: [],
          currentAlerts: [],
          riskBySegment: {},
          recommendations: [],
        ),
        status: RouteStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        name: 'Ruta reciente',
        description: 'Ruta completada recientemente',
        userId: userId,
      ),
    ]);
  }

  @override
  Future<Either<AppError, RouteNavigationSession>> startNavigation({
    required RouteEntity route,
    required String userId,
    bool enableSafetyMonitoring = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return Right(RouteNavigationSession(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      routeId: route.id,
      userId: userId,
      status: RouteNavigationStatus.started,
      startedAt: DateTime.now(),
      currentLocation: route.origin,
      progressPercentage: 0.0,
      remainingTimeMinutes: route.estimatedDurationMinutes,
      remainingDistanceKm: route.distanceKm,
      expectedArrivalTime: DateTime.now().add(Duration(minutes: route.estimatedDurationMinutes)),
      activeAlerts: [],
      deviations: [],
    ));
  }

  @override
  Future<Either<AppError, RouteNavigationSession>> updateNavigationStatus({
    required String sessionId,
    required LatLng currentLocation,
    RouteNavigationStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    return Right(RouteNavigationSession(
      sessionId: sessionId,
      routeId: 'route_active',
      userId: 'user_1',
      status: status ?? RouteNavigationStatus.inProgress,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      currentLocation: currentLocation,
      progressPercentage: 45.0,
      remainingTimeMinutes: 15,
      remainingDistanceKm: 8.5,
      expectedArrivalTime: DateTime.now().add(const Duration(minutes: 15)),
      activeAlerts: [],
      deviations: [],
    ));
  }

  @override
  Future<Either<AppError, DepartureTimeAnalysis>> getOptimalDepartureTime({
    required LatLng origin,
    required LatLng destination,
    DateTime? preferredTime,
    Duration? timeWindow,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final now = DateTime.now();
    return Right(DepartureTimeAnalysis(
      recommendedDepartureTime: now.add(const Duration(minutes: 30)),
      reasoning: 'Menor tráfico y mejor seguridad en este horario',
      safetyScoreByTime: {
        now: 0.7,
        now.add(const Duration(minutes: 30)): 0.9,
        now.add(const Duration(hours: 1)): 0.8,
      },
      unsafeTimeWindows: [
        TimeWindow(
          start: now.add(const Duration(hours: 2)),
          end: now.add(const Duration(hours: 4)),
          reason: 'Horario de alta actividad delictiva',
          riskScore: 0.8,
        ),
      ],
      recommendations: [
        'Salir en los próximos 30 minutos para óptima seguridad',
        'Evitar viajar entre 22:00 y 02:00',
      ],
    ));
  }

  @override
  Future<Either<AppError, bool>> reportRouteIssue({
    required String routeId,
    required LatLng location,
    required RouteIssueType issueType,
    required String description,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const Right(true);
  }

  @override
  Future<Either<AppError, List<SafePlace>>> getNearbyPlacesOnRoute({
    required RouteEntity route,
    SafePlaceType? placeType,
    double radiusKm = 2.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    
    return Right([
      SafePlace(
        id: 'place_1',
        name: 'Estación de Policía Central',
        coordinates: LatLng(
          route.origin.latitude + 0.005,
          route.origin.longitude + 0.005,
        ),
        type: SafePlaceType.policeStation,
        distanceFromRouteKm: 0.8,
        isOpen24Hours: true,
        address: 'Av. Principal 123',
        phoneNumber: '911',
        rating: 4.5,
        services: ['Emergencias', 'Reportes', 'Seguridad'],
      ),
      SafePlace(
        id: 'place_2',
        name: 'Hospital General',
        coordinates: LatLng(
          route.destination.latitude - 0.003,
          route.destination.longitude + 0.002,
        ),
        type: SafePlaceType.hospital,
        distanceFromRouteKm: 1.2,
        isOpen24Hours: true,
        address: 'Calle Salud 456',
        phoneNumber: '911',
        rating: 4.2,
        services: ['Urgencias', 'Consulta externa'],
      ),
    ]);
  }

  String _getRouteNameByType(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return 'Ruta Rápida';
      case RouteType.safest:
        return 'Ruta Segura';
      case RouteType.shortest:
        return 'Ruta Corta';
      case RouteType.mostEconomical:
        return 'Ruta Económica';
      case RouteType.balanced:
        return 'Ruta Balanceada';
      case RouteType.custom:
        return 'Ruta Personalizada';
    }
  }
}