import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_tokens.dart';
import '../models/menu_item.dart';
import 'navigation_system.dart';

/// Sistema de navegación adaptativo cross-platform
/// Optimizado para iOS, Android y Web según contexto
class PlatformNavigation extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final bool showFab;
  final VoidCallback? onFabPressed;
  final NavigationStyle style;

  const PlatformNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.showFab = true,
    this.onFabPressed,
    this.style = NavigationStyle.adaptive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (_getEffectiveStyle(context)) {
      case NavigationStyle.material:
        return AppBottomNavigation(
          currentIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          showFab: showFab,
          onFabPressed: onFabPressed,
        );
      case NavigationStyle.cupertino:
        return _CupertinoTabSystem(
          currentIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
        );
      case NavigationStyle.pill:
        return PillNavigationBar(
          currentIndex: currentIndex,
          onTap: onDestinationSelected,
        );
      case NavigationStyle.adaptive:
        return _buildAdaptiveMenu(context, ref);
    }
  }

  NavigationStyle _getEffectiveStyle(BuildContext context) {
    if (style != NavigationStyle.adaptive) return style;
    
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return NavigationStyle.cupertino;
    }
    
    if (kIsWeb) {
      return NavigationStyle.pill;
    }
    
    return NavigationStyle.material;
  }

  Widget _buildAdaptiveMenu(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // En pantallas grandes, usar diseño horizontal
    if (screenWidth > 600) {
      return _buildRailNavigation(context, ref);
    }
    
    return AppBottomNavigation(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      showFab: showFab,
      onFabPressed: onFabPressed,
    );
  }

  Widget _buildRailNavigation(BuildContext context, WidgetRef ref) {
    return _NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}

enum NavigationStyle {
  material,
  cupertino,
  pill,
  adaptive,
}

/// Navigation Rail para pantallas grandes
class _NavigationRail extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const _NavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.secondaryContainer,
      labelType: NavigationRailLabelType.selected,
      useIndicator: true,
      minWidth: 72,
      destinations: MenuConfig.bottomNavigationItems.map((item) =>
        NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon ?? item.icon),
          label: Text(item.title),
        ),
      ).toList(),
    );
  }
}

/// Sistema Cupertino nativo para iOS
class _CupertinoTabSystem extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const _CupertinoTabSystem({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: (index) {
        HapticFeedback.selectionClick();
        onDestinationSelected(index);
      },
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      activeColor: CupertinoColors.systemBlue.resolveFrom(context),
      inactiveColor: CupertinoColors.systemGrey.resolveFrom(context),
      iconSize: DesignTokens.iconSizeL,
      items: MenuConfig.bottomNavigationItems.map((item) =>
        BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon ?? item.icon),
          label: item.title,
        ),
      ).toList(),
    );
  }
}

/// Menú contextual inteligente
class ContextualMenu extends StatefulWidget {
  final Widget child;
  final List<ContextualAction> actions;
  final bool showOnLongPress;

  const ContextualMenu({
    super.key,
    required this.child,
    required this.actions,
    this.showOnLongPress = true,
  });

  @override
  State<ContextualMenu> createState() => _ContextualMenuState();
}

class _ContextualMenuState extends State<ContextualMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  OverlayEntry? _overlayEntry;
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hideMenu();
    _animationController.dispose();
    super.dispose();
  }

  void _showMenu(Offset position) {
    if (_isMenuVisible) return;
    
    _isMenuVisible = true;
    HapticFeedback.mediumImpact();
    
    _overlayEntry = _createOverlayEntry(position);
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _hideMenu() {
    if (!_isMenuVisible) return;
    
    _isMenuVisible = false;
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry(Offset position) {
    return OverlayEntry(
      builder: (context) => _ContextualMenuOverlay(
        position: position,
        actions: widget.actions,
        scaleAnimation: _scaleAnimation,
        opacityAnimation: _opacityAnimation,
        onDismiss: _hideMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: widget.showOnLongPress 
          ? (details) => _showMenu(details.globalPosition)
          : null,
      onTap: _isMenuVisible ? _hideMenu : null,
      child: widget.child,
    );
  }
}

class _ContextualMenuOverlay extends StatelessWidget {
  final Offset position;
  final List<ContextualAction> actions;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final VoidCallback onDismiss;

  const _ContextualMenuOverlay({
    required this.position,
    required this.actions,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop para cerrar el menú
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Menú contextual
        Positioned(
          left: position.dx - 100,
          top: position.dy - 50,
          child: AnimatedBuilder(
            animation: Listenable.merge([scaleAnimation, opacityAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                child: Opacity(
                  opacity: opacityAnimation.value,
                  child: _ContextualMenuContent(
                    actions: actions,
                    onActionSelected: (action) {
                      onDismiss();
                      action.onPressed();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContextualMenuContent extends StatelessWidget {
  final List<ContextualAction> actions;
  final Function(ContextualAction) onActionSelected;

  const _ContextualMenuContent({
    required this.actions,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: DesignTokens.radiusL,
      elevation: DesignTokens.elevationL,
      child: Container(
        constraints: const BoxConstraints(minWidth: 200),
        padding: DesignTokens.spacingS,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions.map((action) =>
            _ContextualMenuItem(
              action: action,
              onTap: () => onActionSelected(action),
            ),
          ).toList(),
        ),
      ),
    );
  }
}

class _ContextualMenuItem extends StatefulWidget {
  final ContextualAction action;
  final VoidCallback onTap;

  const _ContextualMenuItem({
    required this.action,
    required this.onTap,
  });

  @override
  State<_ContextualMenuItem> createState() => _ContextualMenuItemState();
}

class _ContextualMenuItemState extends State<_ContextualMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: DesignTokens.spacingM,
          decoration: BoxDecoration(
            color: _isHovered 
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: DesignTokens.radiusS,
          ),
          child: Row(
            children: [
              Icon(
                widget.action.icon,
                size: DesignTokens.iconSizeM,
                color: widget.action.isDestructive 
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Text(
                  widget.action.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.action.isDestructive 
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (widget.action.shortcut != null)
                Text(
                  widget.action.shortcut!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContextualAction {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;
  final String? shortcut;

  const ContextualAction({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
    this.shortcut,
  });
}

/// Sistema de navegación breadcrumbs para jerarquías complejas
class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Function(BreadcrumbItem) onItemTap;

  const BreadcrumbNavigation({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: DesignTokens.spacingM,
      child: Row(
        children: _buildBreadcrumbItems(theme),
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(ThemeData theme) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      
      widgets.add(
        GestureDetector(
          onTap: isLast ? null : () => onItemTap(item),
          child: Text(
            item.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isLast 
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.primary,
              fontWeight: isLast 
                  ? DesignTokens.fontWeightMedium
                  : DesignTokens.fontWeightRegular,
            ),
          ),
        ),
      );
      
      if (!isLast) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing2),
            child: Icon(
              Icons.chevron_right,
              size: DesignTokens.iconSizeS,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
}

class BreadcrumbItem {
  final String title;
  final String path;

  const BreadcrumbItem({
    required this.title,
    required this.path,
  });
}