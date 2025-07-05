import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/unified_menu.dart';
import '../../../app/presentation/providers/navigation_provider.dart';
import '../../domain/entities/alert_entity.dart';
import '../providers/alert_provider.dart';
import '../providers/alert_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_filter_chip.dart';
import '../widgets/alert_statistics_widget.dart';
import '../widgets/create_alert_fab.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AlertType? _selectedType;
  AlertPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load alerts when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertNotifierProvider.notifier).loadActiveAlerts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertNotifierProvider);
    final highPriorityAlerts = ref.watch(highPriorityAlertsProvider);
    final recentAlerts = ref.watch(recentAlertsProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber,
                color: theme.colorScheme.onErrorContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Alertas de Seguridad'),
          ],
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(alertNotifierProvider.notifier).loadActiveAlerts();
              ref.read(alertStatisticsNotifierProvider.notifier).refresh();
            },
            tooltip: 'Actualizar alertas',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filtrar alertas',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Exportar datos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('Ayuda'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Todas', icon: Icon(Icons.list, size: 20)),
                    Tab(text: 'Prioritarias', icon: Icon(Icons.priority_high, size: 20)),
                    Tab(text: 'Recientes', icon: Icon(Icons.access_time, size: 20)),
                  ],
                ),
              ),
              if (_selectedType != null || _selectedPriority != null)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (_selectedType != null)
                        AlertFilterChip(
                          label: _selectedType!.name.toUpperCase(),
                          onDeleted: () => setState(() => _selectedType = null),
                        ),
                      if (_selectedType != null && _selectedPriority != null)
                        const SizedBox(width: 8),
                      if (_selectedPriority != null)
                        AlertFilterChip(
                          label: _selectedPriority!.name.toUpperCase(),
                          backgroundColor: theme.colorScheme.secondary,
                          onDeleted: () => setState(() => _selectedPriority = null),
                        ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedType = null;
                            _selectedPriority = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Limpiar'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Statistics Card
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: AlertStatisticsWidget(),
          ),
          
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllAlertsTab(alertState),
                _buildHighPriorityTab(highPriorityAlerts),
                _buildRecentAlertsTab(recentAlerts),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const CreateAlertFAB(),
    );
  }

  Widget _buildAllAlertsTab(AlertState alertState) {
    return alertState.when(
      initial: () => const Center(
        child: Text('Desliza hacia abajo para cargar alertas'),
      ),
      loading: () => const Center(child: LoadingWidget()),
      loaded: (alerts) {
        final filteredAlerts = _getFilteredAlerts(alerts);
        
        if (filteredAlerts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay alertas que mostrar',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(alertNotifierProvider.notifier).loadActiveAlerts();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredAlerts.length,
            itemBuilder: (context, index) {
              final alert = filteredAlerts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertCard(
                  alert: alert,
                  onTap: () => _navigateToAlertDetail(alert),
                  onStatusChanged: (newStatus) {
                    ref
                        .read(alertNotifierProvider.notifier)
                        .updateAlertStatus(alert.id, newStatus);
                  },
                ),
              );
            },
          ),
        );
      },
      error: (error, message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar alertas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(alertNotifierProvider.notifier).clearError();
                ref.read(alertNotifierProvider.notifier).loadActiveAlerts();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighPriorityTab(List<AlertEntity> highPriorityAlerts) {
    if (highPriorityAlerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No hay alertas de alta prioridad',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: highPriorityAlerts.length,
      itemBuilder: (context, index) {
        final alert = highPriorityAlerts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AlertCard(
            alert: alert,
            onTap: () => _navigateToAlertDetail(alert),
            onStatusChanged: (newStatus) {
              ref
                  .read(alertNotifierProvider.notifier)
                  .updateAlertStatus(alert.id, newStatus);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentAlertsTab(List<AlertEntity> recentAlerts) {
    if (recentAlerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay alertas recientes',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentAlerts.length,
      itemBuilder: (context, index) {
        final alert = recentAlerts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AlertCard(
            alert: alert,
            onTap: () => _navigateToAlertDetail(alert),
            onStatusChanged: (newStatus) {
              ref
                  .read(alertNotifierProvider.notifier)
                  .updateAlertStatus(alert.id, newStatus);
            },
          ),
        );
      },
    );
  }

  List<AlertEntity> _getFilteredAlerts(List<AlertEntity> alerts) {
    var filteredAlerts = alerts;
    
    if (_selectedType != null) {
      filteredAlerts = filteredAlerts.where((alert) => alert.tipo == _selectedType).toList();
    }
    
    if (_selectedPriority != null) {
      filteredAlerts = filteredAlerts.where((alert) => alert.prioridad == _selectedPriority).toList();
    }
    
    return filteredAlerts;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrar alertas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Filter by type
            Text(
              'Tipo de alerta',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AlertType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Filter by priority
            Text(
              'Prioridad',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AlertPriority.values.map((priority) {
                return ChoiceChip(
                  label: Text(priority.name.toUpperCase()),
                  selected: _selectedPriority == priority,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? priority : null;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToAlertDetail(AlertEntity alert) {
    context.push('/sky/alerts/${alert.id}');
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'export':
        _showExportDialog(context);
        break;
      case 'settings':
        _showSettingsDialog(context);
        break;
      case 'help':
        _showHelpDialog(context);
        break;
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download),
            SizedBox(width: 8),
            Text('Exportar datos'),
          ],
        ),
        content: const Text('¿Qué datos deseas exportar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToPDF();
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToExcel();
            },
            child: const Text('Excel'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Text('Configuración'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification settings
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Actualización automática'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement auto-refresh settings
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 8),
            Text('Ayuda'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cómo usar las alertas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Toca el botón + para crear una nueva alerta'),
              Text('• Usa los filtros para encontrar alertas específicas'),
              Text('• Desliza hacia abajo para actualizar'),
              Text('• Toca una alerta para ver más detalles'),
              SizedBox(height: 16),
              Text(
                'Tipos de alerta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Robo: Incidentes de seguridad'),
              Text('• Accidente: Accidentes de tráfico'),
              Text('• Violencia: Situaciones de violencia'),
              Text('• Emergencia: Emergencias médicas'),
              Text('• Otro: Otros incidentes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF() {
    // TODO: Implement PDF export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportación PDF en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _exportToExcel() {
    // TODO: Implement Excel export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportación Excel en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
