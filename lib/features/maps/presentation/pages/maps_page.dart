import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/unified_app_bar.dart';
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

class MapsPage extends ConsumerStatefulWidget {
  const MapsPage({super.key});

  @override
  ConsumerState<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends ConsumerState<MapsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();
  
  RiskFilter? _activeRiskFilter;
  POIFilter? _activePOIFilter;
  bool _showRiskLayer = true;
  bool _showPOILayer = true;
  bool _showRiskLegend = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial map data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapsNotifierProvider.notifier).refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapsState = ref.watch(mapsNotifierProvider);
    final highRiskPolygons = ref.watch(highRiskPolygonsProvider);
    final activePOIs = ref.watch(activePOIsProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: UnifiedAppBarFactory.maps(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(mapsNotifierProvider.notifier).refreshData();
            },
            tooltip: 'Actualizar mapa',
          ),
          IconButton(
            icon: Icon(_showRiskLegend ? Icons.toggle_on_rounded : Icons.toggle_off_rounded),
            onPressed: () {
              setState(() {
                _showRiskLegend = !_showRiskLegend;
              });
            },
            tooltip: 'Mostrar leyenda',
          ),
          IconButton(
            icon: const Icon(Icons.layers_rounded),
            onPressed: () => _showLayersBottomSheet(context),
            tooltip: 'Capas del mapa',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'center_location',
                child: Row(
                  children: [
                    const Icon(Icons.my_location_rounded),
                    const SizedBox(width: 8),
                    const Text('Centrar en mi ubicación'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded),
                    SizedBox(width: 8),
                    Text('Exportar mapa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded),
                    SizedBox(width: 8),
                    Text('Ayuda'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Tab Bar
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
                    Tab(text: 'Mapa', icon: Icon(Icons.map_rounded, size: 20)),
                    Tab(text: 'Riesgos', icon: Icon(Icons.warning_rounded, size: 20)),
                    Tab(text: 'POIs', icon: Icon(Icons.place_rounded, size: 20)),
                  ],
                ),
              ),
              
              // Active filters
              if (_activeRiskFilter != null || _activePOIFilter != null)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (_activeRiskFilter != null)
                        Chip(
                          label: Text('Filtro de Riesgo Activo'),
                          backgroundColor: theme.colorScheme.errorContainer,
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          onDeleted: () => _clearRiskFilter(),
                        ),
                      if (_activeRiskFilter != null && _activePOIFilter != null)
                        const SizedBox(width: 8),
                      if (_activePOIFilter != null)
                        Chip(
                          label: Text('Filtro de POI Activo'),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          onDeleted: () => _clearPOIFilter(),
                        ),
                      const Spacer(),
                      if (_activeRiskFilter != null || _activePOIFilter != null)
                        TextButton.icon(
                          onPressed: () {
                            _clearRiskFilter();
                            _clearPOIFilter();
                          },
                          icon: const Icon(Icons.clear_all_rounded, size: 16),
                          label: const Text('Limpiar todo'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                child: LocationSearchWidget(
                  onLocationSelected: (location) {
                    _centerMapOn(location);
                  },
                ),
              ),
              
              // Map Statistics
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: MapStatisticsWidget(),
              ),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMapTab(mapsState),
                    _buildRiskPolygonsTab(highRiskPolygons),
                    _buildPOIsTab(activePOIs),
                  ],
                ),
              ),
            ],
          ),
          
          // Risk legend overlay
          if (_showRiskLegend)
            Positioned(
              top: 16,
              right: 16,
              child: RiskLegendWidget(
                onClose: () => setState(() => _showRiskLegend = false),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "center_location",
            onPressed: _centerOnCurrentLocation,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            mini: true,
            child: const Icon(Icons.my_location_rounded),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "filter",
            onPressed: () => _showFiltersBottomSheet(context),
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
            mini: true,
            child: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab(MapsState mapsState) {
    return mapsState.when(
      initial: () => const Center(
        child: Text('Cargando mapa...'),
      ),
      loading: () => const Center(child: LoadingWidget()),
      loaded: (polygons, pois, location, riskFilter, poiFilter) {
        return MapWidget(
          mapController: _mapController,
          center: location ?? const LatLng(19.4326, -99.1332), // Default to Mexico City
          riskPolygons: _showRiskLayer ? polygons : [],
          pois: _showPOILayer ? pois : [],
          onMapTap: _onMapTap,
          onPolygonTap: _onPolygonTap,
          onPOITap: _onPOITap,
        );
      },
      error: (error, message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el mapa',
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
                ref.read(mapsNotifierProvider.notifier).clearError();
                ref.read(mapsNotifierProvider.notifier).refreshData();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskPolygonsTab(List<RiskPolygon> polygons) {
    if (polygons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No hay zonas de alto riesgo',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: polygons.length,
      itemBuilder: (context, index) {
        final polygon = polygons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: polygon.riskLevel.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getRiskIcon(polygon.riskLevel),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(polygon.riskLevel.label),
            subtitle: Text(
              'Nivel de riesgo: ${polygon.riskLevel.description}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.map_rounded),
              onPressed: () {
                _tabController.animateTo(0);
                _centerMapOnPolygon(polygon);
              },
            ),
            onTap: () => _showPolygonDetails(polygon),
          ),
        );
      },
    );
  }

  Widget _buildPOIsTab(List<POIEntity> pois) {
    if (pois.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay puntos de interés',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pois.length,
      itemBuilder: (context, index) {
        final poi = pois[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: poi.type.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                poi.type.icon,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            title: Text(poi.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(poi.type.label),
                if (poi.address != null)
                  Text(
                    poi.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.map_rounded),
              onPressed: () {
                _tabController.animateTo(0);
                _centerMapOnPOI(poi);
              },
            ),
            onTap: () => _showPOIDetails(poi),
          ),
        );
      },
    );
  }

  void _showLayersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capas del mapa',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Capa de riesgos'),
              subtitle: const Text('Mostrar polígonos de riesgo'),
              value: _showRiskLayer,
              onChanged: (value) {
                setState(() {
                  _showRiskLayer = value;
                });
                Navigator.pop(context);
              },
            ),
            
            SwitchListTile(
              title: const Text('Puntos de interés'),
              subtitle: const Text('Mostrar POIs en el mapa'),
              value: _showPOILayer,
              onChanged: (value) {
                setState(() {
                  _showPOILayer = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const TabBar(
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

  void _onMapTap(LatLng location) {
    // Handle map tap
  }

  void _onPolygonTap(RiskPolygon polygon) {
    _showPolygonDetails(polygon);
  }

  void _onPOITap(POIEntity poi) {
    _showPOIDetails(poi);
  }

  void _showPolygonDetails(RiskPolygon polygon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: polygon.riskLevel.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(polygon.riskLevel.label),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción: ${polygon.riskLevel.description}'),
            const SizedBox(height: 8),
            Text('Fuente: ${polygon.dataSource.label}'),
            if (polygon.crimeTypes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Tipos de crimen: ${polygon.crimeTypes.map((e) => e.label).join(', ')}'),
            ],
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

  void _showPOIDetails(POIEntity poi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(poi.type.icon, style: TextStyle(color: poi.type.color, fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(poi.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${poi.type.label}'),
            const SizedBox(height: 8),
            Text('Descripción: ${poi.description}'),
            if (poi.address != null) ...[
              const SizedBox(height: 8),
              Text('Dirección: ${poi.address}'),
            ],
            if (poi.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Calificación: '),
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
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _centerMapOn(LatLng location) {
    _mapController.move(location, 15.0);
    ref.read(mapsNotifierProvider.notifier).updateCurrentLocation(location);
  }

  void _centerMapOnPolygon(RiskPolygon polygon) {
    if (polygon.coordinates.isNotEmpty) {
      final center = polygon.coordinates.first; // Simplified
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

  void _applyRiskFilter(RiskFilter? filter) {
    setState(() {
      _activeRiskFilter = filter;
    });
    ref.read(mapsNotifierProvider.notifier).applyRiskFilter(filter);
    Navigator.pop(context);
  }

  void _applyPOIFilter(POIFilter? filter) {
    setState(() {
      _activePOIFilter = filter;
    });
    ref.read(mapsNotifierProvider.notifier).applyPOIFilter(filter);
    Navigator.pop(context);
  }

  void _clearRiskFilter() {
    setState(() {
      _activeRiskFilter = null;
    });
    ref.read(mapsNotifierProvider.notifier).applyRiskFilter(null);
  }

  void _clearPOIFilter() {
    setState(() {
      _activePOIFilter = null;
    });
    ref.read(mapsNotifierProvider.notifier).applyPOIFilter(null);
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'center_location':
        _centerOnCurrentLocation();
        break;
      case 'export':
        _showExportDialog(context);
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
            Icon(Icons.download_rounded),
            SizedBox(width: 8),
            Text('Exportar mapa'),
          ],
        ),
        content: const Text('¿En qué formato deseas exportar el mapa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportMapAsImage();
            },
            child: const Text('Imagen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportMapData();
            },
            child: const Text('Datos'),
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
            Icon(Icons.help_outline_rounded),
            SizedBox(width: 8),
            Text('Ayuda del Mapa'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cómo usar el mapa:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Arrastra para mover el mapa'),
              Text('• Pellizca para hacer zoom'),
              Text('• Toca un polígono para ver detalles de riesgo'),
              Text('• Toca un POI para ver información'),
              Text('• Usa los filtros para personalizar la vista'),
              SizedBox(height: 16),
              Text(
                'Niveles de riesgo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('🟢 Muy Bajo: Zona muy segura'),
              Text('🟡 Bajo: Zona segura'),
              Text('🟠 Moderado: Precaución recomendada'),
              Text('🔴 Alto: Alto riesgo'),
              Text('🟣 Muy Alto: Zona peligrosa'),
              Text('⚫ Extremo: Evitar completamente'),
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

  void _exportMapAsImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportación de imagen en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _exportMapData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportación de datos en desarrollo'),
        backgroundColor: Colors.orange,
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
