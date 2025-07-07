import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/header_bar.dart';
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
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _infoBarController;
  late Animation<double> _infoBarAnimation;
  late AnimationController _cardAnimationController;
  
  StatisticsPeriod _selectedPeriod = StatisticsPeriod.monthly;
  bool _showUserData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _infoBarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _infoBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _infoBarController,
      curve: Curves.easeOutBack,
    ));
    
    // Load dashboard data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStatisticsNotifierProvider.notifier).loadDashboard();
      _fadeController.forward();
      _slideController.forward();
      
      // Delayed animation for info bar
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _infoBarController.forward();
          _cardAnimationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _infoBarController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStatisticsNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: HeaderBarFactory.dashboard(
        subtitle: 'Análisis de seguridad integral',
        actions: [
          HeaderActions.filter(() => _showPeriodFilter(context)),
          HeaderActions.refresh(() {
            HapticFeedback.lightImpact();
            _refreshData();
          }),
        ],
        notification: _buildHeaderNotification(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: dashboardState.when(
          initial: () => _buildLoadingState(),
          loading: () => _buildLoadingState(),
          loaded: (dashboard) => FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  //  Tab bar
                  _buildTabBar(context, colorScheme),
                  
                  // Quick stats header with animation
                  _buildAnimatedQuickStats(dashboard.securityOverview, theme),
                  
                  // Barra de información contextual del dashboard (inspirada en maps)
                  AnimatedBuilder(
                    animation: _infoBarAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _infoBarAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-0.3, 0),
                            end: Offset.zero,
                          ).animate(_infoBarController),
                          child: _buildDashboardInfoBar(dashboard, colorScheme, theme),
                        ),
                      );
                    },
                  ),
                  
                  // Indicadores de estado del sistema (inspirado en maps)
                  AnimatedBuilder(
                    animation: _infoBarAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _infoBarAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.3, 0),
                            end: Offset.zero,
                          ).animate(_infoBarController),
                          child: _buildSystemStatusIndicators(dashboard, colorScheme, theme),
                        ),
                      );
                    },
                  ),
                  
                  // Main content with enhanced styling
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
            ),
          ),
          error: (error, message) => _buildErrorState(context, message),
        ),
      ),
    );
  }

  //  Loading State
  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(),
            SizedBox(height: DesignTokens.spacing4),
            Text(
              'Cargando análisis de seguridad...',
              style: TextStyle(
                fontSize: DesignTokens.fontSizeL,
                fontWeight: DesignTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Error State
  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Container(
        margin: DesignTokens.spacingXL,
        padding: DesignTokens.spacingXL,
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: DesignTokens.radiusL,
          border: Border.all(
            color: colorScheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: DesignTokens.spacingL,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                borderRadius: DesignTokens.radiusFull,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: DesignTokens.iconSizeXXXL,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing6),
            Text(
              'Error al cargar dashboard',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: DesignTokens.fontWeightSemiBold,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing6),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(dashboardStatisticsNotifierProvider.notifier).clearError();
                _refreshData();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: DesignTokens.spacingL,
                shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.radiusL,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Tab Bar
  Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: DesignTokens.radiusXL,
        boxShadow: [
          ShadowTokens.createShadow(
            color: colorScheme.shadow,
            opacity: DesignTokens.shadowOpacityLight,
            blurRadius: DesignTokens.blurRadiusL,
            offset: DesignTokens.shadowOffsetM,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: DesignTokens.radiusL,
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelStyle: const TextStyle(
          fontSize: DesignTokens.fontSizeS,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: DesignTokens.fontSizeS,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
        tabs: const [
          Tab(
            text: 'Resumen',
            icon: Icon(Icons.dashboard_rounded, size: DesignTokens.iconSizeS),
          ),
          Tab(
            text: 'Tendencias',
            icon: Icon(Icons.trending_up_rounded, size: DesignTokens.iconSizeS),
          ),
          Tab(
            text: 'Regiones',
            icon: Icon(Icons.map_rounded, size: DesignTokens.iconSizeS),
          ),
          Tab(
            text: 'Actividad',
            icon: Icon(Icons.person_rounded, size: DesignTokens.iconSizeS),
          ),
        ],
      ),
    );
  }

  // Barra de información contextual (inspirada en maps)
  Widget _buildDashboardInfoBar(DashboardStatistics dashboard, ColorScheme colorScheme, ThemeData theme) {
    final now = DateTime.now();
    final lastUpdate = now.subtract(const Duration(minutes: 2));
    final timeAgo = _formatTimeAgo(lastUpdate);
    
    return Container(
      margin: DesignTokens.spacingM,
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.8),
            colorScheme.primaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: DesignTokens.radiusL,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: DesignTokens.blurRadiusM,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: DesignTokens.spacingS,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: DesignTokens.radiusM,
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: colorScheme.onPrimary,
              size: DesignTokens.iconSizeL,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema de Análisis Operativo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Datos actualizados $timeAgo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: DesignTokens.paddingHorizontalM.add(DesignTokens.paddingVerticalS),
            decoration: BoxDecoration(
              color: _getSystemStatusColor(dashboard.securityOverview.currentSecurityLevel).withOpacity(0.2),
              borderRadius: DesignTokens.radiusM,
            ),
            child: Text(
              _getSystemStatusText(dashboard.securityOverview.currentSecurityLevel),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getSystemStatusColor(dashboard.securityOverview.currentSecurityLevel),
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Indicadores de estado del sistema (inspirado en maps)
  Widget _buildSystemStatusIndicators(DashboardStatistics dashboard, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      margin: DesignTokens.paddingHorizontalL,
      child: Row(
        children: [
          Expanded(
            child: _buildSystemStatusCard(
              'Estado General',
              dashboard.securityOverview.currentSecurityLevel.label.toUpperCase(),
              Icons.shield_rounded,
              _getSystemStatusColor(dashboard.securityOverview.currentSecurityLevel),
              colorScheme,
              theme,
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: _buildSystemStatusCard(
              'Alertas Activas',
              '${dashboard.securityOverview.activeAlerts}',
              Icons.warning_rounded,
              dashboard.securityOverview.activeAlerts > 10 ? Colors.red : Colors.orange,
              colorScheme,
              theme,
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: _buildSystemStatusCard(
              'Cobertura',
              '${(dashboard.securityOverview.improvementPercentage + 85).toInt()}%',
              Icons.signal_cellular_4_bar_rounded,
              Colors.blue,
              colorScheme,
              theme,
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: _buildSystemStatusCard(
              'Tendencia',
              dashboard.securityOverview.improvementPercentage >= 0 ? '↗' : '↘',
              Icons.trending_up_rounded,
              dashboard.securityOverview.improvementPercentage >= 0 ? Colors.green : Colors.red,
              colorScheme,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_cardAnimationController.value * 0.2),
          child: Container(
            padding: DesignTokens.spacingM,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: DesignTokens.radiusM,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: DesignTokens.blurRadiusS,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: DesignTokens.iconSizeL,
                ),
                SizedBox(height: DesignTokens.spacing1),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightBold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Métodos auxiliares para el estado del sistema
  Color _getSystemStatusColor(SecurityLevel level) {
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

  String _getSystemStatusText(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.veryLow:
      case SecurityLevel.low:
        return 'ÓPTIMO';
      case SecurityLevel.moderate:
        return 'NORMAL';
      case SecurityLevel.high:
      case SecurityLevel.veryHigh:
        return 'ALERTA';
      case SecurityLevel.critical:
        return 'CRÍTICO';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else {
      return 'hace ${difference.inDays}d';
    }
  }

  //  Quick Stats
  Widget _buildAnimatedQuickStats(SecurityOverview overview, ThemeData theme) {
    return Container(
      margin: DesignTokens.spacingL,
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: DesignTokens.radiusL,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(DesignTokens.shadowOpacityMedium),
            blurRadius: DesignTokens.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.shield_rounded,
              label: 'Nivel de Seguridad',
              value: overview.currentSecurityLevel.label,
              color: _getSecurityLevelColor(overview.currentSecurityLevel),
              animationDelay: Duration.zero,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.warning_amber_rounded,
              label: 'Alertas Activas',
              value: overview.activeAlerts.toString(),
              color: overview.activeAlerts > 10 ? Colors.red : Colors.orange,
              animationDelay: const Duration(milliseconds: 100),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.trending_up_rounded,
              label: 'Mejora',
              value: '${overview.improvementPercentage.toStringAsFixed(1)}%',
              color: overview.improvementPercentage >= 0 ? Colors.green : Colors.red,
              animationDelay: const Duration(milliseconds: 200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(DashboardStatistics dashboard) {
    return SingleChildScrollView(
      padding: DesignTokens.spacingL,
      child: Column(
        children: [
          SecurityOverviewCard(overview: dashboard.securityOverview),
          const SizedBox(height: DesignTokens.spacing4),
          CrimeStatisticsChart(crimeStats: dashboard.crimeStats),
          const SizedBox(height: DesignTokens.spacing4),
          RecommendationsWidget(recommendations: dashboard.recommendations),
          const SizedBox(height: DesignTokens.spacing6), // Extra bottom padding
        ],
      ),
    );
  }

  Widget _buildTrendsTab(DashboardStatistics dashboard) {
    return SingleChildScrollView(
      padding: DesignTokens.spacingL,
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

  HeaderNotification? _buildHeaderNotification() {
    final dashboardState = ref.watch(dashboardStatisticsNotifierProvider);
    return dashboardState.maybeWhen(
      loaded: (dashboard) {
        final criticalAlerts = dashboard.securityOverview.activeAlerts;
        if (criticalAlerts > 0) {
          return HeaderNotification(
            icon: Icons.warning_rounded,
            count: criticalAlerts,
            color: criticalAlerts > 10 ? Colors.red : Colors.orange,
            message: 'Alertas críticas activas',
          );
        }
        return null;
      },
      orElse: () => null,
    );
  }

  void _showPeriodFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: DesignTokens.radiusXL.copyWith(
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: DesignTokens.spacing4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: DesignTokens.radiusS,
              ),
            ),
            Text(
              'Período de análisis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),
            ...StatisticsPeriod.values.map((period) => ListTile(
              leading: Icon(
                _selectedPeriod == period 
                    ? Icons.radio_button_checked_rounded 
                    : Icons.radio_button_unchecked_rounded,
                color: _selectedPeriod == period 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey,
              ),
              title: Text(period.label),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedPeriod = period);
                Navigator.pop(context);
                _refreshData();
              },
            )),
            SizedBox(height: DesignTokens.spacing6),
          ],
        ),
      ),
    );
  }

  void _showMoreOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: DesignTokens.radiusXL.copyWith(
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: DesignTokens.spacing4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: DesignTokens.radiusS,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Exportar datos'),
              onTap: () {
                Navigator.pop(context);
                _showExportDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                _showSettingsDialog(context);
              },
            ),
            SizedBox(height: DesignTokens.spacing6),
          ],
        ),
      ),
    );
  }
}

/// Quick Stat Item with animations and improved design
class _QuickStatItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Duration animationDelay;

  const _QuickStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.animationDelay,
  });

  @override
  State<_QuickStatItem> createState() => _QuickStatItemState();
}

class _QuickStatItemState extends State<_QuickStatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Start animation after delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: DesignTokens.spacingM,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //  icon container
                  Container(
                    padding: DesignTokens.spacingS,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: DesignTokens.radiusM,
                      boxShadow: [
                        ShadowTokens.createShadow(
                          color: widget.color,
                          opacity: DesignTokens.shadowOpacityLight,
                          blurRadius: DesignTokens.blurRadiusS,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: DesignTokens.iconSizeL,
                    ),
                  ),
                  
                  const SizedBox(height: DesignTokens.spacing2),
                  
                  // Value with  styling
                  Text(
                    widget.value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: DesignTokens.fontWeightBold,
                      color: widget.color,
                      fontSize: DesignTokens.fontSizeXL,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: DesignTokens.spacing1),
                  
                  // Label with subtle styling
                  Text(
                    widget.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: DesignTokens.fontWeightMedium,
                      fontSize: DesignTokens.fontSizeXS,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

