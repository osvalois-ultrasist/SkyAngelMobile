import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/header_bar.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/risk_level.dart';
import '../providers/maps_provider.dart';
import '../providers/maps_state.dart';
import '../widgets/map_widget.dart' hide POITypeMapExtension, DataSourceMapExtension, CrimeTypeMapExtension;
import '../widgets/risk_filter_bottom_sheet.dart';
import '../widgets/poi_filter_bottom_sheet.dart';
import '../widgets/map_statistics_widget.dart';
import '../widgets/location_search_widget.dart';
import '../widgets/risk_legend_widget.dart';

/// Página de mapas refinada y homologada con el marco de diseño
/// Optimizada para transportistas con diseño consistente con login/loading
class RefinedMapsPage extends ConsumerStatefulWidget {
  const RefinedMapsPage({super.key});

  @override
  ConsumerState<RefinedMapsPage> createState() => _RefinedMapsPageState();
}

class _RefinedMapsPageState extends ConsumerState<RefinedMapsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _entryAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _cardAnimationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fabAnimation;
  
  final MapController _mapController = MapController();
  
  RiskFilter? _activeRiskFilter;
  POIFilter? _activePOIFilter;
  bool _showRiskLayer = true;
  bool _showPOILayer = true;
  bool _showRiskLegend = false;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadMapData();
  }

  void _initializeAnimations() {
    // Animación de entrada principal (similar al login)
    _entryAnimationController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    // Animación del FAB
    _fabAnimationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    // Animación de las tarjetas
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // Iniciar animaciones
    _entryAnimationController.forward();
  }

  void _loadMapData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapsNotifierProvider.notifier).refreshData();
      
      // Simular carga del mapa y animar entrada
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _isMapReady = true);
          _fabAnimationController.forward();
          _cardAnimationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    _entryAnimationController.dispose();
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapsState = ref.watch(mapsNotifierProvider);
    final highRiskPolygons = ref.watch(highRiskPolygonsProvider);
    final activePOIs = ref.watch(activePOIsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: HeaderBarFactory.maps(
        subtitle: 'Información de seguridad en tiempo real',
        actions: [
          HeaderActions.layers(() => _showLayersBottomSheet(context)),
          HeaderActions.refresh(() {
            HapticFeedback.lightImpact();
            ref.read(mapsNotifierProvider.notifier).refreshData();
          }),
        ],
      ),
      body: AnimatedBuilder(
        animation: _entryAnimationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildMapContent(mapsState, highRiskPolygons, activePOIs, colorScheme),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () => _showCurrentLocation(),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: DesignTokens.elevationL,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Mi Ubicación'),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMapContent(
    MapsState mapsState,
    AsyncValue<List<RiskPolygon>> highRiskPolygons,
    AsyncValue<List<POIEntity>> activePOIs,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // Barra de información rápida
        _buildQuickInfoBar(colorScheme),
        
        // Indicadores de estado
        _buildStatusIndicators(mapsState, colorScheme),
        
        // Contenido principal del mapa
        Expanded(
          child: Stack(
            children: [
              // Widget del mapa con loading
              _buildMapWithLoading(mapsState, highRiskPolygons, activePOIs),
              
              // Controles flotantes
              _buildFloatingControls(colorScheme),
              
              // Leyenda de riesgo (si está activa)
              if (_showRiskLegend)
                _buildRiskLegend(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoBar(ColorScheme colorScheme) {
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
          ShadowTokens.createShadow(
            color: colorScheme.primary,
            opacity: 0.1,
            blurRadius: DesignTokens.blurRadiusM,
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
              Icons.security_rounded,
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
                  'Zona de Operación Segura',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Datos actualizados hace 2 minutos',
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
              color: Colors.green.withOpacity(0.2),
              borderRadius: DesignTokens.radiusM,
            ),
            child: Text(
              'ACTIVO',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green[700],
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators(MapsState mapsState, ColorScheme colorScheme) {
    return Container(
      margin: DesignTokens.paddingHorizontalL,
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              'Riesgo Actual',
              'BAJO',
              Icons.verified_rounded,
              Colors.green,
              colorScheme,
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: _buildStatusCard(
              'Alertas',
              '3',
              Icons.warning_rounded,
              Colors.orange,
              colorScheme,
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: _buildStatusCard(
              'Cobertura',
              '98%',
              Icons.signal_cellular_4_bar_rounded,
              Colors.blue,
              colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
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
                ShadowTokens.createShadow(
                  color: color,
                  opacity: 0.1,
                  blurRadius: DesignTokens.blurRadiusS,
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

  Widget _buildMapWithLoading(
    MapsState mapsState,
    AsyncValue<List<RiskPolygon>> highRiskPolygons,
    AsyncValue<List<POIEntity>> activePOIs,
  ) {
    return Container(
      margin: DesignTokens.spacingM,
      decoration: BoxDecoration(
        borderRadius: DesignTokens.radiusL,
        boxShadow: [
          ShadowTokens.createShadow(
            color: Colors.black,
            opacity: 0.1,
            blurRadius: DesignTokens.blurRadiusL,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: DesignTokens.radiusL,
        child: Stack(
          children: [
            // Mapa principal
            if (_isMapReady)
              ScaleTransition(
                scale: _scaleAnimation,
                child: MapWidget(
                  mapController: _mapController,
                  center: const LatLng(19.4326, -99.1332), // Ciudad de México
                  riskPolygons: highRiskPolygons.value ?? [],
                  pois: activePOIs.value ?? [],
                  onMapTap: _onMapTap,
                  onPolygonTap: _onPolygonTap,
                  onPOITap: _onPOITap,
                ),
              ),
            
            // Loading overlay con diseño homologado
            if (!_isMapReady)
              Container(
                color: theme.colorScheme.surface,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PulseLoadingWidget(
                        message: 'Cargando mapa seguro...',
                        size: 80,
                      ),
                    ],
                  ),
                ),
              ),
            
            // Loading overlay para datos
            if (mapsState.isLoading && _isMapReady)
              Positioned(
                top: DesignTokens.spacing4,
                right: DesignTokens.spacing4,
                child: Container(
                  padding: DesignTokens.spacingM,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: DesignTokens.radiusM,
                  ),
                  child: const DotsLoadingWidget(
                    message: 'Actualizando...',
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingControls(ColorScheme colorScheme) {
    return Positioned(
      top: DesignTokens.spacing4,
      left: DesignTokens.spacing4,
      child: Column(
        children: [
          _buildControlButton(
            Icons.layers_rounded,
            'Capas',
            () => _showLayersBottomSheet(context),
            colorScheme,
          ),
          SizedBox(height: DesignTokens.spacing2),
          _buildControlButton(
            _showRiskLegend ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            _showRiskLegend ? 'Ocultar' : 'Leyenda',
            () {
              HapticFeedback.lightImpact();
              setState(() => _showRiskLegend = !_showRiskLegend);
            },
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: DesignTokens.radiusM,
        boxShadow: [
          ShadowTokens.createShadow(
            color: Colors.black,
            opacity: 0.1,
            blurRadius: DesignTokens.blurRadiusM,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildRiskLegend(ColorScheme colorScheme) {
    return Positioned(
      bottom: DesignTokens.spacing4,
      left: DesignTokens.spacing4,
      child: AnimatedContainer(
        duration: DesignTokens.animationDurationNormal,
        padding: DesignTokens.spacingL,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.95),
          borderRadius: DesignTokens.radiusL,
          boxShadow: [
            ShadowTokens.createShadow(
              color: Colors.black,
              opacity: 0.2,
              blurRadius: DesignTokens.blurRadiusL,
            ),
          ],
        ),
        child: const RiskLegendWidget(),
      ),
    );
  }

  // Métodos de interacción
  void _onMapTap(LatLng point) {
    HapticFeedback.lightImpact();
    debugPrint('Map tapped at: ${point.latitude}, ${point.longitude}');
  }

  void _onPolygonTap(RiskPolygon polygon) {
    HapticFeedback.mediumImpact();
    _showPolygonDetails(polygon);
  }

  void _onPOITap(POIEntity poi) {
    HapticFeedback.mediumImpact();
    _showPOIDetails(poi);
  }

  void _showCurrentLocation() {
    HapticFeedback.lightImpact();
    // TODO: Implementar geolocalización
    _mapController.move(const LatLng(19.4326, -99.1332), 15.0);
  }

  void _showLayersBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
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
        child: const POIFilterBottomSheet(),
      ),
    );
  }

  void _showPolygonDetails(RiskPolygon polygon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Zona de Riesgo ${polygon.riskLevel.name.toUpperCase()}'),
        content: Text('Información detallada de la zona de riesgo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPOIDetails(POIEntity poi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(poi.name),
        content: Text('Tipo: ${poi.type}\nDescripción: ${poi.description ?? "No disponible"}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

/// Clase de utilidad para sombras siguiendo el design system
class ShadowTokens {
  static BoxShadow createShadow({
    required Color color,
    double opacity = 0.1,
    double blurRadius = 4.0,
    Offset offset = const Offset(0, 2),
  }) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blurRadius,
      offset: offset,
    );
  }
}