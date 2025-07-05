import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/app_error.dart';
import '../entities/statistics_entity.dart';

part 'statistics_repository.freezed.dart';

abstract class StatisticsRepository {
  /// Get comprehensive dashboard statistics
  Future<Either<AppError, DashboardStatistics>> getDashboardStatistics({
    String? userId,
    StatisticsFilter? filter,
  });

  /// Get security overview for a specific area or global
  Future<Either<AppError, SecurityOverview>> getSecurityOverview({
    LatLng? center,
    double? radiusKm,
    StatisticsFilter? filter,
  });

  /// Get security trends over time
  Future<Either<AppError, List<TrendData>>> getSecurityTrends({
    required TrendType trendType,
    required StatisticsPeriod period,
    LatLng? location,
    StatisticsFilter? filter,
  });

  /// Get statistics by region
  Future<Either<AppError, List<RegionStatistics>>> getRegionStatistics({
    List<String>? regionIds,
    StatisticsFilter? filter,
  });

  /// Get crime statistics breakdown
  Future<Either<AppError, List<CrimeStatistics>>> getCrimeStatistics({
    List<CrimeType>? crimeTypes,
    StatisticsFilter? filter,
  });

  /// Get user activity summary
  Future<Either<AppError, UserActivitySummary>> getUserActivitySummary({
    required String userId,
    StatisticsFilter? filter,
  });

  /// Get personalized safety recommendations
  Future<Either<AppError, List<SafetyRecommendation>>> getSafetyRecommendations({
    String? userId,
    LatLng? location,
    RecommendationType? type,
  });

  /// Get comparative analysis between periods
  Future<Either<AppError, ComparativeAnalysis>> getComparativeAnalysis({
    required StatisticsPeriod period1,
    required StatisticsPeriod period2,
    LatLng? location,
    List<CrimeType>? crimeTypes,
  });

  /// Get heat map data for visualization
  Future<Either<AppError, List<HeatMapPoint>>> getHeatMapData({
    required LatLng center,
    required double radiusKm,
    CrimeType? crimeType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Export statistics data
  Future<Either<AppError, StatisticsExport>> exportStatistics({
    required StatisticsFilter filter,
    required ExportFormat format,
    String? userId,
  });

  /// Get real-time statistics updates
  Stream<DashboardStatistics> getDashboardUpdates({
    String? userId,
    Duration updateInterval = const Duration(minutes: 5),
  });
}

// Additional entities for the repository
@freezed
class ComparativeAnalysis with _$ComparativeAnalysis {
  const factory ComparativeAnalysis({
    required StatisticsPeriod period1,
    required StatisticsPeriod period2,
    required SecurityOverview period1Data,
    required SecurityOverview period2Data,
    required Map<CrimeType, ComparisonMetric> crimeComparison,
    required List<TrendComparison> trendComparisons,
    required String summary,
    required DateTime analyzedAt,
  }) = _ComparativeAnalysis;
}

@freezed
class ComparisonMetric with _$ComparisonMetric {
  const factory ComparisonMetric({
    required double period1Value,
    required double period2Value,
    required double changePercentage,
    required ChangeDirection direction,
    required String interpretation,
  }) = _ComparisonMetric;
}

@freezed
class TrendComparison with _$TrendComparison {
  const factory TrendComparison({
    required TrendType type,
    required List<TrendData> period1Trends,
    required List<TrendData> period2Trends,
    required double correlationCoefficient,
    required String analysis,
  }) = _TrendComparison;
}

@freezed
class HeatMapPoint with _$HeatMapPoint {
  const factory HeatMapPoint({
    required LatLng coordinates,
    required double intensity,
    required int incidentCount,
    required CrimeType? dominantCrimeType,
    required double radius,
  }) = _HeatMapPoint;
}

@freezed
class StatisticsExport with _$StatisticsExport {
  const factory StatisticsExport({
    required String exportId,
    required ExportFormat format,
    required String downloadUrl,
    required DateTime createdAt,
    required DateTime expiresAt,
    required int fileSizeBytes,
    String? fileName,
  }) = _StatisticsExport;
}

enum ChangeDirection {
  increase,
  decrease,
  stable,
}

enum ExportFormat {
  pdf,
  excel,
  csv,
  json,
}

// Helper classes for complex queries
class StatisticsQueryBuilder {
  StatisticsFilter? _filter;
  LatLng? _location;
  double? _radius;
  String? _userId;

  StatisticsQueryBuilder filter(StatisticsFilter filter) {
    _filter = filter;
    return this;
  }

  StatisticsQueryBuilder location(LatLng location, {double radiusKm = 10.0}) {
    _location = location;
    _radius = radiusKm;
    return this;
  }

  StatisticsQueryBuilder user(String userId) {
    _userId = userId;
    return this;
  }

  Map<String, dynamic> build() {
    final query = <String, dynamic>{};
    
    if (_filter != null) {
      query['filter'] = _filter;
    }
    
    if (_location != null) {
      query['location'] = {
        'lat': _location!.latitude,
        'lng': _location!.longitude,
        'radius_km': _radius,
      };
    }
    
    if (_userId != null) {
      query['user_id'] = _userId;
    }
    
    return query;
  }
}

// Extensions for helper methods
extension ChangeDirectionExtension on ChangeDirection {
  String get label {
    switch (this) {
      case ChangeDirection.increase:
        return 'Aumento';
      case ChangeDirection.decrease:
        return 'Disminución';
      case ChangeDirection.stable:
        return 'Estable';
    }
  }

  String get icon {
    switch (this) {
      case ChangeDirection.increase:
        return '📈';
      case ChangeDirection.decrease:
        return '📉';
      case ChangeDirection.stable:
        return '➡️';
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

  String get mimeType {
    switch (this) {
      case ExportFormat.pdf:
        return 'application/pdf';
      case ExportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.json:
        return 'application/json';
    }
  }
}