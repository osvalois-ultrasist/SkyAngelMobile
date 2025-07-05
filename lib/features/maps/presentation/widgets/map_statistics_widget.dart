import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/risk_level.dart';
import '../providers/maps_provider.dart';

class MapStatisticsWidget extends ConsumerWidget {
  const MapStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapsState = ref.watch(mapsNotifierProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: mapsState.when(
          initial: () => const SizedBox(
            height: 60,
            child: Center(child: Text('Cargando estadísticas...')),
          ),
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          ),
          loaded: (polygons, pois, _, __, ___) => Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.warning,
                  label: 'Zonas de Riesgo',
                  value: polygons.length.toString(),
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  icon: Icons.place,
                  label: 'Puntos de Interés',
                  value: pois.length.toString(),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  icon: Icons.shield,
                  label: 'Alto Riesgo',
                  value: polygons.where((p) => p.riskLevel.priority >= 3).length.toString(),
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          error: (_, __) => SizedBox(
            height: 60,
            child: Center(
              child: Text(
                'Error al cargar estadísticas',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}