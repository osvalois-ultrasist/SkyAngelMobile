import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/header_bar.dart';
import '../../domain/entities/alert_entity.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_card.dart';

class AlertDetailPage extends ConsumerWidget {
  final int alertId;

  const AlertDetailPage({
    super.key,
    required this.alertId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(alertByIdProvider(alertId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: HeaderBarFactory.alerts(
        subtitle: 'Detalle de Alerta #$alertId',
        actions: [
          HeaderActions.refresh(() {
            ref.read(alertNotifierProvider.notifier).loadActiveAlerts();
          }),
          HeaderActions.more(() {
            _showMoreOptions(context, ref, alert);
          }),
        ],
      ),
      body: alert == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Alerta no encontrada',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La alerta #$alertId no existe o ya no está disponible',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/sky/home'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver a Alertas'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert Card
                  AlertCard(
                    alert: alert,
                    onTap: null, // Disable tap since we're already in detail
                    showFullContent: true,
                    onStatusChanged: (newStatus) {
                      ref
                          .read(alertNotifierProvider.notifier)
                          .updateAlertStatus(alert.id, newStatus);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Additional Details Section
                  _buildDetailsSection(context, alert),
                  
                  const SizedBox(height: 24),
                  
                  // Location Section
                  _buildLocationSection(context, alert),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(context, ref, alert),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, AlertEntity alert) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles Adicionales',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow('ID', '#${alert.id}'),
            _buildDetailRow('Tipo', alert.tipo.name.toUpperCase()),
            _buildDetailRow('Prioridad', alert.prioridad.name.toUpperCase()),
            _buildDetailRow('Estado', alert.estado.name.toUpperCase()),
            _buildDetailRow('Fecha', _formatDate(alert.fecha)),
            
            if (alert.comentario.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Comentario',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                alert.comentario,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, AlertEntity alert) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lat: ${alert.coordenadas.lat.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Lng: ${alert.coordenadas.lng.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Open map with location
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de mapa en desarrollo'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('Ver en Mapa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, AlertEntity alert) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Share alert functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de compartir en desarrollo'),
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('Compartir'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Report alert functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de reporte en desarrollo'),
                    ),
                  );
                },
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Reportar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/sky/home'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver a Alertas'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, AlertEntity? alert) {
    if (alert == null) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar Estado'),
              onTap: () {
                Navigator.pop(context);
                _showStatusUpdateDialog(context, ref, alert);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: const Text('Eliminar Alerta'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, alert);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: const Text('Información Adicional'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show additional info
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, WidgetRef ref, AlertEntity alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Estado'),
        content: const Text('¿Deseas marcar esta alerta como resuelta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(alertNotifierProvider.notifier)
                  .updateAlertStatus(alert.id, AlertStatus.resuelta);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estado de alerta actualizado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Marcar Resuelta'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, AlertEntity alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Alerta'),
        content: const Text('Esta acción no se puede deshacer. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de eliminación en desarrollo'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}