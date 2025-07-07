import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/header_bar.dart';
import '../../../../shared/widgets/map_skeleton_widgets.dart';
import '../../../../shared/utils/memory_manager.dart';
import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/risk_level.dart';
import '../providers/maps_provider.dart';
import '../providers/maps_state.dart';
import '../widgets/map_widget.dart' hide POITypeMapExtension, DataSourceMapExtension, CrimeTypeMapExtension;
import '../widgets/risk_filter_bottom_sheet.dart';
import '../widgets/poi_filter_bottom_sheet.dart';
import '../widgets/location_search_widget.dart';

/// Maps page optimizada para transportistas, operadores de seguridad y planeadores de rutas
/// Enfoque en información crítica inmediata, operación con una mano y acceso rápido a datos de seguridad
class TransportOptimizedMapsPage extends ConsumerStatefulWidget {
  const TransportOptimizedMapsPage({super.key});

  @override
  ConsumerState<TransportOptimizedMapsPage> createState() => _TransportOptimizedMapsPageState();
}

class _TransportOptimizedMapsPageState extends ConsumerState<TransportOptimizedMapsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, AutoMemoryManagement {
  
  // Animation controllers optimizados para feedback inmediato
  late AnimationController _headerController;
  late AnimationController _criticalAlertController;
  late AnimationController _quickAccessController;
  
  // Animations para contexto operacional
  late Animation<double> _headerFadeAnimation;
  late Animation<Color?> _criticalAlertColorAnimation;
  late Animation<double> _quickAccessSlideAnimation;
  
  final MapController _mapController = MapController();
  final PageController _viewModeController = PageController();
  
  // Estado operacional crítico
  RiskFilter? _activeRiskFilter;
  POIFilter? _activePOIFilter;
  bool _showCriticalOnly = true; // Por defecto solo mostrar riesgos críticos
  bool _operationalMode = true; // Modo operacional vs exploración
  int _currentViewMode = 0; // 0: Mapa, 1: Lista Crítica, 2: Planificación
  
  // Contexto operacional
  String _currentOperationalContext = 'transport'; // transport, security, planning
  bool _isEmergencyMode = false;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeOperationalAnimations();
    _scheduleOperationalDataLoad();
  }

  void _initializeOperationalAnimations() {
    // Header con fade rápido para no distraer
    _headerController = AnimationController(
      duration: DesignTokens.animationDurationQuick,
      vsync: this,
    );
    
    // Alertas críticas con pulsación para atención inmediata
    _criticalAlertController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Acceso rápido que aparece desde abajo
    _quickAccessController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
    
    _criticalAlertColorAnimation = ColorTween(
      begin: Colors.red[400],
      end: Colors.red[600],
    ).animate(CurvedAnimation(parent: _criticalAlertController, curve: Curves.easeInOut));
    
    _quickAccessSlideAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _quickAccessController, curve: Curves.easeOutCubic));

    // Iniciar animaciones
    _headerController.forward();
    _quickAccessController.forward();
    
    // Pulsar alertas críticas continuamente si hay riesgos altos
    _criticalAlertController.repeat(reverse: true);
  }

  void _scheduleOperationalDataLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Priorizar carga de datos críticos para transporte
      _loadCriticalTransportData();
    });
  }

  Future<void> _loadCriticalTransportData() async {
    // Optimizar memoria antes de carga crítica
    final memoryManager = MemoryManager();
    memoryManager.optimizeForHeavyOperation();
    
    // Cargar solo datos críticos primero
    ref.read(mapsNotifierProvider.notifier).refreshData();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _criticalAlertController.dispose();
    _quickAccessController.dispose();
    _mapController.dispose();
    _viewModeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mapsState = ref.watch(mapsNotifierProvider);
    
    return RepaintBoundary(
      child: Scaffold(
        appBar: _buildOperationalHeader(context),
        body: _buildOperationalBody(context, mapsState),
        floatingActionButton: _buildOperationalFAB(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: _buildQuickAccessBar(context),
      ),
    );
  }

  PreferredSizeWidget _buildOperationalHeader(BuildContext context) {
    final theme = Theme.of(context);
    final criticalAlertsCount = _getCriticalAlertsCount();
    
    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: HeaderBarFactory.maps(
        actions: [
          // Cambio rápido de contexto operacional
          HeaderAction(
            icon: _getContextIcon(_currentOperationalContext),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showOperationalContextMenu(context);
            },
            tooltip: 'Cambiar contexto: ${_getContextLabel(_currentOperationalContext)}',
            badge: _isEmergencyMode ? HeaderBadge(count: 1, color: Colors.red) : null,
          ),
          // Filtros críticos rápidos
          HeaderAction(
            icon: _showCriticalOnly ? Icons.priority_high : Icons.tune_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
              _toggleCriticalMode();
            },
            tooltip: _showCriticalOnly ? 'Mostrando solo críticos' : 'Mostrar todos',
            badge: criticalAlertsCount > 0 ? HeaderBadge(count: criticalAlertsCount, color: Colors.red) : null,
          ),
        ],
        notification: criticalAlertsCount > 0 
            ? HeaderNotification(
                icon: Icons.warning_rounded,
                count: criticalAlertsCount,
                color: Colors.red,
              ) 
            : null,
        onNotificationTap: () => _showCriticalAlertsDialog(context),
      ),
    );
  }

  Widget _buildOperationalBody(BuildContext context, MapsState mapsState) {
    return Column(
      children: [
        // Barra de estado operacional crítico
        _buildCriticalStatusBar(context),
        
        // Selector de vista optimizado para una mano
        _buildViewModeSelector(context),
        
        // Contenido principal con PageView para swipe rápido
        Expanded(
          child: PageView(
            controller: _viewModeController,
            onPageChanged: (index) {
              setState(() => _currentViewMode = index);
              HapticFeedback.selectionClick();
            },
            children: [
              _buildOperationalMapView(mapsState),
              _buildCriticalListView(),
              _buildPlanningView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalStatusBar(BuildContext context) {
    final highRiskPolygons = ref.watch(highRiskPolygonsProvider);
    final criticalCount = highRiskPolygons.where((p) => 
        p.riskLevel == RiskLevelType.high || 
        p.riskLevel == RiskLevelType.veryHigh || 
        p.riskLevel == RiskLevelType.extreme
    ).length;
    
    if (criticalCount == 0) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _criticalAlertColorAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: DesignTokens.paddingVerticalS.add(DesignTokens.paddingHorizontalL),
          decoration: BoxDecoration(
            color: _criticalAlertColorAnimation.value?.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: _criticalAlertColorAnimation.value ?? Colors.red,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: _criticalAlertColorAnimation.value,
                size: DesignTokens.iconSizeS,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: Text(
                  '$criticalCount ZONA${criticalCount > 1 ? 'S' : ''} DE ALTO RIESGO DETECTADA${criticalCount > 1 ? 'S' : ''}',
                  style: TextStyle(
                    color: _criticalAlertColorAnimation.value,
                    fontSize: DesignTokens.fontSizeS,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _showCriticalAlertsDialog(context);
                },
                child: Container(
                  padding: DesignTokens.paddingVerticalXS.add(DesignTokens.paddingHorizontalS),
                  decoration: BoxDecoration(
                    color: _criticalAlertColorAnimation.value,
                    borderRadius: DesignTokens.radiusM,
                  ),
                  child: Text(
                    'VER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DesignTokens.fontSizeXS,
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewModeSelector(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: DesignTokens.paddingHorizontalL.add(DesignTokens.paddingVerticalS),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: DesignTokens.radiusXXL,
      ),
      child: Row(
        children: [
          _buildViewModeTab(0, Icons.map_rounded, 'MAPA', context),
          _buildViewModeTab(1, Icons.list_rounded, 'CRÍTICOS', context),
          _buildViewModeTab(2, Icons.route_rounded, 'RUTAS', context),
        ],
      ),
    );
  }

  Widget _buildViewModeTab(int index, IconData icon, String label, BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = _currentViewMode == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _viewModeController.animateToPage(
            index,
            duration: DesignTokens.animationDurationNormal,
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: DesignTokens.animationDurationQuick,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: DesignTokens.radiusXXL,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                size: DesignTokens.iconSizeS,
              ),
              if (isSelected) ...[
                SizedBox(width: DesignTokens.spacing1),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DesignTokens.fontSizeXS,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationalMapView(MapsState mapsState) {
    return RepaintBoundary(
      child: mapsState.when(
        initial: () => _buildOperationalLoadingState(),
        loading: () => _buildOperationalLoadingState(),
        loaded: (polygons, pois, location, riskFilter, poiFilter) {
          // Filtrar solo datos críticos si está en modo crítico
          final filteredPolygons = _showCriticalOnly 
              ? polygons.where((p) => p.riskLevel == RiskLevelType.high || 
                                     p.riskLevel == RiskLevelType.veryHigh || 
                                     p.riskLevel == RiskLevelType.extreme).toList()
              : polygons;
          
          return Stack(
            children: [
              MapWidget(
                mapController: _mapController,
                center: location ?? const LatLng(19.4326, -99.1332),
                riskPolygons: filteredPolygons,
                pois: pois,
                onMapTap: _onMapTap,
                onPolygonTap: _onPolygonTap,
                onPOITap: _onPOITap,
              ),
              
              // Overlay de información crítica para transportistas
              _buildTransportInfoOverlay(context, filteredPolygons),
            ],
          );
        },
        error: (error, message) => _buildOperationalErrorState(context, error, message),
      ),
    );
  }

  Widget _buildOperationalLoadingState() {
    return Container(
      child: Column(
        children: [
          // Mensaje específico para transportistas
          Container(
            padding: DesignTokens.spacingL,
            child: Row(
              children: [
                PulseLoadingWidget(size: 40),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cargando datos de seguridad...',
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeM,
                          fontWeight: DesignTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacing1),
                      Text(
                        'Analizando rutas y zonas de riesgo',
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeS,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Skeleton específico para transporte
          Expanded(
            child: MapSkeletonLoaders.mapView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportInfoOverlay(BuildContext context, List<RiskPolygon> polygons) {
    return Positioned(
      top: DesignTokens.spacing4,
      left: DesignTokens.spacing4,
      child: Container(
        padding: DesignTokens.spacingM,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: DesignTokens.radiusL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: DesignTokens.iconSizeS,
                ),
                SizedBox(width: DesignTokens.spacing1),
                Text(
                  'ESTADO OPERACIONAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DesignTokens.fontSizeXS,
                    fontWeight: DesignTokens.fontWeightBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacing2),
            _buildQuickStat('Zonas Críticas', polygons.length.toString(), Colors.red[400]!),
            _buildQuickStat('Estado Ruta', 'SEGURA', Colors.green[400]!),
            _buildQuickStat('Última Act.', 'Hace 2 min', Colors.blue[400]!),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacing1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: DesignTokens.radiusFull,
            ),
          ),
          SizedBox(width: DesignTokens.spacing1),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: DesignTokens.fontSizeXS,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: DesignTokens.fontSizeXS,
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalListView() {
    final highRiskPolygons = ref.watch(highRiskPolygonsProvider);
    final criticalPolygons = highRiskPolygons.where((p) => 
        p.riskLevel == RiskLevelType.high || 
        p.riskLevel == RiskLevelType.veryHigh || 
        p.riskLevel == RiskLevelType.extreme
    ).toList();
    
    if (criticalPolygons.isEmpty) {
      return _buildNoCriticalAlertsState();
    }
    
    return ListView.builder(
      padding: DesignTokens.spacingL,
      itemCount: criticalPolygons.length,
      itemBuilder: (context, index) {
        return _buildCriticalRiskCard(criticalPolygons[index], index);
      },
    );
  }

  Widget _buildNoCriticalAlertsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: DesignTokens.spacingXXL,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: DesignTokens.radiusXXL,
            ),
            child: Icon(
              Icons.verified_rounded,
              size: 64,
              color: Colors.green,
            ),
          ),
          SizedBox(height: DesignTokens.spacing6),
          Text(
            'RUTAS SEGURAS',
            style: TextStyle(
              fontSize: DesignTokens.fontSizeXL,
              fontWeight: DesignTokens.fontWeightBold,
              color: Colors.green,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),
          Text(
            'No hay alertas críticas en tu área',
            style: TextStyle(
              fontSize: DesignTokens.fontSizeM,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalRiskCard(RiskPolygon polygon, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Card(
        elevation: 4,
        shadowColor: polygon.riskLevel.color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusL,
          side: BorderSide(
            color: polygon.riskLevel.color,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.heavyImpact();
            _showCriticalPolygonDetails(polygon);
          },
          borderRadius: DesignTokens.radiusL,
          child: Padding(
            padding: DesignTokens.spacingL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: DesignTokens.spacingS,
                      decoration: BoxDecoration(
                        color: polygon.riskLevel.color,
                        borderRadius: DesignTokens.radiusM,
                      ),
                      child: Icon(
                        _getCriticalRiskIcon(polygon.riskLevel),
                        color: Colors.white,
                        size: DesignTokens.iconSizeL,
                      ),
                    ),
                    SizedBox(width: DesignTokens.spacing3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            polygon.riskLevel.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeL,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: polygon.riskLevel.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Recomendación: ${_getTransportRecommendation(polygon.riskLevel)}',
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeS,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              fontWeight: DesignTokens.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: polygon.riskLevel.color,
                        ),
                        Text(
                          'VER',
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeXS,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: polygon.riskLevel.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: DesignTokens.spacing3),
                
                // Información operacional específica para transportistas
                Container(
                  padding: DesignTokens.spacingM,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: DesignTokens.radiusM,
                  ),
                  child: Row(
                    children: [
                      _buildOperationalIndicator(
                        'TIEMPO',
                        _getEstimatedTime(polygon),
                        Icons.schedule_rounded,
                      ),
                      SizedBox(width: DesignTokens.spacing4),
                      _buildOperationalIndicator(
                        'DISTANCIA',
                        _getEstimatedDistance(polygon),
                        Icons.straighten_rounded,
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _showAlternativeRoutes(polygon);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: DesignTokens.paddingHorizontalM,
                          minimumSize: Size(0, 32),
                        ),
                        child: Text(
                          'RUTAS ALT.',
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeXS,
                            fontWeight: DesignTokens.fontWeightBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationalIndicator(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: DesignTokens.iconSizeXS, color: Colors.grey[600]),
            SizedBox(width: DesignTokens.spacing1),
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTokens.fontSizeXS,
                color: Colors.grey[600],
                fontWeight: DesignTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeS,
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanningView() {
    return Container(
      padding: DesignTokens.spacingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLANIFICACIÓN DE RUTAS',
            style: TextStyle(
              fontSize: DesignTokens.fontSizeL,
              fontWeight: DesignTokens.fontWeightBold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: DesignTokens.spacing4),
          
          // Cards de planificación
          _buildPlanningCard(
            'Análisis de Seguridad',
            'Evaluación completa de riesgos en tiempo real',
            Icons.analytics_rounded,
            Colors.blue,
            () => _showSecurityAnalysis(),
          ),
          
          _buildPlanningCard(
            'Optimización de Rutas',
            'Calcular la ruta más segura y eficiente',
            Icons.route_rounded,
            Colors.green,
            () => _showRouteOptimization(),
          ),
          
          _buildPlanningCard(
            'Reportes Operacionales',
            'Historial y estadísticas de seguridad',
            Icons.assessment_rounded,
            Colors.orange,
            () => _showOperationalReports(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: DesignTokens.radiusL,
          child: Padding(
            padding: DesignTokens.spacingL,
            child: Row(
              children: [
                Container(
                  padding: DesignTokens.spacingM,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: DesignTokens.radiusM,
                  ),
                  child: Icon(icon, color: color, size: DesignTokens.iconSizeXL),
                ),
                SizedBox(width: DesignTokens.spacing4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeM,
                          fontWeight: DesignTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacing1),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeS,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: DesignTokens.iconSizeS,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationalErrorState(BuildContext context, Object error, String message) {
    return Container(
      padding: DesignTokens.spacingXXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: DesignTokens.spacingXL,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: DesignTokens.radiusXXL,
            ),
            child: Icon(
              Icons.warning_rounded,
              size: 64,
              color: Colors.red,
            ),
          ),
          
          SizedBox(height: DesignTokens.spacing6),
          
          Text(
            'ERROR EN DATOS DE SEGURIDAD',
            style: TextStyle(
              fontSize: DesignTokens.fontSizeL,
              fontWeight: DesignTokens.fontWeightBold,
              color: Colors.red,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: DesignTokens.spacing2),
          
          Text(
            'No se pueden cargar los datos de riesgo.\nOperación manual requerida.',
            style: TextStyle(
              fontSize: DesignTokens.fontSizeM,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: DesignTokens.spacing6),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  ref.read(mapsNotifierProvider.notifier).clearError();
                  ref.read(mapsNotifierProvider.notifier).refreshData();
                },
                icon: Icon(Icons.refresh_rounded),
                label: Text('REINTENTAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: DesignTokens.paddingHorizontalXL.add(DesignTokens.paddingVerticalL),
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              OutlinedButton(
                onPressed: () => _showManualOperationMode(),
                child: Text('MODO MANUAL'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  padding: DesignTokens.paddingHorizontalXL.add(DesignTokens.paddingVerticalL),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalFAB(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // FAB de emergencia - siempre visible
        FloatingActionButton(
          heroTag: "emergency",
          onPressed: () {
            HapticFeedback.heavyImpact();
            _activateEmergencyMode();
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          child: Icon(Icons.emergency_rounded),
        ),
        
        SizedBox(height: DesignTokens.spacing2),
        
        // FAB contextual según modo
        FloatingActionButton(
          heroTag: "context_action",
          onPressed: _getContextualAction(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(_getContextualIcon()),
        ),
      ],
    );
  }

  Widget _buildQuickAccessBar(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, _quickAccessSlideAnimation.value),
        end: Offset.zero,
      ).animate(_quickAccessController),
      child: Container(
        height: 80,
        padding: DesignTokens.paddingHorizontalL,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            ShadowTokens.createShadow(
              color: Colors.black,
              opacity: 0.1,
              blurRadius: DesignTokens.blurRadiusL,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickAccessButton(
              Icons.my_location_rounded,
              'MI UBICACIÓN',
              () => _centerOnCurrentLocation(),
            ),
            _buildQuickAccessButton(
              Icons.search_rounded,
              'BUSCAR',
              () => _showQuickSearch(),
            ),
            _buildQuickAccessButton(
              Icons.filter_alt_rounded,
              'FILTROS',
              () => _showQuickFilters(),
            ),
            _buildQuickAccessButton(
              Icons.share_rounded,
              'COMPARTIR',
              () => _shareOperationalData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: DesignTokens.iconSizeL,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: DesignTokens.spacing1),
          Text(
            label,
            style: TextStyle(
              fontSize: DesignTokens.fontSizeXS,
              fontWeight: DesignTokens.fontWeightMedium,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Utility methods para contexto operacional
  IconData _getContextIcon(String context) {
    switch (context) {
      case 'transport': return Icons.local_shipping_rounded;
      case 'security': return Icons.security_rounded;
      case 'planning': return Icons.route_rounded;
      default: return Icons.work_rounded;
    }
  }

  String _getContextLabel(String context) {
    switch (context) {
      case 'transport': return 'Transporte';
      case 'security': return 'Seguridad';
      case 'planning': return 'Planificación';
      default: return 'Operacional';
    }
  }

  IconData _getCriticalRiskIcon(RiskLevelType riskLevel) {
    switch (riskLevel) {
      case RiskLevelType.high: return Icons.warning_rounded;
      case RiskLevelType.veryHigh: return Icons.error_rounded;
      case RiskLevelType.extreme: return Icons.dangerous_rounded;
      default: return Icons.info_rounded;
    }
  }

  String _getTransportRecommendation(RiskLevelType riskLevel) {
    switch (riskLevel) {
      case RiskLevelType.high: return 'EVITAR ZONA - Buscar ruta alternativa';
      case RiskLevelType.veryHigh: return 'NO TRANSITAR - Riesgo crítico';
      case RiskLevelType.extreme: return 'ZONA PROHIBIDA - No ingresar';
      default: return 'Proceder con precaución';
    }
  }

  String _getEstimatedTime(RiskPolygon polygon) {
    // Simulación - en implementación real calcular basado en datos
    return '5-8 min';
  }

  String _getEstimatedDistance(RiskPolygon polygon) {
    // Simulación - en implementación real calcular basado en datos
    return '2.3 km';
  }

  int _getCriticalAlertsCount() {
    final highRiskPolygons = ref.watch(highRiskPolygonsProvider);
    return highRiskPolygons.where((p) => 
        p.riskLevel == RiskLevelType.high || 
        p.riskLevel == RiskLevelType.veryHigh || 
        p.riskLevel == RiskLevelType.extreme
    ).length;
  }

  VoidCallback _getContextualAction() {
    switch (_currentViewMode) {
      case 0: return () => _centerOnCurrentLocation();
      case 1: return () => _showCriticalAlertsDialog(context);
      case 2: return () => _showRouteOptimization();
      default: return () => _centerOnCurrentLocation();
    }
  }

  IconData _getContextualIcon() {
    switch (_currentViewMode) {
      case 0: return Icons.my_location_rounded;
      case 1: return Icons.warning_rounded;
      case 2: return Icons.route_rounded;
      default: return Icons.my_location_rounded;
    }
  }

  // Event handlers operacionales
  void _onMapTap(LatLng location) {
    HapticFeedback.selectionClick();
  }

  void _onPolygonTap(RiskPolygon polygon) {
    HapticFeedback.mediumImpact();
    _showCriticalPolygonDetails(polygon);
  }

  void _onPOITap(POIEntity poi) {
    HapticFeedback.lightImpact();
    _showPOIDetails(poi);
  }

  void _toggleCriticalMode() {
    setState(() => _showCriticalOnly = !_showCriticalOnly);
    if (_showCriticalOnly) {
      _criticalAlertController.repeat(reverse: true);
    } else {
      _criticalAlertController.stop();
    }
  }

  void _centerOnCurrentLocation() {
    final location = ref.read(currentMapLocationProvider);
    if (location != null) {
      _mapController.move(location, 15.0);
    } else {
      ref.read(mapsNotifierProvider.notifier).refreshData();
    }
  }

  void _activateEmergencyMode() {
    setState(() => _isEmergencyMode = true);
    // Implementar lógica de emergencia
    _showEmergencyDialog();
  }

  // Dialog methods específicos para operadores
  void _showOperationalContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: DesignTokens.radiusXL.copyWith(
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CONTEXTO OPERACIONAL',
              style: TextStyle(
                fontSize: DesignTokens.fontSizeL,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),
            
            _buildContextOption('transport', 'Transporte', Icons.local_shipping_rounded),
            _buildContextOption('security', 'Seguridad', Icons.security_rounded),
            _buildContextOption('planning', 'Planificación', Icons.route_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildContextOption(String context, String label, IconData icon) {
    final isSelected = _currentOperationalContext == context;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? DesignTokens.fontWeightSemiBold : DesignTokens.fontWeightMedium,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        setState(() => _currentOperationalContext = context);
        Navigator.pop(context);
      },
    );
  }

  void _showCriticalAlertsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: DesignTokens.spacing2),
            Text('ALERTAS CRÍTICAS'),
          ],
        ),
        content: Text('Se han detectado ${_getCriticalAlertsCount()} zonas de alto riesgo en el área.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CERRAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModeController.animateToPage(1, duration: DesignTokens.animationDurationNormal, curve: Curves.easeInOut);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('VER DETALLES'),
          ),
        ],
      ),
    );
  }

  void _showCriticalPolygonDetails(RiskPolygon polygon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
        title: Row(
          children: [
            Container(
              padding: DesignTokens.spacingS,
              decoration: BoxDecoration(
                color: polygon.riskLevel.color,
                borderRadius: DesignTokens.radiusS,
              ),
              child: Icon(
                _getCriticalRiskIcon(polygon.riskLevel),
                color: Colors.white,
                size: DesignTokens.iconSizeM,
              ),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(child: Text(polygon.riskLevel.label.toUpperCase())),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECOMENDACIÓN OPERACIONAL:',
              style: TextStyle(
                fontWeight: DesignTokens.fontWeightBold,
                fontSize: DesignTokens.fontSizeS,
              ),
            ),
            SizedBox(height: DesignTokens.spacing1),
            Text(_getTransportRecommendation(polygon.riskLevel)),
            SizedBox(height: DesignTokens.spacing3),
            Text('Fuente: ${polygon.dataSource.label}'),
            if (polygon.crimeTypes.isNotEmpty) ...[
              SizedBox(height: DesignTokens.spacing2),
              Text('Tipos de riesgo: ${polygon.crimeTypes.map((e) => e.label).join(', ')}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CERRAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAlternativeRoutes(polygon);
            },
            child: Text('RUTAS ALTERNATIVAS'),
          ),
        ],
      ),
    );
  }

  void _showPOIDetails(POIEntity poi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
        title: Row(
          children: [
            Text(poi.type.icon, style: TextStyle(color: poi.type.color, fontSize: 24)),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(child: Text(poi.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${poi.type.label}'),
            SizedBox(height: DesignTokens.spacing2),
            Text('Descripción: ${poi.description}'),
            if (poi.address != null) ...[
              SizedBox(height: DesignTokens.spacing2),
              Text('Dirección: ${poi.address}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
        title: Row(
          children: [
            Icon(Icons.emergency_rounded, color: Colors.red, size: 32),
            SizedBox(width: DesignTokens.spacing2),
            Text('MODO EMERGENCIA', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text('Se ha activado el modo de emergencia. ¿Necesita asistencia inmediata?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isEmergencyMode = false);
              Navigator.pop(context);
            },
            child: Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => _callEmergencyServices(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('LLAMAR EMERGENCIA'),
          ),
        ],
      ),
    );
  }

  // Placeholder methods for operational features
  void _showQuickSearch() {
    // Implementar búsqueda rápida
  }

  void _showQuickFilters() {
    // Implementar filtros rápidos
  }

  void _shareOperationalData() {
    // Implementar compartir datos operacionales
  }

  void _showAlternativeRoutes(RiskPolygon polygon) {
    // Implementar rutas alternativas
  }

  void _showSecurityAnalysis() {
    // Implementar análisis de seguridad
  }

  void _showRouteOptimization() {
    // Implementar optimización de rutas
  }

  void _showOperationalReports() {
    // Implementar reportes operacionales
  }

  void _showManualOperationMode() {
    // Implementar modo operacional manual
  }

  void _callEmergencyServices() {
    // Implementar llamada a servicios de emergencia
  }
}