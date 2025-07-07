import 'package:flutter/material.dart';
import '../../../../shared/design_system/design_tokens.dart';

class ProfileStatsWidget extends StatelessWidget {
  const ProfileStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas de uso',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing4),
        
        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: DesignTokens.spacing3,
          mainAxisSpacing: DesignTokens.spacing3,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Rutas completadas',
              '247',
              Icons.route_rounded,
              Colors.blue,
              theme,
            ),
            _buildStatCard(
              'Km recorridos',
              '15,234',
              Icons.straighten_rounded,
              Colors.green,
              theme,
            ),
            _buildStatCard(
              'Alertas reportadas',
              '12',
              Icons.warning_rounded,
              Colors.orange,
              theme,
            ),
            _buildStatCard(
              'Días activo',
              '89',
              Icons.calendar_today_rounded,
              Colors.purple,
              theme,
            ),
          ],
        ),
        
        SizedBox(height: DesignTokens.spacing4),
        
        // Security score
        Container(
          padding: DesignTokens.spacingL,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withOpacity(0.3),
                colorScheme.primaryContainer.withOpacity(0.1),
              ],
            ),
            borderRadius: DesignTokens.radiusL,
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: colorScheme.primary,
                    size: DesignTokens.iconSizeL,
                  ),
                  SizedBox(width: DesignTokens.spacing2),
                  Text(
                    'Puntuación de seguridad',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignTokens.spacing3),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.85,
                      backgroundColor: colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacing2),
                  Text(
                    '85/100',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightBold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignTokens.spacing2),
              Text(
                'Excelente historial de seguridad',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: DesignTokens.spacingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: DesignTokens.radiusL,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: DesignTokens.blurRadiusS,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: DesignTokens.iconSizeL,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: DesignTokens.fontWeightBold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}