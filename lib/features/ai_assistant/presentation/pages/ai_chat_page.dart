import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../../../shared/widgets/header_bar.dart';
import '../../../../shared/widgets/header_theme.dart';
import '../../domain/entities/ai_chat_session.dart';
import '../../domain/entities/ai_message.dart';
import '../providers/ai_assistant_provider.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_typing_indicator.dart';
import '../widgets/ai_quick_actions.dart';
import '../widgets/ai_suggestions_panel.dart';
import '../widgets/ai_chat_input.dart';

class AiChatPage extends ConsumerStatefulWidget {
  final AiChatContext initialContext;
  final String? sessionId;

  const AiChatPage({
    super.key,
    required this.initialContext,
    this.sessionId,
  });

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late AnimationController _suggestionsAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _suggestionsSlideAnimation;

  bool _showScrollToBottom = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _setupChat();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    _suggestionsAnimationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );

    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _suggestionsSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _suggestionsAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sessionId != null) {
        ref.read(aiAssistantProvider.notifier).loadSession(widget.sessionId!);
      } else {
        ref.read(aiAssistantProvider.notifier).createNewSession(
          widget.initialContext,
          initialMessage: _getWelcomeMessage(),
        );
      }
      _showInitialSuggestions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _suggestionsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assistantState = ref.watch(aiAssistantProvider);
    final isTyping = ref.watch(isAiTypingProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Main chat area
          Column(
            children: [
              // Quick actions bar
              if (assistantState.quickActions.isNotEmpty)
                AiQuickActions(
                  actions: assistantState.quickActions,
                  onActionTap: _handleQuickAction,
                ),

              // Messages list
              Expanded(
                child: _buildMessagesList(assistantState),
              ),

              // Typing indicator
              if (isTyping) const AiTypingIndicator(),

              // Chat input
              AiChatInput(
                onSendMessage: _sendMessage,
                contextType: widget.initialContext.type,
              ),
            ],
          ),

          // Suggestions panel
          if (_showSuggestions)
            Positioned(
              right: 0,
              top: 0,
              bottom: 100,
              child: SlideTransition(
                position: _suggestionsSlideAnimation,
                child: AiSuggestionsPanel(
                  context: widget.initialContext,
                  onSuggestionTap: _applySuggestion,
                  onClose: () => _toggleSuggestions(false),
                ),
              ),
            ),

          // Scroll to bottom FAB
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 100,
              child: ScaleTransition(
                scale: _fabScaleAnimation,
                child: FloatingActionButton.small(
                  onPressed: _scrollToBottom,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return HeaderBar(
      title: 'SkyAngel AI',
      subtitle: _getContextSubtitle(),
      icon: Icons.psychology_rounded,
      type: widget.initialContext.type == AiChatContextType.emergency 
          ? HeaderType.error 
          : HeaderType.primary,
      showBackButton: true,
      actions: [
        HeaderAction(
          icon: _showSuggestions ? Icons.close_rounded : Icons.lightbulb_rounded,
          onPressed: () => _toggleSuggestions(!_showSuggestions),
          tooltip: _showSuggestions ? 'Cerrar sugerencias' : 'Ver sugerencias',
        ),
        HeaderAction(
          icon: Icons.refresh_rounded,
          onPressed: _refreshChat,
          tooltip: 'Reiniciar conversación',
        ),
        HeaderAction(
          icon: Icons.more_vert_rounded,
          onPressed: () => _showChatMenu(context),
          tooltip: 'Más opciones',
        ),
      ],
    );
  }

  Widget _buildMessagesList(AiAssistantState state) {
    if (state.isLoading && state.currentMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: DesignTokens.spacing4),
            Text('Inicializando SkyAngel AI...'),
          ],
        ),
      );
    }

    if (state.currentMessages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: DesignTokens.spacingL,
      itemCount: state.currentMessages.length,
      itemBuilder: (context, index) {
        final message = state.currentMessages[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == state.currentMessages.length - 1 
                ? DesignTokens.spacing6 
                : DesignTokens.spacing3,
          ),
          child: AiMessageBubble(
            message: message,
            onActionTap: _handleMessageAction,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: DesignTokens.spacingXL,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: DesignTokens.radiusFull,
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: DesignTokens.iconSizeXXXL,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing6),
          Text(
            '¡Hola! Soy SkyAngel AI',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: DesignTokens.fontWeightBold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            _getWelcomeMessage(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing6),
          _buildQuickStartButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickStartButtons() {
    final quickStarts = _getQuickStartOptions();
    
    return Wrap(
      spacing: DesignTokens.spacing2,
      runSpacing: DesignTokens.spacing2,
      children: quickStarts.map((option) {
        return ActionChip(
          label: Text(option['label'] as String),
          avatar: Icon(
            option['icon'] as IconData,
            size: DesignTokens.iconSizeS,
          ),
          onPressed: () => _sendMessage(option['message'] as String),
        );
      }).toList(),
    );
  }

  void _onScroll() {
    final showFab = _scrollController.hasClients &&
        _scrollController.offset > 200;

    if (showFab != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showFab;
      });
      
      if (showFab) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  void _scrollToBottom() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: DesignTokens.animationDurationNormal,
      curve: Curves.easeOutCubic,
    );
  }

  void _sendMessage(String message) {
    ref.read(aiAssistantProvider.notifier).sendMessage(message);
    
    // Auto-scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  void _handleQuickAction(AiMessageAction action) {
    HapticFeedback.lightImpact();
    ref.read(aiAssistantProvider.notifier).executeQuickAction(action);
  }

  void _handleMessageAction(AiMessageAction action) {
    _handleQuickAction(action);
  }

  void _applySuggestion(String suggestion) {
    _sendMessage(suggestion);
    _toggleSuggestions(false);
  }

  void _toggleSuggestions(bool show) {
    setState(() {
      _showSuggestions = show;
    });

    if (show) {
      _suggestionsAnimationController.forward();
    } else {
      _suggestionsAnimationController.reverse();
    }
  }

  void _showInitialSuggestions() {
    ref.read(aiAssistantProvider.notifier).generateSuggestion(
      widget.initialContext,
      data: widget.initialContext.currentData,
    );
  }

  void _refreshChat() {
    HapticFeedback.mediumImpact();
    ref.read(aiAssistantProvider.notifier).createNewSession(
      widget.initialContext,
      initialMessage: _getWelcomeMessage(),
    );
  }

  void _showChatMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Historial de conversaciones'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to chat history
              },
            ),
            ListTile(
              leading: const Icon(Icons.save_rounded),
              title: const Text('Guardar conversación'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Save conversation
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Compartir conversación'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share conversation
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getContextSubtitle() {
    switch (widget.initialContext.type) {
      case AiChatContextType.dashboard:
        return 'Análisis de datos de seguridad';
      case AiChatContextType.maps:
        return 'Análisis geoespacial de riesgo';
      case AiChatContextType.alerts:
        return 'Gestión de alertas comunitarias';
      case AiChatContextType.routes:
        return 'Planificación de rutas seguras';
      case AiChatContextType.profile:
        return 'Asistente personal de seguridad';
      case AiChatContextType.emergency:
        return 'Asistencia de emergencia';
      default:
        return 'Tu asistente inteligente de seguridad';
    }
  }

  String _getWelcomeMessage() {
    switch (widget.initialContext.type) {
      case AiChatContextType.dashboard:
        return '¿Qué aspectos de tus datos de seguridad te gustaría analizar?';
      case AiChatContextType.maps:
        return '¿Necesitas ayuda para interpretar el mapa de riesgos o encontrar información sobre alguna zona?';
      case AiChatContextType.alerts:
        return '¿Quieres crear una nueva alerta, revisar las existentes o necesitas ayuda con las notificaciones?';
      case AiChatContextType.routes:
        return '¿A dónde quieres ir? Te ayudo a encontrar la ruta más segura.';
      case AiChatContextType.profile:
        return '¿Necesitas ayuda con tu configuración de seguridad o tienes preguntas sobre tu cuenta?';
      case AiChatContextType.emergency:
        return '¿Necesitas asistencia inmediata? Estoy aquí para ayudarte con cualquier situación de emergencia.';
      default:
        return '¿En qué puedo ayudarte hoy? Soy tu asistente especializado en seguridad urbana.';
    }
  }

  List<Map<String, dynamic>> _getQuickStartOptions() {
    switch (widget.initialContext.type) {
      case AiChatContextType.dashboard:
        return [
          {'label': 'Explicar tendencias', 'icon': Icons.trending_up, 'message': 'Explícame las tendencias de seguridad que veo en el dashboard'},
          {'label': 'Áreas de riesgo', 'icon': Icons.warning, 'message': '¿Cuáles son las áreas de mayor riesgo actualmente?'},
          {'label': 'Recomendaciones', 'icon': Icons.lightbulb, 'message': 'Dame recomendaciones basadas en los datos actuales'},
        ];
      case AiChatContextType.maps:
        return [
          {'label': 'Zona segura', 'icon': Icons.location_on, 'message': '¿Esta zona es segura para transitar?'},
          {'label': 'Mejor ruta', 'icon': Icons.directions, 'message': '¿Cuál es la ruta más segura para llegar a mi destino?'},
          {'label': 'Incidentes recientes', 'icon': Icons.report, 'message': 'Muéstrame los incidentes recientes en esta área'},
        ];
      case AiChatContextType.alerts:
        return [
          {'label': 'Crear alerta', 'icon': Icons.add_alert, 'message': 'Quiero reportar un incidente de seguridad'},
          {'label': 'Mis alertas', 'icon': Icons.list, 'message': 'Muéstrame mis alertas recientes'},
          {'label': 'Alertas cercanas', 'icon': Icons.near_me, 'message': '¿Hay alertas activas cerca de mi ubicación?'},
        ];
      case AiChatContextType.routes:
        return [
          {'label': 'Ruta al trabajo', 'icon': Icons.work, 'message': '¿Cuál es la ruta más segura a mi trabajo?'},
          {'label': 'Evitar zonas', 'icon': Icons.block, 'message': 'Quiero evitar zonas peligrosas en mi ruta'},
          {'label': 'Horario seguro', 'icon': Icons.schedule, 'message': '¿Cuál es el mejor horario para viajar de forma segura?'},
        ];
      default:
        return [
          {'label': 'Estado actual', 'icon': Icons.info, 'message': '¿Cuál es el estado actual de seguridad en mi área?'},
          {'label': 'Consejos', 'icon': Icons.tips_and_updates, 'message': 'Dame consejos de seguridad personalizados'},
          {'label': 'Ayuda', 'icon': Icons.help, 'message': '¿Cómo puedo usar mejor la aplicación SkyAngel?'},
        ];
    }
  }
}