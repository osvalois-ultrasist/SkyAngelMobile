import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/statistics_entity.dart';

class CrimeStatisticsChart extends StatelessWidget {
  final List<CrimeStatistics> crimeStats;

  const CrimeStatisticsChart({
    super.key,
    required this.crimeStats,
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
              'Estadísticas de Crimen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: crimeStats.isEmpty
                  ? const Center(child: Text('No hay datos disponibles'))
                  : PieChart(
                      PieChartData(
                        sections: _buildPieSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = crimeStats.fold<int>(0, (sum, stat) => sum + stat.totalCount);
    
    return crimeStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final percentage = (stat.totalCount / total) * 100;
      
      return PieChartSectionData(
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getCrimeTypeColor(stat.crimeType),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: crimeStats.map((stat) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getCrimeTypeColor(stat.crimeType),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${stat.crimeType.label} (${stat.totalCount})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getCrimeTypeColor(CrimeType type) {
    switch (type) {
      case CrimeType.theft:
        return Colors.blue;
      case CrimeType.assault:
        return Colors.red;
      case CrimeType.robbery:
        return Colors.orange;
      case CrimeType.kidnapping:
        return Colors.purple;
      case CrimeType.homicide:
        return Colors.red[900]!;
      case CrimeType.fraud:
        return Colors.yellow[700]!;
      case CrimeType.vandalism:
        return Colors.brown;
      case CrimeType.drugRelated:
        return Colors.green[700]!;
      case CrimeType.domesticViolence:
        return Colors.pink;
      case CrimeType.other:
        return Colors.grey;
    }
  }
}