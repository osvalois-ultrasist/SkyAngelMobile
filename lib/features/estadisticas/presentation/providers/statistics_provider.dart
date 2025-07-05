import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/statistics_entity.dart';
import '../../domain/usecases/get_dashboard_statistics_usecase.dart';
import 'statistics_state.dart';

part 'statistics_provider.g.dart';

@riverpod
class DashboardStatisticsNotifier extends _$DashboardStatisticsNotifier {
  @override
  DashboardStatisticsState build() {
    return const DashboardStatisticsState.initial();
  }

  Future<void> loadDashboard({
    String? userId,
    StatisticsFilter? filter,
  }) async {
    state = const DashboardStatisticsState.loading();
    
    try {
      final useCase = getIt<GetDashboardStatisticsUseCase>();
      final params = GetDashboardStatisticsParams(
        userId: userId,
        filter: filter,
      );
      
      final result = await useCase(params);
      
      result.fold(
        (error) => state = DashboardStatisticsState.error(
          error: error,
          message: error.message,
        ),
        (dashboard) => state = DashboardStatisticsState.loaded(
          dashboard: dashboard,
        ),
      );
    } catch (e) {
      AppLogger.error('Error loading dashboard statistics', error: e);
      state = DashboardStatisticsState.error(
        error: e is AppError ? e : AppError.unknown(message: e.toString()),
        message: 'Error inesperado al cargar estadísticas del dashboard',
      );
    }
  }

  Future<void> refreshDashboard() async {
    final currentState = state;
    if (currentState is DashboardStatisticsLoaded) {
      await loadDashboard();
    } else {
      await loadDashboard();
    }
  }

  void clearError() {
    state = state.when(
      initial: () => state,
      loading: () => state,
      loaded: (dashboard) => state,
      error: (_, __) => const DashboardStatisticsState.initial(),
    );
  }
}

@riverpod
class SecurityTrendsNotifier extends _$SecurityTrendsNotifier {
  @override
  AsyncValue<List<TrendData>> build(TrendType trendType, StatisticsPeriod period) {
    loadTrends(trendType, period);
    return const AsyncValue.loading();
  }

  Future<void> loadTrends(TrendType trendType, StatisticsPeriod period) async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate API call - replace with actual repository call
      await Future.delayed(const Duration(seconds: 1));
      
      final trends = _generateMockTrends(trendType, period);
      state = AsyncValue.data(trends);
    } catch (e) {
      AppLogger.error('Error loading security trends', error: e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  List<TrendData> _generateMockTrends(TrendType trendType, StatisticsPeriod period) {
    final now = DateTime.now();
    final trends = <TrendData>[];
    
    for (int i = 0; i < 30; i++) {
      trends.add(TrendData(
        date: now.subtract(Duration(days: i)),
        value: 50 + (i * 2) + (i % 7) * 10,
        label: 'Día ${30 - i}',
        type: trendType,
      ));
    }
    
    return trends.reversed.toList();
  }
}

@riverpod
class CrimeStatisticsNotifier extends _$CrimeStatisticsNotifier {
  @override
  AsyncValue<List<CrimeStatistics>> build() {
    loadCrimeStatistics();
    return const AsyncValue.loading();
  }

  Future<void> loadCrimeStatistics() async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate API call - replace with actual repository call
      await Future.delayed(const Duration(seconds: 1));
      
      final crimeStats = _generateMockCrimeStats();
      state = AsyncValue.data(crimeStats);
    } catch (e) {
      AppLogger.error('Error loading crime statistics', error: e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  List<CrimeStatistics> _generateMockCrimeStats() {
    return CrimeType.values.map((type) {
      return CrimeStatistics(
        crimeType: type,
        totalCount: 100 + type.index * 50,
        monthlyCount: 10 + type.index * 5,
        changePercentage: -5.0 + type.index * 2,
        monthlyTrends: _generateMockTrendsForCrime(type),
        regionalBreakdown: [],
        timeDistribution: [],
        severityAverage: 3.0 + type.index * 0.5,
      );
    }).toList();
  }

  List<TrendData> _generateMockTrendsForCrime(CrimeType type) {
    final now = DateTime.now();
    final trends = <TrendData>[];
    
    for (int i = 0; i < 12; i++) {
      trends.add(TrendData(
        date: DateTime(now.year, now.month - i, 1),
        value: 20 + (i * 3) + (type.index * 10),
        label: 'Mes ${12 - i}',
        type: TrendType.crimeRate,
        category: type.label,
      ));
    }
    
    return trends.reversed.toList();
  }
}

@riverpod
class UserActivityNotifier extends _$UserActivityNotifier {
  @override
  AsyncValue<UserActivitySummary> build(String userId) {
    loadUserActivity(userId);
    return const AsyncValue.loading();
  }

  Future<void> loadUserActivity(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate API call - replace with actual repository call
      await Future.delayed(const Duration(seconds: 1));
      
      final activity = _generateMockUserActivity();
      state = AsyncValue.data(activity);
    } catch (e) {
      AppLogger.error('Error loading user activity', error: e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  UserActivitySummary _generateMockUserActivity() {
    return const UserActivitySummary(
      totalTrips: 45,
      totalDistanceKm: 234.5,
      safeTrips: 42,
      riskyTrips: 3,
      alertsReceived: 12,
      alertsReported: 3,
      avgTripSafety: 4.2,
      frequentRoutes: ['Casa - Trabajo', 'Trabajo - Gimnasio', 'Casa - Centro Comercial'],
      activityByDay: {
        'Lunes': 8,
        'Martes': 7,
        'Miércoles': 6,
        'Jueves': 9,
        'Viernes': 8,
        'Sábado': 4,
        'Domingo': 3,
      },
    );
  }
}

@riverpod
class SafetyRecommendationsNotifier extends _$SafetyRecommendationsNotifier {
  @override
  AsyncValue<List<SafetyRecommendation>> build() {
    loadRecommendations();
    return const AsyncValue.loading();
  }

  Future<void> loadRecommendations() async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate API call - replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final recommendations = _generateMockRecommendations();
      state = AsyncValue.data(recommendations);
    } catch (e) {
      AppLogger.error('Error loading safety recommendations', error: e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  List<SafetyRecommendation> _generateMockRecommendations() {
    final now = DateTime.now();
    
    return [
      SafetyRecommendation(
        id: '1',
        type: RecommendationType.routeOptimization,
        title: 'Ruta más segura disponible',
        description: 'Hay una ruta alternativa 15% más segura para tu trayecto habitual al trabajo.',
        priority: RecommendationPriority.medium,
        actionItems: [
          'Revisar ruta alternativa sugerida',
          'Comparar tiempos de viaje',
          'Probar la nueva ruta'
        ],
        validUntil: now.add(const Duration(days: 7)),
        isPersonalized: true,
      ),
      SafetyRecommendation(
        id: '2',
        type: RecommendationType.timeAvoidance,
        title: 'Evitar horario de alto riesgo',
        description: 'Se recomienda evitar viajar entre 22:00 y 24:00 por tu área frecuente.',
        priority: RecommendationPriority.high,
        actionItems: [
          'Planificar salidas más temprano',
          'Considerar transporte alternativo',
          'Informar a contactos de emergencia'
        ],
        validUntil: now.add(const Duration(days: 30)),
        isPersonalized: true,
      ),
      SafetyRecommendation(
        id: '3',
        type: RecommendationType.areaWarning,
        title: 'Área de alta actividad criminal',
        description: 'Incremento del 25% en reportes de robo en el centro de la ciudad.',
        priority: RecommendationPriority.urgent,
        actionItems: [
          'Evitar zona del centro en horarios nocturnos',
          'Usar rutas alternativas',
          'Mantenerse alerta en la zona'
        ],
        validUntil: now.add(const Duration(days: 14)),
        isPersonalized: false,
      ),
    ];
  }
}

// Provider for getting filtered statistics
@riverpod
Future<DashboardStatistics> filteredDashboard(
  FilteredDashboardRef ref,
  StatisticsFilter filter,
) async {
  final useCase = getIt<GetDashboardStatisticsUseCase>();
  final params = GetDashboardStatisticsParams(filter: filter);
  
  final result = await useCase(params);
  
  return result.fold(
    (error) => throw error,
    (dashboard) => dashboard,
  );
}