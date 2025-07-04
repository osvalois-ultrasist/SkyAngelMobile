import 'package:flutter/material.dart';

class AlertFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? textColor;

  const AlertFilterChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      deleteIcon: onDeleted != null 
          ? Icon(
              Icons.close,
              size: 16,
              color: textColor ?? theme.colorScheme.onPrimary,
            )
          : null,
      onDeleted: onDeleted,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
