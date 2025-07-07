import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_navigation.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../ai_assistant/domain/entities/ai_chat_session.dart';
import '../../../ai_assistant/presentation/widgets/ai_floating_action_button.dart';
import '../providers/navigation_provider.dart';

class AppPage extends ConsumerStatefulWidget {
  final int initialTab;
  
  const AppPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<AppPage> createState() => AppPageState();
}

class AppPageState extends ConsumerState<AppPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationProvider.notifier).navigateToTab(widget.initialTab);
    });
  }


  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final navigation = ref.watch(navigationProvider);
    
    return AppScaffold(
      body: currentPage,
      bottomNavigationBar: AppNavigation(
        currentIndex: navigation.currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setCurrentIndex(index);
        },
      ),
    );
  }

  AiChatContextType _getContextTypeForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return AiChatContextType.maps;
      case 1:
        return AiChatContextType.alerts;
      case 2:
        return AiChatContextType.routes;
      case 3:
        return AiChatContextType.general; // Copilot tab
      case 4:
        return AiChatContextType.profile;
      default:
        return AiChatContextType.general;
    }
  }

  Map<String, dynamic>? _getContextDataForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return {
          'page': 'maps',
          'features': ['crime_mapping', 'risk_zones', 'geospatial_analysis'],
        };
      case 1:
        return {
          'page': 'alerts',
          'features': ['community_alerts', 'emergency_notifications', 'safety_reports'],
        };
      case 2:
        return {
          'page': 'routes',
          'features': ['safe_routing', 'route_optimization', 'traffic_analysis'],
        };
      case 3:
        return {
          'page': 'copilot',
          'features': ['ai_assistance', 'smart_recommendations', 'contextual_help'],
        };
      case 4:
        return {
          'page': 'profile',
          'features': ['user_settings', 'preferences', 'security_config'],
        };
      default:
        return null;
    }
  }
}

// Placeholder pages - these will be implemented later
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarFactory.dashboard(
        actions: [
          AppBarActions.search(
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          AppBarActions.settings(
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bienvenido a SkyAngel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plataforma de análisis de seguridad\ny riesgo para el transporte',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            _AnimatedFeatureCard(
              delay: 0,
              icon: Icons.map,
              title: 'Mapas Interactivos',
              description: 'Visualiza datos de criminalidad en tiempo real',
              onTap: () => ref.read(navigationProvider.notifier).navigateToTab(1),
            ),
            const SizedBox(height: 16),
            _AnimatedFeatureCard(
              delay: 200,
              icon: Icons.route,
              title: 'Rutas Seguras',
              description: 'Calcula rutas optimizadas con análisis de riesgo',
              onTap: () => ref.read(navigationProvider.notifier).navigateToTab(3),
            ),
            const SizedBox(height: 16),
            _AnimatedFeatureCard(
              delay: 400,
              icon: Icons.notifications,
              title: 'Alertas en Tiempo Real',
              description: 'Recibe notificaciones de seguridad instantáneas',
              onTap: () => ref.read(navigationProvider.notifier).navigateToTab(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedFeatureCard extends StatefulWidget {
  final int delay;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _AnimatedFeatureCard({
    required this.delay,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MapPage is implemented in lib/features/maps/presentation/pages/maps_page.dart

// AlertsPage is implemented in lib/features/alertas/presentation/pages/alerts_page.dart
// RoutesPage is implemented in lib/features/rutas/presentation/pages/routes_page.dart

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBarFactory.profile(
        actions: [
          AppBarActions.notifications(
            onPressed: () {
              // TODO: Show notifications dialog or navigate to notifications
            },
            badgeCount: 3,
          ),
          AppBarActions.logout(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await authNotifier.signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.user?.name ?? 'Usuario',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.user?.email ?? 'usuario@example.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Menu options
            _buildMenuSection(
              context,
              'Configuración',
              [
                _buildMenuItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notificaciones',
                  subtitle: 'Configura alertas y avisos',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.security_rounded,
                  title: 'Seguridad',
                  subtitle: 'Privacidad y autenticación',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.map_rounded,
                  title: 'Preferencias de Mapa',
                  subtitle: 'Capas y filtros predeterminados',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildMenuSection(
              context,
              'Soporte',
              [
                _buildMenuItem(
                  icon: Icons.help_rounded,
                  title: 'Ayuda',
                  subtitle: 'Preguntas frecuentes',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.info_rounded,
                  title: 'Acerca de',
                  subtitle: 'Versión ${AppConstants.appVersion}',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}