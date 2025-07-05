import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'statistics_entity.freezed.dart';

@freezed
class DashboardStatistics with _$DashboardStatistics {
  const factory DashboardStatistics({
    required SecurityOverview securityOverview,
    required List<TrendData> securityTrends,
    required List<RegionStatistics> regionStats,
    required List<CrimeStatistics> crimeStats,
    required UserActivitySummary userActivity,
    required List<SafetyRecommendation> recommendations,
    required DateTime lastUpdated,
    String? period,
  }) = _DashboardStatistics;
}

@freezed
class SecurityOverview with _$SecurityOverview {
  const factory SecurityOverview({
    required int totalIncidents,
    required int activeAlerts,
    required double avgRiskScore,
    required SecurityLevel currentSecurityLevel,
    required int safeRoutes,
    required int riskAreas,
    required double improvementPercentage,
    required String improvementPeriod,
  }) = _SecurityOverview;
}

@freezed
class TrendData with _$TrendData {
  const factory TrendData({
    required DateTime date,
    required double value,
    required String label,
    required TrendType type,
    String? category,
    Map<String, dynamic>? metadata,
  }) = _TrendData;
}

@freezed
class RegionStatistics with _$RegionStatistics {
  const factory RegionStatistics({
    required String regionId,
    required String regionName,
    required LatLng centerCoordinates,
    required int incidentCount,
    required double riskScore,
    required SecurityLevel securityLevel,
    required List<CrimeTypeCount> crimeBreakdown,
    required double areaKm2,
    required int population,
    String? description,
  }) = _RegionStatistics;
}

@freezed
class CrimeStatistics with _$CrimeStatistics {
  const factory CrimeStatistics({
    required CrimeType crimeType,
    required int totalCount,
    required int monthlyCount,
    required double changePercentage,
    required List<TrendData> monthlyTrends,
    required List<RegionalBreakdown> regionalBreakdown,
    required List<TimeDistribution> timeDistribution,
    required double severityAverage,
  }) = _CrimeStatistics;
}

@freezed
class UserActivitySummary with _$UserActivitySummary {
  const factory UserActivitySummary({
    required int totalTrips,
    required double totalDistanceKm,
    required int safeTrips,
    required int riskyTrips,
    required int alertsReceived,
    required int alertsReported,
    required double avgTripSafety,
    required List<String> frequentRoutes,
    required Map<String, int> activityByDay,
  }) = _UserActivitySummary;
}

@freezed
class SafetyRecommendation with _$SafetyRecommendation {
  const factory SafetyRecommendation({
    required String id,
    required RecommendationType type,
    required String title,
    required String description,
    required RecommendationPriority priority,
    required List<String> actionItems,
    required DateTime validUntil,
    LatLng? location,
    String? routeId,
    bool? isPersonalized,
  }) = _SafetyRecommendation;
}

@freezed
class CrimeTypeCount with _$CrimeTypeCount {
  const factory CrimeTypeCount({
    required CrimeType type,
    required int count,
    required double percentage,
  }) = _CrimeTypeCount;
}

@freezed
class RegionalBreakdown with _$RegionalBreakdown {
  const factory RegionalBreakdown({
    required String regionName,
    required int count,
    required double riskScore,
  }) = _RegionalBreakdown;
}

@freezed
class TimeDistribution with _$TimeDistribution {
  const factory TimeDistribution({
    required int hour,
    required int count,
    required double riskMultiplier,
  }) = _TimeDistribution;
}

@freezed
class StatisticsFilter with _$StatisticsFilter {
  const factory StatisticsFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? regions,
    List<CrimeType>? crimeTypes,
    SecurityLevel? minSecurityLevel,
    SecurityLevel? maxSecurityLevel,
    String? userId,
    StatisticsPeriod? period,
  }) = _StatisticsFilter;
}

enum SecurityLevel {
  veryLow,
  low,
  moderate,
  high,
  veryHigh,
  critical,
}

enum TrendType {
  crimeRate,
  securityLevel,
  userActivity,
  alertCount,
  riskScore,
}

enum CrimeType {
  theft,
  assault,
  robbery,
  kidnapping,
  homicide,
  fraud,
  vandalism,
  drugRelated,
  domesticViolence,
  other,
}

enum RecommendationType {
  routeOptimization,
  timeAvoidance,
  areaWarning,
  safetyTip,
  emergencyPrep,
  personalSafety,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  urgent,
}

enum StatisticsPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum ExportFormat {
  pdf,
  excel,
  csv,
  json,
}

// Extensions for enum helpers
extension SecurityLevelExtension on SecurityLevel {
  String get label {
    switch (this) {
      case SecurityLevel.veryLow:
        return 'Muy Seguro';
      case SecurityLevel.low:
        return 'Seguro';
      case SecurityLevel.moderate:
        return 'Moderado';
      case SecurityLevel.high:
        return 'Inseguro';
      case SecurityLevel.veryHigh:
        return 'Muy Inseguro';
      case SecurityLevel.critical:
        return 'Crítico';
    }
  }

  String get description {
    switch (this) {
      case SecurityLevel.veryLow:
        return 'Área muy segura con mínimos incidentes';
      case SecurityLevel.low:
        return 'Área generalmente segura';
      case SecurityLevel.moderate:
        return 'Área con seguridad moderada, precaución recomendada';
      case SecurityLevel.high:
        return 'Área insegura, extremar precauciones';
      case SecurityLevel.veryHigh:
        return 'Área muy insegura, evitar si es posible';
      case SecurityLevel.critical:
        return 'Área crítica, evitar completamente';
    }
  }

  int get numericValue {
    switch (this) {
      case SecurityLevel.veryLow:
        return 1;
      case SecurityLevel.low:
        return 2;
      case SecurityLevel.moderate:
        return 3;
      case SecurityLevel.high:
        return 4;
      case SecurityLevel.veryHigh:
        return 5;
      case SecurityLevel.critical:
        return 6;
    }
  }
}

extension CrimeTypeExtension on CrimeType {
  String get label {
    switch (this) {
      case CrimeType.theft:
        return 'Robo';
      case CrimeType.assault:
        return 'Agresión';
      case CrimeType.robbery:
        return 'Asalto';
      case CrimeType.kidnapping:
        return 'Secuestro';
      case CrimeType.homicide:
        return 'Homicidio';
      case CrimeType.fraud:
        return 'Fraude';
      case CrimeType.vandalism:
        return 'Vandalismo';
      case CrimeType.drugRelated:
        return 'Relacionado con Drogas';
      case CrimeType.domesticViolence:
        return 'Violencia Doméstica';
      case CrimeType.other:
        return 'Otro';
    }
  }

  String get icon {
    switch (this) {
      case CrimeType.theft:
        return '🔓';
      case CrimeType.assault:
        return '👊';
      case CrimeType.robbery:
        return '💰';
      case CrimeType.kidnapping:
        return '🚨';
      case CrimeType.homicide:
        return '☠️';
      case CrimeType.fraud:
        return '💳';
      case CrimeType.vandalism:
        return '🔨';
      case CrimeType.drugRelated:
        return '💊';
      case CrimeType.domesticViolence:
        return '🏠';
      case CrimeType.other:
        return '⚠️';
    }
  }
}

extension RecommendationTypeExtension on RecommendationType {
  String get label {
    switch (this) {
      case RecommendationType.routeOptimization:
        return 'Optimización de Ruta';
      case RecommendationType.timeAvoidance:
        return 'Evitar Horarios';
      case RecommendationType.areaWarning:
        return 'Advertencia de Área';
      case RecommendationType.safetyTip:
        return 'Consejo de Seguridad';
      case RecommendationType.emergencyPrep:
        return 'Preparación para Emergencias';
      case RecommendationType.personalSafety:
        return 'Seguridad Personal';
    }
  }
}

extension StatisticsPeriodExtension on StatisticsPeriod {
  String get label {
    switch (this) {
      case StatisticsPeriod.daily:
        return 'Diario';
      case StatisticsPeriod.weekly:
        return 'Semanal';
      case StatisticsPeriod.monthly:
        return 'Mensual';
      case StatisticsPeriod.quarterly:
        return 'Trimestral';
      case StatisticsPeriod.yearly:
        return 'Anual';
    }
  }

  Duration get duration {
    switch (this) {
      case StatisticsPeriod.daily:
        return const Duration(days: 1);
      case StatisticsPeriod.weekly:
        return const Duration(days: 7);
      case StatisticsPeriod.monthly:
        return const Duration(days: 30);
      case StatisticsPeriod.quarterly:
        return const Duration(days: 90);
      case StatisticsPeriod.yearly:
        return const Duration(days: 365);
    }
  }
}

extension ExportFormatExtension on ExportFormat {
  String get label {
    switch (this) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.json:
        return 'JSON';
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.pdf:
        return '.pdf';
      case ExportFormat.excel:
        return '.xlsx';
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.json:
        return '.json';
    }
  }
}