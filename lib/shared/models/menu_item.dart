import 'package:flutter/material.dart';
import '../../core/services/permission_service.dart';

class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final IconData? activeIcon;
  final Permission? requiredPermission;
  final int? tabIndex;
  final String? routePath;
  final VoidCallback? onTap;
  final bool isDivider;
  final List<MenuItem>? subItems;

  const MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.activeIcon,
    this.requiredPermission,
    this.tabIndex,
    this.routePath,
    this.onTap,
    this.isDivider = false,
    this.subItems,
  });

  const MenuItem.divider()
      : this(
          id: 'divider',
          title: '',
          icon: Icons.horizontal_rule,
          isDivider: true,
        );

  bool get isNavigationItem => tabIndex != null;
  bool get isActionItem => onTap != null;
  bool get hasSubItems => subItems != null && subItems!.isNotEmpty;
}

class MenuConfig {
  static const List<MenuItem> bottomNavigationItems = [
    MenuItem(
      id: 'maps',
      title: 'Mapa',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      requiredPermission: Permission.viewMaps,
      tabIndex: 0,
    ),
    MenuItem(
      id: 'alerts',
      title: 'Alertas',
      icon: Icons.warning_amber_outlined,
      activeIcon: Icons.warning_amber,
      requiredPermission: Permission.viewAlerts,
      tabIndex: 1,
    ),
    MenuItem(
      id: 'routes',
      title: 'Rutas',
      icon: Icons.route_outlined,
      activeIcon: Icons.route,
      requiredPermission: Permission.viewRoutes,
      tabIndex: 2,
    ),
    MenuItem(
      id: 'copilot',
      title: 'Copiloto',
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      requiredPermission: Permission.aiCopilot,
      tabIndex: 3,
    ),
    MenuItem(
      id: 'profile',
      title: 'Perfil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      requiredPermission: Permission.viewProfile,
      tabIndex: 4,
    ),
  ];

  static const List<MenuItem> drawerMenuItems = [
    MenuItem(
      id: 'maps_drawer',
      title: 'Mapa de Delitos',
      icon: Icons.map,
      requiredPermission: Permission.viewMaps,
      tabIndex: 0,
    ),
    MenuItem(
      id: 'alerts_drawer',
      title: 'Alertas',
      icon: Icons.warning_amber,
      requiredPermission: Permission.viewAlerts,
      tabIndex: 1,
    ),
    MenuItem(
      id: 'routes_drawer',
      title: 'Rutas Seguras',
      icon: Icons.route,
      requiredPermission: Permission.viewRoutes,
      tabIndex: 2,
    ),
    MenuItem(
      id: 'copilot_drawer',
      title: 'Copiloto AI',
      icon: Icons.psychology,
      requiredPermission: Permission.aiCopilot,
      tabIndex: 3,
    ),
    MenuItem.divider(),
    MenuItem(
      id: 'statistics',
      title: 'Estadísticas',
      icon: Icons.analytics,
      requiredPermission: Permission.viewStatistics,
    ),
    MenuItem(
      id: 'export',
      title: 'Exportar Datos',
      icon: Icons.download,
      requiredPermission: Permission.exportData,
    ),
    MenuItem(
      id: 'manage_users',
      title: 'Gestión de Usuarios',
      icon: Icons.people,
      requiredPermission: Permission.manageUsers,
    ),
    MenuItem(
      id: 'settings',
      title: 'Configuración',
      icon: Icons.settings,
      requiredPermission: Permission.systemSettings,
    ),
    MenuItem.divider(),
    MenuItem(
      id: 'help',
      title: 'Ayuda',
      icon: Icons.help_outline,
    ),
    MenuItem(
      id: 'about',
      title: 'Acerca de',
      icon: Icons.info_outline,
    ),
  ];
}