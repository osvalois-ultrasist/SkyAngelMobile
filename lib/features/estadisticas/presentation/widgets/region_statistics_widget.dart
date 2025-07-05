import 'package:flutter/material.dart';

import '../../domain/entities/statistics_entity.dart';

class RegionStatisticsWidget extends StatelessWidget {
  final List<RegionStatistics> regions;

  const RegionStatisticsWidget({
    super.key,
    required this.regions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas por Región',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (regions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No hay datos de regiones disponibles',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: regions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final region = regions[index];
                  return _RegionCard(region: region);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  final RegionStatistics region;

  const _RegionCard({required this.region});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final securityColor = _getSecurityLevelColor(region.securityLevel);

    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: securityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.location_city,
          color: securityColor,
          size: 20,
        ),
      ),
      title: Text(
        region.regionName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${region.incidentCount} incidentes - ${region.securityLevel.label}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: securityColor,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Risk score indicator
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puntuación de Riesgo',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: region.riskScore / 10.0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(securityColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${region.riskScore.toStringAsFixed(1)}/10.0',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: securityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Region info
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.groups,
                      label: 'Población',
                      value: _formatNumber(region.population),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.area_chart,
                      label: 'Área',
                      value: '${region.areaKm2.toStringAsFixed(1)} km²',
                    ),
                  ),
                ],
              ),
              
              if (region.crimeBreakdown.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Tipos de Crimen Principales',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...region.crimeBreakdown.take(3).map((crime) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        crime.type.label,
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${crime.count} (${crime.percentage.toStringAsFixed(1)}%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ],
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}