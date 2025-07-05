import 'package:flutter/material.dart';

import '../../domain/entities/statistics_entity.dart';

class RecommendationsWidget extends StatelessWidget {
  final List<SafetyRecommendation> recommendations;

  const RecommendationsWidget({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recomendaciones de Seguridad',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recommendations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, size: 48, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'No hay recomendaciones pendientes',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tu actividad actual es segura',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index];
                  return _RecommendationCard(recommendation: recommendation);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final SafetyRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(recommendation.priority);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: priorityColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: priorityColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPriorityLabel(recommendation.priority),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.type.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (recommendation.isPersonalized == true)
                Icon(
                  Icons.person,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: theme.textTheme.bodyMedium,
          ),
          if (recommendation.actionItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Acciones sugeridas:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...recommendation.actionItems.map((action) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(action, style: theme.textTheme.bodySmall)),
                ],
              ),
            )),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Válido hasta: ${_formatDate(recommendation.validUntil)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _dismissRecommendation(context),
                    child: const Text('Omitir'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _acceptRecommendation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: priorityColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.low:
        return Colors.blue;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.urgent:
        return Colors.red[900]!;
    }
  }

  String _getPriorityLabel(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.low:
        return 'BAJA';
      case RecommendationPriority.medium:
        return 'MEDIA';
      case RecommendationPriority.high:
        return 'ALTA';
      case RecommendationPriority.urgent:
        return 'URGENTE';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _dismissRecommendation(BuildContext context) {
    // TODO: Implement dismiss functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recomendación omitida'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _acceptRecommendation(BuildContext context) {
    // TODO: Implement accept functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recomendación aplicada'),
        backgroundColor: Colors.green,
      ),
    );
  }
}