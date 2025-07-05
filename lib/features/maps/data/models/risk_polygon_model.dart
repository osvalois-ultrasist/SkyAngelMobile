import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/risk_level.dart';

part 'risk_polygon_model.g.dart';

@JsonSerializable()
class RiskPolygonModel {
  final String id;
  final List<List<double>> coordinates;
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  @JsonKey(name: 'risk_value')
  final double riskValue;
  @JsonKey(name: 'data_source')
  final String dataSource;
  @JsonKey(name: 'crime_types')
  final List<String> crimeTypes;
  @JsonKey(name: 'incident_count')
  final int incidentCount;
  @JsonKey(name: 'last_update')
  final String lastUpdate;
  final String? municipio;
  final String? estado;
  final Map<String, dynamic>? metadata;

  RiskPolygonModel({
    required this.id,
    required this.coordinates,
    required this.riskLevel,
    required this.riskValue,
    required this.dataSource,
    required this.crimeTypes,
    required this.incidentCount,
    required this.lastUpdate,
    this.municipio,
    this.estado,
    this.metadata,
  });

  factory RiskPolygonModel.fromJson(Map<String, dynamic> json) =>
      _$RiskPolygonModelFromJson(json);

  Map<String, dynamic> toJson() => _$RiskPolygonModelToJson(this);

  factory RiskPolygonModel.fromGeoJson(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final geometry = geoJson['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    // Convert GeoJSON coordinates to our format
    List<List<double>> coordinatesList = [];
    if (geometry['type'] == 'Polygon') {
      final polygon = coordinates[0] as List;
      coordinatesList = polygon.map<List<double>>((coord) {
        final coordList = coord as List;
        return [coordList[1].toDouble(), coordList[0].toDouble()]; // lat, lng
      }).toList();
    }

    return RiskPolygonModel(
      id: properties['id']?.toString() ?? '',
      coordinates: coordinatesList,
      riskLevel: properties['risk_level']?.toString() ?? 'low',
      riskValue: (properties['risk_value'] ?? 0.0).toDouble(),
      dataSource: properties['data_source']?.toString() ?? 'skyangel',
      crimeTypes: (properties['crime_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      incidentCount: properties['incident_count'] ?? 0,
      lastUpdate: properties['last_update']?.toString() ?? DateTime.now().toIso8601String(),
      municipio: properties['municipio']?.toString(),
      estado: properties['estado']?.toString(),
      metadata: properties['metadata'] as Map<String, dynamic>?,
    );
  }
}

extension RiskPolygonModelExtension on RiskPolygonModel {
  RiskPolygon toEntity() {
    return RiskPolygon(
      id: id,
      coordinates: coordinates.map((coord) => LatLng(coord[0], coord[1])).toList(),
      riskLevel: _parseRiskLevel(riskLevel),
      riskValue: riskValue,
      dataSource: _parseDataSource(dataSource),
      crimeTypes: crimeTypes.map((type) => _parseCrimeType(type)).toList(),
      incidentCount: incidentCount,
      lastUpdate: DateTime.parse(lastUpdate),
      municipio: municipio,
      estado: estado,
      metadata: metadata,
    );
  }

  RiskLevelType _parseRiskLevel(String level) {
    switch (level.toLowerCase()) {
      case 'very_low':
      case 'muy_bajo':
        return RiskLevelType.veryLow;
      case 'low':
      case 'bajo':
        return RiskLevelType.low;
      case 'moderate':
      case 'moderado':
        return RiskLevelType.moderate;
      case 'high':
      case 'alto':
        return RiskLevelType.high;
      case 'very_high':
      case 'muy_alto':
        return RiskLevelType.veryHigh;
      case 'extreme':
      case 'extremo':
        return RiskLevelType.extreme;
      default:
        return RiskLevelType.low;
    }
  }

  DataSource _parseDataSource(String source) {
    switch (source.toLowerCase()) {
      case 'secretariado':
        return DataSource.secretariado;
      case 'anerpv':
        return DataSource.anerpv;
      case 'skyangel':
        return DataSource.skyangel;
      default:
        return DataSource.skyangel;
    }
  }

  CrimeType _parseCrimeType(String type) {
    switch (type.toLowerCase()) {
      case 'homicidio':
        return CrimeType.homicidio;
      case 'robo':
        return CrimeType.robo;
      case 'violacion':
        return CrimeType.violacion;
      case 'secuestro':
        return CrimeType.secuestro;
      case 'feminicidio':
        return CrimeType.feminicidio;
      case 'extorsion':
        return CrimeType.extorsion;
      case 'accidente':
        return CrimeType.accidente;
      default:
        return CrimeType.otro;
    }
  }
}