import 'package:flutter/material.dart';
import '../../domain/entities/route_entity.dart';

class RouteListWidget extends StatelessWidget {
  final List<RouteEntity> routes;
  final Function(RouteEntity) onRouteSelected;
  final Function(RouteEntity)? onRouteSaved;
  final Function(RouteEntity)? onRouteDeleted;
  final bool showSaveButton;

  const RouteListWidget({
    super.key,
    required this.routes,
    required this.onRouteSelected,
    this.onRouteSaved,
    this.onRouteDeleted,
    this.showSaveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return _RouteCard(
          route: route,
          onTap: () => onRouteSelected(route),
          onSave: showSaveButton ? () => onRouteSaved?.call(route) : null,
          onDelete: onRouteDeleted != null ? () => onRouteDeleted!(route) : null,
        );
      },
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteEntity route;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;

  const _RouteCard({
    required this.route,
    required this.onTap,
    this.onSave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with route type and safety level
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getRouteTypeColor(route.routeType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getRouteTypeIcon(route.routeType),
                      color: _getRouteTypeColor(route.routeType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name ?? route.routeType.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${route.distanceKm.toStringAsFixed(1)} km • ${route.estimatedDurationMinutes} min',
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
                      color: _getSafetyColor(route.safetyAnalysis.riskLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      route.safetyAnalysis.riskLevel.label,
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
              
              // Route details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.security,
                      label: 'Seguridad',
                      value: '${(route.safetyAnalysis.overallRiskScore * 10).toInt()}/10',
                      color: _getSafetyScoreColor(route.safetyAnalysis.overallRiskScore),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.warning_amber,
                      label: 'Alertas',
                      value: '${route.safetyAnalysis.currentAlerts.length}',
                      color: route.safetyAnalysis.currentAlerts.isEmpty 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.route,
                      label: 'Tipo',
                      value: _getShortRouteTypeLabel(route.routeType),
                      color: _getRouteTypeColor(route.routeType),
                    ),
                  ),
                ],
              ),
              
              // Recommendations (if any)
              if (route.safetyAnalysis.recommendations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          route.safetyAnalysis.recommendations.first,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action buttons
              if (onSave != null || onDelete != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar ruta',
                        color: Colors.red[400],
                      ),
                    if (onSave != null)
                      IconButton(
                        onPressed: onSave,
                        icon: const Icon(Icons.bookmark_border),
                        tooltip: 'Guardar ruta',
                        color: theme.colorScheme.primary,
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.navigation, size: 16),
                      label: const Text('Ver detalles'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
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

  String _getShortRouteTypeLabel(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return 'Rápida';
      case RouteType.shortest:
        return 'Corta';
      case RouteType.safest:
        return 'Segura';
      case RouteType.mostEconomical:
        return 'Económica';
      case RouteType.balanced:
        return 'Balanceada';
      case RouteType.custom:
        return 'Personal';
    }
  }
}