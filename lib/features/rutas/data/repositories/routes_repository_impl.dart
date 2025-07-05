import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/routes_repository.dart';

@LazySingleton(as: RoutesRepository)
class RoutesRepositoryImpl implements RoutesRepository {
  @override
  Future<List<RouteEntity>> calculateRoute({
    required LatLng start,
    required LatLng end,
    RouteType routeType = RouteType.fastest,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      RouteEntity(
        id: 'route_1',
        name: 'Ruta Principal',
        startLocation: start,
        endLocation: end,
        routeType: routeType,
        waypoints: [start, end],
        distanceKm: 15.5,
        estimatedTimeMinutes: 25,
        safetyScore: 85.0,
        riskLevel: 'low',
        description: 'Ruta por avenidas principales',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<RouteEntity>> calculateSafeRoute({
    required LatLng start,
    required LatLng end,
    DateTime? departureTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return [
      RouteEntity(
        id: 'safe_route_1',
        name: 'Ruta Segura',
        startLocation: start,
        endLocation: end,
        routeType: RouteType.safest,
        waypoints: [start, end],
        distanceKm: 18.2,
        estimatedTimeMinutes: 32,
        safetyScore: 95.0,
        riskLevel: 'very_low',
        description: 'Ruta optimizada para seguridad',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<RouteEntity>> getSavedRoutes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      RouteEntity(
        id: 'saved_1',
        name: 'Casa - Trabajo',
        startLocation: const LatLng(19.4326, -99.1332),
        endLocation: const LatLng(19.4420, -99.1281),
        routeType: RouteType.fastest,
        waypoints: [
          const LatLng(19.4326, -99.1332),
          const LatLng(19.4420, -99.1281),
        ],
        distanceKm: 12.8,
        estimatedTimeMinutes: 22,
        safetyScore: 78.5,
        riskLevel: 'medium',
        description: 'Ruta diaria al trabajo',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<void> saveRoute(RouteEntity route) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock save implementation
  }

  @override
  Future<void> deleteRoute(String routeId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Mock delete implementation
  }

  @override
  Future<List<RouteEntity>> compareRoutes({
    required LatLng start,
    required LatLng end,
    DateTime? departureTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    return [
      RouteEntity(
        id: 'compare_fast',
        name: 'Ruta Rápida',
        startLocation: start,
        endLocation: end,
        routeType: RouteType.fastest,
        waypoints: [start, end],
        distanceKm: 14.2,
        estimatedTimeMinutes: 20,
        safetyScore: 65.0,
        riskLevel: 'medium',
        description: 'Ruta más rápida disponible',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RouteEntity(
        id: 'compare_safe',
        name: 'Ruta Segura',
        startLocation: start,
        endLocation: end,
        routeType: RouteType.safest,
        waypoints: [start, end],
        distanceKm: 18.7,
        estimatedTimeMinutes: 30,
        safetyScore: 92.0,
        riskLevel: 'low',
        description: 'Ruta más segura disponible',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getSafeRouteRecommendations({
    required LatLng start,
    required LatLng end,
    DateTime? departureTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      {
        'type': 'avoid_area',
        'title': 'Evitar zona centro',
        'description': 'Alta incidencia de robos después de las 20:00',
        'priority': 'high',
        'area': {
          'center': {'lat': 19.4326, 'lng': -99.1332},
          'radius': 2000,
        },
      },
      {
        'type': 'preferred_route',
        'title': 'Usar avenidas principales',
        'description': 'Mejor iluminación y presencia policial',
        'priority': 'medium',
      },
      {
        'type': 'time_recommendation',
        'title': 'Horario recomendado',
        'description': 'Viajar entre 6:00 AM y 8:00 PM para mayor seguridad',
        'priority': 'low',
      },
    ];
  }
}