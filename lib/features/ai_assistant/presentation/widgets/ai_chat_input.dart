import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/ai_chat_session.dart';

class AiChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final AiChatContextType contextType;
  final bool isEnabled;

  const AiChatInput({
    super.key,
    required this.onSendMessage,
    required this.contextType,
    this.isEnabled = true,
  });

  @override
  State<AiChatInput> createState() => _AiChatInputState();
}

class _AiChatInputState extends State<AiChatInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _sendButtonScaleAnimation;
  Animation<Color?>? _sendButtonColorAnimation;

  bool _hasText = false;
  bool _isRecording = false;
  bool _dependenciesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeBasicAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesInitialized) {
      _initializeThemeAnimations();
      _dependenciesInitialized = true;
    }
  }

  void _initializeControllers() {
    _textController = TextEditingController();
    _focusNode = FocusNode();
    
    _textController.addListener(_onTextChanged);
  }

  void _initializeBasicAnimations() {
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );

    _sendButtonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeThemeAnimations() {
    final colorScheme = Theme.of(context).colorScheme;
    
    _sendButtonColorAnimation = ColorTween(
      begin: colorScheme.outline,
      end: colorScheme.primary,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          ShadowTokens.createShadow(
            color: theme.colorScheme.shadow,
            opacity: DesignTokens.shadowOpacityLight,
            blurRadius: DesignTokens.blurRadiusM,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quick context actions
            _buildContextActionButton(theme),
            
            const SizedBox(width: DesignTokens.spacing2),
            
            // Text input field
            Expanded(
              child: _buildTextInput(theme),
            ),
            
            const SizedBox(width: DesignTokens.spacing2),
            
            // Voice/Send button
            _buildActionButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildContextActionButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: DesignTokens.radiusFull,
      ),
      child: IconButton(
        onPressed: _showContextActions,
        icon: Icon(
          _getContextIcon(),
          color: theme.colorScheme.primary,
          size: DesignTokens.iconSizeM,
        ),
        tooltip: _getContextTooltip(),
      ),
    );
  }

  Widget _buildTextInput(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: DesignTokens.radiusXL,
        border: Border.all(
          color: _focusNode.hasFocus 
              ? theme.colorScheme.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: widget.isEnabled,
        maxLines: 5,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: _getHintText(),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: DesignTokens.spacingL,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onSubmitted: _hasText ? _onSendMessage : null,
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _sendButtonScaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: _hasText || _isRecording
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceVariant,
              borderRadius: DesignTokens.radiusFull,
              boxShadow: _hasText || _isRecording ? [
                ShadowTokens.createShadow(
                  color: theme.colorScheme.primary,
                  opacity: 0.3,
                  blurRadius: DesignTokens.blurRadiusS,
                ),
              ] : null,
            ),
            child: IconButton(
              onPressed: _hasText ? _onSendMessage : _toggleVoiceInput,
              icon: Icon(
                _getActionIcon(),
                color: _hasText || _isRecording
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: DesignTokens.iconSizeM,
              ),
              tooltip: _hasText ? 'Enviar mensaje' : 'Mensaje de voz',
            ),
          ),
        );
      },
    );
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (hasText) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _onSendMessage([String? value]) {
    final message = value ?? _textController.text.trim();
    
    if (message.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSendMessage(message);
      _textController.clear();
      _focusNode.unfocus();
    }
  }

  void _toggleVoiceInput() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      _animationController.forward();
      _startVoiceRecording();
    } else {
      _animationController.reverse();
      _stopVoiceRecording();
    }
  }

  void _startVoiceRecording() {
    // TODO: Implement voice recording
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de voz en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Auto-stop after 3 seconds for demo
    Future.delayed(const Duration(seconds: 3), () {
      if (_isRecording) {
        _toggleVoiceInput();
      }
    });
  }

  void _stopVoiceRecording() {
    // TODO: Process voice recording and convert to text
  }

  void _showContextActions() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.spacing4),
        ),
      ),
      builder: (context) => Container(
        padding: DesignTokens.spacingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing4),
            ..._getQuickActions().map((action) {
              return ListTile(
                leading: Icon(action['icon'] as IconData),
                title: Text(action['label'] as String),
                subtitle: Text(action['description'] as String),
                onTap: () {
                  Navigator.pop(context);
                  _textController.text = action['template'] as String;
                  _focusNode.requestFocus();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getContextIcon() {
    switch (widget.contextType) {
      case AiChatContextType.dashboard:
        return Icons.dashboard_rounded;
      case AiChatContextType.maps:
        return Icons.map_rounded;
      case AiChatContextType.alerts:
        return Icons.warning_amber_rounded;
      case AiChatContextType.routes:
        return Icons.route_rounded;
      case AiChatContextType.profile:
        return Icons.person_rounded;
      case AiChatContextType.emergency:
        return Icons.emergency_rounded;
      default:
        return Icons.psychology_rounded;
    }
  }

  String _getContextTooltip() {
    switch (widget.contextType) {
      case AiChatContextType.dashboard:
        return 'Acciones de dashboard';
      case AiChatContextType.maps:
        return 'Acciones de mapas';
      case AiChatContextType.alerts:
        return 'Acciones de alertas';
      case AiChatContextType.routes:
        return 'Acciones de rutas';
      case AiChatContextType.profile:
        return 'Acciones de perfil';
      case AiChatContextType.emergency:
        return 'Acciones de emergencia';
      default:
        return 'Acciones rápidas';
    }
  }

  String _getHintText() {
    switch (widget.contextType) {
      case AiChatContextType.dashboard:
        return '¿Qué datos te gustaría analizar?';
      case AiChatContextType.maps:
        return '¿Qué zona quieres consultar?';
      case AiChatContextType.alerts:
        return '¿Qué incidente quieres reportar?';
      case AiChatContextType.routes:
        return '¿A dónde quieres ir?';
      case AiChatContextType.profile:
        return '¿Cómo puedo ayudarte con tu perfil?';
      case AiChatContextType.emergency:
        return '¿Qué tipo de emergencia tienes?';
      default:
        return 'Escribe tu mensaje...';
    }
  }

  IconData _getActionIcon() {
    if (_isRecording) {
      return Icons.stop_rounded;
    } else if (_hasText) {
      return Icons.send_rounded;
    } else {
      return Icons.mic_rounded;
    }
  }

  List<Map<String, dynamic>> _getQuickActions() {
    switch (widget.contextType) {
      case AiChatContextType.dashboard:
        return [
          {
            'label': 'Explicar tendencias',
            'description': 'Análisis de tendencias actuales',
            'icon': Icons.trending_up,
            'template': 'Explícame las tendencias de seguridad que veo en el dashboard',
          },
          {
            'label': 'Áreas críticas',
            'description': 'Identificar zonas de alto riesgo',
            'icon': Icons.warning,
            'template': '¿Cuáles son las áreas más críticas según los datos actuales?',
          },
          {
            'label': 'Recomendaciones',
            'description': 'Sugerencias basadas en datos',
            'icon': Icons.lightbulb,
            'template': 'Dame recomendaciones específicas basadas en los datos que veo',
          },
        ];
      case AiChatContextType.maps:
        return [
          {
            'label': 'Analizar zona',
            'description': 'Información sobre una zona específica',
            'icon': Icons.location_on,
            'template': 'Analiza la seguridad de esta zona que estoy viendo',
          },
          {
            'label': 'Patrones de crimen',
            'description': 'Identificar patrones criminales',
            'icon': Icons.pattern,
            'template': '¿Qué patrones de criminalidad puedes identificar en este mapa?',
          },
          {
            'label': 'Mejor momento',
            'description': 'Horarios recomendados para transitar',
            'icon': Icons.schedule,
            'template': '¿Cuál es el mejor horario para transitar por esta zona?',
          },
        ];
      case AiChatContextType.alerts:
        return [
          {
            'label': 'Reportar robo',
            'description': 'Crear alerta de robo',
            'icon': Icons.money_off,
            'template': 'Quiero reportar un robo que acaba de ocurrir',
          },
          {
            'label': 'Situación sospechosa',
            'description': 'Reportar actividad sospechosa',
            'icon': Icons.visibility,
            'template': 'He observado actividad sospechosa en mi área',
          },
          {
            'label': 'Persona perdida',
            'description': 'Reportar persona desaparecida',
            'icon': Icons.person_search,
            'template': 'Necesito reportar una persona perdida',
          },
        ];
      case AiChatContextType.routes:
        return [
          {
            'label': 'Ruta al trabajo',
            'description': 'Optimizar ruta laboral',
            'icon': Icons.work,
            'template': 'Ayúdame a encontrar la ruta más segura a mi trabajo',
          },
          {
            'label': 'Evitar peligros',
            'description': 'Rutas evitando zonas peligrosas',
            'icon': Icons.shield,
            'template': 'Quiero una ruta que evite completamente las zonas peligrosas',
          },
          {
            'label': 'Transporte público',
            'description': 'Rutas en transporte público',
            'icon': Icons.directions_bus,
            'template': '¿Cuál es la opción más segura en transporte público?',
          },
        ];
      default:
        return [
          {
            'label': 'Estado general',
            'description': 'Información general de seguridad',
            'icon': Icons.info,
            'template': '¿Cuál es el estado general de seguridad en mi área?',
          },
          {
            'label': 'Consejos personalizados',
            'description': 'Recomendaciones específicas para ti',
            'icon': Icons.person,
            'template': 'Dame consejos de seguridad personalizados para mi situación',
          },
          {
            'label': 'Ayuda general',
            'description': 'Cómo usar la aplicación',
            'icon': Icons.help,
            'template': '¿Cómo puedo aprovechar mejor las funciones de SkyAngel?',
          },
        ];
    }
  }
}