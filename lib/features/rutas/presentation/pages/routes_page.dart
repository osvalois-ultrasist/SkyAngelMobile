import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/header_bar.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/route_entity.dart';
import '../providers/routes_provider.dart';
// import '../providers/routes_state.dart';
import '../widgets/route_search_widget.dart';
import '../widgets/route_list_widget.dart';
import '../widgets/route_map_widget.dart';
import '../widgets/route_options_widget.dart';
import '../widgets/route_statistics_widget.dart';
import '../widgets/route_filter_bottom_sheet.dart' as filter_sheet;

class RoutesPage extends ConsumerStatefulWidget {
  const RoutesPage({super.key});

  @override
  ConsumerState<RoutesPage> createState() => _RoutesPageState();
}

/// Página de rutas refinada y homologada con el marco de diseño
/// Optimizada para transportistas con diseño consistente con mapas
class _RoutesPageState extends ConsumerState<RoutesPage>
    with TickerProviderStateMixin {
  late AnimationController _entryAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _cardAnimationController;
  late TabController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fabAnimation;
  
  RouteType _selectedRouteType = RouteType.safest;
  bool _showMap = true;
  bool _showRouteStatistics = false;
  bool _isRoutesReady = false;
  
  // Search state
  LatLng? _origin;
  LatLng? _destination;
  bool _isSearching = false;
  // RouteFilter? _activeRouteFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadRoutesData();
  }

  void _initializeAnimations() {
    // Animación de entrada principal (similar al mapa)
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

  void _loadRoutesData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedRoutesNotifierProvider.notifier).loadSavedRoutes('current_user');
      
      // Simular carga de rutas y animar entrada
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _isRoutesReady = true);
          _fabAnimationController.forward();
          _cardAnimationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entryAnimationController.dispose();
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeState = ref.watch(routeCalculationNotifierProvider);
    final savedRoutesState = ref.watch(savedRoutesNotifierProvider);
    
    return AnimatedBuilder(
      animation: _entryAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Scaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: HeaderBarFactory.routes(
        subtitle: 'Encuentra la ruta más segura a tu destino',
        actions: [
          HeaderActions.viewMode(() {
            setState(() {
              _showMap = !_showMap;
            });
          }),
          HeaderActions.filter(() {
            // TODO: Show route type filter
          }),
          HeaderActions.refresh(() {
            HapticFeedback.lightImpact();
            if (_origin != null && _destination != null) {
              _searchRoutes();
            } else {
              _refreshData();
            }
          }),
          // HeaderActions.more(() {
          //   // TODO: Show more options
          // }),
        ],
      ),
      body: Column(
        children: [
          // TabBar moved here since UnifiedAppBar doesn't support bottom parameter
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Buscar', icon: Icon(Icons.search_rounded, size: 16)),
                Tab(text: 'Guardadas', icon: Icon(Icons.bookmark_rounded, size: 16)),
                Tab(text: 'Historial', icon: Icon(Icons.history_rounded, size: 16)),
              ],
            ),
          ),
          // Route search bar (always visible)
          Container(
            padding: const EdgeInsets.all(16),
            child: RouteSearchWidget(
              onOriginChanged: (location) {
                setState(() {
                  _origin = location;
                });
              },
              onDestinationChanged: (location) {
                setState(() {
                  _destination = location;
                });
              },
              onSearchPressed: _searchRoutes,
              isLoading: _isSearching,
            ),
          ),
          
          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(routeState),
                _buildSavedRoutesTab(savedRoutesState),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isRoutesReady && _origin != null && _destination != null
          ? AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showRouteOptionsDialog(context),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: DesignTokens.elevationL,
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Comenzar'),
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchTab(AsyncValue<List<RouteEntity>> routeState) {
    if (_origin == null || _destination == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Buscar Rutas Seguras',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa origen y destino para calcular\nrutas optimizadas con análisis de seguridad',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Análisis de seguridad en tiempo real',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Optimización inteligente de rutas',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Alertas y recomendaciones',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return routeState.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al calcular rutas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchRoutes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (routes) {
        if (routes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.route_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No se encontraron rutas'),
                SizedBox(height: 8),
                Text('Intenta con ubicaciones diferentes'),
              ],
            ),
          );
        }

        return _showMap
            ? RouteMapWidget(
                routes: routes,
                selectedRouteType: _selectedRouteType,
                onRouteSelected: (route) => _selectRoute(route),
              )
            : RouteListWidget(
                routes: routes,
                onRouteSelected: (route) => _selectRoute(route),
                onRouteSaved: (route) => _saveRoute(route),
              );
      },
    );
  }

  Widget _buildSavedRoutesTab(AsyncValue<List<RouteEntity>> savedRoutesState) {
    return savedRoutesState.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar rutas guardadas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(savedRoutesNotifierProvider.notifier)
                  .loadSavedRoutes('current_user'),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (routes) {
        if (routes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No tienes rutas guardadas'),
                SizedBox(height: 8),
                Text('Las rutas que guardes aparecerán aquí'),
              ],
            ),
          );
        }

        return RouteListWidget(
          routes: routes,
          onRouteSelected: (route) => _selectRoute(route),
          onRouteDeleted: (route) => _deleteRoute(route),
          showSaveButton: false,
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Historial de Rutas'),
          SizedBox(height: 8),
          Text('Funcionalidad en desarrollo'),
        ],
      ),
    );
  }

  IconData _getRouteTypeIcon(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return Icons.speed_rounded;
      case RouteType.shortest:
        return Icons.straighten_rounded;
      case RouteType.safest:
        return Icons.security_rounded;
      case RouteType.mostEconomical:
        return Icons.savings_rounded;
      case RouteType.balanced:
        return Icons.balance_rounded;
      case RouteType.custom:
        return Icons.tune_rounded;
    }
  }

  void _searchRoutes() {
    if (_origin == null || _destination == null) return;
    
    setState(() {
      _isSearching = true;
    });

    ref.read(routeCalculationNotifierProvider.notifier).calculateRoute(
      origin: _origin!,
      destination: _destination!,
      routeType: _selectedRouteType,
    ).then((_) {
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _selectRoute(RouteEntity route) {
    // Show route details or start navigation
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Detalles de la Ruta',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRouteDetailCard(route),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _startNavigation(route);
                              },
                              icon: const Icon(Icons.navigation_rounded),
                              label: const Text('Iniciar Navegación'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _saveRoute(route),
                            icon: const Icon(Icons.bookmark_border_rounded),
                            tooltip: 'Guardar ruta',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteDetailCard(RouteEntity route) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRouteTypeIcon(route.routeType),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  route.routeType.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSafetyColor(route.safetyAnalysis.overallRiskScore),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    route.safetyAnalysis.riskLevel.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.access_time_rounded,
                    label: 'Duración',
                    value: '${route.estimatedDurationMinutes} min',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.straighten_rounded,
                    label: 'Distancia',
                    value: '${route.distanceKm.toStringAsFixed(1)} km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.security_rounded,
                    label: 'Seguridad',
                    value: '${(route.safetyAnalysis.overallRiskScore * 10).toInt()}/10',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.warning_rounded,
                    label: 'Alertas',
                    value: '${route.safetyAnalysis.currentAlerts.length}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getSafetyColor(double riskScore) {
    if (riskScore <= 0.3) return Colors.green;
    if (riskScore <= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _saveRoute(RouteEntity route) {
    ref.read(savedRoutesNotifierProvider.notifier).saveRoute(route, 'current_user');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ruta guardada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteRoute(RouteEntity route) {
    ref.read(savedRoutesNotifierProvider.notifier).deleteRoute(route.id, 'current_user');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ruta eliminada'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _startNavigation(RouteEntity route) {
    // TODO: Implement navigation start
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegación iniciada - Funcionalidad en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showRouteOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RouteOptionsWidget(
        origin: _origin!,
        destination: _destination!,
        onRouteTypeSelected: (routeType) {
          setState(() {
            _selectedRouteType = routeType;
          });
          _searchRoutes();
        },
      ),
    );
  }

  void _refreshData() {
    if (_origin != null && _destination != null) {
      _searchRoutes();
    }
    ref.read(savedRoutesNotifierProvider.notifier).loadSavedRoutes('current_user');
  }
}