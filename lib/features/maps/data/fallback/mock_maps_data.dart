import 'package:latlong2/latlong.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/risk_level.dart';

/// Datos mock de fallback para el módulo de mapas
/// Se usa cuando las APIs no están disponibles
class MockMapsData {
  
  /// POIs mock por tipo para usar como fallback
  static Map<String, List<POIEntity>> getMockPOIsByType() {
    return {
      'hospital': [
        POIEntity(
          id: 'mock_hospital_1',
          name: 'Hospital General',
          description: 'Hospital público de atención general',
          type: POIType.hospital,
          coordinates: const LatLng(19.4326, -99.1332), // CDMX
          address: 'Av. Principal 123, Centro',
          status: POIStatus.activo,
          rating: 4.2,
          tags: ['salud', 'emergencias', 'público'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        POIEntity(
          id: 'mock_hospital_2',
          name: 'Hospital Cruz Roja',
          description: 'Hospital de la Cruz Roja Mexicana',
          type: POIType.hospital,
          coordinates: const LatLng(19.4200, -99.1300),
          address: 'Calle Reforma 456',
          status: POIStatus.activo,
          rating: 4.5,
          tags: ['salud', 'emergencias', 'cruz roja'],
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now(),
        ),
      ],
      'policia': [
        POIEntity(
          id: 'mock_policia_1',
          name: 'Estación de Policía Centro',
          description: 'Estación de policía del centro histórico',
          type: POIType.policia,
          coordinates: const LatLng(19.4350, -99.1300),
          address: 'Plaza de la Constitución',
          status: POIStatus.activo,
          rating: 3.8,
          tags: ['seguridad', 'policía', 'emergencias'],
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now(),
        ),
      ],
      'gasolinera': [
        POIEntity(
          id: 'mock_gas_1',
          name: 'Gasolinera PEMEX',
          description: 'Estación de servicio PEMEX',
          type: POIType.gasolinera,
          coordinates: const LatLng(19.4400, -99.1400),
          address: 'Av. Insurgentes 789',
          status: POIStatus.activo,
          rating: 4.0,
          tags: ['combustible', 'pemex', 'servicio'],
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
        ),
      ],
      'banco': [
        POIEntity(
          id: 'mock_bank_1',
          name: 'Banco Nacional',
          description: 'Sucursal bancaria con cajeros automáticos',
          type: POIType.banco,
          coordinates: const LatLng(19.4250, -99.1280),
          address: 'Av. Juárez 321',
          status: POIStatus.activo,
          rating: 3.9,
          tags: ['banco', 'cajero', 'servicios financieros'],
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
        ),
      ],
      'otro': [
        POIEntity(
          id: 'mock_other_1',
          name: 'Centro Comercial',
          description: 'Centro comercial con múltiples tiendas',
          type: POIType.otro,
          coordinates: const LatLng(19.4100, -99.1200),
          address: 'Zona Rosa',
          status: POIStatus.activo,
          rating: 4.3,
          tags: ['comercio', 'tiendas', 'entretenimiento'],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
      ],
    };
  }

  /// Polígonos de riesgo mock para usar como fallback
  static List<RiskPolygon> getMockRiskPolygons() {
    return [
      RiskPolygon(
        id: 'mock_risk_1',
        coordinates: [
          const LatLng(19.4300, -99.1350),
          const LatLng(19.4320, -99.1350),
          const LatLng(19.4320, -99.1300),
          const LatLng(19.4300, -99.1300),
          const LatLng(19.4300, -99.1350),
        ],
        riskLevel: RiskLevelType.moderate,
        riskValue: 0.6,
        crimeTypes: [CrimeType.robo],
        dataSource: DataSource.skyangel,
        incidentCount: 25,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {
          'population_density': 'high',
          'lighting_quality': 'medium',
          'police_presence': 'medium',
        },
      ),
      RiskPolygon(
        id: 'mock_risk_2',
        coordinates: [
          const LatLng(19.4400, -99.1400),
          const LatLng(19.4450, -99.1400),
          const LatLng(19.4450, -99.1350),
          const LatLng(19.4400, -99.1350),
          const LatLng(19.4400, -99.1400),
        ],
        riskLevel: RiskLevelType.high,
        riskValue: 0.8,
        crimeTypes: [CrimeType.robo, CrimeType.homicidio],
        dataSource: DataSource.skyangel,
        incidentCount: 45,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
        metadata: {
          'population_density': 'very_high',
          'lighting_quality': 'low',
          'police_presence': 'low',
        },
      ),
      RiskPolygon(
        id: 'mock_risk_3',
        coordinates: [
          const LatLng(19.4100, -99.1250),
          const LatLng(19.4150, -99.1250),
          const LatLng(19.4150, -99.1200),
          const LatLng(19.4100, -99.1200),
          const LatLng(19.4100, -99.1250),
        ],
        riskLevel: RiskLevelType.low,
        riskValue: 0.3,
        crimeTypes: [CrimeType.accidente],
        dataSource: DataSource.skyangel,
        incidentCount: 8,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 3)),
        metadata: {
          'population_density': 'medium',
          'lighting_quality': 'high',
          'police_presence': 'high',
        },
      ),
    ];
  }

  /// Obtiene POIs mock por tipo específico
  static List<POIEntity> getMockPOIsBySpecificType(String typeString) {
    final allMockPOIs = getMockPOIsByType();
    return allMockPOIs[typeString] ?? [];
  }

  /// Verifica si un tipo de POI tiene datos mock disponibles
  static bool hasMockDataForType(String typeString) {
    final allMockPOIs = getMockPOIsByType();
    return allMockPOIs.containsKey(typeString) && 
           allMockPOIs[typeString]!.isNotEmpty;
  }

  /// Obtiene una respuesta mock similar a la API real
  static Map<String, dynamic> getMockAPIResponse(String endpoint) {
    if (endpoint.contains('/puntos-interes/')) {
      final type = endpoint.split('/').last;
      final pois = getMockPOIsBySpecificType(type);
      
      return {
        'type': 'FeatureCollection',
        'features': pois.map((poi) => _poiToGeoJSON(poi)).toList(),
        'metadata': {
          'total': pois.length,
          'source': 'SkyAngel Mock Data',
          'generated_at': DateTime.now().toIso8601String(),
        }
      };
    }
    
    if (endpoint.contains('/maps/get-poligono')) {
      final polygons = getMockRiskPolygons();
      
      return {
        'type': 'FeatureCollection',
        'features': polygons.map((polygon) => _polygonToGeoJSON(polygon)).toList(),
        'metadata': {
          'total': polygons.length,
          'source': 'SkyAngel Mock Data',
          'generated_at': DateTime.now().toIso8601String(),
        }
      };
    }
    
    return {
      'error': 'Mock endpoint not implemented',
      'available_endpoints': [
        '/puntos-interes/{type}',
        '/maps/get-poligono'
      ]
    };
  }

  static Map<String, dynamic> _poiToGeoJSON(POIEntity poi) {
    return {
      'type': 'Feature',
      'id': poi.id,
      'geometry': {
        'type': 'Point',
        'coordinates': [poi.coordinates.longitude, poi.coordinates.latitude],
      },
      'properties': {
        'name': poi.name,
        'description': poi.description,
        'type': poi.type.name,
        'address': poi.address,
        'status': poi.status.name,
        'rating': poi.rating,
        'tags': poi.tags,
        'created_at': poi.createdAt.toIso8601String(),
        'updated_at': poi.updatedAt?.toIso8601String(),
      },
    };
  }

  static Map<String, dynamic> _polygonToGeoJSON(RiskPolygon polygon) {
    return {
      'type': 'Feature',
      'id': polygon.id,
      'geometry': {
        'type': 'Polygon',
        'coordinates': [
          polygon.coordinates.map((coord) => [coord.longitude, coord.latitude]).toList()
        ],
      },
      'properties': {
        'name': 'Risk Polygon ${polygon.id}',
        'description': 'Risk polygon with ${polygon.incidentCount} incidents',
        'risk_level': polygon.riskLevel.name,
        'risk_score': polygon.riskValue,
        'crime_types': polygon.crimeTypes,
        'data_source': polygon.dataSource,
        'incident_count': polygon.incidentCount,
        'last_update': polygon.lastUpdate.toIso8601String(),
        'metadata': polygon.metadata,
      },
    };
  }
}