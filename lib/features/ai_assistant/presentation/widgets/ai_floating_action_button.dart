import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../providers/ai_assistant_provider.dart';
import '../pages/ai_chat_page.dart';
import '../../domain/entities/ai_chat_session.dart';

class AiFloatingActionButton extends ConsumerStatefulWidget {
  final AiChatContextType contextType;
  final Map<String, dynamic>? contextData;
  final String? heroTag;

  const AiFloatingActionButton({
    super.key,
    required this.contextType,
    this.contextData,
    this.heroTag,
  });

  @override
  ConsumerState<AiFloatingActionButton> createState() => _AiFloatingActionButtonState();
}

class _AiFloatingActionButtonState extends ConsumerState<AiFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  Animation<Color?>? _colorAnimation;
  
  bool _isPressed = false;
  bool _hasNotifications = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNotifications();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeColorAnimation(ColorScheme colorScheme) {
    if (_colorAnimation == null) {
      _colorAnimation = ColorTween(
        begin: colorScheme.primary,
        end: colorScheme.secondary,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
  }

  void _checkForNotifications() {
    // Check if there are pending AI suggestions or recommendations
    if (mounted) {
      final assistantState = ref.read(aiAssistantProvider);
      setState(() {
        _hasNotifications = assistantState.hasActiveSuggestions;
      });
    }
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
    
    // Initialize color animation on first build
    _initializeColorAnimation(colorScheme);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radiusFull,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(_isPressed ? 0.4 : 0.2),
                    blurRadius: DesignTokens.blurRadiusL,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _onPressed,
                heroTag: widget.heroTag ?? 'ai_assistant_fab',
                backgroundColor: _colorAnimation?.value ?? colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: _isPressed ? 2 : 6,
                tooltip: 'Asistente Inteligente SkyAngel',
                shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.radiusFull,
                ),
                child: Stack(
                  children: [
                    // Main AI icon
                    const Icon(
                      Icons.psychology_rounded,
                      size: DesignTokens.iconSizeL,
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

  void _onPressed() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isPressed = true;
    });
    
    _animationController.forward().then((_) {
      _animationController.reverse();
      setState(() {
        _isPressed = false;
      });
    });

    // Navigate to AI chat
    _openAiChat();
  }

  void _openAiChat() {
    final context = AiChatContext(
      type: widget.contextType,
      location: widget.contextType.label,
      currentData: widget.contextData,
      relevantFeatures: _getRelevantFeatures(),
    );

    Navigator.of(this.context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => AiChatPage(
          initialContext: context,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: DesignTokens.animationDurationNormal,
      ),
    );
  }

  List<String> _getRelevantFeatures() {
    switch (widget.contextType) {
      case AiChatContextType.dashboard:
        return ['statistics', 'trends', 'security_analysis', 'recommendations'];
      case AiChatContextType.maps:
        return ['crime_mapping', 'risk_analysis', 'location_intelligence', 'geospatial'];
      case AiChatContextType.alerts:
        return ['emergency_alerts', 'community_safety', 'incident_reporting', 'notifications'];
      case AiChatContextType.routes:
        return ['route_optimization', 'safety_routing', 'traffic_analysis', 'navigation'];
      case AiChatContextType.profile:
        return ['user_preferences', 'security_settings', 'privacy', 'personalization'];
      case AiChatContextType.general:
        return ['general_assistance', 'platform_help', 'feature_guidance'];
      case AiChatContextType.emergency:
        return ['emergency_protocols', 'safety_assistance', 'quick_response', 'risk_assessment'];
    }
  }
}