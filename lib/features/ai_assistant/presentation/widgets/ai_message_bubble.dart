import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/ai_message.dart';

class AiMessageBubble extends StatefulWidget {
  final AiMessage message;
  final Function(AiMessageAction)? onActionTap;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onActionTap,
  });

  @override
  State<AiMessageBubble> createState() => _AiMessageBubbleState();
}

class _AiMessageBubbleState extends State<AiMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.type.isFromUser;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildMessageContainer(context, theme, isUser),
          ),
        );
      },
    );
  }

  Widget _buildMessageContainer(BuildContext context, ThemeData theme, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              padding: DesignTokens.spacingL,
              decoration: BoxDecoration(
                color: _getBubbleColor(theme, isUser),
                borderRadius: _getBubbleBorderRadius(isUser),
                boxShadow: [
                  ShadowTokens.createShadow(
                    color: theme.colorScheme.shadow,
                    opacity: DesignTokens.shadowOpacityLight,
                    blurRadius: DesignTokens.blurRadiusS,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  _buildMessageContent(theme, isUser),
                  
                  // Quick actions
                  if (widget.message.quickActions?.isNotEmpty == true)
                    _buildQuickActions(theme),
                ],
              ),
            ),
            
            // Message metadata
            _buildMessageMetadata(theme, isUser),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme, bool isUser) {
    return SelectableText(
      widget.message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: _getTextColor(theme, isUser),
        height: 1.4,
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.spacing3),
      child: Wrap(
        spacing: DesignTokens.spacing2,
        runSpacing: DesignTokens.spacing1,
        children: widget.message.quickActions!.map((action) {
          return _buildActionChip(action, theme);
        }).toList(),
      ),
    );
  }

  Widget _buildActionChip(AiMessageAction action, ThemeData theme) {
    return ActionChip(
      label: Text(
        action.label,
        style: TextStyle(
          fontSize: DesignTokens.fontSizeS,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        widget.onActionTap?.call(action);
      },
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: theme.colorScheme.outline.withOpacity(0.5),
        width: 1,
      ),
      padding: DesignTokens.spacingS,
    );
  }

  Widget _buildMessageMetadata(ThemeData theme, bool isUser) {
    return Padding(
      padding: EdgeInsets.only(
        top: DesignTokens.spacing1,
        left: isUser ? 0 : DesignTokens.spacing2,
        right: isUser ? DesignTokens.spacing2 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message type indicator
          if (!isUser) ...[
            Icon(
              _getMessageTypeIcon(),
              size: DesignTokens.iconSizeXS,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: DesignTokens.spacing1),
          ],
          
          // Timestamp
          Text(
            _formatTimestamp(widget.message.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: DesignTokens.fontSizeXS,
            ),
          ),
          
          // Status indicator
          if (isUser && widget.message.status != null) ...[
            const SizedBox(width: DesignTokens.spacing1),
            Icon(
              _getStatusIcon(),
              size: DesignTokens.iconSizeXS,
              color: _getStatusColor(theme),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(ThemeData theme, bool isUser) {
    if (isUser) {
      return theme.colorScheme.primary;
    }
    
    switch (widget.message.type) {
      case AiMessageType.assistant:
        return theme.colorScheme.surfaceVariant;
      case AiMessageType.system:
        return theme.colorScheme.tertiaryContainer;
      case AiMessageType.suggestion:
        return theme.colorScheme.secondaryContainer;
      case AiMessageType.alert:
        return theme.colorScheme.errorContainer;
      case AiMessageType.recommendation:
        return theme.colorScheme.primaryContainer.withOpacity(0.3);
      default:
        return theme.colorScheme.surfaceVariant;
    }
  }

  Color _getTextColor(ThemeData theme, bool isUser) {
    if (isUser) {
      return theme.colorScheme.onPrimary;
    }
    
    switch (widget.message.type) {
      case AiMessageType.assistant:
        return theme.colorScheme.onSurfaceVariant;
      case AiMessageType.system:
        return theme.colorScheme.onTertiaryContainer;
      case AiMessageType.suggestion:
        return theme.colorScheme.onSecondaryContainer;
      case AiMessageType.alert:
        return theme.colorScheme.onErrorContainer;
      case AiMessageType.recommendation:
        return theme.colorScheme.onPrimaryContainer;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  BorderRadius _getBubbleBorderRadius(bool isUser) {
    const radius = DesignTokens.radiusL;
    
    if (isUser) {
      return BorderRadius.only(
        topLeft: Radius.circular(DesignTokens.spacing4),
        topRight: Radius.circular(DesignTokens.spacing4),
        bottomLeft: Radius.circular(DesignTokens.spacing4),
        bottomRight: const Radius.circular(DesignTokens.spacing1),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(DesignTokens.spacing4),
        topRight: Radius.circular(DesignTokens.spacing4),
        bottomLeft: const Radius.circular(DesignTokens.spacing1),
        bottomRight: Radius.circular(DesignTokens.spacing4),
      );
    }
  }

  IconData _getMessageTypeIcon() {
    switch (widget.message.type) {
      case AiMessageType.assistant:
        return Icons.psychology_rounded;
      case AiMessageType.system:
        return Icons.info_outline_rounded;
      case AiMessageType.suggestion:
        return Icons.lightbulb_outline_rounded;
      case AiMessageType.alert:
        return Icons.warning_amber_rounded;
      case AiMessageType.recommendation:
        return Icons.recommend_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.message.status) {
      case AiMessageStatus.sending:
        return Icons.schedule_rounded;
      case AiMessageStatus.sent:
        return Icons.check_rounded;
      case AiMessageStatus.delivered:
        return Icons.done_all_rounded;
      case AiMessageStatus.read:
        return Icons.done_all_rounded;
      case AiMessageStatus.failed:
        return Icons.error_outline_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (widget.message.status) {
      case AiMessageStatus.sending:
        return theme.colorScheme.onSurface.withOpacity(0.6);
      case AiMessageStatus.sent:
        return theme.colorScheme.primary;
      case AiMessageStatus.delivered:
      case AiMessageStatus.read:
        return theme.colorScheme.primary;
      case AiMessageStatus.failed:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface.withOpacity(0.6);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}