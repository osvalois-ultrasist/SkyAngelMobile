import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/ai_message.dart';

class AiQuickActions extends StatelessWidget {
  final List<AiMessageAction> actions;
  final Function(AiMessageAction) onActionTap;

  const AiQuickActions({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing2),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing4),
        itemCount: actions.length,
        separatorBuilder: (context, index) => SizedBox(width: DesignTokens.spacing2),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _QuickActionChip(
            action: action,
            onTap: () => onActionTap(action),
            theme: theme,
          );
        },
      ),
    );
  }
}

class _QuickActionChip extends StatefulWidget {
  final AiMessageAction action;
  final VoidCallback onTap;
  final ThemeData theme;

  const _QuickActionChip({
    required this.action,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing3,
                vertical: DesignTokens.spacing2,
              ),
              decoration: BoxDecoration(
                color: _isPressed
                    ? widget.theme.colorScheme.primary.withOpacity(0.2)
                    : widget.theme.colorScheme.primaryContainer,
                borderRadius: DesignTokens.radiusL,
                border: Border.all(
                  color: widget.theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getActionIcon(widget.action.actionType),
                    size: DesignTokens.iconSizeS,
                    color: widget.theme.colorScheme.primary,
                  ),
                  SizedBox(width: DesignTokens.spacing1),
                  Text(
                    widget.action.label,
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      color: widget.theme.colorScheme.onPrimaryContainer,
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'navigate':
        return Icons.directions_rounded;
      case 'suggestion':
        return Icons.lightbulb_rounded;
      case 'analysis':
        return Icons.analytics_rounded;
      case 'report':
        return Icons.report_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'help':
        return Icons.help_rounded;
      default:
        return Icons.touch_app_rounded;
    }
  }
}