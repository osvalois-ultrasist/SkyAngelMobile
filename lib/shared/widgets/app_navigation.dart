import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/permission_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../models/menu_item.dart';
import '../design_system/design_tokens.dart';

/// Bottom Navigation principal de la aplicación siguiendo el patrón de diseño de SkyAngel
class AppNavigation extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  ConsumerState<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends ConsumerState<AppNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final availableItems = MenuConfig.bottomNavigationItems
        .where((item) => item.requiredPermission == null || 
                       PermissionService.hasPermission(user, item.requiredPermission!))
        .toList();

    if (availableItems.isEmpty) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: DesignTokens.spacingL,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: DesignTokens.radiusXXL,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: DesignTokens.radiusXXL,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: availableItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _mapToAvailableIndex(widget.currentIndex, availableItems) == index;
                    
                    return Expanded(
                      child: _NavigationItem(
                        item: item,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (item.tabIndex != null) {
                            widget.onTap(item.tabIndex!);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

class _NavigationItem extends StatefulWidget {
  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _selectionController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: DesignTokens.animationDurationQuick,
      vsync: this,
    );
    
    _selectionController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(_NavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    _colorAnimation = ColorTween(
      begin: colorScheme.onSurface.withOpacity(0.6),
      end: colorScheme.primary,
    ).animate(_selectionController);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _hoverAnimation,
            _selectionAnimation,
            _colorAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _hoverAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isSelected 
                      ? colorScheme.primary.withOpacity(0.1)
                      : _isHovered 
                          ? colorScheme.onSurface.withOpacity(0.05)
                          : Colors.transparent,
                  borderRadius: DesignTokens.radiusL,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.isSelected)
                          AnimatedBuilder(
                            animation: _selectionAnimation,
                            builder: (context, child) {
                              final opacity = (0.1 * (1.0 - _selectionAnimation.value)).clamp(0.0, 1.0);
                              return Transform.scale(
                                scale: 1.0 + (_selectionAnimation.value * 0.2),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(opacity),
                                    borderRadius: DesignTokens.radiusFull,
                                  ),
                                ),
                              );
                            },
                          ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.isSelected 
                                ? colorScheme.primaryContainer.withOpacity(0.6)
                                : Colors.transparent,
                            borderRadius: DesignTokens.radiusS,
                          ),
                          child: Icon(
                            widget.isSelected && widget.item.activeIcon != null
                                ? widget.item.activeIcon!
                                : widget.item.icon,
                            color: _colorAnimation.value,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 2),
                    
                    AnimatedBuilder(
                      animation: _selectionAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: (0.8 + (_selectionAnimation.value * 0.2)).clamp(0.0, 1.0),
                          child: Text(
                            widget.item.title,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _colorAnimation.value,
                              fontWeight: widget.isSelected 
                                  ? DesignTokens.fontWeightSemiBold
                                  : DesignTokens.fontWeightMedium,
                              fontSize: 10 + (_selectionAnimation.value * 0.5),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                    
                    AnimatedBuilder(
                      animation: _selectionAnimation,
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.only(top: 1),
                          height: 2,
                          width: 20 * _selectionAnimation.value,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: DesignTokens.radiusXS,
                            boxShadow: widget.isSelected ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ] : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Floating Action Button para alertas rápidas
class AlertButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AlertButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<AlertButton> createState() => _AlertButtonState();
}

class _AlertButtonState extends State<AlertButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: DesignTokens.animationDurationQuick,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      bottom: 100,
      right: 20,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTapDown: (_) => _scaleController.forward(),
                    onTapUp: (_) => _scaleController.reverse(),
                    onTapCancel: () => _scaleController.reverse(),
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      widget.onPressed();
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.error,
                            colorScheme.error.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: DesignTokens.radiusXXL,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.error.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: colorScheme.error.withOpacity(0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: colorScheme.onError,
                        size: DesignTokens.iconSizeXL,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}