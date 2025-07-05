import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'risk_level.dart';

part 'risk_polygon.freezed.dart';

enum DataSource {
  secretariado,
  anerpv,
  skyangel,
}

enum CrimeType {
  homicidio,
  robo,
  violacion,
  secuestro,
  feminicidio,
  extorsion,
  accidente,
  otro,
}

@freezed
class RiskPolygon with _$RiskPolygon {
  const factory RiskPolygon({
    required String id,
    required List<LatLng> coordinates,
    required RiskLevelType riskLevel,
    required double riskValue,
    required DataSource dataSource,
    required List<CrimeType> crimeTypes,
    required int incidentCount,
    required DateTime lastUpdate,
    String? municipio,
    String? estado,
    Map<String, dynamic>? metadata,
  }) = _RiskPolygon;
}

@freezed
class RiskFilter with _$RiskFilter {
  const factory RiskFilter({
    @Default([]) List<DataSource> dataSources,
    @Default([]) List<CrimeType> crimeTypes,
    @Default([]) List<RiskLevelType> riskLevels,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    LatLng? center,
    double? radiusKm,
  }) = _RiskFilter;
}

extension DataSourceExtension on DataSource {
  String get label {
    switch (this) {
      case DataSource.secretariado:
        return 'Secretariado Ejecutivo';
      case DataSource.anerpv:
        return 'ANERPV';
      case DataSource.skyangel:
        return 'SkyAngel';
    }
  }

  String get description {
    switch (this) {
      case DataSource.secretariado:
        return 'Sistema Nacional de Seguridad Pública';
      case DataSource.anerpv:
        return 'Asociación Nacional de Empresas de Rastreo';
      case DataSource.skyangel:
        return 'Datos propios de la plataforma';
    }
  }
}

extension CrimeTypeExtension on CrimeType {
  String get label {
    switch (this) {
      case CrimeType.homicidio:
        return 'Homicidio';
      case CrimeType.robo:
        return 'Robo';
      case CrimeType.violacion:
        return 'Violación';
      case CrimeType.secuestro:
        return 'Secuestro';
      case CrimeType.feminicidio:
        return 'Feminicidio';
      case CrimeType.extorsion:
        return 'Extorsión';
      case CrimeType.accidente:
        return 'Accidente';
      case CrimeType.otro:
        return 'Otro';
    }
  }

  String get icon {
    switch (this) {
      case CrimeType.homicidio:
        return '💀';
      case CrimeType.robo:
        return '🦹';
      case CrimeType.violacion:
        return '🚨';
      case CrimeType.secuestro:
        return '🆘';
      case CrimeType.feminicidio:
        return '👩‍💼';
      case CrimeType.extorsion:
        return '💰';
      case CrimeType.accidente:
        return '🚗';
      case CrimeType.otro:
        return '⚠️';
    }
  }
}