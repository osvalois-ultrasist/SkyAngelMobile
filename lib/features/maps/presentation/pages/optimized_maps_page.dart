import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/header_bar.dart';
import '../../../../shared/widgets/map_skeleton_widgets.dart';
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

/// Maps page optimizada con performance mejorada, lazy loading y skeleton states
/// Implementa el diseño refinado de SkyAngel con estados de carga avanzados
class OptimizedMapsPage extends ConsumerStatefulWidget {
  const OptimizedMapsPage({super.key});

  @override
  ConsumerState<OptimizedMapsPage> createState() => _OptimizedMapsPageState();
}

class _OptimizedMapsPageState extends ConsumerState<OptimizedMapsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  // Animation controllers para transiciones fluidas
  late AnimationController _pageController;
  late AnimationController _searchController;
  late AnimationController _filtersController;
  
  // Animations
  late Animation<double> _pageAnimation;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _filtersScaleAnimation;
  
  // Map and tab controllers
  late TabController _tabController;
  final MapController _mapController = MapController();
  
  // State variables
  RiskFilter? _activeRiskFilter;
  POIFilter? _activePOIFilter;
  bool _showRiskLayer = true;
  bool _showPOILayer = true;
  bool _showRiskLegend = false;
  bool _isSearchExpanded = false;
  bool _isInitialized = false;
  
  // Performance optimization - debounce timers
  Duration _refreshDebounce = const Duration(milliseconds: 300);
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupTabController();
    _scheduleInitialLoad();
  }

  void _initializeAnimations() {
    _pageController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _searchController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _filtersController = AnimationController(
      duration: DesignTokens.animationDurationQuick,
      vsync: this,
    );
    
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutQuart,
    ));
    
    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOutCubic,
    ));
    
    _filtersScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filtersController,
      curve: Curves.easeOutBack,
    ));

    // Start page animation
    _pageController.forward();
  }

  void _setupTabController() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.lightImpact();
      _animateTabTransition();
    }
  }

  void _animateTabTransition() {
    _filtersController.reset();
    _filtersController.forward();
  }

  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(_refreshDebounce, () {
        if (mounted && !_isInitialized) {
          ref.read(mapsNotifierProvider.notifier).refreshData();
          _isInitialized = true;
          _searchController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _filtersController.dispose();
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mapsState = ref.watch(mapsNotifierProvider);
    final theme = Theme.of(context);
    
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _pageAnimation,
        child: Scaffold(
          appBar: _buildOptimizedAppBar(context),
          body: _buildResponsiveBody(context, mapsState, theme),
          floatingActionButton: _buildFloatingActions(context, theme),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildOptimizedAppBar(BuildContext context) {
    return HeaderBarFactory.maps(
      subtitle: 'Datos en tiempo real • Seguridad inteligente',
      actions: [
        HeaderActions.layers(() => _showLayersBottomSheet(context)),
        HeaderAction(
          icon: _showRiskLegend ? Icons.legend_toggle : Icons.legend_toggle_outlined,
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _showRiskLegend = !_showRiskLegend);
          },
          tooltip: 'Leyenda de riesgos',
        ),
      ],
    );
  }

  Widget _buildResponsiveBody(BuildContext context, MapsState mapsState, ThemeData theme) {
    return Column(
      children: [
        // Search section with animation
        SlideTransition(
          position: _searchSlideAnimation,
          child: _buildSearchSection(context),
        ),
        
        // Tab navigation
        _buildTabBar(context, theme),
        
        // Active filters with animations
        AnimatedContainer(
          duration: DesignTokens.animationDurationNormal,
          height: (_activeRiskFilter != null || _activePOIFilter != null) ? 60 : 0,
          child: _buildActiveFiltersSection(context, theme),
        ),
        
        // Main content with optimized loading
        Expanded(
          child: _buildMainContent(context, mapsState, theme),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      margin: DesignTokens.spacingL,
      child: AnimatedContainer(
        duration: DesignTokens.animationDurationNormal,
        padding: DesignTokens.spacingM,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: DesignTokens.radiusXL,
          boxShadow: [
            ShadowTokens.createShadow(
              color: Theme.of(context).shadowColor,
              opacity: DesignTokens.shadowOpacityLight,
              blurRadius: DesignTokens.blurRadiusL,
            ),
          ],
        ),
        child: Column(
          children: [
            LocationSearchWidget(
              onLocationSelected: (location) => _centerMapOn(location),
              isExpanded: _isSearchExpanded,
              onExpandChanged: (expanded) {
                setState(() => _isSearchExpanded = expanded);
              },
            ),
            
            // Statistics cards con skeleton loading
            SizedBox(height: DesignTokens.spacing3),
            _buildStatisticsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    final mapsState = ref.watch(mapsNotifierProvider);
    
    return mapsState.when(
      initial: () => MapSkeletonLoaders.mapHeader(),
      loading: () => MapSkeletonLoaders.mapHeader(),
      loaded: (_, __, ___, ____, _____) => const MapStatisticsWidget(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTabBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: DesignTokens.paddingHorizontalXL,
      decoration: BoxDecoration(
        borderRadius: DesignTokens.radiusXL,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          borderRadius: DesignTokens.radiusXL,
          color: theme.colorScheme.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontWeight: DesignTokens.fontWeightSemiBold,
          fontSize: DesignTokens.fontSizeS,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: DesignTokens.fontWeightMedium,
          fontSize: DesignTokens.fontSizeS,
        ),
        dividerColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        tabs: [
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: DesignTokens.iconSizeS),
                SizedBox(width: DesignTokens.spacing1),
                Text('Mapa'),
              ],
            ),
          ),
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, size: DesignTokens.iconSizeS),
                SizedBox(width: DesignTokens.spacing1),
                Text('Riesgos'),
              ],
            ),
          ),
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.place_rounded, size: DesignTokens.iconSizeS),
                SizedBox(width: DesignTokens.spacing1),
                Text('POIs'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersSection(BuildContext context, ThemeData theme) {
    if (_activeRiskFilter == null && _activePOIFilter == null) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _filtersScaleAnimation,
      child: Container(
        padding: DesignTokens.paddingHorizontalXL,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (_activeRiskFilter != null) ...[
                _buildFilterChip(
                  'Filtro de Riesgo',
                  theme.colorScheme.errorContainer,
                  theme.colorScheme.onErrorContainer,
                  () => _clearRiskFilter(),
                ),
                SizedBox(width: DesignTokens.spacing2),
              ],
              if (_activePOIFilter != null) ...[
                _buildFilterChip(
                  'Filtro de POI',
                  theme.colorScheme.secondaryContainer,
                  theme.colorScheme.onSecondaryContainer,
                  () => _clearPOIFilter(),
                ),
                SizedBox(width: DesignTokens.spacing2),
              ],
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _clearAllFilters();
                },
                icon: Icon(Icons.clear_all_rounded, size: DesignTokens.iconSizeS),
                label: Text('Limpiar todo'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  padding: DesignTokens.paddingHorizontalL,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color backgroundColor, Color foregroundColor, VoidCallback onRemove) {
    return Container(
      padding: DesignTokens.paddingHorizontalM.add(DesignTokens.paddingVerticalS),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: DesignTokens.radiusL,
        border: Border.all(
          color: foregroundColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: DesignTokens.fontSizeS,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
          SizedBox(width: DesignTokens.spacing1),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRemove();
            },
            child: Icon(
              Icons.close_rounded,
              size: DesignTokens.iconSizeS,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, MapsState mapsState, ThemeData theme) {
    return ScaleTransition(
      scale: _filtersScaleAnimation,
      child: Stack(
        children: [
          // Main TabBarView
          TabBarView(
            controller: _tabController,
            children: [
              _buildOptimizedMapTab(mapsState),
              _buildOptimizedRiskTab(),
              _buildOptimizedPOITab(),
            ],
          ),
          
          // Risk legend overlay
          if (_showRiskLegend)
            Positioned(
              top: DesignTokens.spacing4,
              right: DesignTokens.spacing4,
              child: RiskLegendWidget(
                onClose: () => setState(() => _showRiskLegend = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptimizedMapTab(MapsState mapsState) {
    return RepaintBoundary(
      child: mapsState.when(
        initial: () => MapSkeletonLoaders.mapView(),
        loading: () => MapSkeletonLoaders.mapView(),
        loaded: (polygons, pois, location, riskFilter, poiFilter) {
          return MapWidget(
            mapController: _mapController,
            center: location ?? const LatLng(19.4326, -99.1332),
            riskPolygons: _showRiskLayer ? polygons : [],
            pois: _showPOILayer ? pois : [],
            onMapTap: _onMapTap,
            onPolygonTap: _onPolygonTap,
            onPOITap: _onPOITap,
          );
        },
        error: (error, message) => _buildErrorState(context, error, message),
      ),
    );
  }

  Widget _buildOptimizedRiskTab() {
    final highRiskPolygons = ref.watch(highRiskPolygonsProvider);
    
    if (highRiskPolygons.isEmpty) {
      return MapSkeletonLoaders.riskPolygonsList();
    }
    
    return RepaintBoundary(
      child: _buildRiskPolygonsList(highRiskPolygons),
    );
  }

  Widget _buildOptimizedPOITab() {
    final activePOIs = ref.watch(activePOIsProvider);
    
    if (activePOIs.isEmpty) {
      return MapSkeletonLoaders.poisList();
    }
    
    return RepaintBoundary(
      child: _buildPOIsList(activePOIs),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, String message) {
    return Container(
      padding: DesignTokens.spacingXXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: DesignTokens.spacingXL,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: DesignTokens.radiusXXL,
            ),
            child: Icon(
              Icons.warning_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          
          SizedBox(height: DesignTokens.spacing6),
          
          Text(
            'Error al cargar el mapa',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: DesignTokens.spacing2),
          
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: DesignTokens.spacing6),
          
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(mapsNotifierProvider.notifier).clearError();
              ref.read(mapsNotifierProvider.notifier).refreshData();
            },
            icon: Icon(Icons.refresh_rounded),
            label: Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              padding: DesignTokens.paddingHorizontalXL.add(DesignTokens.paddingVerticalL),
              shape: RoundedRectangleBorder(
                borderRadius: DesignTokens.radiusL,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskPolygonsList(List<RiskPolygon> polygons) {
    return ListView.builder(
      padding: DesignTokens.spacingL,
      itemCount: polygons.length,
      itemBuilder: (context, index) {
        final polygon = polygons[index];
        return _buildOptimizedRiskCard(polygon, index);
      },
    );
  }

  Widget _buildOptimizedRiskCard(RiskPolygon polygon, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusL,
        ),
        child: InkWell(
          onTap: () => _showPolygonDetails(polygon),
          borderRadius: DesignTokens.radiusL,
          child: Padding(
            padding: DesignTokens.spacingL,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: polygon.riskLevel.color,
                    borderRadius: DesignTokens.radiusM,
                    boxShadow: [
                      ShadowTokens.createShadow(
                        color: polygon.riskLevel.color,
                        opacity: 0.3,
                        blurRadius: DesignTokens.blurRadiusS,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getRiskIcon(polygon.riskLevel),
                    color: Colors.white,
                    size: DesignTokens.iconSizeL,
                  ),
                ),
                
                SizedBox(width: DesignTokens.spacing4),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        polygon.riskLevel.label,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeL,
                          fontWeight: DesignTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacing1),
                      Text(
                        polygon.riskLevel.description,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeS,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                IconButton(
                  icon: Icon(Icons.map_rounded),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _tabController.animateTo(0);
                    _centerMapOnPolygon(polygon);
                  },
                  tooltip: 'Ver en mapa',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPOIsList(List<POIEntity> pois) {
    return ListView.builder(
      padding: DesignTokens.spacingL,
      itemCount: pois.length,
      itemBuilder: (context, index) {
        final poi = pois[index];
        return _buildOptimizedPOICard(poi, index);
      },
    );
  }

  Widget _buildOptimizedPOICard(POIEntity poi, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusL,
        ),
        child: InkWell(
          onTap: () => _showPOIDetails(poi),
          borderRadius: DesignTokens.radiusL,
          child: Padding(
            padding: DesignTokens.spacingL,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: poi.type.color,
                    borderRadius: DesignTokens.radiusM,
                    boxShadow: [
                      ShadowTokens.createShadow(
                        color: poi.type.color,
                        opacity: 0.3,
                        blurRadius: DesignTokens.blurRadiusS,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      poi.type.icon,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: DesignTokens.fontSizeXL,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: DesignTokens.spacing4),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poi.name,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeL,
                          fontWeight: DesignTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacing1),
                      Text(
                        poi.type.label,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeS,
                          color: poi.type.color,
                          fontWeight: DesignTokens.fontWeightMedium,
                        ),
                      ),
                      if (poi.address != null) ...[
                        SizedBox(height: DesignTokens.spacing1),
                        Text(
                          poi.address!,
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeXS,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                IconButton(
                  icon: Icon(Icons.map_rounded),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _tabController.animateTo(0);
                    _centerMapOnPOI(poi);
                  },
                  tooltip: 'Ver en mapa',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "center_location",
          onPressed: () {
            HapticFeedback.lightImpact();
            _centerOnCurrentLocation();
          },
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          mini: true,
          child: Icon(Icons.my_location_rounded),
        ),
        
        SizedBox(height: DesignTokens.spacing2),
        
        FloatingActionButton(
          heroTag: "filter",
          onPressed: () {
            HapticFeedback.lightImpact();
            _showFiltersBottomSheet(context);
          },
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          mini: true,
          child: Icon(Icons.filter_list_rounded),
        ),
      ],
    );
  }

  // Event handlers and utility methods
  void _onMapTap(LatLng location) {
    // Handle map tap with haptic feedback
    HapticFeedback.selectionClick();
  }

  void _onPolygonTap(RiskPolygon polygon) {
    HapticFeedback.lightImpact();
    _showPolygonDetails(polygon);
  }

  void _onPOITap(POIEntity poi) {
    HapticFeedback.lightImpact();
    _showPOIDetails(poi);
  }

  void _centerMapOn(LatLng location) {
    _mapController.move(location, 15.0);
    ref.read(mapsNotifierProvider.notifier).updateCurrentLocation(location);
  }

  void _centerMapOnPolygon(RiskPolygon polygon) {
    if (polygon.coordinates.isNotEmpty) {
      final center = polygon.coordinates.first;
      _centerMapOn(center);
    }
  }

  void _centerMapOnPOI(POIEntity poi) {
    _centerMapOn(poi.coordinates);
  }

  void _centerOnCurrentLocation() {
    final location = ref.read(currentMapLocationProvider);
    if (location != null) {
      _centerMapOn(location);
    } else {
      ref.read(mapsNotifierProvider.notifier).refreshData();
    }
  }

  void _clearRiskFilter() {
    setState(() => _activeRiskFilter = null);
    ref.read(mapsNotifierProvider.notifier).applyRiskFilter(null);
    _filtersController.forward();
  }

  void _clearPOIFilter() {
    setState(() => _activePOIFilter = null);
    ref.read(mapsNotifierProvider.notifier).applyPOIFilter(null);
    _filtersController.forward();
  }

  void _clearAllFilters() {
    setState(() {
      _activeRiskFilter = null;
      _activePOIFilter = null;
    });
    ref.read(mapsNotifierProvider.notifier).applyRiskFilter(null);
    ref.read(mapsNotifierProvider.notifier).applyPOIFilter(null);
  }

  // Bottom sheet and dialog methods
  void _showLayersBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capas del mapa',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),
            
            SwitchListTile(
              title: Text('Capa de riesgos'),
              subtitle: Text('Mostrar polígonos de riesgo'),
              value: _showRiskLayer,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _showRiskLayer = value);
                Navigator.pop(context);
              },
            ),
            
            SwitchListTile(
              title: Text('Puntos de interés'),
              subtitle: Text('Mostrar POIs en el mapa'),
              value: _showPOILayer,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _showPOILayer = value);
                Navigator.pop(context);
              },
            ),
            
            SizedBox(height: DesignTokens.spacing4),
          ],
        ),
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: DesignTokens.radiusXL.copyWith(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: DesignTokens.spacing2),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: DesignTokens.radiusXS,
                  ),
                ),
                
                TabBar(
                  labelStyle: TextStyle(fontWeight: DesignTokens.fontWeightSemiBold),
                  tabs: [
                    Tab(text: 'Filtros de Riesgo'),
                    Tab(text: 'Filtros de POI'),
                  ],
                ),
                
                Expanded(
                  child: TabBarView(
                    children: [
                      RiskFilterBottomSheet(
                        currentFilter: _activeRiskFilter,
                        onApplyFilter: _applyRiskFilter,
                      ),
                      POIFilterBottomSheet(
                        currentFilter: _activePOIFilter,
                        onApplyFilter: _applyPOIFilter,
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

  void _applyRiskFilter(RiskFilter? filter) {
    setState(() => _activeRiskFilter = filter);
    ref.read(mapsNotifierProvider.notifier).applyRiskFilter(filter);
    Navigator.pop(context);
    _filtersController.forward();
  }

  void _applyPOIFilter(POIFilter? filter) {
    setState(() => _activePOIFilter = filter);
    ref.read(mapsNotifierProvider.notifier).applyPOIFilter(filter);
    Navigator.pop(context);
    _filtersController.forward();
  }

  void _showPolygonDetails(RiskPolygon polygon) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: polygon.riskLevel.color,
                borderRadius: DesignTokens.radiusXS,
              ),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(child: Text(polygon.riskLevel.label)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción: ${polygon.riskLevel.description}'),
            SizedBox(height: DesignTokens.spacing2),
            Text('Fuente: ${polygon.dataSource.label}'),
            if (polygon.crimeTypes.isNotEmpty) ...[
              SizedBox(height: DesignTokens.spacing2),
              Text('Tipos de crimen: ${polygon.crimeTypes.map((e) => e.label).join(', ')}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPOIDetails(POIEntity poi) {
    HapticFeedback.lightImpact();
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
            if (poi.rating != null) ...[
              SizedBox(height: DesignTokens.spacing2),
              Row(
                children: [
                  Text('Calificación: '),
                  ...List.generate(5, (index) => Icon(
                    index < poi.rating! ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: Colors.amber,
                  )),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(RiskLevelType riskLevel) {
    switch (riskLevel) {
      case RiskLevelType.veryLow:
      case RiskLevelType.low:
        return Icons.check_circle_rounded;
      case RiskLevelType.moderate:
        return Icons.warning_rounded;
      case RiskLevelType.high:
      case RiskLevelType.veryHigh:
        return Icons.error_rounded;
      case RiskLevelType.extreme:
        return Icons.dangerous_rounded;
    }
  }
}