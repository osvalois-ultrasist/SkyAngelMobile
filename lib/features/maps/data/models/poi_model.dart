import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/poi_entity.dart';

part 'poi_model.g.dart';

@JsonSerializable()
class POIModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final double lat;
  final double lng;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final String? address;
  final String? phone;
  final String? website;
  final Map<String, dynamic>? metadata;
  final double? rating;
  final List<String>? tags;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  POIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.lat,
    required this.lng,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.address,
    this.phone,
    this.website,
    this.metadata,
    this.rating,
    this.tags,
    this.imageUrl,
  });

  factory POIModel.fromJson(Map<String, dynamic> json) =>
      _$POIModelFromJson(json);

  Map<String, dynamic> toJson() => _$POIModelToJson(this);

  factory POIModel.fromGeoJson(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final geometry = geoJson['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    return POIModel(
      id: properties['id']?.toString() ?? '',
      name: properties['name']?.toString() ?? '',
      description: properties['description']?.toString() ?? '',
      type: properties['type']?.toString() ?? 'otro',
      lat: coordinates[1].toDouble(),
      lng: coordinates[0].toDouble(),
      status: properties['status']?.toString() ?? 'activo',
      createdAt: properties['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: properties['updated_at']?.toString(),
      address: properties['address']?.toString(),
      phone: properties['phone']?.toString(),
      website: properties['website']?.toString(),
      metadata: properties['metadata'] as Map<String, dynamic>?,
      rating: (properties['rating'] as num?)?.toDouble(),
      tags: (properties['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      imageUrl: properties['image_url']?.toString(),
    );
  }

  factory POIModel.fromEntity(POIEntity entity) {
    return POIModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: _poiTypeToString(entity.type),
      lat: entity.coordinates.latitude,
      lng: entity.coordinates.longitude,
      status: _poiStatusToString(entity.status),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
      address: entity.address,
      phone: entity.phone,
      website: entity.website,
      metadata: entity.metadata,
      rating: entity.rating,
      tags: entity.tags,
      imageUrl: entity.imageUrl,
    );
  }

  static String _poiTypeToString(POIType type) {
    switch (type) {
      case POIType.accidenteTransito:
        return 'accidente_transito';
      case POIType.incidenciaFerroviaria:
        return 'incidencia_ferroviaria';
      case POIType.agenciaMinisterioPublico:
        return 'agencia_ministerio_publico';
      case POIType.guardiaNacional:
        return 'guardia_nacional';
      case POIType.caseta:
        return 'caseta';
      case POIType.corralon:
        return 'corralon';
      case POIType.paradero:
        return 'paradero';
      case POIType.pension:
        return 'pension';
      case POIType.coberturaCelular:
        return 'cobertura_celular';
      case POIType.hospital:
        return 'hospital';
      case POIType.gasolinera:
        return 'gasolinera';
      case POIType.banco:
        return 'banco';
      case POIType.policia:
        return 'policia';
      case POIType.otro:
        return 'otro';
    }
  }

  static String _poiStatusToString(POIStatus status) {
    switch (status) {
      case POIStatus.activo:
        return 'activo';
      case POIStatus.inactivo:
        return 'inactivo';
      case POIStatus.mantenimiento:
        return 'mantenimiento';
      case POIStatus.cerrado:
        return 'cerrado';
    }
  }
}

extension POIModelExtension on POIModel {
  POIEntity toEntity() {
    return POIEntity(
      id: id,
      name: name,
      description: description,
      type: _parsePOIType(type),
      coordinates: LatLng(lat, lng),
      status: _parsePOIStatus(status),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      address: address,
      phone: phone,
      website: website,
      metadata: metadata,
      rating: rating,
      tags: tags,
      imageUrl: imageUrl,
    );
  }

  POIType _parsePOIType(String type) {
    switch (type.toLowerCase()) {
      case 'accidente_transito':
        return POIType.accidenteTransito;
      case 'incidencia_ferroviaria':
        return POIType.incidenciaFerroviaria;
      case 'agencia_ministerio_publico':
        return POIType.agenciaMinisterioPublico;
      case 'guardia_nacional':
        return POIType.guardiaNacional;
      case 'caseta':
        return POIType.caseta;
      case 'corralon':
        return POIType.corralon;
      case 'paradero':
        return POIType.paradero;
      case 'pension':
        return POIType.pension;
      case 'cobertura_celular':
        return POIType.coberturaCelular;
      case 'hospital':
        return POIType.hospital;
      case 'gasolinera':
        return POIType.gasolinera;
      case 'banco':
        return POIType.banco;
      case 'policia':
        return POIType.policia;
      default:
        return POIType.otro;
    }
  }

  POIStatus _parsePOIStatus(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return POIStatus.activo;
      case 'inactivo':
        return POIStatus.inactivo;
      case 'mantenimiento':
        return POIStatus.mantenimiento;
      case 'cerrado':
        return POIStatus.cerrado;
      default:
        return POIStatus.activo;
    }
  }
}