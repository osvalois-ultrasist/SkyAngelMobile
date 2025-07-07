import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_tokens.dart';
import '../models/menu_item.dart';
import '../../core/services/permission_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Sistema de navegación basado en Material 3 y mejores prácticas
/// Optimizado para performance, accesibilidad y experiencia de usuario
class NavigationConfig {
  static const double bottomNavHeight = 80.0;
  static const double fabSize = 56.0;
  static const Duration microAnimationDuration = Duration(milliseconds: 200);
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);
  
  // Configuraciones adaptivas según plataforma
  static bool get useHapticFeedback => true;
  static bool get showLabels => true;
  static NavigationDestinationLabelBehavior get labelBehavior => 
      NavigationDestinationLabelBehavior.onlyShowSelected;
}

/// Bottom Navigation Bar con Material 3
class AppBottomNavigation extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final bool showFab;
  final VoidCallback? onFabPressed;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.showFab = true,
    this.onFabPressed,
  });

  @override
  ConsumerState<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends ConsumerState<AppBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fabController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: NavigationConfig.standardAnimationDuration,
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: NavigationConfig.microAnimationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    
    final availableDestinations = MenuConfig.bottomNavigationItems
        .where((item) => item.requiredPermission == null || 
                        PermissionService.hasPermission(user, item.requiredPermission!))
        .toList();

    if (availableDestinations.isEmpty) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildNavigationBar(availableDestinations),
            if (widget.showFab) _buildFab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(List<MenuItem> destinations) {
    return NavigationBar(
      selectedIndex: _mapToAvailableIndex(widget.currentIndex, destinations),
      onDestinationSelected: (index) {
        if (NavigationConfig.useHapticFeedback) {
          HapticFeedback.selectionClick();
        }
        
        final destination = destinations[index];
        if (destination.tabIndex != null) {
          widget.onDestinationSelected(destination.tabIndex!);
        }
      },
      height: NavigationConfig.bottomNavHeight,
      labelBehavior: NavigationConfig.labelBehavior,
      animationDuration: NavigationConfig.microAnimationDuration,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      shadowColor: Theme.of(context).shadowColor,
      indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
      destinations: destinations.map((item) => 
        _buildNavigationDestination(item)).toList(),
    );
  }

  NavigationDestination _buildNavigationDestination(MenuItem item) {
    return NavigationDestination(
      icon: Icon(item.icon),
      selectedIcon: Icon(item.activeIcon ?? item.icon),
      label: item.title,
      tooltip: item.title,
    );
  }

  Widget _buildFab() {
    return Positioned(
      bottom: NavigationConfig.bottomNavHeight / 2 - NavigationConfig.fabSize / 2,
      right: DesignTokens.spacing4,
      child: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: () {
            if (NavigationConfig.useHapticFeedback) {
              HapticFeedback.heavyImpact();
            }
            _animateFabPress();
            widget.onFabPressed?.call();
          },
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          elevation: DesignTokens.elevationL,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NavigationConfig.fabSize / 2),
          ),
          child: const Icon(Icons.add_alert_rounded),
        ),
      ),
    );
  }

  void _animateFabPress() {
    _fabController.reverse().then((_) => _fabController.forward());
  }

  int _mapToAvailableIndex(int originalIndex, List<MenuItem> availableItems) {
    for (int i = 0; i < availableItems.length; i++) {
      if (availableItems[i].tabIndex == originalIndex) {
        return i;
      }
    }
    return 0;
  }
}

/// Drawer optimizado con Material 3
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  late List<AnimationController> _itemControllers;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _listController = AnimationController(
      duration: NavigationConfig.standardAnimationDuration,
      vsync: this,
    );

    _itemControllers = List.generate(
      MenuConfig.drawerMenuItems.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 150 + (index * 30)),
        vsync: this,
      ),
    );

    _animateIn();
  }

  void _animateIn() {
    _listController.forward();
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted) _itemControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return NavigationDrawer(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shadowColor: theme.shadowColor,
      indicatorColor: theme.colorScheme.secondaryContainer,
      children: [
        _buildDrawerHeader(theme, user),
        const SizedBox(height: DesignTokens.spacing3),
        ..._buildMenuItems(user),
        const SizedBox(height: DesignTokens.spacing3),
        _buildFooter(theme),
      ],
    );
  }

  Widget _buildDrawerHeader(ThemeData theme, dynamic user) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: DesignTokens.spacingS,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
                  borderRadius: DesignTokens.radiusM,
                ),
                child: Icon(
                  Icons.security_rounded,
                  size: DesignTokens.iconSizeXL,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Text(
                'SkyAngel',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: DesignTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? 'Usuario',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Usuario activo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(dynamic user) {
    final visibleItems = MenuConfig.drawerMenuItems
        .where((item) => item.requiredPermission == null || 
                        PermissionService.hasPermission(user, item.requiredPermission!))
        .toList();

    return visibleItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final controller = index < _itemControllers.length 
          ? _itemControllers[index] 
          : _itemControllers.last;

      if (item.isDivider) {
        return const Divider(height: DesignTokens.spacing6);
      }

      return _buildAnimatedMenuItem(item, controller);
    }).toList();
  }

  Widget _buildAnimatedMenuItem(MenuItem item, AnimationController controller) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: NavigationDrawerDestination(
          icon: Icon(item.icon),
          label: Text(item.title),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: DesignTokens.spacingL,
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: DesignTokens.spacing2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security_rounded,
                size: DesignTokens.iconSizeS,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: DesignTokens.spacing2),
              Text(
                'SkyAngel Mobile v2.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pill Navigation Bar - Alternativa compacta
class PillNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PillNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    
    final availableItems = MenuConfig.bottomNavigationItems
        .where((item) => item.requiredPermission == null || 
                        PermissionService.hasPermission(user, item.requiredPermission!))
        .take(4) // Máximo 4 items para mejor UX
        .toList();

    return Container(
      margin: DesignTokens.spacingL,
      padding: DesignTokens.spacingS,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: DesignTokens.radiusXXL,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: availableItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == (item.tabIndex ?? 0);
          
          return _PillNavigationItem(
            item: item,
            isSelected: isSelected,
            onTap: () {
              if (NavigationConfig.useHapticFeedback) {
                HapticFeedback.lightImpact();
              }
              if (item.tabIndex != null) {
                onTap(item.tabIndex!);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class _PillNavigationItem extends StatefulWidget {
  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillNavigationItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PillNavigationItem> createState() => _PillNavigationItemState();
}

class _PillNavigationItemState extends State<_PillNavigationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NavigationConfig.microAnimationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(_PillNavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    _colorAnimation = ColorTween(
      begin: theme.colorScheme.onSurfaceVariant,
      end: theme.colorScheme.onSecondaryContainer,
    ).animate(_controller);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: DesignTokens.spacingM,
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? theme.colorScheme.secondaryContainer
                    : Colors.transparent,
                borderRadius: DesignTokens.radiusXL,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isSelected && widget.item.activeIcon != null
                        ? widget.item.activeIcon!
                        : widget.item.icon,
                    color: _colorAnimation.value,
                    size: DesignTokens.iconSizeM,
                  ),
                  if (widget.isSelected) ...[
                    const SizedBox(width: DesignTokens.spacing2),
                    Text(
                      widget.item.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _colorAnimation.value,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}