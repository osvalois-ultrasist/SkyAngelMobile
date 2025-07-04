import 'package:flutter/material.dart';

import '../../domain/entities/alert_entity.dart';

class AlertCard extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback? onTap;
  final Function(AlertStatus)? onStatusChanged;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(alert.prioridad);
    final typeIcon = _getTypeIcon(alert.tipo);
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with priority and time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: priorityColor, width: 1),
                    ),
                    child: Text(
                      alert.prioridad.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    alert.formattedTimeElapsed,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Alert type and incident
              Row(
                children: [
                  Icon(
                    typeIcon,
                    size: 24,
                    color: priorityColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.tipo.name.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          alert.incidencia,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Comment if available
              if (alert.comentario.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  alert.comentario,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Status and actions
              Row(
                children: [
                  _buildStatusChip(context, alert.estado),
                  const Spacer(),
                  if (onStatusChanged != null && alert.isActive)
                    PopupMenuButton<AlertStatus>(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSelected: onStatusChanged,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: AlertStatus.resuelta,
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Marcar como resuelta'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: AlertStatus.falsa,
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Marcar como falsa alarma'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, AlertStatus status) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case AlertStatus.activa:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        icon = Icons.warning;
        break;
      case AlertStatus.resuelta:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case AlertStatus.falsa:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.name.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.baja:
        return Colors.green;
      case AlertPriority.media:
        return Colors.orange;
      case AlertPriority.alta:
        return Colors.red;
      case AlertPriority.critica:
        return Colors.red.shade900;
    }
  }

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.robo:
        return Icons.security;
      case AlertType.accidente:
        return Icons.car_crash;
      case AlertType.violencia:
        return Icons.warning;
      case AlertType.emergencia:
        return Icons.local_hospital;
      case AlertType.otro:
        return Icons.info;
    }
  }
}
