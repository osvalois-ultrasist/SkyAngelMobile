import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/unified_menu.dart';
import '../../../app/presentation/providers/navigation_provider.dart';
import '../../domain/entities/statistics_entity.dart';
import '../providers/statistics_provider.dart';
import '../widgets/security_overview_card.dart';
import '../widgets/crime_statistics_chart.dart';
import '../widgets/trend_chart_widget.dart';
import '../widgets/recommendations_widget.dart';
import '../widgets/region_statistics_widget.dart';
import '../widgets/user_activity_widget.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  StatisticsPeriod _selectedPeriod = StatisticsPeriod.monthly;
  bool _showUserData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load dashboard data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStatisticsNotifierProvider.notifier).loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStatisticsNotifierProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.dashboard,
                color: theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Dashboard de Seguridad'),
          ],
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        actions: [
          PopupMenuButton<StatisticsPeriod>(
            icon: const Icon(Icons.date_range),
            tooltip: 'Período de tiempo',
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _refreshData();
            },
            itemBuilder: (context) => StatisticsPeriod.values.map((period) =>
              PopupMenuItem(
                value: period,
                child: Row(
                  children: [
                    Icon(
                      _selectedPeriod == period ? Icons.check : Icons.calendar_today,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(period.label),
                  ],
                ),
              ),
            ).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Actualizar datos',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_user_data',
                child: Row(
                  children: [
                    Icon(_showUserData ? Icons.person_off : Icons.person),
                    const SizedBox(width: 8),
                    Text(_showUserData ? 'Ocultar datos personales' : 'Mostrar datos personales'),
                  ],
                ),
              ),
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
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Resumen', icon: Icon(Icons.dashboard, size: 16)),
                Tab(text: 'Tendencias', icon: Icon(Icons.trending_up, size: 16)),
                Tab(text: 'Regiones', icon: Icon(Icons.map, size: 16)),
                Tab(text: 'Actividad', icon: Icon(Icons.person, size: 16)),
              ],
            ),
          ),
        ),
      ),
      body: dashboardState.when(
        initial: () => const Center(
          child: Text('Cargando dashboard...'),
        ),
        loading: () => const Center(child: LoadingWidget()),
        loaded: (dashboard) => Column(
          children: [
            // Quick stats header
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildQuickStats(dashboard.securityOverview, theme),
            ),
            
            // Main content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(dashboard),
                  _buildTrendsTab(dashboard),
                  _buildRegionsTab(dashboard),
                  _buildActivityTab(dashboard),
                ],
              ),
            ),
          ],
        ),
        error: (error, message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar dashboard',
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
                  ref.read(dashboardStatisticsNotifierProvider.notifier).clearError();
                  _refreshData();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(SecurityOverview overview, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _QuickStatItem(
                icon: Icons.shield,
                label: 'Nivel de Seguridad',
                value: overview.currentSecurityLevel.label,
                color: _getSecurityLevelColor(overview.currentSecurityLevel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickStatItem(
                icon: Icons.warning,
                label: 'Alertas Activas',
                value: overview.activeAlerts.toString(),
                color: overview.activeAlerts > 10 ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickStatItem(
                icon: Icons.trending_up,
                label: 'Mejora',
                value: '${overview.improvementPercentage.toStringAsFixed(1)}%',
                color: overview.improvementPercentage >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(DashboardStatistics dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SecurityOverviewCard(overview: dashboard.securityOverview),
          const SizedBox(height: 16),
          CrimeStatisticsChart(crimeStats: dashboard.crimeStats),
          const SizedBox(height: 16),
          RecommendationsWidget(recommendations: dashboard.recommendations),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(DashboardStatistics dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TrendChartWidget(
            trends: dashboard.securityTrends,
            title: 'Tendencias de Seguridad',
            period: _selectedPeriod,
          ),
          const SizedBox(height: 16),
          // Crime trends chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tendencias por Tipo de Crimen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      _buildCrimeTrendsChart(dashboard.crimeStats),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsTab(DashboardStatistics dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RegionStatisticsWidget(regions: dashboard.regionStats),
    );
  }

  Widget _buildActivityTab(DashboardStatistics dashboard) {
    if (!_showUserData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.privacy_tip, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Datos de actividad personal ocultos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Activa la visualización en el menú superior',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: UserActivityWidget(activity: dashboard.userActivity),
    );
  }

  LineChartData _buildCrimeTrendsChart(List<CrimeStatistics> crimeStats) {
    final spots = <String, List<FlSpot>>{};
    final colors = <String, Color>{};
    
    for (int i = 0; i < crimeStats.length; i++) {
      final stat = crimeStats[i];
      final color = _getCrimeTypeColor(stat.crimeType);
      colors[stat.crimeType.label] = color;
      
      spots[stat.crimeType.label] = stat.monthlyTrends.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.value);
      }).toList();
    }

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => Text(
              'Mes ${value.toInt() + 1}',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: spots.entries.map((entry) {
        return LineChartBarData(
          spots: entry.value,
          isCurved: true,
          color: colors[entry.key],
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: colors[entry.key]!.withOpacity(0.1),
          ),
        );
      }).toList(),
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

  void _refreshData() {
    final filter = StatisticsFilter(period: _selectedPeriod);
    ref.read(dashboardStatisticsNotifierProvider.notifier).loadDashboard(filter: filter);
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'toggle_user_data':
        setState(() {
          _showUserData = !_showUserData;
        });
        break;
      case 'export':
        _showExportDialog(context);
        break;
      case 'settings':
        _showSettingsDialog(context);
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
        content: const Text('¿En qué formato deseas exportar los datos del dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(ExportFormat.pdf);
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(ExportFormat.excel);
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
            Text('Configuración del Dashboard'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Mostrar datos personales'),
              value: _showUserData,
              onChanged: (value) {
                setState(() {
                  _showUserData = value;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Tema del dashboard'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme selection
              },
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

  void _exportData(ExportFormat format) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportación ${format.label} en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStatItem({
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
            size: 24,
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