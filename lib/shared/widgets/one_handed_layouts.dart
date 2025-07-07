import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// Layouts optimizados para operación con una mano
/// Especialmente diseñados para transportistas en movimiento
class OneHandedLayouts {
  
  /// Layout principal optimizado para pulgar derecho
  /// Elementos críticos en zona de fácil acceso (parte inferior derecha)
  static Widget thumbZoneOptimized({
    required Widget child,
    Widget? criticalAction,
    Widget? secondaryAction,
    Widget? quickInfo,
    bool leftHanded = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final thumbZone = _calculateThumbZone(constraints, leftHanded);
        
        return Stack(
          children: [
            // Contenido principal
            child,
            
            // Zona crítica para pulgar
            if (criticalAction != null)
              Positioned(
                bottom: thumbZone.bottom,
                right: leftHanded ? null : thumbZone.right,
                left: leftHanded ? thumbZone.left : null,
                child: _ThumbZoneAction(
                  child: criticalAction,
                  isPrimary: true,
                ),
              ),
            
            // Acción secundaria
            if (secondaryAction != null)
              Positioned(
                bottom: thumbZone.bottom + 80,
                right: leftHanded ? null : thumbZone.right,
                left: leftHanded ? thumbZone.left : null,
                child: _ThumbZoneAction(
                  child: secondaryAction,
                  isPrimary: false,
                ),
              ),
            
            // Información rápida en zona accesible
            if (quickInfo != null)
              Positioned(
                bottom: thumbZone.bottom,
                left: leftHanded ? null : DesignTokens.spacing4,
                right: leftHanded ? DesignTokens.spacing4 : null,
                child: _QuickInfoPanel(child: quickInfo),
              ),
          ],
        );
      },
    );
  }

  /// Grid de acciones rápidas optimizado para pulgar
  static Widget thumbFriendlyGrid({
    required List<QuickActionItem> actions,
    bool leftHanded = false,
    int maxColumns = 2,
  }) {
    return Container(
      padding: DesignTokens.spacingL,
      child: Column(
        children: [
          // Información crítica arriba (fácil de ver)
          _buildCriticalInfoBar(),
          
          SizedBox(height: DesignTokens.spacing4),
          
          // Grid de acciones en zona del pulgar
          Expanded(
            child: _buildThumbOptimizedGrid(actions, leftHanded, maxColumns),
          ),
        ],
      ),
    );
  }

  /// Layout de lista optimizado para scroll con pulgar
  static Widget thumbScrollList({
    required List<Widget> children,
    Widget? stickyHeader,
    Widget? floatingInfo,
    bool leftHanded = false,
  }) {
    return Column(
      children: [
        // Header pegajoso si se proporciona
        if (stickyHeader != null)
          Container(
            width: double.infinity,
            child: stickyHeader,
          ),
        
        // Lista con padding optimizado para pulgar
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(
                  left: leftHanded ? DesignTokens.spacing8 : DesignTokens.spacing4,
                  right: leftHanded ? DesignTokens.spacing4 : DesignTokens.spacing8,
                  top: DesignTokens.spacing4,
                  bottom: 120, // Espacio para acciones flotantes
                ),
                itemCount: children.length,
                itemBuilder: (context, index) => _OptimizedListItem(
                  child: children[index],
                  leftHanded: leftHanded,
                ),
              ),
              
              // Información flotante
              if (floatingInfo != null)
                Positioned(
                  top: DesignTokens.spacing4,
                  right: leftHanded ? null : DesignTokens.spacing4,
                  left: leftHanded ? DesignTokens.spacing4 : null,
                  child: _FloatingInfoWidget(child: floatingInfo),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom sheet optimizado para una mano
  static Widget thumbOptimizedBottomSheet({
    required Widget content,
    String? title,
    List<Widget>? quickActions,
    bool leftHanded = false,
  }) {
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
          // Handle de arrastre centrado y grande
          Container(
            margin: EdgeInsets.only(top: DesignTokens.spacing2),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: DesignTokens.radiusXS,
            ),
          ),
          
          // Header con título si se proporciona
          if (title != null)
            Container(
              width: double.infinity,
              padding: DesignTokens.spacingL,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: DesignTokens.fontSizeXL,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
                textAlign: leftHanded ? TextAlign.left : TextAlign.center,
              ),
            ),
          
          // Contenido principal
          Flexible(child: content),
          
          // Acciones rápidas en la parte inferior
          if (quickActions != null && quickActions.isNotEmpty)
            Container(
              padding: DesignTokens.spacingL,
              child: Row(
                mainAxisAlignment: leftHanded 
                    ? MainAxisAlignment.start 
                    : MainAxisAlignment.end,
                children: quickActions
                    .map((action) => Padding(
                          padding: EdgeInsets.only(
                            left: leftHanded ? 0 : DesignTokens.spacing2,
                            right: leftHanded ? DesignTokens.spacing2 : 0,
                          ),
                          child: action,
                        ))
                    .toList(),
              ),
            ),
          
          // Espacio inferior para zona segura
          SizedBox(height: DesignTokens.spacing4),
        ],
      ),
    );
  }

  static _ThumbZone _calculateThumbZone(BoxConstraints constraints, bool leftHanded) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    
    // Zona natural del pulgar en pantallas móviles
    final thumbRadius = screenWidth * 0.25; // 25% del ancho de pantalla
    final centerX = leftHanded 
        ? thumbRadius 
        : screenWidth - thumbRadius;
    final centerY = screenHeight - (screenHeight * 0.25); // 25% desde abajo
    
    return _ThumbZone(
      centerX: centerX,
      centerY: centerY,
      radius: thumbRadius,
      left: leftHanded ? DesignTokens.spacing4 : null,
      right: leftHanded ? null : DesignTokens.spacing4,
      bottom: DesignTokens.spacing6,
    );
  }

  static Widget _buildCriticalInfoBar() {
    return Container(
      padding: DesignTokens.spacingM,
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: DesignTokens.radiusL,
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange[700], size: 20),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: Text(
              'INFORMACIÓN CRÍTICA',
              style: TextStyle(
                fontSize: DesignTokens.fontSizeS,
                fontWeight: DesignTokens.fontWeightSemiBold,
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildThumbOptimizedGrid(
    List<QuickActionItem> actions, 
    bool leftHanded, 
    int maxColumns,
  ) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: maxColumns,
        childAspectRatio: 1.2,
        crossAxisSpacing: DesignTokens.spacing3,
        mainAxisSpacing: DesignTokens.spacing3,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final isInThumbZone = _isInThumbZone(index, actions.length, maxColumns);
        
        return _ThumbOptimizedActionCard(
          action: action,
          isInThumbZone: isInThumbZone,
          leftHanded: leftHanded,
        );
      },
    );
  }

  static bool _isInThumbZone(int index, int totalItems, int columns) {
    final row = index ~/ columns;
    final col = index % columns;
    final totalRows = (totalItems / columns).ceil();
    
    // Últimas 2 filas están en zona del pulgar
    return row >= totalRows - 2;
  }
}

class _ThumbZone {
  final double centerX;
  final double centerY;
  final double radius;
  final double? left;
  final double? right;
  final double bottom;

  const _ThumbZone({
    required this.centerX,
    required this.centerY,
    required this.radius,
    this.left,
    this.right,
    required this.bottom,
  });
}

class _ThumbZoneAction extends StatefulWidget {
  final Widget child;
  final bool isPrimary;

  const _ThumbZoneAction({
    required this.child,
    required this.isPrimary,
  });

  @override
  State<_ThumbZoneAction> createState() => _ThumbZoneActionState();
}

class _ThumbZoneActionState extends State<_ThumbZoneAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _controller.forward();
    
    if (widget.isPrimary) {
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
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPrimary ? _pulseAnimation.value : _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: DesignTokens.radiusFull,
              boxShadow: [
                ShadowTokens.createShadow(
                  color: widget.isPrimary ? Colors.red : Colors.blue,
                  opacity: 0.3,
                  blurRadius: DesignTokens.blurRadiusL,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _QuickInfoPanel extends StatelessWidget {
  final Widget child;

  const _QuickInfoPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: DesignTokens.spacingM,
      constraints: BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: DesignTokens.radiusL,
      ),
      child: child,
    );
  }
}

class _OptimizedListItem extends StatelessWidget {
  final Widget child;
  final bool leftHanded;

  const _OptimizedListItem({
    required this.child,
    required this.leftHanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Row(
        children: [
          if (leftHanded) ...[
            // Zona de acción rápida a la izquierda
            SizedBox(width: 60),
            Expanded(child: child),
          ] else ...[
            Expanded(child: child),
            // Zona de acción rápida a la derecha
            SizedBox(width: 60),
          ],
        ],
      ),
    );
  }
}

class _FloatingInfoWidget extends StatefulWidget {
  final Widget child;

  const _FloatingInfoWidget({required this.child});

  @override
  State<_FloatingInfoWidget> createState() => _FloatingInfoWidgetState();
}

class _FloatingInfoWidgetState extends State<_FloatingInfoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, _slideAnimation.value),
        end: Offset.zero,
      ).animate(_controller),
      child: Container(
        padding: DesignTokens.spacingM,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: DesignTokens.radiusL,
          boxShadow: [
            ShadowTokens.createShadow(
              color: Colors.black,
              opacity: 0.1,
              blurRadius: DesignTokens.blurRadiusL,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _ThumbOptimizedActionCard extends StatefulWidget {
  final QuickActionItem action;
  final bool isInThumbZone;
  final bool leftHanded;

  const _ThumbOptimizedActionCard({
    required this.action,
    required this.isInThumbZone,
    required this.leftHanded,
  });

  @override
  State<_ThumbOptimizedActionCard> createState() => _ThumbOptimizedActionCardState();
}

class _ThumbOptimizedActionCardState extends State<_ThumbOptimizedActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final isHighPriority = widget.action.priority == ActionPriority.critical;
    final cardHeight = widget.isInThumbZone ? 80.0 : 70.0; // Más alto en zona del pulgar
    
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
        if (isHighPriority) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        widget.action.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: cardHeight,
              decoration: BoxDecoration(
                color: _isPressed 
                    ? widget.action.color.withOpacity(0.2)
                    : Colors.white,
                borderRadius: DesignTokens.radiusL,
                border: Border.all(
                  color: isHighPriority 
                      ? Colors.red 
                      : widget.action.color.withOpacity(0.3),
                  width: isHighPriority ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isInThumbZone)
                    ShadowTokens.createShadow(
                      color: widget.action.color,
                      opacity: 0.2,
                      blurRadius: DesignTokens.blurRadiusM,
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.action.icon,
                    color: widget.action.color,
                    size: widget.isInThumbZone ? 32 : 28,
                  ),
                  SizedBox(height: DesignTokens.spacing1),
                  Text(
                    widget.action.label,
                    style: TextStyle(
                      fontSize: widget.isInThumbZone 
                          ? DesignTokens.fontSizeS 
                          : DesignTokens.fontSizeXS,
                      fontWeight: isHighPriority 
                          ? DesignTokens.fontWeightBold 
                          : DesignTokens.fontWeightMedium,
                      color: widget.action.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isHighPriority)
                    Container(
                      margin: EdgeInsets.only(top: DesignTokens.spacing1),
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: DesignTokens.radiusXS,
                      ),
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

/// Modelo para acciones rápidas
class QuickActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final ActionPriority priority;
  final String? badge;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.priority = ActionPriority.normal,
    this.badge,
  });
}

enum ActionPriority {
  normal,
  important,
  critical,
}

/// Widget de apoyo para pantallas completas optimizadas para una mano
class OneHandedScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? headerActions;
  final Widget? criticalFAB;
  final Widget? secondaryFAB;
  final Widget? bottomBar;
  final bool leftHanded;

  const OneHandedScaffold({
    super.key,
    required this.body,
    this.title,
    this.headerActions,
    this.criticalFAB,
    this.secondaryFAB,
    this.bottomBar,
    this.leftHanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(
        title: Text(title!),
        actions: headerActions,
        titleSpacing: leftHanded ? 0 : null,
      ) : null,
      body: OneHandedLayouts.thumbZoneOptimized(
        child: body,
        criticalAction: criticalFAB,
        secondaryAction: secondaryFAB,
        leftHanded: leftHanded,
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}