import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/routes_repository.dart';
import '../../domain/usecases/calculate_route_usecase.dart';
import '../../domain/usecases/save_route_usecase.dart';
import '../../domain/usecases/get_saved_routes_usecase.dart';
import '../../domain/usecases/delete_route_usecase.dart';

part 'routes_provider.g.dart';

@riverpod
class RouteCalculationNotifier extends _$RouteCalculationNotifier {
  @override
  AsyncValue<List<RouteEntity>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    required RouteType routeType,
    List<LatLng>? waypoints,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final useCase = getIt<CalculateRouteUseCase>();
      final params = CalculateRouteParams(
        origin: origin,
        destination: destination,
        routeType: routeType,
        waypoints: waypoints,
      );
      
      final result = await useCase(params);
      
      result.fold(
        (error) => state = AsyncValue.error(error, StackTrace.current),
        (route) => state = AsyncValue.data([route]),
      );
    } catch (e) {
      AppLogger.error('Error calculating route', error: e);
      state = AsyncValue.error(
        e is AppError ? e : AppError.unknown(message: e.toString()),
        StackTrace.current,
      );
    }
  }

  Future<void> compareRoutes({
    required LatLng origin,
    required LatLng destination,
    List<RouteType>? routeTypes,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final useCase = getIt<CalculateRouteUseCase>();
      final routesToCompare = routeTypes ?? RouteType.values;
      final routes = <RouteEntity>[];
      
      for (final routeType in routesToCompare) {
        final params = CalculateRouteParams(
          origin: origin,
          destination: destination,
          routeType: routeType,
        );
        
        final result = await useCase(params);
        result.fold(
          (error) => AppLogger.warning('Failed to calculate route for $routeType'),
          (route) => routes.add(route),
        );
      }
      
      state = AsyncValue.data(routes);
    } catch (e) {
      AppLogger.error('Error comparing routes', error: e);
      state = AsyncValue.error(
        e is AppError ? e : AppError.unknown(message: e.toString()),
        StackTrace.current,
      );
    }
  }

  void clearRoutes() {
    state = const AsyncValue.data([]);
  }
}

@riverpod
class SavedRoutesNotifier extends _$SavedRoutesNotifier {
  @override
  AsyncValue<List<RouteEntity>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadSavedRoutes(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      final useCase = getIt<GetSavedRoutesUseCase>();
      final params = GetSavedRoutesParams(userId: userId);
      
      final result = await useCase(params);
      
      result.fold(
        (error) => state = AsyncValue.error(error, StackTrace.current),
        (routes) => state = AsyncValue.data(routes),
      );
    } catch (e) {
      AppLogger.error('Error loading saved routes', error: e);
      state = AsyncValue.error(
        e is AppError ? e : AppError.unknown(message: e.toString()),
        StackTrace.current,
      );
    }
  }

  Future<void> saveRoute(RouteEntity route, String userId) async {
    try {
      final useCase = getIt<SaveRouteUseCase>();
      final params = SaveRouteParams(
        route: route,
        userId: userId,
      );
      
      final result = await useCase(params);
      
      result.fold(
        (error) {
          AppLogger.error('Error saving route', error: error);
          // Could show error to user here
        },
        (savedRoute) {
          // Update the state with the new saved route
          final currentRoutes = state.value ?? [];
          state = AsyncValue.data([...currentRoutes, savedRoute]);
        },
      );
    } catch (e) {
      AppLogger.error('Error saving route', error: e);
    }
  }

  Future<void> deleteRoute(String routeId, String userId) async {
    try {
      final useCase = getIt<DeleteRouteUseCase>();
      final params = DeleteRouteParams(
        routeId: routeId,
        userId: userId,
      );
      
      final result = await useCase(params);
      
      result.fold(
        (error) {
          AppLogger.error('Error deleting route', error: error);
        },
        (success) {
          if (success) {
            // Remove the route from the state
            final currentRoutes = state.value ?? [];
            final updatedRoutes = currentRoutes.where((route) => route.id != routeId).toList();
            state = AsyncValue.data(updatedRoutes);
          }
        },
      );
    } catch (e) {
      AppLogger.error('Error deleting route', error: e);
    }
  }
}

@riverpod
class RouteNavigationNotifier extends _$RouteNavigationNotifier {
  @override
  AsyncValue<RouteNavigationSession?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> startNavigation({
    required RouteEntity route,
    required String userId,
    bool enableSafetyMonitoring = true,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // TODO: Implement actual navigation start with repository
      await Future.delayed(const Duration(seconds: 1));
      
      final session = RouteNavigationSession(
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        routeId: route.id,
        userId: userId,
        status: RouteNavigationStatus.started,
        startedAt: DateTime.now(),
        currentLocation: route.waypoints.first,
        progressPercentage: 0.0,
        remainingTimeMinutes: route.estimatedDurationMinutes,
        remainingDistanceKm: route.distanceKm,
        expectedArrivalTime: DateTime.now().add(
          Duration(minutes: route.estimatedDurationMinutes),
        ),
        activeAlerts: route.safetyAnalysis.currentAlerts,
      );
      
      state = AsyncValue.data(session);
    } catch (e) {
      AppLogger.error('Error starting navigation', error: e);
      state = AsyncValue.error(
        e is AppError ? e : AppError.unknown(message: e.toString()),
        StackTrace.current,
      );
    }
  }

  Future<void> updateNavigationStatus({
    required String sessionId,
    required LatLng currentLocation,
    RouteNavigationStatus? status,
  }) async {
    final currentSession = state.value;
    if (currentSession == null) return;
    
    try {
      // TODO: Implement actual navigation update with repository
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedSession = currentSession.copyWith(
        currentLocation: currentLocation,
        status: status ?? currentSession.status,
      );
      
      state = AsyncValue.data(updatedSession);
    } catch (e) {
      AppLogger.error('Error updating navigation status', error: e);
    }
  }

  void stopNavigation() {
    state = const AsyncValue.data(null);
  }
}

// Provider for mock route data during development
@riverpod
Future<List<RouteEntity>> mockRoutes(MockRoutesRef ref) async {
  await Future.delayed(const Duration(seconds: 1));
  
  final mockRoute1 = RouteEntity(
    id: 'route_1',
    name: 'Ruta Principal',
    origin: const LatLng(19.4326, -99.1332),
    destination: const LatLng(19.4500, -99.1300),
    waypoints: [
      const LatLng(19.4326, -99.1332),
      const LatLng(19.4400, -99.1320),
      const LatLng(19.4500, -99.1300),
    ],
    distanceKm: 5.2,
    estimatedDurationMinutes: 15,
    routeType: RouteType.safest,
    safetyAnalysis: const RouteSafetyAnalysis(
      overallRiskScore: 0.3,
      riskLevel: RouteRiskLevel.low,
      riskPoints: [],
      currentAlerts: [],
      riskBySegment: {},
      recommendations: ['Mantener velocidad moderada'],
    ),
    status: RouteStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final mockRoute2 = RouteEntity(
    id: 'route_2',
    name: 'Ruta Rápida',
    origin: const LatLng(19.4326, -99.1332),
    destination: const LatLng(19.4500, -99.1300),
    waypoints: [
      const LatLng(19.4326, -99.1332),
      const LatLng(19.4450, -99.1250),
      const LatLng(19.4500, -99.1300),
    ],
    distanceKm: 4.8,
    estimatedDurationMinutes: 12,
    routeType: RouteType.fastest,
    safetyAnalysis: const RouteSafetyAnalysis(
      overallRiskScore: 0.6,
      riskLevel: RouteRiskLevel.moderate,
      riskPoints: [],
      currentAlerts: [],
      riskBySegment: {},
      recommendations: ['Evitar horarios nocturnos'],
    ),
    status: RouteStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  return [mockRoute1, mockRoute2];
}