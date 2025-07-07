import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/ai_chat_session.dart';

class AiSuggestionsPanel extends StatefulWidget {
  final AiChatContext context;
  final Function(String) onSuggestionTap;
  final VoidCallback onClose;

  const AiSuggestionsPanel({
    super.key,
    required this.context,
    required this.onSuggestionTap,
    required this.onClose,
  });

  @override
  State<AiSuggestionsPanel> createState() => _AiSuggestionsPanelState();
}

class _AiSuggestionsPanelState extends State<AiSuggestionsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  late List<Map<String, dynamic>> _suggestions;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSuggestions();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void _loadSuggestions() {
    _suggestions = _getSuggestionsForContext();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: DesignTokens.blurRadiusL,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                Expanded(
                  child: _buildSuggestionsList(theme),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: theme.colorScheme.primary,
            size: DesignTokens.iconSizeM,
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: Text(
              'Sugerencias',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onClose();
            },
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: DesignTokens.iconSizeS,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(ThemeData theme) {
    return ListView.builder(
      padding: DesignTokens.spacingM,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _SuggestionTile(
          icon: suggestion['icon'] as IconData,
          title: suggestion['title'] as String,
          description: suggestion['description'] as String,
          message: suggestion['message'] as String,
          onTap: () => widget.onSuggestionTap(suggestion['message'] as String),
          theme: theme,
        );
      },
    );
  }

  List<Map<String, dynamic>> _getSuggestionsForContext() {
    switch (widget.context.type) {
      case AiChatContextType.dashboard:
        return [
          {
            'icon': Icons.trending_up,
            'title': 'Análisis de tendencias',
            'description': 'Comprende las tendencias actuales',
            'message': 'Analiza las tendencias de seguridad de los últimos 30 días',
          },
          {
            'icon': Icons.place,
            'title': 'Zonas críticas',
            'description': 'Identifica áreas de alto riesgo',
            'message': '¿Cuáles son las 5 zonas más peligrosas actualmente?',
          },
          {
            'icon': Icons.schedule,
            'title': 'Patrones temporales',
            'description': 'Horarios de mayor incidencia',
            'message': '¿En qué horarios ocurren más incidentes?',
          },
        ];
      case AiChatContextType.maps:
        return [
          {
            'icon': Icons.location_on,
            'title': 'Análisis de zona',
            'description': 'Información detallada del área',
            'message': 'Analiza detalladamente esta zona del mapa',
          },
          {
            'icon': Icons.compare_arrows,
            'title': 'Comparar áreas',
            'description': 'Compara niveles de seguridad',
            'message': 'Compara la seguridad entre diferentes zonas de la ciudad',
          },
          {
            'icon': Icons.timeline,
            'title': 'Evolución temporal',
            'description': 'Cambios en el tiempo',
            'message': '¿Cómo ha evolucionado la seguridad en esta zona?',
          },
        ];
      case AiChatContextType.alerts:
        return [
          {
            'icon': Icons.add_alert,
            'title': 'Crear alerta',
            'description': 'Reporta un nuevo incidente',
            'message': 'Quiero crear una nueva alerta de seguridad',
          },
          {
            'icon': Icons.history,
            'title': 'Historial de alertas',
            'description': 'Revisa alertas anteriores',
            'message': 'Muéstrame el historial de alertas de mi zona',
          },
          {
            'icon': Icons.group,
            'title': 'Alertas comunitarias',
            'description': 'Alertas de tu comunidad',
            'message': '¿Qué alertas han reportado mis vecinos recientemente?',
          },
        ];
      case AiChatContextType.routes:
        return [
          {
            'icon': Icons.home,
            'title': 'Ruta a casa',
            'description': 'La ruta más segura a tu hogar',
            'message': 'Calcula la ruta más segura a mi casa',
          },
          {
            'icon': Icons.explore,
            'title': 'Rutas alternativas',
            'description': 'Opciones adicionales',
            'message': 'Muéstrame rutas alternativas evitando zonas peligrosas',
          },
          {
            'icon': Icons.timer,
            'title': 'Mejor horario',
            'description': 'Horario óptimo para viajar',
            'message': '¿Cuál es el mejor horario para hacer este recorrido?',
          },
        ];
      default:
        return [
          {
            'icon': Icons.help,
            'title': 'Ayuda general',
            'description': 'Aprende a usar SkyAngel',
            'message': '¿Cómo puedo aprovechar mejor SkyAngel?',
          },
          {
            'icon': Icons.security,
            'title': 'Consejos de seguridad',
            'description': 'Recomendaciones personalizadas',
            'message': 'Dame consejos de seguridad para mi situación',
          },
          {
            'icon': Icons.info,
            'title': 'Estado actual',
            'description': 'Información de tu área',
            'message': '¿Cuál es el estado de seguridad en mi área?',
          },
        ];
    }
  }
}

class _SuggestionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String message;
  final VoidCallback onTap;
  final ThemeData theme;

  const _SuggestionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.message,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.radiusM,
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: DesignTokens.radiusM,
        child: Padding(
          padding: DesignTokens.spacingM,
          child: Row(
            children: [
              Container(
                padding: DesignTokens.spacingS,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: DesignTokens.radiusS,
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: DesignTokens.iconSizeS,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: DesignTokens.iconSizeXS,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}