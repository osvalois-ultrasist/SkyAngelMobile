import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// Sistema de accesibilidad para navegación siguiendo WCAG 2.1 AA
class NavigationAccessibility {
  static const double minimumTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;
  static const double contrastRatio = 4.5; // AA standard
  
  // Configuraciones de accesibilidad
  static bool reduceMotion = false;
  static bool highContrast = false;
  static double textScaleFactor = 1.0;
  static bool screenReaderEnabled = false;
  
  static void initialize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    reduceMotion = mediaQuery.disableAnimations;
    textScaleFactor = mediaQuery.textScaleFactor;
    highContrast = mediaQuery.highContrast;
    
    // Detectar si hay screen reader activo
    screenReaderEnabled = mediaQuery.accessibleNavigation;
  }
  
  static Duration getAnimationDuration(Duration normalDuration) {
    if (reduceMotion) return Duration.zero;
    return normalDuration;
  }
  
  static Color getContrastColor(Color background, Color foreground) {
    if (!highContrast) return foreground;
    
    // Incrementar contraste si es necesario
    final luminanceBackground = background.computeLuminance();
    final luminanceForeground = foreground.computeLuminance();
    
    final contrast = (luminanceBackground + 0.05) / (luminanceForeground + 0.05);
    
    if (contrast < contrastRatio) {
      return luminanceBackground > 0.5 ? Colors.black : Colors.white;
    }
    
    return foreground;
  }
}

/// Botón de navegación accesible
class AccessibleNavigationButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final bool isSelected;
  final bool enabled;

  const AccessibleNavigationButton({
    super.key,
    required this.child,
    this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.isSelected = false,
    this.enabled = true,
  });

  @override
  State<AccessibleNavigationButton> createState() => _AccessibleNavigationButtonState();
}

class _AccessibleNavigationButtonState extends State<AccessibleNavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NavigationAccessibility.getAnimationDuration(
        const Duration(milliseconds: 150)
      ),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
    
    return Semantics(
      label: widget.semanticLabel,
      hint: widget.tooltip,
      button: true,
      enabled: widget.enabled,
      selected: widget.isSelected,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onTapDown: widget.enabled ? (_) => _controller.forward() : null,
                  onTapUp: widget.enabled ? (_) => _controller.reverse() : null,
                  onTapCancel: widget.enabled ? () => _controller.reverse() : null,
                  onTap: widget.enabled ? () {
                    if (NavigationAccessibility.screenReaderEnabled) {
                      HapticFeedback.selectionClick();
                    } else {
                      HapticFeedback.lightImpact();
                    }
                    widget.onPressed?.call();
                  } : null,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: NavigationAccessibility.minimumTouchTarget,
                      minHeight: NavigationAccessibility.minimumTouchTarget,
                    ),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(colorScheme),
                      borderRadius: DesignTokens.radiusM,
                      border: _isFocused ? Border.all(
                        color: colorScheme.primary,
                        width: 2,
                      ) : null,
                    ),
                    child: widget.child,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (!widget.enabled) {
      return colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }
    
    if (widget.isSelected) {
      return NavigationAccessibility.getContrastColor(
        colorScheme.surface,
        colorScheme.primaryContainer,
      );
    }
    
    if (_isHovered || _isFocused) {
      return NavigationAccessibility.getContrastColor(
        colorScheme.surface,
        colorScheme.surfaceContainerHighest,
      );
    }
    
    return Colors.transparent;
  }
}

/// Indicador de navegación accesible
class AccessibleNavigationIndicator extends StatelessWidget {
  final bool isSelected;
  final Color? color;
  final double width;

  const AccessibleNavigationIndicator({
    super.key,
    required this.isSelected,
    this.color,
    this.width = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;
    
    return AnimatedContainer(
      duration: NavigationAccessibility.getAnimationDuration(
        const Duration(milliseconds: 200)
      ),
      height: 3,
      width: isSelected ? width : 0,
      decoration: BoxDecoration(
        color: NavigationAccessibility.getContrastColor(
          theme.colorScheme.surface,
          indicatorColor,
        ),
        borderRadius: DesignTokens.radiusXS,
      ),
    );
  }
}

/// Etiqueta de navegación accesible
class AccessibleNavigationLabel extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color? color;

  const AccessibleNavigationLabel({
    super.key,
    required this.text,
    this.isSelected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = color ?? (isSelected 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurfaceVariant);
    
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: NavigationAccessibility.getContrastColor(
          theme.colorScheme.surface,
          textColor,
        ),
        fontWeight: isSelected 
            ? DesignTokens.fontWeightSemiBold
            : DesignTokens.fontWeightMedium,
        fontSize: theme.textTheme.labelSmall!.fontSize! * 
            NavigationAccessibility.textScaleFactor.clamp(1.0, 1.3),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

/// Widget que anuncia cambios de navegación para screen readers
class NavigationAnnouncer extends StatelessWidget {
  final String currentPage;
  final String? previousPage;
  final Widget child;

  const NavigationAnnouncer({
    super.key,
    required this.currentPage,
    this.previousPage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (NavigationAccessibility.screenReaderEnabled && previousPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SemanticsService.announce(
          'Navegando a $currentPage',
          TextDirection.ltr,
        );
      });
    }
    
    return Semantics(
      liveRegion: true,
      child: child,
    );
  }
}

/// Sistema de atajos de teclado para navegación
class KeyboardNavigationShortcuts extends StatefulWidget {
  final Widget child;
  final Function(int)? onTabNavigation;
  final VoidCallback? onMenuToggle;

  const KeyboardNavigationShortcuts({
    super.key,
    required this.child,
    this.onTabNavigation,
    this.onMenuToggle,
  });

  @override
  State<KeyboardNavigationShortcuts> createState() => _KeyboardNavigationShortcutsState();
}

class _KeyboardNavigationShortcutsState extends State<KeyboardNavigationShortcuts> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.digit1): const NavigationIntent(0),
        LogicalKeySet(LogicalKeyboardKey.digit2): const NavigationIntent(1),
        LogicalKeySet(LogicalKeyboardKey.digit3): const NavigationIntent(2),
        LogicalKeySet(LogicalKeyboardKey.digit4): const NavigationIntent(3),
        LogicalKeySet(LogicalKeyboardKey.digit5): const NavigationIntent(4),
        LogicalKeySet(LogicalKeyboardKey.escape): const MenuToggleIntent(),
        LogicalKeySet(LogicalKeyboardKey.f10): const MenuToggleIntent(),
      },
      child: Actions(
        actions: {
          NavigationIntent: CallbackAction<NavigationIntent>(
            onInvoke: (intent) {
              widget.onTabNavigation?.call(intent.tabIndex);
              return null;
            },
          ),
          MenuToggleIntent: CallbackAction<MenuToggleIntent>(
            onInvoke: (intent) {
              widget.onMenuToggle?.call();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: widget.child,
        ),
      ),
    );
  }
}

class NavigationIntent extends Intent {
  final int tabIndex;
  const NavigationIntent(this.tabIndex);
}

class MenuToggleIntent extends Intent {
  const MenuToggleIntent();
}

/// Overlay de ayuda de accesibilidad
class AccessibilityHelpOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const AccessibilityHelpOverlay({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface.withOpacity(0.95),
      child: SafeArea(
        child: Padding(
          padding: DesignTokens.spacingXL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ayuda de Accesibilidad',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                  AccessibleNavigationButton(
                    onPressed: onClose,
                    semanticLabel: 'Cerrar ayuda',
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacing6),
              Expanded(
                child: ListView(
                  children: [
                    _buildHelpSection(
                      'Navegación por Teclado',
                      [
                        'Números 1-5: Navegar entre pestañas',
                        'Escape: Abrir/cerrar menú',
                        'Tab: Navegar entre elementos',
                        'Enter/Espacio: Activar elemento',
                      ],
                      theme,
                    ),
                    _buildHelpSection(
                      'Gestos de Accesibilidad',
                      [
                        'Deslizar arriba con 1 dedo: Leer siguiente',
                        'Deslizar abajo con 1 dedo: Leer anterior',
                        'Doble toque: Activar elemento',
                        'Pellizcar: Zoom',
                      ],
                      theme,
                    ),
                    _buildHelpSection(
                      'Funciones de Audio',
                      [
                        'TalkBack/VoiceOver activo',
                        'Retroalimentación háptica',
                        'Anuncios de navegación',
                        'Sonidos de confirmación',
                      ],
                      theme,
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

  Widget _buildHelpSection(String title, List<String> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing2),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spacing1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(child: Text(item)),
            ],
          ),
        )),
        const SizedBox(height: DesignTokens.spacing4),
      ],
    );
  }
}