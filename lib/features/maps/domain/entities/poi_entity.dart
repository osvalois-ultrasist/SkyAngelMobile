import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

part 'poi_entity.freezed.dart';

enum POIType {
  accidenteTransito,
  incidenciaFerroviaria,
  agenciaMinisterioPublico,
  guardiaNacional,
  caseta,
  corralon,
  paradero,
  pension,
  coberturaCelular,
  hospital,
  gasolinera,
  banco,
  policia,
  otro,
}

enum POIStatus {
  activo,
  inactivo,
  mantenimiento,
  cerrado,
}

@freezed
class POIEntity with _$POIEntity {
  const factory POIEntity({
    required String id,
    required String name,
    required String description,
    required POIType type,
    required LatLng coordinates,
    required POIStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? address,
    String? phone,
    String? website,
    Map<String, dynamic>? metadata,
    double? rating,
    List<String>? tags,
    String? imageUrl,
  }) = _POIEntity;
}

@freezed
class POIFilter with _$POIFilter {
  const factory POIFilter({
    @Default([]) List<POIType> types,
    @Default([]) List<POIStatus> statuses,
    String? searchQuery,
    LatLng? center,
    double? radiusKm,
    double? minRating,
  }) = _POIFilter;
}

extension POITypeExtension on POIType {
  String get label {
    switch (this) {
      case POIType.accidenteTransito:
        return 'Accidente de Tránsito';
      case POIType.incidenciaFerroviaria:
        return 'Incidencia Ferroviaria';
      case POIType.agenciaMinisterioPublico:
        return 'Agencia del Ministerio Público';
      case POIType.guardiaNacional:
        return 'Guardia Nacional';
      case POIType.caseta:
        return 'Caseta';
      case POIType.corralon:
        return 'Corralón';
      case POIType.paradero:
        return 'Paradero';
      case POIType.pension:
        return 'Pensión';
      case POIType.coberturaCelular:
        return 'Cobertura Celular';
      case POIType.hospital:
        return 'Hospital';
      case POIType.gasolinera:
        return 'Gasolinera';
      case POIType.banco:
        return 'Banco';
      case POIType.policia:
        return 'Policía';
      case POIType.otro:
        return 'Otro';
    }
  }

  String get icon {
    switch (this) {
      case POIType.accidenteTransito:
        return '🚗';
      case POIType.incidenciaFerroviaria:
        return '🚂';
      case POIType.agenciaMinisterioPublico:
        return '🏛️';
      case POIType.guardiaNacional:
        return '🛡️';
      case POIType.caseta:
        return '🏠';
      case POIType.corralon:
        return '🏭';
      case POIType.paradero:
        return '🚌';
      case POIType.pension:
        return '🏨';
      case POIType.coberturaCelular:
        return '📶';
      case POIType.hospital:
        return '🏥';
      case POIType.gasolinera:
        return '⛽';
      case POIType.banco:
        return '🏦';
      case POIType.policia:
        return '👮';
      case POIType.otro:
        return '📍';
    }
  }

  String get category {
    switch (this) {
      case POIType.accidenteTransito:
      case POIType.incidenciaFerroviaria:
        return 'Incidencias';
      case POIType.agenciaMinisterioPublico:
      case POIType.guardiaNacional:
      case POIType.policia:
        return 'Seguridad';
      case POIType.caseta:
      case POIType.corralon:
      case POIType.paradero:
        return 'Transporte';
      case POIType.pension:
      case POIType.hospital:
        return 'Servicios';
      case POIType.coberturaCelular:
        return 'Comunicaciones';
      case POIType.gasolinera:
      case POIType.banco:
        return 'Comercial';
      case POIType.otro:
        return 'General';
    }
  }

  Color get color {
    switch (this) {
      case POIType.accidenteTransito:
        return const Color(0xFFFF5252);
      case POIType.incidenciaFerroviaria:
        return const Color(0xFFFF9800);
      case POIType.agenciaMinisterioPublico:
        return const Color(0xFF9C27B0);
      case POIType.guardiaNacional:
        return const Color(0xFF4CAF50);
      case POIType.caseta:
        return const Color(0xFF795548);
      case POIType.corralon:
        return const Color(0xFF757575);
      case POIType.paradero:
        return const Color(0xFF2196F3);
      case POIType.pension:
        return const Color(0xFF009688);
      case POIType.coberturaCelular:
        return const Color(0xFF00BCD4);
      case POIType.hospital:
        return const Color(0xFFD32F2F);
      case POIType.gasolinera:
        return const Color(0xFFFFC107);
      case POIType.banco:
        return const Color(0xFF3F51B5);
      case POIType.policia:
        return const Color(0xFF1565C0);
      case POIType.otro:
        return const Color(0xFF616161);
    }
  }
}

extension POIStatusExtension on POIStatus {
  String get label {
    switch (this) {
      case POIStatus.activo:
        return 'Activo';
      case POIStatus.inactivo:
        return 'Inactivo';
      case POIStatus.mantenimiento:
        return 'En Mantenimiento';
      case POIStatus.cerrado:
        return 'Cerrado';
    }
  }
}