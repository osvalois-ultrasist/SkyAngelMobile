import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/header_bar.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_stats_widget.dart';
import '../widgets/profile_settings_widget.dart';
import '../widgets/profile_activity_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Load profile data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: HeaderBarFactory.profile(
        userName: 'Usuario', // TODO: Get from user state
        actions: [
          HeaderActions.notifications(() => _showNotifications(context)),
          HeaderActions.more(() => _showMoreOptionsMenu(context)),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Profile header
                      _buildProfileHeader(theme),
                      
                      // Tab bar
                      _buildTabBar(context, colorScheme),
                      
                      // Main content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildStatsTab(),
                            _buildActivityTab(),
                            _buildSettingsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(),
            SizedBox(height: DesignTokens.spacing4),
            Text(
              'Cargando perfil...',
              style: TextStyle(
                fontSize: DesignTokens.fontSizeL,
                fontWeight: DesignTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      margin: DesignTokens.spacingL,
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.8),
            theme.colorScheme.primaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: DesignTokens.radiusL,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          ShadowTokens.createShadow(
            color: theme.colorScheme.primary,
            opacity: 0.1,
            blurRadius: DesignTokens.blurRadiusM,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: DesignTokens.radiusFull,
              boxShadow: [
                ShadowTokens.createShadow(
                  color: theme.colorScheme.primary,
                  opacity: 0.3,
                  blurRadius: DesignTokens.blurRadiusM,
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.onPrimary,
              size: DesignTokens.iconSizeXXL,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario SkyAngel', // TODO: Get from user state
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing1),
                Text(
                  'Transportista verificado',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: DesignTokens.spacing2),
                Container(
                  padding: DesignTokens.paddingHorizontalM.add(DesignTokens.paddingVerticalS),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: DesignTokens.radiusM,
                  ),
                  child: Text(
                    'ACTIVO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editProfile(context),
            icon: Icon(
              Icons.edit_rounded,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Editar perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: DesignTokens.radiusXL,
        boxShadow: [
          ShadowTokens.createShadow(
            color: colorScheme.shadow,
            opacity: DesignTokens.shadowOpacityLight,
            blurRadius: DesignTokens.blurRadiusL,
            offset: DesignTokens.shadowOffsetM,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: DesignTokens.radiusL,
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelStyle: const TextStyle(
          fontSize: DesignTokens.fontSizeS,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: DesignTokens.fontSizeS,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
        tabs: const [
          Tab(
            text: 'Estadísticas',
            icon: Icon(Icons.analytics_rounded, size: DesignTokens.iconSizeS),
          ),
          Tab(
            text: 'Actividad',
            icon: Icon(Icons.timeline_rounded, size: DesignTokens.iconSizeS),
          ),
          Tab(
            text: 'Configuración',
            icon: Icon(Icons.settings_rounded, size: DesignTokens.iconSizeS),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: DesignTokens.spacingL,
      child: Column(
        children: [
          const ProfileStatsWidget(),
          SizedBox(height: DesignTokens.spacing6),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: DesignTokens.spacingL,
      child: Column(
        children: [
          const ProfileActivityWidget(),
          SizedBox(height: DesignTokens.spacing6),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: DesignTokens.spacingL,
      child: Column(
        children: [
          const ProfileSettingsWidget(),
          SizedBox(height: DesignTokens.spacing6),
        ],
      ),
    );
  }

  void _loadProfileData() {
    setState(() => _isLoading = true);
    // TODO: Load profile data from providers
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _refreshData() {
    HapticFeedback.lightImpact();
    _loadProfileData();
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: DesignTokens.radiusXL.copyWith(
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: DesignTokens.spacing4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: DesignTokens.radiusS,
              ),
            ),
            Text(
              'Notificaciones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay notificaciones'),
                ],
              ),
            ),
            SizedBox(height: DesignTokens.spacing6),
          ],
        ),
      ),
    );
  }

  void _showMoreOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: DesignTokens.radiusXL.copyWith(
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: DesignTokens.spacing4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: DesignTokens.radiusS,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Compartir perfil'),
              onTap: () {
                Navigator.pop(context);
                _shareProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text('Ayuda y soporte'),
              onTap: () {
                Navigator.pop(context);
                _showHelp(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
            SizedBox(height: DesignTokens.spacing6),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // TODO: Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edición de perfil en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareProfile() {
    // TODO: Implement profile sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartir perfil en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded),
            SizedBox(width: 8),
            Text('Ayuda'),
          ],
        ),
        content: const Text('¿Necesitas ayuda con tu perfil o la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open support chat or email
            },
            child: const Text('Contactar soporte'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded),
            SizedBox(width: 8),
            Text('Cerrar sesión'),
          ],
        ),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

/// Utilidad para crear sombras siguiendo el design system
class ShadowTokens {
  static BoxShadow createShadow({
    required Color color,
    double opacity = 0.1,
    double blurRadius = 4.0,
    Offset offset = const Offset(0, 2),
  }) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blurRadius,
      offset: offset,
    );
  }
}