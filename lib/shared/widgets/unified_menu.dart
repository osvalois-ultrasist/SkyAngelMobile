import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/permission_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/app/presentation/providers/navigation_provider.dart';
import '../models/menu_item.dart';
import '../../core/constants/app_constants.dart';

class UnifiedBottomNavigation extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const UnifiedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final availableItems = MenuConfig.bottomNavigationItems
        .where((item) => item.requiredPermission == null || 
                       PermissionService.hasPermission(user, item.requiredPermission!))
        .toList();

    if (availableItems.isEmpty) return const SizedBox.shrink();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _mapToAvailableIndex(currentIndex, availableItems),
      onTap: (index) {
        final selectedItem = availableItems[index];
        if (selectedItem.tabIndex != null) {
          onTap(selectedItem.tabIndex!);
        }
      },
      items: availableItems.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        activeIcon: Icon(item.activeIcon ?? item.icon),
        label: item.title,
      )).toList(),
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

class UnifiedDrawer extends ConsumerWidget {
  const UnifiedDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final userRole = PermissionService.getUserRole(user);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, theme, user, userRole),
          ...MenuConfig.drawerMenuItems.map((item) => 
            _buildMenuItem(context, ref, item, user)),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, ThemeData theme, dynamic user, UserRole userRole) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              _getRoleIcon(userRole),
              size: 30,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'SkyAngel',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getRoleDisplayName(userRole),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, WidgetRef ref, MenuItem item, dynamic user) {
    if (item.isDivider) {
      return const Divider();
    }

    if (item.requiredPermission != null && 
        !PermissionService.hasPermission(user, item.requiredPermission!)) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      onTap: () {
        Navigator.pop(context);
        
        if (item.tabIndex != null) {
          ref.read(navigationProvider.notifier).navigateToTab(item.tabIndex!);
        } else {
          _handleSpecialActions(context, item.id);
        }
      },
    );
  }

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
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 8),
            Text('Ayuda'),
          ],
        ),
        content: const SingleChildScrollView(
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
              SizedBox(height: 16),
              Text(
                'Funciones principales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Mapa interactivo con capas de información'),
              Text('• Sistema de alertas comunitarias'),
              Text('• Algoritmos de rutas optimizadas'),
              Text('• Análisis estadístico de seguridad'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
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
            const SizedBox(height: 16),
            const Text(
              'Desarrollado con Flutter y tecnologías de vanguardia para brindar '
              'la mejor experiencia de seguridad en transporte.',
              style: TextStyle(fontSize: 12),
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