import 'package:flutter/material.dart';
import '../design_system/design_tokens.dart';

/// Skeleton loading específico para operadores de transporte
/// Enfocado en información crítica inmediata y contexto operacional
class TransportSkeletonLoaders {
  
  /// Skeleton para dashboard operacional crítico
  static Widget criticalDashboard() {
    return Container(
      padding: DesignTokens.spacingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado operacional principal
          _CriticalStatusSkeleton(),
          
          SizedBox(height: DesignTokens.spacing4),
          
          // Métricas operacionales en fila
          Row(
            children: [
              Expanded(child: _OperationalMetricSkeleton('ZONAS CRÍTICAS')),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(child: _OperationalMetricSkeleton('ESTADO RUTA')),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(child: _OperationalMetricSkeleton('TIEMPO EST.')),
            ],
          ),
          
          SizedBox(height: DesignTokens.spacing4),
          
          // Mapa operacional
          _OperationalMapSkeleton(),
        ],
      ),
    );
  }

  /// Skeleton para lista de alertas críticas
  static Widget criticalAlertsList() {
    return ListView.builder(
      padding: DesignTokens.spacingL,
      itemCount: 4,
      itemBuilder: (context, index) => _CriticalAlertItemSkeleton(
        isUrgent: index == 0, // Primera alerta siempre urgente
      ),
    );
  }

  /// Skeleton para vista de planificación de rutas
  static Widget routePlanningView() {
    return Container(
      padding: DesignTokens.spacingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanningHeaderSkeleton(),
          
          SizedBox(height: DesignTokens.spacing4),
          
          // Opciones de planificación
          _PlanningOptionSkeleton('Análisis de Seguridad'),
          _PlanningOptionSkeleton('Optimización de Rutas'),
          _PlanningOptionSkeleton('Reportes Operacionales'),
        ],
      ),
    );
  }

  /// Skeleton para búsqueda operacional rápida
  static Widget operationalSearch() {
    return Container(
      margin: DesignTokens.spacingL,
      padding: DesignTokens.spacingM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignTokens.radiusXL,
        boxShadow: [
          ShadowTokens.createShadow(
            color: Colors.black,
            opacity: DesignTokens.shadowOpacityLight,
            blurRadius: DesignTokens.blurRadiusL,
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          SkeletonLoadingWidget(
            width: double.infinity,
            height: 48,
            borderRadius: DesignTokens.radiusXXL,
          ),
          
          SizedBox(height: DesignTokens.spacing3),
          
          // Filtros rápidos
          Row(
            children: [
              _QuickFilterSkeleton('CRÍTICO'),
              SizedBox(width: DesignTokens.spacing2),
              _QuickFilterSkeleton('RUTAS'),
              SizedBox(width: DesignTokens.spacing2),
              _QuickFilterSkeleton('SEGURAS'),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton para overlay de información crítica en mapa
  static Widget mapInfoOverlay() {
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
            // Header operacional
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonLoadingWidget(
                  width: 16,
                  height: 16,
                  borderRadius: DesignTokens.radiusS,
                ),
                SizedBox(width: DesignTokens.spacing1),
                SkeletonLoadingWidget(
                  width: 120,
                  height: 12,
                  borderRadius: DesignTokens.radiusXS,
                ),
              ],
            ),
            
            SizedBox(height: DesignTokens.spacing2),
            
            // Métricas críticas
            ...List.generate(3, (index) => Padding(
              padding: EdgeInsets.only(bottom: DesignTokens.spacing1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonLoadingWidget(
                    width: 8,
                    height: 8,
                    borderRadius: DesignTokens.radiusFull,
                  ),
                  SizedBox(width: DesignTokens.spacing1),
                  SkeletonLoadingWidget(
                    width: 80 + (index * 10.0),
                    height: 10,
                    borderRadius: DesignTokens.radiusXS,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Skeleton para barra de acceso rápido operacional
  static Widget quickAccessBar() {
    return Container(
      height: 80,
      padding: DesignTokens.paddingHorizontalL,
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: List.generate(4, (index) => _QuickAccessButtonSkeleton()),
      ),
    );
  }
}

/// Skeleton para estado crítico principal
class _CriticalStatusSkeleton extends StatefulWidget {
  @override
  State<_CriticalStatusSkeleton> createState() => _CriticalStatusSkeletonState();
}

class _CriticalStatusSkeletonState extends State<_CriticalStatusSkeleton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.orange[300],
      end: Colors.orange[600],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: DesignTokens.spacingL,
          decoration: BoxDecoration(
            color: _colorAnimation.value?.withOpacity(0.1),
            borderRadius: DesignTokens.radiusL,
            border: Border.all(
              color: _colorAnimation.value ?? Colors.orange,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: DesignTokens.radiusS,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoadingWidget(
                      width: 200,
                      height: 16,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                    SizedBox(height: DesignTokens.spacing1),
                    SkeletonLoadingWidget(
                      width: 150,
                      height: 12,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                  ],
                ),
              ),
              SkeletonLoadingWidget(
                width: 60,
                height: 32,
                borderRadius: DesignTokens.radiusM,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton para métrica operacional individual
class _OperationalMetricSkeleton extends StatelessWidget {
  final String label;
  
  const _OperationalMetricSkeleton(this.label);

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
            width: 32,
            height: 32,
            borderRadius: DesignTokens.radiusS,
          ),
          SizedBox(height: DesignTokens.spacing2),
          SkeletonLoadingWidget(
            width: double.infinity,
            height: 20,
            borderRadius: DesignTokens.radiusXS,
          ),
          SizedBox(height: DesignTokens.spacing1),
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
    );
  }
}

/// Skeleton para mapa operacional con overlay
class _OperationalMapSkeleton extends StatefulWidget {
  @override
  State<_OperationalMapSkeleton> createState() => _OperationalMapSkeletonState();
}

class _OperationalMapSkeletonState extends State<_OperationalMapSkeleton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationDurationExtraSlow * 2,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: DesignTokens.radiusL,
      ),
      child: Stack(
        children: [
          // Fondo de mapa simulado
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: OperationalMapPatternPainter(_animation.value),
              );
            },
          ),
          
          // Overlay de carga operacional
          Center(
            child: Container(
              padding: DesignTokens.spacingXL,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: DesignTokens.radiusL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange[400],
                      borderRadius: DesignTokens.radiusFull,
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing3),
                  Text(
                    'CARGANDO DATOS DE SEGURIDAD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DesignTokens.fontSizeS,
                      fontWeight: DesignTokens.fontWeightBold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing1),
                  Text(
                    'Analizando rutas y zonas de riesgo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: DesignTokens.fontSizeXS,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Overlay de información operacional
          TransportSkeletonLoaders.mapInfoOverlay(),
        ],
      ),
    );
  }
}

/// Painter para patrón de mapa operacional
class OperationalMapPatternPainter extends CustomPainter {
  final double animationValue;
  
  OperationalMapPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.grey[400]!.withOpacity(0.3 + (animationValue * 0.2))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dangerPaint = Paint()
      ..color = Colors.red.withOpacity(0.2 + (animationValue * 0.3))
      ..style = PaintingStyle.fill;

    final safePaint = Paint()
      ..color = Colors.green.withOpacity(0.2 + (animationValue * 0.3))
      ..style = PaintingStyle.fill;

    // Dibujar carreteras principales (más gruesas)
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint..strokeWidth = 4,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      roadPaint..strokeWidth = 4,
    );

    // Carreteras secundarias
    for (int i = 1; i < 6; i++) {
      final y = (size.height / 6) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        roadPaint..strokeWidth = 2,
      );
    }

    for (int i = 1; i < 5; i++) {
      final x = (size.width / 5) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        roadPaint..strokeWidth = 2,
      );
    }

    // Zonas de peligro (rojas)
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.2),
      15 + (animationValue * 5),
      dangerPaint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      12 + (animationValue * 4),
      dangerPaint,
    );

    // Zonas seguras (verdes)
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      10 + (animationValue * 3),
      safePaint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.9),
      8 + (animationValue * 2),
      safePaint,
    );

    // Vehículos simulados (puntos que se mueven)
    final vehiclePaint = Paint()
      ..color = Colors.blue.withOpacity(0.6 + (animationValue * 0.4))
      ..style = PaintingStyle.fill;

    final vehiclePositions = [
      Offset(size.width * (0.1 + animationValue * 0.8), size.height * 0.3),
      Offset(size.width * 0.4, size.height * (0.1 + animationValue * 0.8)),
    ];

    for (final pos in vehiclePositions) {
      canvas.drawCircle(pos, 4, vehiclePaint);
    }
  }

  @override
  bool shouldRepaint(OperationalMapPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Skeleton para item de alerta crítica
class _CriticalAlertItemSkeleton extends StatelessWidget {
  final bool isUrgent;
  
  const _CriticalAlertItemSkeleton({this.isUrgent = false});

  @override
  Widget build(BuildContext context) {
    final borderColor = isUrgent ? Colors.red : Colors.orange;
    
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Card(
        elevation: isUrgent ? 6 : 3,
        shadowColor: borderColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusL,
          side: BorderSide(
            color: borderColor,
            width: isUrgent ? 3 : 2,
          ),
        ),
        child: Padding(
          padding: DesignTokens.spacingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonLoadingWidget(
                    width: isUrgent ? 56 : 48,
                    height: isUrgent ? 56 : 48,
                    borderRadius: DesignTokens.radiusM,
                  ),
                  SizedBox(width: DesignTokens.spacing3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoadingWidget(
                          width: double.infinity,
                          height: isUrgent ? 20 : 18,
                          borderRadius: DesignTokens.radiusXS,
                        ),
                        SizedBox(height: DesignTokens.spacing1),
                        SkeletonLoadingWidget(
                          width: 150,
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
              
              SizedBox(height: DesignTokens.spacing3),
              
              // Información operacional
              Container(
                padding: DesignTokens.spacingM,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: DesignTokens.radiusM,
                ),
                child: Row(
                  children: [
                    _buildOperationalInfoSkeleton('TIEMPO'),
                    SizedBox(width: DesignTokens.spacing4),
                    _buildOperationalInfoSkeleton('DISTANCIA'),
                    Spacer(),
                    SkeletonLoadingWidget(
                      width: 80,
                      height: 32,
                      borderRadius: DesignTokens.radiusM,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationalInfoSkeleton(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeXS,
            color: Colors.grey[600],
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        SkeletonLoadingWidget(
          width: 40,
          height: 16,
          borderRadius: DesignTokens.radiusXS,
        ),
      ],
    );
  }
}

/// Skeleton para header de planificación
class _PlanningHeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoadingWidget(
          width: 200,
          height: 24,
          borderRadius: DesignTokens.radiusS,
        ),
        SizedBox(height: DesignTokens.spacing2),
        SkeletonLoadingWidget(
          width: double.infinity,
          height: 16,
          borderRadius: DesignTokens.radiusXS,
        ),
      ],
    );
  }
}

/// Skeleton para opción de planificación
class _PlanningOptionSkeleton extends StatelessWidget {
  final String title;
  
  const _PlanningOptionSkeleton(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
        child: Padding(
          padding: DesignTokens.spacingL,
          child: Row(
            children: [
              SkeletonLoadingWidget(
                width: 48,
                height: 48,
                borderRadius: DesignTokens.radiusM,
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
                        fontWeight: DesignTokens.fontWeightMedium,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing1),
                    SkeletonLoadingWidget(
                      width: 180,
                      height: 14,
                      borderRadius: DesignTokens.radiusXS,
                    ),
                  ],
                ),
              ),
              SkeletonLoadingWidget(
                width: 16,
                height: 16,
                borderRadius: DesignTokens.radiusXS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton para filtro rápido
class _QuickFilterSkeleton extends StatelessWidget {
  final String label;
  
  const _QuickFilterSkeleton(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: DesignTokens.paddingHorizontalM.add(DesignTokens.paddingVerticalS),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: DesignTokens.radiusL,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: DesignTokens.fontSizeXS,
          color: Colors.grey[500],
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    );
  }
}

/// Skeleton para botón de acceso rápido
class _QuickAccessButtonSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SkeletonLoadingWidget(
          width: 24,
          height: 24,
          borderRadius: DesignTokens.radiusS,
        ),
        SizedBox(height: DesignTokens.spacing1),
        SkeletonLoadingWidget(
          width: 60,
          height: 12,
          borderRadius: DesignTokens.radiusXS,
        ),
      ],
    );
  }
}

/// Extensión del SkeletonLoadingWidget para transportistas
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
      duration: const Duration(milliseconds: 1200),
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