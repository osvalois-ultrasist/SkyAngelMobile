import 'package:flutter/material.dart';
import '../../../../shared/design_system/design_tokens.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userStatus;
  final VoidCallback? onEditPressed;

  const ProfileHeaderWidget({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userStatus,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: DesignTokens.blurRadiusM,
            offset: const Offset(0, 2),
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
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: DesignTokens.blurRadiusM,
                  offset: const Offset(0, 2),
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
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing1),
                Text(
                  userRole,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: DesignTokens.spacing2),
                Container(
                  padding: DesignTokens.paddingHorizontalM.add(DesignTokens.paddingVerticalS),
                  decoration: BoxDecoration(
                    color: _getStatusColor(userStatus).withOpacity(0.2),
                    borderRadius: DesignTokens.radiusM,
                  ),
                  child: Text(
                    userStatus.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(userStatus),
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onEditPressed != null)
            IconButton(
              onPressed: onEditPressed,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.red;
      case 'en pausa':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}