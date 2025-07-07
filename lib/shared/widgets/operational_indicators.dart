import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// Indicadores operacionales contextuales para transportistas
/// Proporcionan información crítica de estado en tiempo real
class OperationalIndicators {
  
  /// Indicador de estado de ruta principal
  /// Muestra el estado actual de seguridad de la ruta
  static Widget routeStatusIndicator({
    required RouteStatus status,
    required String routeName,
    VoidCallback? onTap,
    bool showDetails = true,
  }) {
    return Container(
      margin: DesignTokens.spacingS,
      child: Card(
        elevation: 4,
        color: _getRouteStatusColor(status).withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusM,
          side: BorderSide(
            color: _getRouteStatusColor(status),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          borderRadius: DesignTokens.radiusM,
          child: Padding(
            padding: DesignTokens.spacingM,
            child: Row(
              children: [
                // Indicador visual de estado
                _StatusDot(
                  color: _getRouteStatusColor(status),
                  isAnimated: status == RouteStatus.danger || status == RouteStatus.blocked,
                ),
                
                SizedBox(width: DesignTokens.spacing2),
                
                // Información de ruta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeName.toUpperCase(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeS,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: _getRouteStatusColor(status),
                        ),
                      ),
                      if (showDetails) ...[
                        SizedBox(height: DesignTokens.spacing1),
                        Text(
                          _getRouteStatusMessage(status),
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeXS,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Icono de estado
                Icon(
                  _getRouteStatusIcon(status),
                  color: _getRouteStatusColor(status),
                  size: DesignTokens.iconSizeM,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Barra de métricas operacionales
  /// Muestra métricas clave en tiempo real
  static Widget operationalMetricsBar({
    required List<OperationalMetric> metrics,
    bool isHorizontal = true,
  }) {
    return Container(
      padding: DesignTokens.spacingM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignTokens.radiusL,
        boxShadow: [
          ShadowTokens.createShadow(
            color: Colors.black,
            opacity: DesignTokens.shadowOpacityLight,
            blurRadius: DesignTokens.blurRadiusM,
          ),
        ],
      ),
      child: isHorizontal
          ? Row(
              children: metrics
                  .map((metric) => Expanded(
                        child: _MetricIndicator(metric: metric),
                      ))
                  .toList(),
            )
          : Column(
              children: metrics
                  .map((metric) => _MetricIndicator(metric: metric))
                  .toList(),
            ),
    );
  }

  /// Panel de alertas críticas flotante
  /// Aparece cuando hay alertas que requieren atención inmediata
  static Widget criticalAlertsPanel({
    required List<CriticalAlert> alerts,
    VoidCallback? onDismiss,
    VoidCallback? onViewAll,
  }) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: DesignTokens.spacing4,
      right: DesignTokens.spacing4,
      child: _CriticalAlertsPanel(
        alerts: alerts,
        onDismiss: onDismiss,
        onViewAll: onViewAll,
      ),
    );
  }

  /// Indicador de tiempo operacional
  /// Muestra tiempo estimado, distancia y estado de tráfico
  static Widget timeOperationalIndicator({
    required Duration estimatedTime,
    required double distanceKm,
    required TrafficStatus trafficStatus,
    String? alternativeRouteTime,
  }) {
    return Container(
      padding: DesignTokens.spacingM,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: DesignTokens.radiusL,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiempo estimado
          _buildTimeMetric(
            'TIEMPO',
            _formatDuration(estimatedTime),
            Icons.schedule_rounded,
            _getTrafficColor(trafficStatus),
          ),
          
          SizedBox(width: DesignTokens.spacing4),
          
          // Distancia
          _buildTimeMetric(
            'DISTANCIA',
            '${distanceKm.toStringAsFixed(1)} km',
            Icons.straighten_rounded,
            Colors.blue,
          ),
          
          // Indicador de tráfico
          if (trafficStatus != TrafficStatus.normal) ...[
            SizedBox(width: DesignTokens.spacing4),
            _TrafficIndicator(status: trafficStatus),
          ],
        ],
      ),
    );
  }

  /// Panel de contexto operacional
  /// Cambia según el tipo de operador (transportista, seguridad, planificador)
  static Widget operationalContextPanel({
    required OperatorType operatorType,
    required OperationalContext context,
    VoidCallback? onContextChange,
  }) {
    return Container(
      margin: DesignTokens.spacingM,
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getOperatorColor(operatorType).withOpacity(0.1),
            _getOperatorColor(operatorType).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DesignTokens.radiusL,
        border: Border.all(
          color: _getOperatorColor(operatorType).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del contexto
          Row(
            children: [
              Icon(
                _getOperatorIcon(operatorType),
                color: _getOperatorColor(operatorType),
                size: DesignTokens.iconSizeL,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: Text(
                  _getOperatorLabel(operatorType).toUpperCase(),
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeM,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: _getOperatorColor(operatorType),
                  ),
                ),
              ),
              if (onContextChange != null)
                IconButton(
                  onPressed: onContextChange,
                  icon: Icon(
                    Icons.swap_horiz_rounded,
                    color: _getOperatorColor(operatorType),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: DesignTokens.spacing3),
          
          // Métricas específicas del contexto
          _ContextSpecificMetrics(
            operatorType: operatorType,
            context: context,
          ),
        ],
      ),
    );
  }

  /// Indicador de estado de conectividad
  /// Muestra el estado de conexión de datos críticos
  static Widget connectivityIndicator({
    required ConnectivityStatus status,
    DateTime? lastUpdate,
    bool showDetails = true,
  }) {
    return Container(
      padding: DesignTokens.spacingS,
      decoration: BoxDecoration(
        color: _getConnectivityColor(status).withOpacity(0.1),
        borderRadius: DesignTokens.radiusM,
        border: Border.all(
          color: _getConnectivityColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ConnectivityDot(status: status),
          
          if (showDetails) ...[
            SizedBox(width: DesignTokens.spacing2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getConnectivityLabel(status),
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeXS,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: _getConnectivityColor(status),
                  ),
                ),
                if (lastUpdate != null)
                  Text(
                    'Últ. act: ${_formatTime(lastUpdate)}',
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeXS,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Métodos de utilidad
  static Color _getRouteStatusColor(RouteStatus status) {
    switch (status) {
      case RouteStatus.safe: return Colors.green;
      case RouteStatus.caution: return Colors.orange;
      case RouteStatus.danger: return Colors.red;
      case RouteStatus.blocked: return Colors.purple[800]!;
      case RouteStatus.unknown: return Colors.grey;
    }
  }

  static IconData _getRouteStatusIcon(RouteStatus status) {
    switch (status) {
      case RouteStatus.safe: return Icons.verified_rounded;
      case RouteStatus.caution: return Icons.warning_rounded;
      case RouteStatus.danger: return Icons.dangerous_rounded;
      case RouteStatus.blocked: return Icons.block_rounded;
      case RouteStatus.unknown: return Icons.help_outline_rounded;
    }
  }

  static String _getRouteStatusMessage(RouteStatus status) {
    switch (status) {
      case RouteStatus.safe: return 'Ruta segura, proceder normal';
      case RouteStatus.caution: return 'Precaución recomendada';
      case RouteStatus.danger: return 'Riesgo alto, considerar alternativa';
      case RouteStatus.blocked: return 'Ruta bloqueada, usar alternativa';
      case RouteStatus.unknown: return 'Estado no disponible';
    }
  }

  static Color _getTrafficColor(TrafficStatus status) {
    switch (status) {
      case TrafficStatus.normal: return Colors.green;
      case TrafficStatus.light: return Colors.yellow[700]!;
      case TrafficStatus.heavy: return Colors.orange;
      case TrafficStatus.blocked: return Colors.red;
    }
  }

  static Color _getOperatorColor(OperatorType type) {
    switch (type) {
      case OperatorType.transport: return Colors.blue;
      case OperatorType.security: return Colors.red;
      case OperatorType.planning: return Colors.green;
    }
  }

  static IconData _getOperatorIcon(OperatorType type) {
    switch (type) {
      case OperatorType.transport: return Icons.local_shipping_rounded;
      case OperatorType.security: return Icons.security_rounded;
      case OperatorType.planning: return Icons.route_rounded;
    }
  }

  static String _getOperatorLabel(OperatorType type) {
    switch (type) {
      case OperatorType.transport: return 'Transporte';
      case OperatorType.security: return 'Seguridad';
      case OperatorType.planning: return 'Planificación';
    }
  }

  static Color _getConnectivityColor(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online: return Colors.green;
      case ConnectivityStatus.limited: return Colors.orange;
      case ConnectivityStatus.offline: return Colors.red;
    }
  }

  static String _getConnectivityLabel(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online: return 'ONLINE';
      case ConnectivityStatus.limited: return 'LIMITADO';
      case ConnectivityStatus.offline: return 'OFFLINE';
    }
  }

  static Widget _buildTimeMetric(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: DesignTokens.iconSizeXS, color: Colors.white70),
            SizedBox(width: DesignTokens.spacing1),
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTokens.fontSizeXS,
                color: Colors.white70,
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
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }
}

/// Widget de punto de estado animado
class _StatusDot extends StatefulWidget {
  final Color color;
  final bool isAnimated;

  const _StatusDot({
    required this.color,
    required this.isAnimated,
  });

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isAnimated ? _scaleAnimation.value : 1.0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: DesignTokens.radiusFull,
              boxShadow: widget.isAnimated ? [
                ShadowTokens.createShadow(
                  color: widget.color,
                  opacity: 0.5,
                  blurRadius: DesignTokens.blurRadiusS,
                ),
              ] : null,
            ),
          ),
        );
      },
    );
  }
}

/// Widget de indicador de métrica
class _MetricIndicator extends StatelessWidget {
  final OperationalMetric metric;

  const _MetricIndicator({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          metric.icon,
          color: metric.color,
          size: DesignTokens.iconSizeM,
        ),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          metric.value,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeL,
            fontWeight: DesignTokens.fontWeightBold,
            color: metric.color,
          ),
        ),
        Text(
          metric.label,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeXS,
            color: Colors.grey[600],
            fontWeight: DesignTokens.fontWeightMedium,
          ),
          textAlign: TextAlign.center,
        ),
        if (metric.trend != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                metric.trend! > 0 
                    ? Icons.trending_up_rounded 
                    : Icons.trending_down_rounded,
                size: DesignTokens.iconSizeXS,
                color: metric.trend! > 0 ? Colors.green : Colors.red,
              ),
              Text(
                '${metric.trend!.abs()}%',
                style: TextStyle(
                  fontSize: DesignTokens.fontSizeXS,
                  color: metric.trend! > 0 ? Colors.green : Colors.red,
                  fontWeight: DesignTokens.fontWeightMedium,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Panel de alertas críticas
class _CriticalAlertsPanel extends StatefulWidget {
  final List<CriticalAlert> alerts;
  final VoidCallback? onDismiss;
  final VoidCallback? onViewAll;

  const _CriticalAlertsPanel({
    required this.alerts,
    this.onDismiss,
    this.onViewAll,
  });

  @override
  State<_CriticalAlertsPanel> createState() => _CriticalAlertsPanelState();
}

class _CriticalAlertsPanelState extends State<_CriticalAlertsPanel>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Card(
              elevation: 8,
              color: Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: DesignTokens.radiusL,
                side: BorderSide(color: Colors.red, width: 2),
              ),
              child: Padding(
                padding: DesignTokens.spacingL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.red, size: 24),
                        SizedBox(width: DesignTokens.spacing2),
                        Expanded(
                          child: Text(
                            '${widget.alerts.length} ALERTA${widget.alerts.length > 1 ? 'S' : ''} CRÍTICA${widget.alerts.length > 1 ? 'S' : ''}',
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeM,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onDismiss,
                          icon: Icon(Icons.close, color: Colors.red),
                          iconSize: 20,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: DesignTokens.spacing2),
                    
                    // Primera alerta (más crítica)
                    Text(
                      widget.alerts.first.message,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeS,
                        color: Colors.red[800],
                      ),
                    ),
                    
                    if (widget.alerts.length > 1) ...[
                      SizedBox(height: DesignTokens.spacing1),
                      Text(
                        'y ${widget.alerts.length - 1} alerta${widget.alerts.length > 2 ? 's' : ''} más...',
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeXS,
                          color: Colors.red[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    
                    SizedBox(height: DesignTokens.spacing3),
                    
                    // Acciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.onViewAll != null)
                          TextButton(
                            onPressed: widget.onViewAll,
                            child: Text('VER TODAS'),
                          ),
                        SizedBox(width: DesignTokens.spacing2),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            // Acción de emergencia
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('ACCIÓN INMEDIATA'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Indicador de tráfico
class _TrafficIndicator extends StatelessWidget {
  final TrafficStatus status;

  const _TrafficIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.traffic_rounded,
          color: OperationalIndicators._getTrafficColor(status),
          size: DesignTokens.iconSizeS,
        ),
        Text(
          _getTrafficLabel(status),
          style: TextStyle(
            fontSize: DesignTokens.fontSizeXS,
            color: Colors.white70,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
      ],
    );
  }

  String _getTrafficLabel(TrafficStatus status) {
    switch (status) {
      case TrafficStatus.normal: return 'NORMAL';
      case TrafficStatus.light: return 'LIGERO';
      case TrafficStatus.heavy: return 'PESADO';
      case TrafficStatus.blocked: return 'BLOQUEADO';
    }
  }
}

/// Widget de métricas específicas del contexto
class _ContextSpecificMetrics extends StatelessWidget {
  final OperatorType operatorType;
  final OperationalContext context;

  const _ContextSpecificMetrics({
    required this.operatorType,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    switch (operatorType) {
      case OperatorType.transport:
        return _TransportMetrics(context: this.context);
      case OperatorType.security:
        return _SecurityMetrics(context: this.context);
      case OperatorType.planning:
        return _PlanningMetrics(context: this.context);
    }
  }
}

class _TransportMetrics extends StatelessWidget {
  final OperationalContext context;

  const _TransportMetrics({required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetric('COMBUSTIBLE', '75%', Icons.local_gas_station, Colors.blue),
        ),
        Expanded(
          child: _buildMetric('CARGA', '2.3t', Icons.inventory_2, Colors.green),
        ),
        Expanded(
          child: _buildMetric('TIEMPO', '45m', Icons.schedule, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: DesignTokens.iconSizeS),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          value,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeS,
            fontWeight: DesignTokens.fontWeightBold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeXS,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _SecurityMetrics extends StatelessWidget {
  final OperationalContext context;

  const _SecurityMetrics({required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetric('RIESGO', 'MEDIO', Icons.security, Colors.orange),
        ),
        Expanded(
          child: _buildMetric('ALERTAS', '3', Icons.warning, Colors.red),
        ),
        Expanded(
          child: _buildMetric('PATRULLAS', '2', Icons.local_police, Colors.blue),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: DesignTokens.iconSizeS),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          value,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeS,
            fontWeight: DesignTokens.fontWeightBold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeXS,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _PlanningMetrics extends StatelessWidget {
  final OperationalContext context;

  const _PlanningMetrics({required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetric('RUTAS', '12', Icons.route, Colors.green),
        ),
        Expanded(
          child: _buildMetric('OPTIMIZACIÓN', '95%', Icons.trending_up, Colors.blue),
        ),
        Expanded(
          child: _buildMetric('EFICIENCIA', 'ALTA', Icons.speed, Colors.purple),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: DesignTokens.iconSizeS),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          value,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeS,
            fontWeight: DesignTokens.fontWeightBold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeXS,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Widget de punto de conectividad animado
class _ConnectivityDot extends StatefulWidget {
  final ConnectivityStatus status;

  const _ConnectivityDot({required this.status});

  @override
  State<_ConnectivityDot> createState() => _ConnectivityDotState();
}

class _ConnectivityDotState extends State<_ConnectivityDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    if (widget.status == ConnectivityStatus.limited) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
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
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: OperationalIndicators._getConnectivityColor(widget.status)
                .withOpacity(_animation.value),
            borderRadius: DesignTokens.radiusFull,
          ),
        );
      },
    );
  }
}

// Enums y modelos de datos
enum RouteStatus { safe, caution, danger, blocked, unknown }
enum TrafficStatus { normal, light, heavy, blocked }
enum OperatorType { transport, security, planning }
enum ConnectivityStatus { online, limited, offline }

class OperationalMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? trend; // Porcentaje de cambio

  const OperationalMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
}

class CriticalAlert {
  final String title;
  final String message;
  final DateTime timestamp;
  final AlertSeverity severity;

  const CriticalAlert({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

class OperationalContext {
  final String currentLocation;
  final DateTime sessionStart;
  final Map<String, dynamic> metrics;

  const OperationalContext({
    required this.currentLocation,
    required this.sessionStart,
    required this.metrics,
  });
}

enum AlertSeverity { low, medium, high, critical }