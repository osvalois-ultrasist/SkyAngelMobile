import 'package:flutter/material.dart';
import '../../../../shared/design_system/design_tokens.dart';

class AiTypingIndicator extends StatefulWidget {
  const AiTypingIndicator({super.key});

  @override
  State<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _dotAnimations = List.generate(3, (index) {
      final startInterval = index * 0.2;
      final endInterval = startInterval + 0.6;
      
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            startInterval,
            endInterval,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing4,
        vertical: DesignTokens.spacing2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: DesignTokens.spacingM,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: DesignTokens.radiusL,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology_rounded,
                  size: DesignTokens.iconSizeS,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: DesignTokens.spacing2),
                ...List.generate(3, (index) => _buildDot(index, theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    return AnimatedBuilder(
      animation: _dotAnimations[index],
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: DesignTokens.spacing1 / 2),
          child: Transform.translate(
            offset: Offset(0, -4 * _dotAnimations[index].value),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(
                  0.3 + (0.7 * _dotAnimations[index].value),
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}