import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';
import 'header_theme.dart';

/// Header moderno y funcional específico para SkyAngel
/// Incluye funcionalidades avanzadas por módulo
class HeaderBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final HeaderType type;
  final List<HeaderAction>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool showLogo;
  final Color? backgroundColor;
  final bool floating;
  final HeaderNotification? notification;
  final VoidCallback? onNotificationTap;
  final String? semanticLabel;
  final bool showBorder;
  final double? customHeight;
  final EdgeInsetsGeometry? customPadding;

  const HeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.type = HeaderType.primary,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
    this.showLogo = false,
    this.backgroundColor,
    this.floating = false,
    this.notification,
    this.onNotificationTap,
    this.semanticLabel,
    this.showBorder = false,
    this.customHeight,
    this.customPadding,
  });

  @override
  State<HeaderBar> createState() => _HeaderBarState();

  @override
  Size get preferredSize => Size.fromHeight(customHeight ?? (subtitle != null ? 72 : 56));
}

class _HeaderBarState extends State<HeaderBar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerTheme = _getHeaderTheme(colorScheme);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return RepaintBoundary(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: headerTheme.gradient,
                boxShadow: widget.floating ? [
                  ShadowTokens.createShadow(
                    color: headerTheme.shadowColor,
                    opacity: DesignTokens.shadowOpacityMedium,
                    blurRadius: DesignTokens.blurRadiusL,
                    offset: DesignTokens.shadowOffsetM,
                  ),
                ] : null,
                borderRadius: widget.floating 
                    ? DesignTokens.radiusL.copyWith(
                        topLeft: Radius.zero,
                        topRight: Radius.zero,
                      )
                    : null,
                border: widget.showBorder ? Border(
                  bottom: BorderSide(
                    color: headerTheme.onSurfaceColor.withOpacity(0.1),
                    width: 1,
                  ),
                ) : null,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: _buildLeading(context, headerTheme),
                automaticallyImplyLeading: false,
                title: _buildTitle(context, headerTheme),
                actions: _buildActions(context, headerTheme),
                systemOverlayStyle: headerTheme.systemOverlayStyle,
                toolbarHeight: widget.subtitle != null ? 72 : 56,
                titleSpacing: widget.showBackButton || widget.leading != null ? 0 : DesignTokens.spacing6,
                centerTitle: false,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, AppHeaderTheme headerTheme) {
    if (widget.leading != null) return widget.leading;
    if (!widget.showBackButton) return null;

    return Semantics(
      label: 'Navegar hacia atrás',
      button: true,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: headerTheme.onSurfaceColor,
          size: DesignTokens.iconSizeS,
        ),
      onPressed: () {
        HapticFeedback.lightImpact();
        if (widget.onBackPressed != null) {
          widget.onBackPressed!();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      tooltip: 'Atrás',
      style: IconButton.styleFrom(
        padding: DesignTokens.spacingXS,
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, AppHeaderTheme headerTheme) {
    return Row(
      children: [
        // Título principal - removido el contenedor con ícono
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: headerTheme.onSurfaceColor,
                  fontSize: DesignTokens.fontSizeXL,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                  letterSpacing: DesignTokens.letterSpacingNormal,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
                semanticsLabel: widget.semanticLabel ?? widget.title,
              ),
              if (widget.subtitle != null) ...[
                SizedBox(height: DesignTokens.spacing1),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    color: headerTheme.onSurfaceColor.withOpacity(DesignTokens.opacityMedium),
                    fontSize: DesignTokens.fontSizeS,
                    fontWeight: DesignTokens.fontWeightRegular,
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
        // Solo mostrar notificación si es crítica
        if (widget.notification != null && widget.notification!.count != null && widget.notification!.count! > 0)
          _buildNotificationBadge(headerTheme),
      ],
    );
  }

  Widget _buildNotificationBadge(AppHeaderTheme headerTheme) {
    if (widget.notification == null) return const SizedBox.shrink();
    
    final notification = widget.notification!;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onNotificationTap?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing2,
          vertical: DesignTokens.spacing1,
        ),
        decoration: BoxDecoration(
          color: notification.color ?? Colors.red,
          borderRadius: DesignTokens.radiusFull,
        ),
        child: Text(
          notification.count! > 99 ? '99+' : notification.count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: DesignTokens.fontSizeXS,
            fontWeight: DesignTokens.fontWeightSemiBold,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context, AppHeaderTheme headerTheme) {
    if (widget.actions == null || widget.actions!.isEmpty) return null;

    // Limitar a máximo 2 acciones para evitar sobrecarga
    final limitedActions = widget.actions!.take(2).toList();

    return limitedActions.map((action) {
      return Semantics(
        button: true,
        label: action.tooltip ?? 'Acción del header',
        child: _HeaderActionWidget(
          action: action,
          headerTheme: headerTheme,
        ),
      );
    }).toList();
  }

  AppHeaderTheme _getHeaderTheme(ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return HeaderTheme.getTheme(
      context,
      widget.type,
      customBackgroundColor: widget.backgroundColor,
      isDarkMode: isDarkMode,
    );
  }
}

class _HeaderActionWidget extends StatefulWidget {
  final HeaderAction action;
  final AppHeaderTheme headerTheme;

  const _HeaderActionWidget({
    required this.action,
    required this.headerTheme,
  });

  @override
  State<_HeaderActionWidget> createState() => _HeaderActionWidgetState();
}

class _HeaderActionWidgetState extends State<_HeaderActionWidget>
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_controller);
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
        HapticFeedback.lightImpact();
        widget.action.onPressed();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: DesignTokens.spacing2),
              padding: DesignTokens.spacingS,
              decoration: BoxDecoration(
                color: _isPressed 
                    ? widget.headerTheme.onSurfaceColor.withOpacity(DesignTokens.backgroundOpacityLight)
                    : Colors.transparent,
                borderRadius: DesignTokens.radiusS,
              ),
              child: Stack(
                children: [
                  Icon(
                    widget.action.icon,
                    color: widget.headerTheme.onSurfaceColor,
                    size: DesignTokens.iconSizeL,
                  ),
                  // Badge simplificado - solo si hay count > 0
                  if (widget.action.badge != null && 
                      widget.action.badge!.count != null && 
                      widget.action.badge!.count! > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: DesignTokens.radiusFull,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          widget.action.badge!.count! > 9 ? '9+' : widget.action.badge!.count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: DesignTokens.fontWeightSemiBold,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
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


class HeaderAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final HeaderBadge? badge;

  const HeaderAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge,
  });
}

class HeaderBadge {
  final int? count;
  final Color? color;

  const HeaderBadge({
    this.count,
    this.color,
  });
}

class HeaderNotification {
  final IconData icon;
  final int? count;
  final Color? color;
  final String? message;

  const HeaderNotification({
    required this.icon,
    this.count,
    this.color,
    this.message,
  });
}


// Factory para crear headers específicos por módulo
class HeaderBarFactory {
  static HeaderBar dashboard({
    List<HeaderAction>? actions,
    HeaderNotification? notification,
    VoidCallback? onNotificationTap,
    String? subtitle,
  }) {
    return HeaderBar(
      title: 'Dashboard',
      subtitle: subtitle,
      icon: Icons.dashboard_rounded,
      type: HeaderType.primary,
      actions: actions,
      notification: notification,
      onNotificationTap: onNotificationTap,
    );
  }

  static HeaderBar maps({
    List<HeaderAction>? actions,
    HeaderNotification? notification,
    VoidCallback? onNotificationTap,
    String? subtitle,
  }) {
    return HeaderBar(
      title: 'Mapa',
      subtitle: subtitle,
      icon: Icons.map_rounded,
      type: HeaderType.secondary,
      actions: actions,
      notification: notification,
      onNotificationTap: onNotificationTap,
    );
  }

  static HeaderBar alerts({
    List<HeaderAction>? actions,
    HeaderNotification? notification,
    VoidCallback? onNotificationTap,
    String? subtitle,
  }) {
    return HeaderBar(
      title: 'Alertas',
      subtitle: subtitle,
      icon: Icons.warning_amber_rounded,
      type: HeaderType.warning,
      actions: actions,
      notification: notification,
      onNotificationTap: onNotificationTap,
    );
  }

  static HeaderBar routes({
    List<HeaderAction>? actions,
    HeaderNotification? notification,
    VoidCallback? onNotificationTap,
    String? subtitle,
  }) {
    return HeaderBar(
      title: 'Rutas',
      subtitle: subtitle,
      icon: Icons.route_rounded,
      type: HeaderType.secondary,
      actions: actions,
      notification: notification,
      onNotificationTap: onNotificationTap,
    );
  }

  static HeaderBar profile({
    String? userName,
    List<HeaderAction>? actions,
  }) {
    return HeaderBar(
      title: userName ?? 'Perfil',
      icon: Icons.person_rounded,
      type: HeaderType.surface,
      actions: actions,
    );
  }

  static HeaderBar createAlert() {
    return const HeaderBar(
      title: 'Nueva Alerta',
      icon: Icons.add_alert_rounded,
      type: HeaderType.warning,
      showBackButton: true,
    );
  }

  static HeaderBar settings() {
    return const HeaderBar(
      title: 'Configuración',
      icon: Icons.settings_rounded,
      type: HeaderType.surface,
      showBackButton: true,
    );
  }
}

// Actions esenciales - máximo 2 por header
class HeaderActions {
  static HeaderAction search(VoidCallback onPressed) {
    return HeaderAction(
      icon: Icons.search_rounded,
      onPressed: onPressed,
      tooltip: 'Buscar',
    );
  }

  static HeaderAction notifications(VoidCallback onPressed, {int? count}) {
    return HeaderAction(
      icon: Icons.notifications_outlined,
      onPressed: onPressed,
      tooltip: 'Notificaciones',
      badge: count != null && count > 0 ? HeaderBadge(count: count) : null,
    );
  }

  static HeaderAction more(VoidCallback onPressed) {
    return HeaderAction(
      icon: Icons.more_vert_rounded,
      onPressed: onPressed,
      tooltip: 'Opciones',
    );
  }

  static HeaderAction filter(VoidCallback onPressed) {
    return HeaderAction(
      icon: Icons.tune_rounded,
      onPressed: onPressed,
      tooltip: 'Filtros',
    );
  }

  static HeaderAction refresh(VoidCallback onPressed) {
    return HeaderAction(
      icon: Icons.refresh_rounded,
      onPressed: onPressed,
      tooltip: 'Actualizar',
    );
  }

  static HeaderAction layers(VoidCallback onPressed) {
    return HeaderAction(
      icon: Icons.layers_rounded,
      onPressed: onPressed,
      tooltip: 'Capas',
    );
  }

  static HeaderAction viewMode(VoidCallback onPressed) {
    return HeaderAction(
      icon: Icons.view_module_rounded,
      onPressed: onPressed,
      tooltip: 'Modo de vista',
    );
  }
}