import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/risk_level.dart';
import '../../domain/repositories/maps_repository.dart';
import '../../domain/usecases/get_risk_polygons_usecase.dart';
import '../../domain/usecases/get_pois_usecase.dart';
import '../../domain/usecases/get_route_risk_analysis_usecase.dart';
import 'maps_state.dart';

part 'maps_provider.g.dart';

@riverpod
class MapsNotifier extends _$MapsNotifier {
  @override
  MapsState build() {
    _initializeLocation();
    return const MapsState.initial();
  }

  Future<void> _initializeLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied ||
            requestedPermission == LocationPermission.deniedForever) {
          AppLogger.warning('Location permission denied');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final currentLocation = LatLng(position.latitude, position.longitude);
      
      if (state.hasData) {
        state = state.when(
          initial: () => state,
          loading: () => state,
          loaded: (polygons, pois, _, riskFilter, poiFilter) => 
              MapsState.loaded(
                riskPolygons: polygons,
                pois: pois,
                currentLocation: currentLocation,
                activeRiskFilter: riskFilter,
                activePOIFilter: poiFilter,
              ),
          error: (_, __) => state,
        );
      } else {
        // Load initial data for current location
        await loadMapsData(currentLocation);
      }
    } catch (e) {
      AppLogger.error('Error getting current location', error: e);
    }
  }

  Future<void> loadMapsData(LatLng center, {double radiusKm = 10.0}) async {
    state = const MapsState.loading();
    
    try {
      // Load risk polygons and POIs concurrently
      final futures = await Future.wait([
        _loadRiskPolygons(center, radiusKm),
        _loadPOIs(center, radiusKm),
      ]);

      final riskPolygons = futures[0] as List<RiskPolygon>;
      final pois = futures[1] as List<POIEntity>;

      state = MapsState.loaded(
        riskPolygons: riskPolygons,
        pois: pois,
        currentLocation: center,
        activeRiskFilter: null,
        activePOIFilter: null,
      );
    } catch (e) {
      AppLogger.error('Error loading maps data', error: e);
      state = MapsState.error(
        error: e is AppError ? e : AppError.unknown(message: e.toString()),
        message: 'Error al cargar datos del mapa',
      );
    }
  }

  Future<List<RiskPolygon>> _loadRiskPolygons(LatLng center, double radiusKm) async {
    final useCase = getIt<GetRiskPolygonsUseCase>();
    final params = GetRiskPolygonsParams(
      center: center,
      radiusKm: radiusKm,
    );
    
    final result = await useCase(params);
    return result.fold(
      (error) => throw error,
      (polygons) => polygons,
    );
  }

  Future<List<POIEntity>> _loadPOIs(LatLng center, double radiusKm) async {
    final useCase = getIt<GetPOIsUseCase>();
    final params = GetPOIsParams(
      center: center,
      radiusKm: radiusKm,
    );
    
    final result = await useCase(params);
    return result.fold(
      (error) => throw error,
      (pois) => pois,
    );
  }

  Future<void> loadAllRiskPolygons({RiskFilter? filter}) async {
    final repository = getIt<MapsRepository>();
    final result = await repository.getAllRiskPolygons(filter: filter);
    
    result.fold(
      (error) => state = MapsState.error(error: error, message: error.message),
      (polygons) {
        state = state.when(
          initial: () => MapsState.loaded(
            riskPolygons: polygons,
            pois: [],
            currentLocation: null,
            activeRiskFilter: filter,
            activePOIFilter: null,
          ),
          loading: () => MapsState.loaded(
            riskPolygons: polygons,
            pois: [],
            currentLocation: null,
            activeRiskFilter: filter,
            activePOIFilter: null,
          ),
          loaded: (_, pois, location, __, poiFilter) => MapsState.loaded(
            riskPolygons: polygons,
            pois: pois,
            currentLocation: location,
            activeRiskFilter: filter,
            activePOIFilter: poiFilter,
          ),
          error: (_, __) => MapsState.loaded(
            riskPolygons: polygons,
            pois: [],
            currentLocation: null,
            activeRiskFilter: filter,
            activePOIFilter: null,
          ),
        );
      },
    );
  }

  Future<void> loadPOIsByType(POIType type, {POIFilter? filter}) async {
    final repository = getIt<MapsRepository>();
    final result = await repository.getPOIsByType(type: type, filter: filter);
    
    result.fold(
      (error) => state = MapsState.error(error: error, message: error.message),
      (pois) {
        state = state.when(
          initial: () => MapsState.loaded(
            riskPolygons: [],
            pois: pois,
            currentLocation: null,
            activeRiskFilter: null,
            activePOIFilter: filter,
          ),
          loading: () => MapsState.loaded(
            riskPolygons: [],
            pois: pois,
            currentLocation: null,
            activeRiskFilter: null,
            activePOIFilter: filter,
          ),
          loaded: (polygons, _, location, riskFilter, __) => MapsState.loaded(
            riskPolygons: polygons,
            pois: pois,
            currentLocation: location,
            activeRiskFilter: riskFilter,
            activePOIFilter: filter,
          ),
          error: (_, __) => MapsState.loaded(
            riskPolygons: [],
            pois: pois,
            currentLocation: null,
            activeRiskFilter: null,
            activePOIFilter: filter,
          ),
        );
      },
    );
  }

  Future<void> applyRiskFilter(RiskFilter? filter) async {
    final currentLocation = state.currentLocation;
    if (currentLocation == null) return;

    await loadMapsData(currentLocation);
  }

  Future<void> applyPOIFilter(POIFilter? filter) async {
    final currentLocation = state.currentLocation;
    if (currentLocation == null) return;

    await loadMapsData(currentLocation);
  }

  Future<void> refreshData() async {
    final currentLocation = state.currentLocation;
    if (currentLocation != null) {
      await loadMapsData(currentLocation);
    } else {
      await _initializeLocation();
    }
  }

  void clearError() {
    state = state.when(
      initial: () => state,
      loading: () => state,
      loaded: (polygons, pois, location, riskFilter, poiFilter) => state,
      error: (_, __) => const MapsState.initial(),
    );
  }

  void updateCurrentLocation(LatLng location) {
    state = state.when(
      initial: () => MapsState.loaded(
        riskPolygons: [],
        pois: [],
        currentLocation: location,
        activeRiskFilter: null,
        activePOIFilter: null,
      ),
      loading: () => state,
      loaded: (polygons, pois, _, riskFilter, poiFilter) => MapsState.loaded(
        riskPolygons: polygons,
        pois: pois,
        currentLocation: location,
        activeRiskFilter: riskFilter,
        activePOIFilter: poiFilter,
      ),
      error: (_, __) => state,
    );
  }
}

@riverpod
class RouteAnalysisNotifier extends _$RouteAnalysisNotifier {
  @override
  RouteAnalysisState build() {
    return const RouteAnalysisState.initial();
  }

  Future<void> analyzeRoute(List<LatLng> routePoints, {RiskFilter? filter}) async {
    if (routePoints.isEmpty) return;

    state = const RouteAnalysisState.loading();

    try {
      final useCase = getIt<GetRouteRiskAnalysisUseCase>();
      final params = GetRouteRiskAnalysisParams(
        routePoints: routePoints,
        filter: filter,
      );

      final result = await useCase(params);

      result.fold(
        (error) => state = RouteAnalysisState.error(
          error: error,
          message: error.message,
        ),
        (analysis) => state = RouteAnalysisState.loaded(analysis: analysis),
      );
    } catch (e) {
      AppLogger.error('Error analyzing route', error: e);
      state = RouteAnalysisState.error(
        error: e is AppError ? e : AppError.unknown(message: e.toString()),
        message: 'Error al analizar la ruta',
      );
    }
  }

  void clearAnalysis() {
    state = const RouteAnalysisState.initial();
  }
}

@riverpod
class POISearchNotifier extends _$POISearchNotifier {
  @override
  POISearchState build() {
    return const POISearchState.initial();
  }

  Future<void> searchPOIs(
    String query, {
    LatLng? center,
    double? radiusKm,
  }) async {
    if (query.trim().isEmpty) {
      state = const POISearchState.initial();
      return;
    }

    state = const POISearchState.loading();

    try {
      final repository = getIt<MapsRepository>();
      final result = await repository.searchPOIs(
        query: query,
        center: center,
        radiusKm: radiusKm,
      );

      result.fold(
        (error) => state = POISearchState.error(
          error: error,
          message: error.message,
        ),
        (results) => state = POISearchState.loaded(
          results: results,
          query: query,
        ),
      );
    } catch (e) {
      AppLogger.error('Error searching POIs', error: e);
      state = POISearchState.error(
        error: e is AppError ? e : AppError.unknown(message: e.toString()),
        message: 'Error al buscar puntos de interés',
      );
    }
  }

  void clearSearch() {
    state = const POISearchState.initial();
  }
}

// Provider for getting risk polygons by level
@riverpod
List<RiskPolygon> polygonsByRiskLevel(
  PolygonsByRiskLevelRef ref,
  RiskLevelType? level,
) {
  final mapsState = ref.watch(mapsNotifierProvider);
  
  return mapsState.when(
    initial: () => [],
    loading: () => [],
    loaded: (polygons, _, __, ___, ____) {
      if (level == null) return polygons;
      return polygons.where((polygon) => polygon.riskLevel == level).toList();
    },
    error: (_, __) => [],
  );
}

// Provider for getting POIs by type
@riverpod
List<POIEntity> poisByType(
  PoisByTypeRef ref,
  POIType? type,
) {
  final mapsState = ref.watch(mapsNotifierProvider);
  
  return mapsState.when(
    initial: () => [],
    loading: () => [],
    loaded: (_, pois, __, ___, ____) {
      if (type == null) return pois;
      return pois.where((poi) => poi.type == type).toList();
    },
    error: (_, __) => [],
  );
}

// Provider for getting high-risk polygons only
@riverpod
List<RiskPolygon> highRiskPolygons(HighRiskPolygonsRef ref) {
  final mapsState = ref.watch(mapsNotifierProvider);
  
  return mapsState.when(
    initial: () => [],
    loading: () => [],
    loaded: (polygons, _, __, ___, ____) => 
        polygons.where((polygon) => polygon.riskLevel.priority >= 3).toList(),
    error: (_, __) => [],
  );
}

// Provider for getting active POIs only
@riverpod
List<POIEntity> activePOIs(ActivePOIsRef ref) {
  final mapsState = ref.watch(mapsNotifierProvider);
  
  return mapsState.when(
    initial: () => [],
    loading: () => [],
    loaded: (_, pois, __, ___, ____) => 
        pois.where((poi) => poi.status == POIStatus.activo).toList(),
    error: (_, __) => [],
  );
}

// Provider for location-based helpers
@riverpod
LatLng? currentMapLocation(CurrentMapLocationRef ref) {
  final mapsState = ref.watch(mapsNotifierProvider);
  return mapsState.currentLocation;
}

// Provider for geocoding
@riverpod
class GeocodingNotifier extends _$GeocodingNotifier {
  @override
  AsyncValue<LatLng?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> geocodeAddress(String address) async {
    if (address.trim().isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = getIt<MapsRepository>();
      final result = await repository.geocodeAddress(address);

      result.fold(
        (error) => state = AsyncValue.error(error, StackTrace.current),
        (coordinates) => state = AsyncValue.data(coordinates),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> reverseGeocode(LatLng coordinates) async {
    // This would be implemented similarly for reverse geocoding
    // For now, keeping focus on the main functionality
  }
}