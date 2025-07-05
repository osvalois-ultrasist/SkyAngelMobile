import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_error.dart';
import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/risk_level.dart';
import '../../domain/repositories/maps_repository.dart';

part 'maps_state.freezed.dart';

@freezed
class MapsState with _$MapsState {
  const factory MapsState.initial() = _Initial;
  
  const factory MapsState.loading() = _Loading;
  
  const factory MapsState.loaded({
    required List<RiskPolygon> riskPolygons,
    required List<POIEntity> pois,
    required LatLng? currentLocation,
    RiskFilter? activeRiskFilter,
    POIFilter? activePOIFilter,
  }) = _Loaded;
  
  const factory MapsState.error({
    required AppError error,
    required String message,
  }) = _Error;
}

@freezed
class RouteAnalysisState with _$RouteAnalysisState {
  const factory RouteAnalysisState.initial() = _RouteInitial;
  
  const factory RouteAnalysisState.loading() = _RouteLoading;
  
  const factory RouteAnalysisState.loaded({
    required RouteRiskAnalysis analysis,
  }) = _RouteLoaded;
  
  const factory RouteAnalysisState.error({
    required AppError error,
    required String message,
  }) = _RouteError;
}

@freezed
class POISearchState with _$POISearchState {
  const factory POISearchState.initial() = _POISearchInitial;
  
  const factory POISearchState.loading() = _POISearchLoading;
  
  const factory POISearchState.loaded({
    required List<POIEntity> results,
    required String query,
  }) = _POISearchLoaded;
  
  const factory POISearchState.error({
    required AppError error,
    required String message,
  }) = _POISearchError;
}

extension MapsStateExtension on MapsState {
  bool get isLoading => when(
    initial: () => false,
    loading: () => true,
    loaded: (_, __, ___, ____, _____) => false,
    error: (_, __) => false,
  );
  
  bool get hasError => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __, ___, ____, _____) => false,
    error: (_, __) => true,
  );
  
  bool get hasData => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __, ___, ____, _____) => true,
    error: (_, __) => false,
  );
  
  List<RiskPolygon> get riskPolygons => when(
    initial: () => [],
    loading: () => [],
    loaded: (polygons, _, __, ___, ____) => polygons,
    error: (_, __) => [],
  );
  
  List<POIEntity> get pois => when(
    initial: () => [],
    loading: () => [],
    loaded: (_, pois, __, ___, ____) => pois,
    error: (_, __) => [],
  );
  
  LatLng? get currentLocation => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, location, ___, ____) => location,
    error: (_, __) => null,
  );
  
  RiskFilter? get activeRiskFilter => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, ___, riskFilter, ____) => riskFilter,
    error: (_, __) => null,
  );
  
  POIFilter? get activePOIFilter => when(
    initial: () => null,
    loading: () => null,
    loaded: (_, __, ___, ____, poiFilter) => poiFilter,
    error: (_, __) => null,
  );
  
  int get riskPolygonCount => riskPolygons.length;
  
  int get poiCount => pois.length;
  
  List<RiskPolygon> get highRiskPolygons => riskPolygons
      .where((polygon) => polygon.riskLevel.priority >= 3)
      .toList();
  
  List<POIEntity> get activePOIs => pois
      .where((poi) => poi.status == POIStatus.activo)
      .toList();
  
  Map<RiskLevelType, List<RiskPolygon>> get polygonsByRiskLevel {
    final Map<RiskLevelType, List<RiskPolygon>> grouped = {};
    
    for (final polygon in riskPolygons) {
      grouped.putIfAbsent(polygon.riskLevel, () => []).add(polygon);
    }
    
    return grouped;
  }
  
  Map<POIType, List<POIEntity>> get poisByType {
    final Map<POIType, List<POIEntity>> grouped = {};
    
    for (final poi in pois) {
      grouped.putIfAbsent(poi.type, () => []).add(poi);
    }
    
    return grouped;
  }
  
  Map<DataSource, List<RiskPolygon>> get polygonsByDataSource {
    final Map<DataSource, List<RiskPolygon>> grouped = {};
    
    for (final polygon in riskPolygons) {
      grouped.putIfAbsent(polygon.dataSource, () => []).add(polygon);
    }
    
    return grouped;
  }
}

extension RouteAnalysisStateExtension on RouteAnalysisState {
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
  
  RouteRiskAnalysis? get analysis => when(
    initial: () => null,
    loading: () => null,
    loaded: (analysis) => analysis,
    error: (_, __) => null,
  );
}

extension POISearchStateExtension on POISearchState {
  bool get isLoading => when(
    initial: () => false,
    loading: () => true,
    loaded: (_, __) => false,
    error: (_, __) => false,
  );
  
  bool get hasError => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __) => false,
    error: (_, __) => true,
  );
  
  bool get hasData => when(
    initial: () => false,
    loading: () => false,
    loaded: (_, __) => true,
    error: (_, __) => false,
  );
  
  List<POIEntity> get results => when(
    initial: () => [],
    loading: () => [],
    loaded: (results, _) => results,
    error: (_, __) => [],
  );
  
  String get query => when(
    initial: () => '',
    loading: () => '',
    loaded: (_, query) => query,
    error: (_, __) => '',
  );
}