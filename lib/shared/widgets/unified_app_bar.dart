import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// AppBar unificado siguiendo el design system de SkyAngel
/// Implementa Material Design 3 y mejores prácticas de UX/UI
class UnifiedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;
  final AppBarType type;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final VoidCallback? onLeadingPressed;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool enableHapticFeedback;
  final String? semanticLabel;

  const UnifiedAppBar({
    super.key,
    required this.title,
    required this.icon,
    this.type = AppBarType.primary,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.onLeadingPressed,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.systemOverlayStyle,
    this.enableHapticFeedback = true,
    this.semanticLabel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColor = AppBarTokens.getSemanticColor(context, type);
    
    return AppBar(
      title: _buildTitle(context, theme, semanticColor),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      elevation: elevation ?? AppBarTokens.appBarElevation,
      shadowColor: theme.colorScheme.shadow.withOpacity(
        DesignTokens.shadowOpacityLight,
      ),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      systemOverlayStyle: systemOverlayStyle ?? _getSystemOverlayStyle(theme),
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight,
      scrolledUnderElevation: AppBarTokens.appBarElevation * 1.5,
      notificationPredicate: (notification) => notification.depth == 0,
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme, Color semanticColor) {
    return Semantics(
      label: semanticLabel ?? title,
      header: true,
      child: Container(
        padding: AppBarTokens.titleContainerPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconContainer(theme, semanticColor),
            SizedBox(width: AppBarTokens.titleSpacing),
            _buildTitleText(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(ThemeData theme, Color semanticColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enableHapticFeedback 
          ? () => HapticFeedback.lightImpact()
          : null,
        borderRadius: AppBarTokens.iconContainerRadius,
        child: Container(
          padding: AppBarTokens.iconContainerPadding,
          decoration: BoxDecoration(
            color: semanticColor.withOpacity(AppBarTokens.backgroundOpacity),
            borderRadius: AppBarTokens.iconContainerRadius,
            boxShadow: ShadowTokens.createElevatedShadow(
              color: semanticColor,
              opacity: AppBarTokens.shadowOpacity,
            ),
            border: Border.all(
              color: semanticColor.withOpacity(
                DesignTokens.backgroundOpacityLight,
              ),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            color: semanticColor,
            size: AppBarTokens.iconSize,
            semanticLabel: '$title icon',
          ),
        ),
      ),
    );
  }

  Widget _buildTitleText(ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppBarTokens.titleFontSize,
        fontWeight: AppBarTokens.titleFontWeight,
        color: theme.colorScheme.onSurface,
        letterSpacing: AppBarTokens.titleLetterSpacing,
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: title,
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(ThemeData theme) {
    final brightness = theme.brightness;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness == Brightness.light 
        ? Brightness.dark 
        : Brightness.light,
      statusBarBrightness: brightness,
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness: brightness == Brightness.light 
        ? Brightness.dark 
        : Brightness.light,
    );
  }
}

/// Factory methods para crear AppBars específicos
extension UnifiedAppBarFactory on UnifiedAppBar {
  /// AppBar para Dashboard
  static UnifiedAppBar dashboard({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return UnifiedAppBar(
      title: 'Dashboard',
      icon: Icons.dashboard_rounded,
      type: AppBarType.primary,
      actions: actions,
      semanticLabel: semanticLabel ?? 'Dashboard de Seguridad',
    );
  }

  /// AppBar para Mapa
  static UnifiedAppBar maps({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return UnifiedAppBar(
      title: 'Mapa',
      icon: Icons.map_rounded,
      type: AppBarType.secondary,
      actions: actions,
      semanticLabel: semanticLabel ?? 'Mapa de Riesgos',
    );
  }

  /// AppBar para Alertas
  static UnifiedAppBar alerts({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return UnifiedAppBar(
      title: 'Alertas',
      icon: Icons.warning_amber_rounded,
      type: AppBarType.error,
      actions: actions,
      semanticLabel: semanticLabel ?? 'Alertas de Seguridad',
    );
  }

  /// AppBar para Rutas
  static UnifiedAppBar routes({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return UnifiedAppBar(
      title: 'Rutas',
      icon: Icons.route_rounded,
      type: AppBarType.tertiary,
      actions: actions,
      semanticLabel: semanticLabel ?? 'Rutas Seguras',
    );
  }

  /// AppBar para Perfil
  static UnifiedAppBar profile({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return UnifiedAppBar(
      title: 'Perfil',
      icon: Icons.person_rounded,
      type: AppBarType.primary,
      actions: actions,
      semanticLabel: semanticLabel ?? 'Perfil de Usuario',
    );
  }

  /// AppBar genérico customizable
  static UnifiedAppBar custom({
    required String title,
    required IconData icon,
    AppBarType type = AppBarType.surface,
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return UnifiedAppBar(
      title: title,
      icon: icon,
      type: type,
      actions: actions,
      semanticLabel: semanticLabel,
    );
  }
}

/// Widget para acciones comunes de AppBar
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool enableHapticFeedback;
  final Color? color;
  final double? size;

  const AppBarAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.enableHapticFeedback = true,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: color,
        size: size ?? DesignTokens.iconSizeM,
      ),
      onPressed: enableHapticFeedback && onPressed != null
        ? () {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        : onPressed,
      tooltip: tooltip,
      splashRadius: DesignTokens.iconSizeXL,
      padding: DesignTokens.spacingS,
      constraints: const BoxConstraints(
        minWidth: kMinInteractiveDimension,
        minHeight: kMinInteractiveDimension,
      ),
    );
  }
}

/// Extensión para crear acciones comunes
extension CommonAppBarActions on AppBarAction {
  static AppBarAction refresh({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      icon: Icons.refresh_rounded,
      onPressed: onPressed,
      tooltip: tooltip ?? 'Actualizar',
    );
  }

  static AppBarAction filter({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      icon: Icons.filter_list_rounded,
      onPressed: onPressed,
      tooltip: tooltip ?? 'Filtrar',
    );
  }

  static AppBarAction search({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      icon: Icons.search_rounded,
      onPressed: onPressed,
      tooltip: tooltip ?? 'Buscar',
    );
  }

  static AppBarAction settings({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      icon: Icons.settings_rounded,
      onPressed: onPressed,
      tooltip: tooltip ?? 'Configuración',
    );
  }

  static AppBarAction more({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      icon: Icons.more_vert_rounded,
      onPressed: onPressed,
      tooltip: tooltip ?? 'Más opciones',
    );
  }

  static AppBarAction logout({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      icon: Icons.logout_rounded,
      onPressed: onPressed,
      tooltip: tooltip ?? 'Cerrar sesión',
    );
  }
}