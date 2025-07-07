import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// AppBar base de la aplicación siguiendo el design system de SkyAngel
/// Implementa Material Design 3 y mejores prácticas de UX/UI
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
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

  const AppBarWidget({
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
      leading: _buildLeading(context, theme, semanticColor),
      actions: _buildActions(context, theme, semanticColor),
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppBarTokens.getBackgroundColor(context, type),
      foregroundColor: foregroundColor ?? AppBarTokens.getForegroundColor(context, type),
      elevation: elevation ?? AppBarTokens.getElevation(type),
      systemOverlayStyle: systemOverlayStyle ?? AppBarTokens.getSystemOverlayStyle(context, type),
      scrolledUnderElevation: AppBarTokens.getScrolledUnderElevation(type),
      surfaceTintColor: AppBarTokens.getSurfaceTintColor(context, type),
      shadowColor: AppBarTokens.getShadowColor(context, type),
      titleSpacing: AppBarTokens.getTitleSpacing(type),
      titleTextStyle: AppBarTokens.getTitleTextStyle(context, type),
      toolbarTextStyle: AppBarTokens.getToolbarTextStyle(context, type),
      shape: AppBarTokens.getShape(type),
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme, Color semanticColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: foregroundColor ?? semanticColor,
          size: AppBarTokens.getIconSize(type),
          semanticLabel: semanticLabel,
        ),
        const SizedBox(width: DesignTokens.spacing2),
        Text(
          title,
          style: AppBarTokens.getTitleTextStyle(context, type)?.copyWith(
            color: foregroundColor ?? semanticColor,
          ),
          semanticsLabel: semanticLabel ?? title,
        ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context, ThemeData theme, Color semanticColor) {
    if (leading != null) return leading;
    if (!automaticallyImplyLeading) return null;
    
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: foregroundColor ?? semanticColor,
        size: AppBarTokens.getIconSize(type),
      ),
      onPressed: () {
        if (enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        
        if (onLeadingPressed != null) {
          onLeadingPressed!();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      style: AppBarTokens.getIconButtonStyle(context, type),
    );
  }

  List<Widget>? _buildActions(BuildContext context, ThemeData theme, Color semanticColor) {
    if (actions == null || actions!.isEmpty) return null;
    
    return actions!.map((action) {
      // Envolver acciones en un tema consistente
      return Theme(
        data: theme.copyWith(
          iconButtonTheme: IconButtonThemeData(
            style: AppBarTokens.getIconButtonStyle(context, type),
          ),
        ),
        child: action,
      );
    }).toList();
  }
}

/// Factory para crear AppBars predefinidos comunes
class AppBarFactory {
  static AppBarWidget primary({
    required String title,
    required IconData icon,
    List<Widget>? actions,
    VoidCallback? onLeadingPressed,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: title,
      icon: icon,
      type: AppBarType.primary,
      actions: actions,
      onLeadingPressed: onLeadingPressed,
      semanticLabel: semanticLabel,
    );
  }

  static AppBarWidget secondary({
    required String title,
    required IconData icon,
    List<Widget>? actions,
    VoidCallback? onLeadingPressed,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: title,
      icon: icon,
      type: AppBarType.secondary,
      actions: actions,
      onLeadingPressed: onLeadingPressed,
      semanticLabel: semanticLabel,
    );
  }

  static AppBarWidget danger({
    required String title,
    required IconData icon,
    List<Widget>? actions,
    VoidCallback? onLeadingPressed,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: title,
      icon: icon,
      type: AppBarType.danger,
      actions: actions,
      onLeadingPressed: onLeadingPressed,
      semanticLabel: semanticLabel,
    );
  }

  static AppBarWidget success({
    required String title,
    required IconData icon,
    List<Widget>? actions,
    VoidCallback? onLeadingPressed,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: title,
      icon: icon,
      type: AppBarType.success,
      actions: actions,
      onLeadingPressed: onLeadingPressed,
      semanticLabel: semanticLabel,
    );
  }

  static AppBarWidget warning({
    required String title,
    required IconData icon,
    List<Widget>? actions,
    VoidCallback? onLeadingPressed,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: title,
      icon: icon,
      type: AppBarType.warning,
      actions: actions,
      onLeadingPressed: onLeadingPressed,
      semanticLabel: semanticLabel,
    );
  }

  static AppBarWidget dashboard({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: 'Dashboard',
      icon: Icons.dashboard_rounded,
      type: AppBarType.primary,
      actions: actions,
      automaticallyImplyLeading: false,
      semanticLabel: semanticLabel ?? 'Dashboard',
    );
  }

  static AppBarWidget maps({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: 'Mapa de Delitos',
      icon: Icons.map_rounded,
      type: AppBarType.primary,
      actions: actions,
      automaticallyImplyLeading: false,
      semanticLabel: semanticLabel ?? 'Mapa de delitos',
    );
  }

  static AppBarWidget alerts({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: 'Alertas',
      icon: Icons.warning_amber_rounded,
      type: AppBarType.warning,
      actions: actions,
      automaticallyImplyLeading: false,
      semanticLabel: semanticLabel ?? 'Alertas de seguridad',
    );
  }

  static AppBarWidget routes({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: 'Rutas Seguras',
      icon: Icons.route_rounded,
      type: AppBarType.secondary,
      actions: actions,
      automaticallyImplyLeading: false,
      semanticLabel: semanticLabel ?? 'Rutas seguras',
    );
  }

  static AppBarWidget profile({
    List<Widget>? actions,
    String? semanticLabel,
  }) {
    return AppBarWidget(
      title: 'Perfil',
      icon: Icons.person_rounded,
      type: AppBarType.primary,
      actions: actions,
      automaticallyImplyLeading: false,
      semanticLabel: semanticLabel ?? 'Perfil de usuario',
    );
  }
}

/// Componentes comunes para AppBars
class AppBarActions {
  static Widget search({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return IconButton(
      icon: const Icon(Icons.search_rounded),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      tooltip: tooltip ?? 'Buscar',
    );
  }

  static Widget filter({
    required VoidCallback onPressed,
    String? tooltip,
    bool isActive = false,
  }) {
    return IconButton(
      icon: Icon(
        isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      tooltip: tooltip ?? 'Filtros',
    );
  }

  static Widget notifications({
    required VoidCallback onPressed,
    String? tooltip,
    int? badgeCount,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          tooltip: tooltip ?? 'Notificaciones',
        ),
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  static Widget logout({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      tooltip: tooltip ?? 'Cerrar sesión',
    );
  }

  static Widget menu({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      tooltip: tooltip ?? 'Menú',
    );
  }

  static Widget settings({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return IconButton(
      icon: const Icon(Icons.settings_rounded),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      tooltip: tooltip ?? 'Configuración',
    );
  }
}