import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/risk_level.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final List<RiskPolygon> riskPolygons;
  final List<POIEntity> pois;
  final void Function(LatLng)? onMapTap;
  final void Function(RiskPolygon)? onPolygonTap;
  final void Function(POIEntity)? onPOITap;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.center,
    this.riskPolygons = const [],
    this.pois = const [],
    this.onMapTap,
    this.onPolygonTap,
    this.onPOITap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
        minZoom: 8.0,
        maxZoom: 18.0,
        onTap: (tapPosition, point) => onMapTap?.call(point),
      ),
      children: [
        // Base tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.skyangel.mobile',
          maxZoom: 18,
        ),
        
        // Risk polygons layer
        if (riskPolygons.isNotEmpty)
          PolygonLayer(
            polygons: riskPolygons.map((riskPolygon) => Polygon(
              points: riskPolygon.coordinates,
              color: riskPolygon.riskLevel.color.withOpacity(0.3),
              borderColor: riskPolygon.riskLevel.color,
              borderStrokeWidth: 2.0,
              isFilled: true,
            )).toList(),
          ),
        
        // POI markers layer
        if (pois.isNotEmpty)
          MarkerLayer(
            markers: pois.map((poi) => Marker(
              point: poi.coordinates,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => onPOITap?.call(poi),
                child: Container(
                  decoration: BoxDecoration(
                    color: POITypeMapExtension(poi.type).color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    poi.type.iconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            )).toList(),
          ),
        
        // Current location marker
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 60,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Extension to add helper methods for POI types
extension POITypeMapExtension on POIType {
  IconData get iconData {
    switch (this) {
      case POIType.accidenteTransito:
        return Icons.car_crash;
      case POIType.incidenciaFerroviaria:
        return Icons.train;
      case POIType.agenciaMinisterioPublico:
        return Icons.account_balance;
      case POIType.guardiaNacional:
        return Icons.shield;
      case POIType.caseta:
        return Icons.toll;
      case POIType.corralon:
        return Icons.local_parking;
      case POIType.paradero:
        return Icons.directions_bus;
      case POIType.pension:
        return Icons.hotel;
      case POIType.coberturaCelular:
        return Icons.cell_tower;
      case POIType.hospital:
        return Icons.local_hospital;
      case POIType.gasolinera:
        return Icons.local_gas_station;
      case POIType.banco:
        return Icons.account_balance_wallet;
      case POIType.policia:
        return Icons.local_police;
      case POIType.otro:
        return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case POIType.accidenteTransito:
        return Colors.red;
      case POIType.incidenciaFerroviaria:
        return Colors.orange;
      case POIType.agenciaMinisterioPublico:
        return Colors.purple;
      case POIType.guardiaNacional:
        return Colors.green;
      case POIType.caseta:
        return Colors.brown;
      case POIType.corralon:
        return Colors.grey;
      case POIType.paradero:
        return Colors.blue;
      case POIType.pension:
        return Colors.teal;
      case POIType.coberturaCelular:
        return Colors.cyan;
      case POIType.hospital:
        return Colors.red[700]!;
      case POIType.gasolinera:
        return Colors.amber;
      case POIType.banco:
        return Colors.indigo;
      case POIType.policia:
        return Colors.blue[800]!;
      case POIType.otro:
        return Colors.grey[600]!;
    }
  }

  String get label {
    switch (this) {
      case POIType.accidenteTransito:
        return 'Accidente de Tránsito';
      case POIType.incidenciaFerroviaria:
        return 'Incidencia Ferroviaria';
      case POIType.agenciaMinisterioPublico:
        return 'Agencia Ministerio Público';
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
}

// Extension for DataSource
extension DataSourceMapExtension on DataSource {
  String get label {
    switch (this) {
      case DataSource.secretariado:
        return 'Secretariado';
      case DataSource.anerpv:
        return 'ANERPV';
      case DataSource.skyangel:
        return 'SkyAngel';
    }
  }

  Color get color {
    switch (this) {
      case DataSource.secretariado:
        return Colors.blue;
      case DataSource.anerpv:
        return Colors.orange;
      case DataSource.skyangel:
        return Colors.green;
    }
  }
}

// Extension for CrimeType
extension CrimeTypeMapExtension on CrimeType {
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

  Color get color {
    switch (this) {
      case CrimeType.homicidio:
        return Colors.red[900]!;
      case CrimeType.robo:
        return Colors.orange[700]!;
      case CrimeType.violacion:
        return Colors.red[800]!;
      case CrimeType.secuestro:
        return Colors.red[700]!;
      case CrimeType.feminicidio:
        return Colors.purple[900]!;
      case CrimeType.extorsion:
        return Colors.purple[700]!;
      case CrimeType.accidente:
        return Colors.amber[700]!;
      case CrimeType.otro:
        return Colors.grey[600]!;
    }
  }
}