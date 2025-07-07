import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/route_entity.dart';
import '../providers/routes_provider.dart';

/// Widget de estadísticas de rutas siguiendo el patrón de mapas
/// Muestra métricas clave con animaciones y diseño consistente
class RouteStatisticsWidget extends ConsumerStatefulWidget {
  final List<RouteEntity> routes;
  final VoidCallback? onStatisticTap;

  const RouteStatisticsWidget({
    super.key,
    required this.routes,
    this.onStatisticTap,
  });

  @override
  ConsumerState<RouteStatisticsWidget> createState() => _RouteStatisticsWidgetState();
}

class _RouteStatisticsWidgetState extends ConsumerState<RouteStatisticsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (widget.routes.isEmpty) {
      return const SizedBox.shrink();
    }

    final statistics = _calculateStatistics();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colorScheme, theme),
                  SizedBox(height: DesignTokens.spacing4),
                  _buildStatisticsGrid(statistics, colorScheme, theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, ThemeData theme) {
    return Row(
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
                'Análisis de Rutas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: DesignTokens.fontWeightSemiBold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${widget.routes.length} rutas analizadas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        if (widget.onStatisticTap != null)
          Container(
            padding: DesignTokens.paddingHorizontalM.add(DesignTokens.paddingVerticalS),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: DesignTokens.radiusM,
            ),
            child: Text(
              'VER MÁS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.blue[700],
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatisticsGrid(
    RouteStatistics statistics,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            'Ruta Más Segura',
            '${(statistics.averageSafetyScore * 10).toInt()}/10',
            Icons.security_rounded,
            Colors.green,
            colorScheme,
            theme,
          ),
        ),
        SizedBox(width: DesignTokens.spacing2),
        Expanded(
          child: _buildStatisticCard(
            'Tiempo Promedio',
            '${statistics.averageDurationMinutes.toInt()} min',
            Icons.access_time_rounded,
            Colors.blue,
            colorScheme,
            theme,
          ),
        ),
        SizedBox(width: DesignTokens.spacing2),
        Expanded(
          child: _buildStatisticCard(
            'Distancia',
            '${statistics.averageDistanceKm.toStringAsFixed(1)} km',
            Icons.straighten_rounded,
            Colors.orange,
            colorScheme,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  RouteStatistics _calculateStatistics() {
    if (widget.routes.isEmpty) {
      return RouteStatistics(
        totalRoutes: 0,
        averageSafetyScore: 0.0,
        averageDurationMinutes: 0.0,
        averageDistanceKm: 0.0,
        safestRoute: null,
        fastestRoute: null,
        shortestRoute: null,
      );
    }

    final totalSafetyScore = widget.routes
        .map((route) => route.safetyAnalysis.overallRiskScore)
        .reduce((a, b) => a + b);
    
    final totalDuration = widget.routes
        .map((route) => route.estimatedDurationMinutes.toDouble())
        .reduce((a, b) => a + b);
    
    final totalDistance = widget.routes
        .map((route) => route.distanceKm)
        .reduce((a, b) => a + b);

    // Encontrar la ruta más segura (menor riesgo)
    final safestRoute = widget.routes.reduce(
      (current, next) => current.safetyAnalysis.overallRiskScore < 
          next.safetyAnalysis.overallRiskScore ? current : next,
    );

    // Encontrar la ruta más rápida
    final fastestRoute = widget.routes.reduce(
      (current, next) => current.estimatedDurationMinutes < 
          next.estimatedDurationMinutes ? current : next,
    );

    // Encontrar la ruta más corta
    final shortestRoute = widget.routes.reduce(
      (current, next) => current.distanceKm < next.distanceKm ? current : next,
    );

    return RouteStatistics(
      totalRoutes: widget.routes.length,
      averageSafetyScore: 1.0 - (totalSafetyScore / widget.routes.length), // Invertir para que mayor sea mejor
      averageDurationMinutes: totalDuration / widget.routes.length,
      averageDistanceKm: totalDistance / widget.routes.length,
      safestRoute: safestRoute,
      fastestRoute: fastestRoute,
      shortestRoute: shortestRoute,
    );
  }
}

/// Clase de utilidad para estadísticas de rutas
class RouteStatistics {
  final int totalRoutes;
  final double averageSafetyScore;
  final double averageDurationMinutes;
  final double averageDistanceKm;
  final RouteEntity? safestRoute;
  final RouteEntity? fastestRoute;
  final RouteEntity? shortestRoute;

  const RouteStatistics({
    required this.totalRoutes,
    required this.averageSafetyScore,
    required this.averageDurationMinutes,
    required this.averageDistanceKm,
    this.safestRoute,
    this.fastestRoute,
    this.shortestRoute,
  });
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