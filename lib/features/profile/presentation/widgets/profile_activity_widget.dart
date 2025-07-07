import 'package:flutter/material.dart';
import '../../../../shared/design_system/design_tokens.dart';

class ProfileActivityWidget extends StatelessWidget {
  const ProfileActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad reciente',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing4),
        
        // Activity timeline
        ..._buildActivityItems(theme),
      ],
    );
  }

  List<Widget> _buildActivityItems(ThemeData theme) {
    final activities = [
      ActivityItem(
        title: 'Ruta completada',
        subtitle: 'Centro → Aeropuerto (24.5 km)',
        time: 'Hace 2 horas',
        icon: Icons.check_circle_rounded,
        color: Colors.green,
      ),
      ActivityItem(
        title: 'Alerta reportada',
        subtitle: 'Tráfico intenso en Av. Insurgentes',
        time: 'Hace 5 horas',
        icon: Icons.warning_rounded,
        color: Colors.orange,
      ),
      ActivityItem(
        title: 'Perfil actualizado',
        subtitle: 'Información de contacto',
        time: 'Hace 1 día',
        icon: Icons.person_rounded,
        color: Colors.blue,
      ),
      ActivityItem(
        title: 'Nueva ruta guardada',
        subtitle: 'Casa → Trabajo',
        time: 'Hace 2 días',
        icon: Icons.bookmark_rounded,
        color: Colors.purple,
      ),
    ];

    return activities.map((activity) => _buildActivityTile(activity, theme)).toList();
  }

  Widget _buildActivityTile(ActivityItem activity, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: DesignTokens.radiusM,
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: DesignTokens.iconSizeL,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing1),
                Text(
                  activity.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: DesignTokens.spacing1),
                Text(
                  activity.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: DesignTokens.fontSizeXS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}