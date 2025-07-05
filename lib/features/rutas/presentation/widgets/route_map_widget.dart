import 'package:flutter/material.dart';
import '../../domain/entities/route_entity.dart';

class RouteMapWidget extends StatefulWidget {
  final List<RouteEntity> routes;
  final RouteType selectedRouteType;
  final Function(RouteEntity) onRouteSelected;

  const RouteMapWidget({
    super.key,
    required this.routes,
    required this.selectedRouteType,
    required this.onRouteSelected,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  RouteEntity? _selectedRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Map placeholder (would be flutter_map in real implementation)
        Container(
          color: Colors.grey[100],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Mapa de Rutas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aquí se mostrará el mapa interactivo\ncon las rutas calculadas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Route selection overlay
        if (widget.routes.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rutas encontradas (${widget.routes.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.routes.length,
                        itemBuilder: (context, index) {
                          final route = widget.routes[index];
                          final isSelected = _selectedRoute?.id == route.id;
                          
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(
                                route.routeType.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected 
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              avatar: Icon(
                                _getRouteTypeIcon(route.routeType),
                                size: 16,
                                color: isSelected 
                                    ? theme.colorScheme.onPrimary
                                    : _getRouteTypeColor(route.routeType),
                              ),
                              backgroundColor: Colors.white,
                              selectedColor: theme.colorScheme.primary,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRoute = selected ? route : null;
                                });
                                if (selected) {
                                  widget.onRouteSelected(route);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Selected route info
        if (_selectedRoute != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getRouteTypeColor(_selectedRoute!.routeType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getRouteTypeIcon(_selectedRoute!.routeType),
                            color: _getRouteTypeColor(_selectedRoute!.routeType),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedRoute!.routeType.label,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_selectedRoute!.distanceKm.toStringAsFixed(1)} km • ${_selectedRoute!.estimatedDurationMinutes} min',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSafetyColor(_selectedRoute!.safetyAnalysis.riskLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedRoute!.safetyAnalysis.riskLevel.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.security,
                            label: 'Seguridad',
                            value: '${(_selectedRoute!.safetyAnalysis.overallRiskScore * 10).toInt()}/10',
                            color: _getSafetyScoreColor(_selectedRoute!.safetyAnalysis.overallRiskScore),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.warning,
                            label: 'Alertas',
                            value: '${_selectedRoute!.safetyAnalysis.currentAlerts.length}',
                            color: _selectedRoute!.safetyAnalysis.currentAlerts.isEmpty 
                                ? Colors.green 
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onRouteSelected(_selectedRoute!),
                            icon: const Icon(Icons.navigation, size: 16),
                            label: const Text('Ir'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRouteTypeIcon(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return Icons.speed;
      case RouteType.shortest:
        return Icons.straighten;
      case RouteType.safest:
        return Icons.security;
      case RouteType.mostEconomical:
        return Icons.savings;
      case RouteType.balanced:
        return Icons.balance;
      case RouteType.custom:
        return Icons.tune;
    }
  }

  Color _getRouteTypeColor(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return Colors.blue;
      case RouteType.shortest:
        return Colors.green;
      case RouteType.safest:
        return Colors.purple;
      case RouteType.mostEconomical:
        return Colors.orange;
      case RouteType.balanced:
        return Colors.teal;
      case RouteType.custom:
        return Colors.grey;
    }
  }

  Color _getSafetyColor(RouteRiskLevel level) {
    switch (level) {
      case RouteRiskLevel.veryLow:
      case RouteRiskLevel.low:
        return Colors.green;
      case RouteRiskLevel.moderate:
        return Colors.orange;
      case RouteRiskLevel.high:
      case RouteRiskLevel.veryHigh:
      case RouteRiskLevel.extreme:
        return Colors.red;
    }
  }

  Color _getSafetyScoreColor(double score) {
    if (score <= 0.3) return Colors.green;
    if (score <= 0.6) return Colors.orange;
    return Colors.red;
  }
}