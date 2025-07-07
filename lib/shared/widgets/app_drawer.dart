import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/permission_service.dart';
import '../../features/app/presentation/providers/navigation_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../design_system/design_tokens.dart';
import '../models/menu_item.dart';

/// Drawer principal de la aplicación siguiendo el patrón de diseño de SkyAngel
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
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
    final userRole = PermissionService.getUserRole(user);

    return SlideTransition(
      position: _slideAnimation,
      child: Drawer(
        backgroundColor: colorScheme.surface,
        elevation: DesignTokens.elevationL,
        width: 320,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
          ),
          child: Column(
            children: [
              _buildDrawerHeader(context, theme, user, userRole),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildMenuContent(context, ref, user),
                ),
              ),
              _buildDrawerFooter(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, ThemeData theme, dynamic user, UserRole userRole) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 200,
      padding: DesignTokens.spacingXL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.security_outlined,
                  size: DesignTokens.iconSizeXL,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Text(
                'SkyAngel',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: DesignTokens.fontWeightBold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DesignTokens.spacing4),
          
          Row(
            children: [
              Container(
                padding: DesignTokens.spacingS,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: DesignTokens.radiusL,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getRoleIcon(userRole),
                  size: DesignTokens.iconSizeL,
                  color: colorScheme.primary,
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
                        color: Colors.white,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getRoleDisplayName(userRole),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: DesignTokens.fontWeightMedium,
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

  Widget _buildMenuContent(BuildContext context, WidgetRef ref, dynamic user) {
    final visibleItems = MenuConfig.drawerMenuItems
        .where((item) => item.requiredPermission == null || 
                        PermissionService.hasPermission(user, item.requiredPermission!))
        .toList();

    return ListView.separated(
      padding: DesignTokens.spacingM,
      itemCount: visibleItems.length,
      separatorBuilder: (context, index) {
        final item = visibleItems[index];
        return item.isDivider ? const SizedBox.shrink() : const SizedBox(height: DesignTokens.spacing1);
      },
      itemBuilder: (context, index) {
        final item = visibleItems[index];
        return _buildMenuItem(context, ref, item, index);
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
    int index,
  ) {
    if (item.isDivider) {
      return _buildDivider();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _MenuItemWidget(
            item: item,
            animationDelay: Duration(milliseconds: 100 + (index * 50)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              
              if (item.tabIndex != null) {
                ref.read(navigationProvider.notifier).navigateToTab(item.tabIndex!);
              } else {
                _handleSpecialActions(context, item.id);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDivider() => Container(
    margin: DesignTokens.paddingVerticalL,
    child: Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    ),
  );

  Widget _buildDrawerFooter(BuildContext context, ThemeData theme) => Container(
    padding: DesignTokens.spacingL,
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      border: Border(
        top: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              Icons.security_rounded,
              size: DesignTokens.iconSizeS,
            ),
            const SizedBox(width: DesignTokens.spacing2),
            Text(
              'SkyAngel v${AppConstants.appVersion}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: DesignTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing1),
        Text(
          'Plataforma de seguridad inteligente',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: DesignTokens.fontSizeXS,
          ),
        ),
      ],
    ),
  );

  void _handleSpecialActions(BuildContext context, String itemId) {
    switch (itemId) {
      case 'statistics':
        _showComingSoonDialog(context, 'Estadísticas');
        break;
      case 'export':
        _showComingSoonDialog(context, 'Exportar Datos');
        break;
      case 'manage_users':
        _showComingSoonDialog(context, 'Gestión de Usuarios');
        break;
      case 'settings':
        _showComingSoonDialog(context, 'Configuración');
        break;
      case 'help':
        _showHelpDialog(context);
        break;
      case 'about':
        _showAboutDialog(context);
        break;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.moderator:
        return Icons.security;
      case UserRole.user:
        return Icons.person;
      case UserRole.guest:
        return Icons.person_outline;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.moderator:
        return 'Moderador';
      case UserRole.user:
        return 'Usuario';
      case UserRole.guest:
        return 'Invitado';
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.construction),
            const SizedBox(width: 8),
            Text(feature),
          ],
        ),
        content: Text('La funcionalidad de $feature estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 8),
            Text('Ayuda'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cómo usar SkyAngel:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Navega por el mapa para ver delitos en tiempo real'),
              Text('• Usa las alertas para reportar incidentes'),
              Text('• Calcula rutas seguras con análisis de riesgo'),
              Text('• Personaliza las configuraciones según tus necesidades'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.pop,
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('Acerca de SkyAngel'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SkyAngel Mobile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Versión: ${AppConstants.appVersion}'),
            const SizedBox(height: 16),
            const Text(
              'Plataforma de análisis de seguridad y riesgo para el transporte.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _MenuItemWidget extends StatefulWidget {
  const _MenuItemWidget({
    required this.item,
    required this.onTap,
    required this.animationDelay,
  });

  final MenuItem item;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<_MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<_MenuItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: DesignTokens.animationDurationQuick,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing2,
            vertical: DesignTokens.spacing1,
          ),
          decoration: BoxDecoration(
            color: _isHovered 
                ? colorScheme.primaryContainer.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: DesignTokens.radiusM,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: DesignTokens.radiusM,
              onTap: widget.onTap,
              onHover: (isHovered) {
                setState(() => _isHovered = isHovered);
                if (isHovered) {
                  _hoverController.forward();
                } else {
                  _hoverController.reverse();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing4,
                  vertical: DesignTokens.spacing3,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: DesignTokens.spacingS,
                      decoration: BoxDecoration(
                        color: _isHovered 
                            ? colorScheme.primary.withOpacity(0.12)
                            : colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: DesignTokens.radiusS,
                      ),
                      child: Icon(
                        widget.item.icon,
                        size: DesignTokens.iconSizeM,
                        color: _isHovered 
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(width: DesignTokens.spacing4),
                    
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _isHovered 
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: _isHovered 
                              ? DesignTokens.fontWeightSemiBold
                              : DesignTokens.fontWeightMedium,
                        ),
                      ),
                    ),
                    
                    if (_isHovered)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: DesignTokens.iconSizeS,
                        color: colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}