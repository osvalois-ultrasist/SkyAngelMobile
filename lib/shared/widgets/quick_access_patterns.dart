import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// Patrones de acceso rápido para datos críticos de seguridad
/// Optimizados para transportistas, operadores de seguridad y planeadores de rutas
class QuickAccessPatterns {
  
  /// Panel de control crítico que se puede acceder con un solo tap
  /// Muestra información esencial para transportistas
  static Widget criticalControlPanel({
    required BuildContext context,
    required CriticalData data,
    required List<QuickAction> actions,
    VoidCallback? onExpand,
    bool isExpanded = false,
  }) {
    return Container(
      margin: DesignTokens.spacingM,
      child: Card(
        elevation: 6,
        shadowColor: _getSeverityColor(data.maxSeverity).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusL,
          side: BorderSide(
            color: _getSeverityColor(data.maxSeverity),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header crítico siempre visible
            _CriticalPanelHeader(
              data: data,
              onExpand: onExpand,
              isExpanded: isExpanded,
            ),
            
            // Panel expandible con acciones
            if (isExpanded)
              _ExpandedActionsPanel(actions: actions),
          ],
        ),
      ),
    );
  }

  /// Widget de acceso rápido flotante (FAB personalizado)
  /// Acciones críticas accesibles con pulgar
  static Widget floatingQuickAccess({
    required List<CriticalAction> actions,
    bool leftHanded = false,
  }) {
    return Positioned(
      bottom: 20,
      right: leftHanded ? null : 20,
      left: leftHanded ? 20 : null,
      child: _FloatingQuickAccess(
        actions: actions,
        leftHanded: leftHanded,
      ),
    );
  }

  /// Barra de estado operacional siempre visible
  /// Información crítica condensada
  static Widget operationalStatusBar({
    required OperationalStatus status,
    required List<StatusIndicator> indicators,
    VoidCallback? onStatusTap,
  }) {
    return Container(
      height: 60,
      padding: DesignTokens.paddingHorizontalL,
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: _getStatusColor(status),
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          // Indicador principal de estado
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onStatusTap?.call();
            },
            child: Container(
              padding: DesignTokens.spacingS,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: DesignTokens.radiusM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: Colors.white,
                    size: DesignTokens.iconSizeS,
                  ),
                  SizedBox(width: DesignTokens.spacing1),
                  Text(
                    status.label.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DesignTokens.fontSizeXS,
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: DesignTokens.spacing3),
          
          // Indicadores específicos
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: indicators.map((indicator) => 
                  _StatusIndicatorWidget(indicator: indicator)
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer lateral rápido con gestos
  /// Información contextual accesible por swipe
  static Widget quickInfoDrawer({
    required BuildContext context,
    required QuickInfoData data,
    bool isVisible = false,
    VoidCallback? onClose,
  }) {
    return AnimatedPositioned(
      duration: DesignTokens.animationDurationNormal,
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      right: isVisible ? 0 : -300,
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            ShadowTokens.createShadow(
              color: Colors.black,
              opacity: 0.3,
              blurRadius: DesignTokens.blurRadiusXL,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del drawer
            Container(
              padding: DesignTokens.spacingL.add(
                EdgeInsets.only(top: MediaQuery.of(context).padding.top)
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'INFORMACIÓN RÁPIDA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: DesignTokens.fontSizeM,
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Contenido del drawer
            Expanded(
              child: _QuickInfoContent(data: data),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de notificación crítica emergente
  /// Para alertas que requieren atención inmediata
  static void showCriticalAlert({
    required BuildContext context,
    required CriticalAlert alert,
    required List<AlertAction> actions,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CriticalAlertDialog(
        alert: alert,
        actions: actions,
      ),
    );
  }

  /// Bottom sheet de acceso rápido
  /// Optimizado para operación con pulgar
  static void showQuickAccessSheet({
    required BuildContext context,
    required String title,
    required List<QuickSheetItem> items,
    bool leftHanded = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _QuickAccessBottomSheet(
        title: title,
        items: items,
        leftHanded: leftHanded,
      ),
    );
  }

  // Métodos de utilidad para colores y iconos
  static Color _getSeverityColor(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low: return Colors.green;
      case RiskSeverity.medium: return Colors.yellow[700]!;
      case RiskSeverity.high: return Colors.orange;
      case RiskSeverity.critical: return Colors.red;
      case RiskSeverity.extreme: return Colors.purple[800]!;
    }
  }

  static Color _getStatusColor(OperationalStatus status) {
    switch (status) {
      case OperationalStatus.safe: return Colors.green;
      case OperationalStatus.caution: return Colors.yellow[700]!;
      case OperationalStatus.danger: return Colors.red;
      case OperationalStatus.emergency: return Colors.purple[800]!;
    }
  }

  static IconData _getStatusIcon(OperationalStatus status) {
    switch (status) {
      case OperationalStatus.safe: return Icons.verified_rounded;
      case OperationalStatus.caution: return Icons.warning_rounded;
      case OperationalStatus.danger: return Icons.dangerous_rounded;
      case OperationalStatus.emergency: return Icons.emergency_rounded;
    }
  }
}

/// Widget del header del panel crítico
class _CriticalPanelHeader extends StatefulWidget {
  final CriticalData data;
  final VoidCallback? onExpand;
  final bool isExpanded;

  const _CriticalPanelHeader({
    required this.data,
    this.onExpand,
    required this.isExpanded,
  });

  @override
  State<_CriticalPanelHeader> createState() => _CriticalPanelHeaderState();
}

class _CriticalPanelHeaderState extends State<_CriticalPanelHeader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    if (widget.data.maxSeverity == RiskSeverity.critical || 
        widget.data.maxSeverity == RiskSeverity.extreme) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onExpand?.call();
            },
            child: Container(
              padding: DesignTokens.spacingL,
              child: Row(
                children: [
                  // Indicador de severidad
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: QuickAccessPatterns._getSeverityColor(widget.data.maxSeverity),
                      borderRadius: DesignTokens.radiusM,
                    ),
                    child: Icon(
                      _getSeverityIcon(widget.data.maxSeverity),
                      color: Colors.white,
                      size: DesignTokens.iconSizeL,
                    ),
                  ),
                  
                  SizedBox(width: DesignTokens.spacing3),
                  
                  // Información crítica
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.title.toUpperCase(),
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeL,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: QuickAccessPatterns._getSeverityColor(widget.data.maxSeverity),
                          ),
                        ),
                        Text(
                          widget.data.summary,
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeS,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Indicador de expansión
                  if (widget.onExpand != null)
                    Icon(
                      widget.isExpanded 
                          ? Icons.expand_less_rounded 
                          : Icons.expand_more_rounded,
                      color: QuickAccessPatterns._getSeverityColor(widget.data.maxSeverity),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getSeverityIcon(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low: return Icons.check_circle_rounded;
      case RiskSeverity.medium: return Icons.info_rounded;
      case RiskSeverity.high: return Icons.warning_rounded;
      case RiskSeverity.critical: return Icons.error_rounded;
      case RiskSeverity.extreme: return Icons.dangerous_rounded;
    }
  }
}

/// Widget del panel expandido con acciones
class _ExpandedActionsPanel extends StatelessWidget {
  final List<QuickAction> actions;

  const _ExpandedActionsPanel({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: DesignTokens.spacingL,
      child: Column(
        children: [
          Divider(color: Colors.grey[300]),
          SizedBox(height: DesignTokens.spacing2),
          
          // Grid de acciones críticas
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: DesignTokens.spacing3,
              mainAxisSpacing: DesignTokens.spacing3,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) => _QuickActionButton(
              action: actions[index],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de acción rápida
class _QuickActionButton extends StatefulWidget {
  final QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: () {
        if (widget.action.isCritical) {
          HapticFeedback.heavyImpact();
        }
        widget.action.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _isPressed 
                    ? widget.action.color.withOpacity(0.2)
                    : Colors.white,
                borderRadius: DesignTokens.radiusM,
                border: Border.all(
                  color: widget.action.isCritical 
                      ? Colors.red 
                      : widget.action.color.withOpacity(0.5),
                  width: widget.action.isCritical ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.action.icon,
                    color: widget.action.color,
                    size: DesignTokens.iconSizeL,
                  ),
                  SizedBox(height: DesignTokens.spacing1),
                  Text(
                    widget.action.label,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeXS,
                      fontWeight: widget.action.isCritical 
                          ? DesignTokens.fontWeightBold 
                          : DesignTokens.fontWeightMedium,
                      color: widget.action.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget de acceso rápido flotante
class _FloatingQuickAccess extends StatefulWidget {
  final List<CriticalAction> actions;
  final bool leftHanded;

  const _FloatingQuickAccess({
    required this.actions,
    required this.leftHanded,
  });

  @override
  State<_FloatingQuickAccess> createState() => _FloatingQuickAccessState();
}

class _FloatingQuickAccessState extends State<_FloatingQuickAccess>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _expandController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _expandController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _expandController, curve: Curves.elasticOut));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.leftHanded 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.end,
      children: [
        // Acciones expandidas
        ...widget.actions.skip(1).map((action) => ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: EdgeInsets.only(bottom: DesignTokens.spacing2),
            child: FloatingActionButton(
              heroTag: action.label,
              onPressed: () {
                HapticFeedback.heavyImpact();
                action.onTap();
                _toggleExpanded();
              },
              backgroundColor: action.color,
              mini: true,
              child: Icon(action.icon, color: Colors.white),
            ),
          ),
        )).toList(),
        
        // FAB principal
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: FloatingActionButton(
                heroTag: "main_critical",
                onPressed: _isExpanded ? _toggleExpanded : () {
                  if (widget.actions.isNotEmpty) {
                    HapticFeedback.heavyImpact();
                    widget.actions.first.onTap();
                  }
                },
                onLongPress: widget.actions.length > 1 ? _toggleExpanded : null,
                backgroundColor: Colors.red,
                child: Icon(
                  _isExpanded 
                      ? Icons.close_rounded 
                      : widget.actions.isNotEmpty 
                          ? widget.actions.first.icon 
                          : Icons.warning_rounded,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget indicador de estado
class _StatusIndicatorWidget extends StatelessWidget {
  final StatusIndicator indicator;

  const _StatusIndicatorWidget({required this.indicator});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: DesignTokens.spacing2),
      padding: DesignTokens.paddingHorizontalS.add(DesignTokens.paddingVerticalXS),
      decoration: BoxDecoration(
        color: indicator.color.withOpacity(0.2),
        borderRadius: DesignTokens.radiusM,
        border: Border.all(color: indicator.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            indicator.icon,
            color: indicator.color,
            size: DesignTokens.iconSizeXS,
          ),
          SizedBox(width: DesignTokens.spacing1),
          Text(
            indicator.value,
            style: TextStyle(
              color: indicator.color,
              fontSize: DesignTokens.fontSizeXS,
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de contenido de información rápida
class _QuickInfoContent extends StatelessWidget {
  final QuickInfoData data;

  const _QuickInfoContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: DesignTokens.spacingL,
      children: [
        ...data.sections.map((section) => _InfoSection(section: section)),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final InfoSection section;

  const _InfoSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing4),
      child: Card(
        child: Padding(
          padding: DesignTokens.spacingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(section.icon, color: section.color),
                  SizedBox(width: DesignTokens.spacing2),
                  Text(
                    section.title,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeM,
                      fontWeight: DesignTokens.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignTokens.spacing2),
              ...section.items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.spacing1),
                child: Text(
                  '• $item',
                  style: TextStyle(fontSize: DesignTokens.fontSizeS),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog de alerta crítica
class _CriticalAlertDialog extends StatelessWidget {
  final CriticalAlert alert;
  final List<AlertAction> actions;

  const _CriticalAlertDialog({
    required this.alert,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.radiusL,
        side: BorderSide(color: Colors.red, width: 2),
      ),
      title: Row(
        children: [
          Icon(Icons.emergency_rounded, color: Colors.red, size: 32),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: Text(
              alert.title.toUpperCase(),
              style: TextStyle(
                color: Colors.red,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
          ),
        ],
      ),
      content: Text(alert.message),
      actions: actions.map((action) => ElevatedButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          action.onTap();
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: action.isPrimary ? Colors.red : Colors.grey,
        ),
        child: Text(action.label),
      )).toList(),
    );
  }
}

/// Bottom sheet de acceso rápido
class _QuickAccessBottomSheet extends StatelessWidget {
  final String title;
  final List<QuickSheetItem> items;
  final bool leftHanded;

  const _QuickAccessBottomSheet({
    required this.title,
    required this.items,
    required this.leftHanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignTokens.radiusXL.copyWith(
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle de arrastre
          Container(
            margin: EdgeInsets.only(top: DesignTokens.spacing2),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: DesignTokens.radiusXS,
            ),
          ),
          
          // Título
          Container(
            width: double.infinity,
            padding: DesignTokens.spacingL,
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: DesignTokens.fontSizeL,
                fontWeight: DesignTokens.fontWeightBold,
              ),
              textAlign: leftHanded ? TextAlign.left : TextAlign.center,
            ),
          ),
          
          // Items
          ...items.map((item) => ListTile(
            leading: Icon(item.icon, color: item.color),
            title: Text(item.title),
            subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
            trailing: item.badge != null 
                ? Container(
                    padding: DesignTokens.paddingHorizontalS,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: DesignTokens.radiusM,
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: DesignTokens.fontSizeXS,
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                  )
                : Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              HapticFeedback.lightImpact();
              item.onTap();
              Navigator.pop(context);
            },
          )),
          
          SizedBox(height: DesignTokens.spacing4),
        ],
      ),
    );
  }
}

// Modelos de datos
class CriticalData {
  final String title;
  final String summary;
  final RiskSeverity maxSeverity;
  final int criticalCount;
  final DateTime lastUpdate;

  const CriticalData({
    required this.title,
    required this.summary,
    required this.maxSeverity,
    required this.criticalCount,
    required this.lastUpdate,
  });
}

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isCritical;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isCritical = false,
  });
}

class CriticalAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CriticalAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class StatusIndicator {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatusIndicator({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class QuickInfoData {
  final List<InfoSection> sections;

  const QuickInfoData({required this.sections});
}

class InfoSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const InfoSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class CriticalAlert {
  final String title;
  final String message;
  final RiskSeverity severity;

  const CriticalAlert({
    required this.title,
    required this.message,
    required this.severity,
  });
}

class AlertAction {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const AlertAction({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });
}

class QuickSheetItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const QuickSheetItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });
}

enum RiskSeverity { low, medium, high, critical, extreme }
enum OperationalStatus { safe, caution, danger, emergency }