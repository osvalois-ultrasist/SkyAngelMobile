import 'package:flutter/material.dart';

import '../../domain/entities/statistics_entity.dart';

class SecurityOverviewCard extends StatelessWidget {
  final SecurityOverview overview;

  const SecurityOverviewCard({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
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
                    color: _getSecurityLevelColor(overview.currentSecurityLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.security,
                    color: _getSecurityLevelColor(overview.currentSecurityLevel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de Seguridad',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nivel actual: ${overview.currentSecurityLevel.label}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getSecurityLevelColor(overview.currentSecurityLevel),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Statistics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _StatisticItem(
                  icon: Icons.warning,
                  label: 'Incidentes Totales',
                  value: overview.totalIncidents.toString(),
                  color: Colors.orange,
                ),
                _StatisticItem(
                  icon: Icons.notifications_active,
                  label: 'Alertas Activas',
                  value: overview.activeAlerts.toString(),
                  color: Colors.red,
                ),
                _StatisticItem(
                  icon: Icons.shield_outlined,
                  label: 'Rutas Seguras',
                  value: overview.safeRoutes.toString(),
                  color: Colors.green,
                ),
                _StatisticItem(
                  icon: Icons.dangerous,
                  label: 'Áreas de Riesgo',
                  value: overview.riskAreas.toString(),
                  color: Colors.red[700]!,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Risk score
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Puntuación de Riesgo Promedio',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: overview.avgRiskScore / 10.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRiskScoreColor(overview.avgRiskScore),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${overview.avgRiskScore.toStringAsFixed(1)}/10.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getRiskScoreColor(overview.avgRiskScore),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Improvement indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: overview.improvementPercentage >= 0 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: overview.improvementPercentage >= 0 
                      ? Colors.green 
                      : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    overview.improvementPercentage >= 0 
                        ? Icons.trending_up 
                        : Icons.trending_down,
                    color: overview.improvementPercentage >= 0 
                        ? Colors.green 
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${overview.improvementPercentage >= 0 ? '+' : ''}${overview.improvementPercentage.toStringAsFixed(1)}% ${overview.improvementPeriod}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: overview.improvementPercentage >= 0 
                                ? Colors.green 
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          overview.improvementPercentage >= 0 
                              ? 'Mejora en la seguridad general'
                              : 'Deterioro en la seguridad general',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSecurityLevelColor(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.veryLow:
      case SecurityLevel.low:
        return Colors.green;
      case SecurityLevel.moderate:
        return Colors.orange;
      case SecurityLevel.high:
      case SecurityLevel.veryHigh:
        return Colors.red;
      case SecurityLevel.critical:
        return Colors.red[900]!;
    }
  }

  Color _getRiskScoreColor(double score) {
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}