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

/// Página principal del Copiloto AI integrada como tab del menú principal
/// Proporciona acceso directo a todas las funcionalidades de IA de SkyAngel
class CopilotPage extends ConsumerStatefulWidget {
  const CopilotPage({super.key});

  @override
  ConsumerState<CopilotPage> createState() => _CopilotPageState();
}

class _CopilotPageState extends ConsumerState<CopilotPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _entryAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _suggestionsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _suggestionsSlideAnimation;

  bool _showScrollToBottom = false;
  bool _showSuggestions = true;
  bool _isInitialized = false;

  final AiChatContext _copilotContext = const AiChatContext(
    type: AiChatContextType.general,
    location: 'copilot_page',
    currentData: {
      'mode': 'copilot',
      'features': ['general_assistance', 'smart_recommendations', 'contextual_help'],
      'capabilities': ['security_analysis', 'route_planning', 'alert_management'],
    },
    relevantFeatures: ['ai_assistance', 'smart_recommendations', 'contextual_help'],
    userIntent: 'general_copilot_assistance',
  );

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _setupCopilot();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _entryAnimationController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

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

  void _setupCopilot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        ref.read(aiAssistantProvider.notifier).createNewSession(
          _copilotContext,
          initialMessage: _getWelcomeMessage(),
        );
        _isInitialized = true;
        _entryAnimationController.forward();
        _suggestionsAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entryAnimationController.dispose();
    _fabAnimationController.dispose();
    _suggestionsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assistantState = ref.watch(aiAssistantProvider);
    final isTyping = ref.watch(isAiTypingProvider);

    return AnimatedBuilder(
      animation: _entryAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Scaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: _buildAppBar(context),
              body: Stack(
                children: [
                  // Main copilot area
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
                        contextType: _copilotContext.type,
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
                          context: _copilotContext,
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
                          heroTag: 'copilot_scroll_fab',
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return HeaderBar(
      title: 'SkyAngel Copiloto',
      subtitle: 'Tu asistente inteligente de seguridad',
      icon: Icons.psychology_rounded,
      type: HeaderType.primary,
      showBackButton: false,
      actions: [
        HeaderAction(
          icon: _showSuggestions ? Icons.close_rounded : Icons.lightbulb_rounded,
          onPressed: () => _toggleSuggestions(!_showSuggestions),
          tooltip: _showSuggestions ? 'Cerrar sugerencias' : 'Ver sugerencias',
        ),
        HeaderAction(
          icon: Icons.refresh_rounded,
          onPressed: _refreshCopilot,
          tooltip: 'Reiniciar conversación',
        ),
        HeaderAction(
          icon: Icons.history_rounded,
          onPressed: () => _showCopilotMenu(context),
          tooltip: 'Historial de conversaciones',
        ),
      ],
    );
  }

  Widget _buildMessagesList(AiAssistantState state) {
    if (state.isLoading && state.currentMessages.isEmpty) {
      return _buildLoadingState();
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

  Widget _buildLoadingState() {
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
          const SizedBox(height: DesignTokens.spacing4),
          const CircularProgressIndicator(),
          const SizedBox(height: DesignTokens.spacing4),
          Text(
            'Inicializando SkyAngel Copiloto...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: DesignTokens.spacingXL,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: DesignTokens.radiusFull,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: DesignTokens.iconSizeXXXL,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing6),
            Text(
              '¡Hola! Soy tu Copiloto SkyAngel',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: DesignTokens.fontWeightBold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spacing3),
            Text(
              _getWelcomeMessage(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing6),
            _buildQuickStartButtons(),
            const SizedBox(height: DesignTokens.spacing6),
            _buildFeatureHighlights(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartButtons() {
    final quickStarts = _getQuickStartOptions();
    
    return Wrap(
      spacing: DesignTokens.spacing2,
      runSpacing: DesignTokens.spacing2,
      alignment: WrapAlignment.center,
      children: quickStarts.map((option) {
        return ActionChip(
          label: Text(option['label'] as String),
          avatar: Icon(
            option['icon'] as IconData,
            size: DesignTokens.iconSizeS,
          ),
          onPressed: () => _sendMessage(option['message'] as String),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {
        'icon': Icons.security_rounded,
        'title': 'Análisis de Seguridad',
        'description': 'Obtén insights sobre riesgos y tendencias'
      },
      {
        'icon': Icons.route_rounded,
        'title': 'Rutas Inteligentes',
        'description': 'Encuentra las rutas más seguras'
      },
      {
        'icon': Icons.warning_amber_rounded,
        'title': 'Alertas Contextuales',
        'description': 'Recibe avisos personalizados'
      },
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing1),
          child: Row(
            children: [
              Container(
                padding: DesignTokens.spacingS,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: DesignTokens.radiusS,
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  size: DesignTokens.iconSizeM,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
                    Text(
                      feature['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  void _refreshCopilot() {
    HapticFeedback.mediumImpact();
    ref.read(aiAssistantProvider.notifier).createNewSession(
      _copilotContext,
      initialMessage: _getWelcomeMessage(),
    );
  }

  void _showCopilotMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing4),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Historial de conversaciones'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to conversation history
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
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Configurar Copiloto'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to copilot settings
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getWelcomeMessage() {
    return 'Estoy aquí para ayudarte con toda la funcionalidad de SkyAngel. '
           'Puedo asistirte con análisis de seguridad, planificación de rutas, '
           'gestión de alertas y mucho más. ¿En qué puedo ayudarte hoy?';
  }

  List<Map<String, dynamic>> _getQuickStartOptions() {
    return [
      {
        'label': 'Seguridad actual',
        'icon': Icons.security_rounded,
        'message': '¿Cuál es el estado actual de seguridad en mi área?'
      },
      {
        'label': 'Ruta segura',
        'icon': Icons.route_rounded,
        'message': 'Ayúdame a planificar una ruta segura'
      },
      {
        'label': 'Alertas importantes',
        'icon': Icons.warning_amber_rounded,
        'message': '¿Hay alertas importantes que deba conocer?'
      },
      {
        'label': 'Consejos personalizados',
        'icon': Icons.tips_and_updates_rounded,
        'message': 'Dame consejos de seguridad personalizados'
      },
      {
        'label': 'Analizar datos',
        'icon': Icons.analytics_rounded,
        'message': 'Ayúdame a interpretar los datos del dashboard'
      },
      {
        'label': 'Guía de uso',
        'icon': Icons.help_rounded,
        'message': '¿Cómo puedo usar mejor la aplicación SkyAngel?'
      },
    ];
  }
}