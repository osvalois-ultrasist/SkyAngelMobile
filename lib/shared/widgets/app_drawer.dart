import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../features/app/presentation/pages/app_page.dart';
import '../../features/app/presentation/providers/navigation_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.security,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SkyAngel',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sistema de Seguridad',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to home tab
              ref.read(navigationProvider.notifier).navigateToTab(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Mapa de Delitos'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to map tab
              ref.read(navigationProvider.notifier).navigateToTab(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Alertas'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to alerts tab
              ref.read(navigationProvider.notifier).navigateToTab(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('Rutas Seguras'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to routes tab
              ref.read(navigationProvider.notifier).navigateToTab(3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Estadísticas'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to statistics page
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to history page
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ayuda'),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }


  static void _showHelpDialog(BuildContext context) {
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

  static void _showAboutDialog(BuildContext context) {
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