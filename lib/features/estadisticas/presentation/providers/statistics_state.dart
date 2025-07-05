import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../../domain/entities/statistics_entity.dart';

part 'statistics_state.freezed.dart';

@freezed
class DashboardStatisticsState with _$DashboardStatisticsState {
  const factory DashboardStatisticsState.initial() = DashboardStatisticsInitial;
  
  const factory DashboardStatisticsState.loading() = DashboardStatisticsLoading;
  
  const factory DashboardStatisticsState.loaded({
    required DashboardStatistics dashboard,
  }) = DashboardStatisticsLoaded;
  
  const factory DashboardStatisticsState.error({
    required AppError error,
    required String message,
  }) = DashboardStatisticsError;
}

extension DashboardStatisticsStateExtension on DashboardStatisticsState {
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
  
  DashboardStatistics? get dashboard => when(
    initial: () => null,
    loading: () => null,
    loaded: (dashboard) => dashboard,
    error: (_, __) => null,
  );
}