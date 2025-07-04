import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../domain/entities/alert_entity.dart';

part 'alert_state.freezed.dart';

@freezed
class AlertState with _$AlertState {
  const factory AlertState.initial() = _Initial;
  
  const factory AlertState.loading() = _Loading;
  
  const factory AlertState.loaded({
    required List<AlertEntity> alerts,
  }) = _Loaded;
  
  const factory AlertState.error({
    required AppError error,
    required String message,
  }) = _Error;
}

extension AlertStateExtension on AlertState {
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
  
  List<AlertEntity> get alerts => when(
    initial: () => [],
    loading: () => [],
    loaded: (alerts) => alerts,
    error: (_, __) => [],
  );
  
  int get alertCount => alerts.length;
  
  List<AlertEntity> get activeAlerts => alerts.where((alert) => alert.isActive).toList();
  
  List<AlertEntity> get highPriorityAlerts => alerts.where((alert) => alert.isHighPriority).toList();
  
  Map<AlertType, List<AlertEntity>> get alertsByType {
    final Map<AlertType, List<AlertEntity>> grouped = {};
    
    for (final alert in alerts) {
      grouped.putIfAbsent(alert.tipo, () => []).add(alert);
    }
    
    return grouped;
  }
  
  Map<AlertPriority, List<AlertEntity>> get alertsByPriority {
    final Map<AlertPriority, List<AlertEntity>> grouped = {};
    
    for (final alert in alerts) {
      grouped.putIfAbsent(alert.prioridad, () => []).add(alert);
    }
    
    return grouped;
  }
}
