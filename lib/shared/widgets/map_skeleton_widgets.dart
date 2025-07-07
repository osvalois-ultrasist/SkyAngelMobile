import 'package:flutter/material.dart';
import '../design_system/design_tokens.dart';

/// Skeleton loading específico para la página de Maps
/// Proporciona estados de carga optimizados y visualmente consistentes
class MapSkeletonLoaders {
  
  /// Skeleton para el header del mapa con estadísticas
  static Widget mapHeader() {
    return Container(
      padding: DesignTokens.spacingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar skeleton
          SkeletonLoadingWidget(
            width: double.infinity,
            height: 48,
            borderRadius: DesignTokens.radiusXXL,
          ),
          
          SizedBox(height: DesignTokens.spacing4),
          
          // Statistics cards row
          Row(
            children: [
              Expanded(child: _StatisticCardSkeleton()),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(child: _StatisticCardSkeleton()),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(child: _StatisticCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton para el mapa principal con overlay de carga
  static Widget mapView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: DesignTokens.radiusL,
      ),
      child: Stack(
        children: [
          // Map background pattern
          _MapPatternSkeleton(),
          
          // Loading overlay
          Center(
            child: Container(
              padding: DesignTokens.spacingXXL,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: DesignTokens.radiusL,
                boxShadow: [
                  ShadowTokens.createShadow(
                    color: Colors.black,
                    opacity: DesignTokens.shadowOpacityLight,
                    blurRadius: DesignTokens.blurRadiusXL,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulseLoadingWidget(
                    size: 60,
                    message: 'Cargando mapa...',
                  ),
                  SizedBox(height: DesignTokens.spacing4),
                  Text(
                    'Obteniendo datos geoespaciales',
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeS,
                      color: Colors.grey[600],
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

  /// Skeleton para lista de puntos de riesgo
  static Widget riskPolygonsList() {
    return ListView.builder(
      padding: DesignTokens.spacingL,
      itemCount: 6,
      itemBuilder: (context, index) => _RiskPolygonItemSkeleton(),
    );
  }

  /// Skeleton para lista de POIs
  static Widget poisList() {
    return ListView.builder(
      padding: DesignTokens.spacingL,
      itemCount: 8,
      itemBuilder: (context, index) => _POIItemSkeleton(),
    );
  }

  /// Skeleton para filtros activos
  static Widget activeFilters() {
    return Container(
      height: 50,
      padding: DesignTokens.paddingHorizontalXL,
      child: Row(
        children: [
          _FilterChipSkeleton(),
          SizedBox(width: DesignTokens.spacing2),
          _FilterChipSkeleton(),
          Spacer(),
          SkeletonLoadingWidget(
            width: 80,
            height: 32,
            borderRadius: DesignTokens.radiusM,
          ),
        ],
      ),
    );
  }

  /// Skeleton para la leyenda de riesgos
  static Widget riskLegend() {
    return Container(
      width: 200,
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignTokens.radiusL,
        boxShadow: [
          ShadowTokens.createShadow(
            color: Colors.black,
            opacity: DesignTokens.shadowOpacityMedium,
            blurRadius: DesignTokens.blurRadiusL,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoadingWidget(
            width: 100,
            height: 20,
            borderRadius: DesignTokens.radiusS,
          ),
          SizedBox(height: DesignTokens.spacing3),
          ...List.generate(6, (index) => Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
            child: Row(
              children: [
                SkeletonLoadingWidget(
                  width: 16,
                  height: 16,
                  borderRadius: DesignTokens.radiusXS,
                ),
                SizedBox(width: DesignTokens.spacing2),
                SkeletonLoadingWidget(
                  width: 80 + (index * 10.0),
                  height: 14,
                  borderRadius: DesignTokens.radiusXS,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Widget de esqueleto para tarjetas de estadísticas
class _StatisticCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: DesignTokens.spacingM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignTokens.radiusM,
        boxShadow: [
          ShadowTokens.createShadow(
            color: Colors.black,
            opacity: DesignTokens.shadowOpacityLight,
            blurRadius: DesignTokens.blurRadiusS,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoadingWidget(
            width: 40,
            height: 40,
            borderRadius: DesignTokens.radiusS,
          ),
          SizedBox(height: DesignTokens.spacing2),
          SkeletonLoadingWidget(
            width: double.infinity,
            height: 24,
            borderRadius: DesignTokens.radiusXS,
          ),
          SizedBox(height: DesignTokens.spacing1),
          SkeletonLoadingWidget(
            width: 60,
            height: 14,
            borderRadius: DesignTokens.radiusXS,
          ),
        ],
      ),
    );
  }
}

/// Patrón de fondo para simular un mapa
class _MapPatternSkeleton extends StatefulWidget {
  @override
  State<_MapPatternSkeleton> createState() => _MapPatternSkeletonState();
}

class _MapPatternSkeletonState extends State<_MapPatternSkeleton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationDurationExtraSlow * 4,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: MapPatternPainter(_animation.value),
        );
      },
    );
  }
}

/// Painter para crear un patrón que simule calles/mapa
class MapPatternPainter extends CustomPainter {
  final double animationValue;
  
  MapPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!.withOpacity(0.3 + (animationValue * 0.2))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dibujar líneas horizontales simulando calles
    for (int i = 0; i < 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Dibujar líneas verticales simulando calles
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Dibujar algunos círculos simulando POIs
    final poiPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2 + (animationValue * 0.3))
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.8),
    ];

    for (final pos in positions) {
      canvas.drawCircle(pos, 8 + (animationValue * 4), poiPaint);
    }
  }

  @override
  bool shouldRepaint(MapPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Skeleton para items de polígonos de riesgo
class _RiskPolygonItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing2),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusM,
        ),
        child: Padding(
          padding: DesignTokens.spacingL,
          child: Row(
            children: [
              SkeletonLoadingWidget(
                width: 40,
                height: 40,
                borderRadius: DesignTokens.radiusS,
              ),
              SizedBox(width: DesignTokens.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoadingWidget(
                      width: double.infinity,
                      height: 18,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                    SizedBox(height: DesignTokens.spacing1),
                    SkeletonLoadingWidget(
                      width: 120,
                      height: 14,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                  ],
                ),
              ),
              SkeletonLoadingWidget(
                width: 24,
                height: 24,
                borderRadius: DesignTokens.radiusXS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton para items de POI
class _POIItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing2),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusM,
        ),
        child: Padding(
          padding: DesignTokens.spacingL,
          child: Row(
            children: [
              SkeletonLoadingWidget(
                width: 40,
                height: 40,
                borderRadius: DesignTokens.radiusS,
              ),
              SizedBox(width: DesignTokens.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoadingWidget(
                      width: double.infinity,
                      height: 16,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                    SizedBox(height: DesignTokens.spacing1),
                    SkeletonLoadingWidget(
                      width: 100,
                      height: 14,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                    SizedBox(height: DesignTokens.spacing1),
                    SkeletonLoadingWidget(
                      width: 160,
                      height: 12,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                  ],
                ),
              ),
              SkeletonLoadingWidget(
                width: 24,
                height: 24,
                borderRadius: DesignTokens.radiusXS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton para chips de filtro
class _FilterChipSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SkeletonLoadingWidget(
      width: 120,
      height: 32,
      borderRadius: DesignTokens.radiusL,
    );
  }
}

/// Extensión del SkeletonLoadingWidget base para consistencia
class SkeletonLoadingWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoadingWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationExtraSlow,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 20,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? DesignTokens.radiusXS,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}