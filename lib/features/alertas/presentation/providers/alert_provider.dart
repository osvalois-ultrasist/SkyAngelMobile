import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/alert_category_entity.dart';
import '../../domain/entities/alert_statistics_entity.dart';
import '../../domain/entities/create_alert_request.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/usecases/create_alert_usecase.dart';
import '../../domain/usecases/get_active_alerts_usecase.dart';
import '../../domain/usecases/get_alert_categories_usecase.dart';
import '../../domain/usecases/get_alert_statistics_usecase.dart';
import '../../domain/usecases/update_alert_status_usecase.dart';
import 'alert_state.dart';

part 'alert_provider.g.dart';

@riverpod
class AlertNotifier extends _$AlertNotifier {
  @override
  AlertState build() {
    _initializeRealTimeListeners();
    return const AlertState.initial();
  }

  void _initializeRealTimeListeners() {
    final repository = getIt<AlertRepository>();
    
    // Listen for new alerts
    repository.alertStream.listen(
      (alert) {
        state = state.when(
          initial: () => AlertState.loaded(alerts: [alert]),
          loading: () => AlertState.loaded(alerts: [alert]),
          loaded: (alerts) => AlertState.loaded(alerts: [alert, ...alerts]),
          error: (_, __) => AlertState.loaded(alerts: [alert]),
        );
      },
      onError: (error) {
        // Handle real-time errors gracefully
      },
    );
    
    // Listen for alert updates
    repository.alertUpdatesStream.listen(
      (updatedAlert) {
        state = state.when(
          initial: () => state,
          loading: () => state,
          loaded: (alerts) {
            final updatedAlerts = alerts.map((alert) {
              return alert.id == updatedAlert.id ? updatedAlert : alert;
            }).toList();
            return AlertState.loaded(alerts: updatedAlerts);
          },
          error: (_, __) => state,
        );
      },
      onError: (error) {
        // Handle real-time errors gracefully
      },
    );
  }

  Future<void> loadActiveAlerts() async {
    state = const AlertState.loading();
    
    final useCase = getIt<GetActiveAlertsUseCase>();
    final result = await useCase(NoParams());
    
    result.fold(
      (error) => state = AlertState.error(error: error, message: error.message),
      (alerts) => state = AlertState.loaded(alerts: alerts),
    );
  }

  Future<void> createAlert(CreateAlertRequest request) async {
    final useCase = getIt<CreateAlertUseCase>();
    final result = await useCase(request);
    
    result.fold(
      (error) => state = AlertState.error(error: error, message: error.message),
      (alert) {
        // The alert will be added via real-time stream
        // But we can also add it immediately for better UX
        state = state.when(
          initial: () => AlertState.loaded(alerts: [alert]),
          loading: () => AlertState.loaded(alerts: [alert]),
          loaded: (alerts) => AlertState.loaded(alerts: [alert, ...alerts]),
          error: (_, __) => AlertState.loaded(alerts: [alert]),
        );
      },
    );
  }

  Future<void> updateAlertStatus(int alertId, AlertStatus status) async {
    final useCase = getIt<UpdateAlertStatusUseCase>();
    final params = UpdateAlertStatusParams(alertId: alertId, newStatus: status);
    final result = await useCase(params);
    
    result.fold(
      (error) => state = AlertState.error(error: error, message: error.message),
      (updatedAlert) {
        state = state.when(
          initial: () => state,
          loading: () => state,
          loaded: (alerts) {
            final updatedAlerts = alerts.map((alert) {
              return alert.id == updatedAlert.id ? updatedAlert : alert;
            }).toList();
            return AlertState.loaded(alerts: updatedAlerts);
          },
          error: (_, __) => state,
        );
      },
    );
  }

  void clearError() {
    state = state.when(
      initial: () => state,
      loading: () => state,
      loaded: (alerts) => state,
      error: (_, __) => const AlertState.initial(),
    );
  }
}

@riverpod
class AlertCategoriesNotifier extends _$AlertCategoriesNotifier {
  @override
  AsyncValue<List<AlertCategoryEntity>> build() {
    loadCategories();
    return const AsyncValue.loading();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    
    final useCase = getIt<GetAlertCategoriesUseCase>();
    final result = await useCase(NoParams());
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (categories) => state = AsyncValue.data(categories),
    );
  }
}

// AlertSubcategoriesNotifier removed - feature not implemented yet

@riverpod
class AlertStatisticsNotifier extends _$AlertStatisticsNotifier {
  @override
  AsyncValue<AlertStatisticsEntity> build() {
    loadStatistics();
    return const AsyncValue.loading();
  }

  Future<void> loadStatistics() async {
    state = const AsyncValue.loading();
    
    final useCase = getIt<GetAlertStatisticsUseCase>();
    final result = await useCase(NoParams());
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (statistics) => state = AsyncValue.data(statistics),
    );
  }

  Future<void> refresh() async {
    await loadStatistics();
  }
}

// Provider for getting a specific alert by ID
@riverpod
AlertEntity? alertById(AlertByIdRef ref, int alertId) {
  final alertState = ref.watch(alertNotifierProvider);
  
  return alertState.when(
    initial: () => null,
    loading: () => null,
    loaded: (alerts) => alerts.where((alert) => alert.id == alertId).firstOrNull,
    error: (_, __) => null,
  );
}

// Provider for filtering alerts by type
@riverpod
List<AlertEntity> alertsByType(AlertsByTypeRef ref, AlertType? type) {
  final alertState = ref.watch(alertNotifierProvider);
  
  return alertState.when(
    initial: () => [],
    loading: () => [],
    loaded: (alerts) {
      if (type == null) return alerts;
      return alerts.where((alert) => alert.tipo == type).toList();
    },
    error: (_, __) => [],
  );
}

// Provider for filtering alerts by priority
@riverpod
List<AlertEntity> alertsByPriority(AlertsByPriorityRef ref, AlertPriority? priority) {
  final alertState = ref.watch(alertNotifierProvider);
  
  return alertState.when(
    initial: () => [],
    loading: () => [],
    loaded: (alerts) {
      if (priority == null) return alerts;
      return alerts.where((alert) => alert.prioridad == priority).toList();
    },
    error: (_, __) => [],
  );
}

// Provider for high priority alerts only
@riverpod
List<AlertEntity> highPriorityAlerts(HighPriorityAlertsRef ref) {
  final alertState = ref.watch(alertNotifierProvider);
  
  return alertState.when(
    initial: () => [],
    loading: () => [],
    loaded: (alerts) => alerts.where((alert) => alert.isHighPriority).toList(),
    error: (_, __) => [],
  );
}

// Provider for recent alerts (last 24 hours)
@riverpod
List<AlertEntity> recentAlerts(RecentAlertsRef ref) {
  final alertState = ref.watch(alertNotifierProvider);
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(hours: 24));
  
  return alertState.when(
    initial: () => [],
    loading: () => [],
    loaded: (alerts) => alerts.where((alert) => alert.fecha.isAfter(yesterday)).toList(),
    error: (_, __) => [],
  );
}
