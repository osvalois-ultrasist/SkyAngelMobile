import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/routes_repository.dart';

part 'routes_state.freezed.dart';

@freezed
class RoutesState with _$RoutesState {
  const factory RoutesState.initial() = _Initial;
  
  const factory RoutesState.loading() = _Loading;
  
  const factory RoutesState.loaded({
    required List<RouteEntity> routes,
    required List<RouteEntity> savedRoutes,
    required List<RouteEntity> routeHistory,
    LatLng? currentLocation,
    RouteFilter? activeRouteFilter,
    RouteEntity? selectedRoute,
  }) = _Loaded;
  
  const factory RoutesState.error({
    required AppError error,
    required String message,
  }) = _Error;
}

@freezed
class RouteCalculationState with _$RouteCalculationState {
  const factory RouteCalculationState.initial() = _RouteInitial;
  
  const factory RouteCalculationState.loading() = _RouteLoading;
  
  const factory RouteCalculationState.loaded({
    required List<RouteEntity> calculatedRoutes,
    required LatLng origin,
    required LatLng destination,
    required RouteType routeType,
  }) = _RouteLoaded;
  
  const factory RouteCalculationState.error({
    required AppError error,
    required String message,
  }) = _RouteError;
}

@freezed
class RouteComparisonState with _$RouteComparisonState {
  const factory RouteComparisonState.initial() = _ComparisonInitial;
  
  const factory RouteComparisonState.loading() = _ComparisonLoading;
  
  const factory RouteComparisonState.loaded({
    required RouteComparison comparison,
  }) = _ComparisonLoaded;
  
  const factory RouteComparisonState.error({
    required AppError error,
    required String message,
  }) = _ComparisonError;
}

@freezed
class RouteNavigationState with _$RouteNavigationState {
  const factory RouteNavigationState.initial() = _NavigationInitial;
  
  const factory RouteNavigationState.navigating({
    required RouteEntity activeRoute,
    required LatLng currentLocation,
    required List<NavigationInstruction> instructions,
    required double progressPercent,
    required Duration estimatedTimeRemaining,
    required double distanceRemainingKm,
  }) = _Navigating;
  
  const factory RouteNavigationState.paused({
    required RouteEntity activeRoute,
    required LatLng currentLocation,
    required String pauseReason,
  }) = _NavigationPaused;
  
  const factory RouteNavigationState.completed({
    required RouteEntity completedRoute,
    required Duration totalTime,
    required double totalDistance,
  }) = _NavigationCompleted;
  
  const factory RouteNavigationState.error({
    required AppError error,
    required String message,
  }) = _NavigationError;
}

extension RoutesStateExtension on RoutesState {
  bool get isLoading => when(
    initial: () => false,
    loading: () => true,
    loaded: (_, __, ___, ____, _____, ______) => false,
    error: (_, __) => false,
  );
  
  bool get hasError => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __, ___, ____, _____, ______) => false,
    error: (_, __) => true,
  );
  
  bool get hasData => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __, ___, ____, _____, ______) => true,
    error: (_, __) => false,
  );
  
  List<RouteEntity> get routes => when(
    initial: () => [],
    loading: () => [],
    loaded: (routes, _, __, ___, ____, _____) => routes,
    error: (_, __) => [],
  );
  
  List<RouteEntity> get savedRoutes => when(
    initial: () => [],
    loading: () => [],
    loaded: (_, savedRoutes, __, ___, ____, _____) => savedRoutes,
    error: (_, __) => [],
  );
  
  List<RouteEntity> get routeHistory => when(
    initial: () => [],
    loading: () => [],
    loaded: (_, __, routeHistory, ___, ____, _____) => routeHistory,
    error: (_, __) => [],
  );
  
  LatLng? get currentLocation => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, ___, currentLocation, ____, _____) => currentLocation,
    error: (_, __) => null,
  );
  
  RouteFilter? get activeRouteFilter => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, ___, ____, activeRouteFilter, _____) => activeRouteFilter,
    error: (_, __) => null,
  );
  
  RouteEntity? get selectedRoute => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, ___, ____, _____, selectedRoute) => selectedRoute,
    error: (_, __) => null,
  );
  
  int get routeCount => routes.length;
  
  int get savedRouteCount => savedRoutes.length;
  
  List<RouteEntity> get safeRoutes => routes
      .where((route) => route.safetyAnalysis.overallRiskScore <= 0.3)
      .toList();
  
  List<RouteEntity> get recentRoutes => routeHistory
      .take(5)
      .toList();
  
  Map<RouteType, List<RouteEntity>> get routesByType {
    final Map<RouteType, List<RouteEntity>> grouped = {};
    
    for (final route in routes) {
      grouped.putIfAbsent(route.routeType, () => []).add(route);
    }
    
    return grouped;
  }
  
  Map<RiskLevelType, List<RouteEntity>> get routesByRiskLevel {
    final Map<RiskLevelType, List<RouteEntity>> grouped = {};
    
    for (final route in routes) {
      grouped.putIfAbsent(route.safetyAnalysis.riskLevel, () => []).add(route);
    }
    
    return grouped;
  }
}

extension RouteCalculationStateExtension on RouteCalculationState {
  bool get isLoading => when(
    initial: () => false,
    loading: () => true,
    loaded: (_, __, ___, ____) => false,
    error: (_, __) => false,
  );
  
  bool get hasError => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __, ___, ____) => false,
    error: (_, __) => true,
  );
  
  bool get hasData => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __, ___, ____) => true,
    error: (_, __) => false,
  );
  
  List<RouteEntity> get calculatedRoutes => when(
    initial: () => [],
    loading: () => [],
    loaded: (calculatedRoutes, _, __, ___) => calculatedRoutes,
    error: (_, __) => [],
  );
  
  LatLng? get origin => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, origin, __, ___) => origin,
    error: (_, __) => null,
  );
  
  LatLng? get destination => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, destination, ___) => destination,
    error: (_, __) => null,
  );
  
  RouteType? get routeType => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, ___, routeType) => routeType,
    error: (_, __) => null,
  );
}

extension RouteComparisonStateExtension on RouteComparisonState {
  bool get isLoading => when(
    initial: () => false,
    loading: () => true,
    loaded: (_) => false,
    error: (_, __) => false,
  );
  
  bool get hasError => when(
    initial: () => false,
    loading: () => false,
    loaded: (_) => false,
    error: (_, __) => true,
  );
  
  bool get hasData => when(
    initial: () => false,
    loading: () => false,
    loaded: (_) => true,
    error: (_, __) => false,
  );
  
  RouteComparison? get comparison => when(
    initial: () => null,
    loading: () => null,
    loaded: (comparison) => comparison,
    error: (_, __) => null,
  );
}

extension RouteNavigationStateExtension on RouteNavigationState {
  bool get isNavigating => when(
    initial: () => false,
    navigating: (_, __, ___, ____, _____, ______) => true,
    paused: (_, __, ___) => false,
    completed: (_, __, ___) => false,
    error: (_, __) => false,
  );
  
  bool get isPaused => when(
    initial: () => false,
    navigating: (_, __, ___, ____, _____, ______) => false,
    paused: (_, __, ___) => true,
    completed: (_, __, ___) => false,
    error: (_, __) => false,
  );
  
  bool get isCompleted => when(
    initial: () => false,
    navigating: (_, __, ___, ____, _____, ______) => false,
    paused: (_, __, ___) => false,
    completed: (_, __, ___) => true,
    error: (_, __) => false,
  );
  
  bool get hasError => when(
    initial: () => false,
    navigating: (_, __, ___, ____, _____, ______) => false,
    paused: (_, __, ___) => false,
    completed: (_, __, ___) => false,
    error: (_, __) => true,
  );
  
  RouteEntity? get activeRoute => when(
    initial: () => null,
    navigating: (activeRoute, _, __, ___, ____, _____) => activeRoute,
    paused: (activeRoute, _, __) => activeRoute,
    completed: (completedRoute, _, __) => completedRoute,
    error: (_, __) => null,
  );
  
  LatLng? get currentLocation => when(
    initial: () => null,
    navigating: (_, currentLocation, __, ___, ____, _____) => currentLocation,
    paused: (_, currentLocation, __) => currentLocation,
    completed: (_, __, ___) => null,
    error: (_, __) => null,
  );
  
  double? get progressPercent => when(
    initial: () => null,
    navigating: (_, __, ___, progressPercent, ____, _____) => progressPercent,
    paused: (_, __, ___) => null,
    completed: (_, __, ___) => 100.0,
    error: (_, __) => null,
  );
}