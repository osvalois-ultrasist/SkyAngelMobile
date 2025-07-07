import 'package:flutter/material.dart';
import '../../../../shared/design_system/design_tokens.dart';

class ProfileSettingsWidget extends StatefulWidget {
  const ProfileSettingsWidget({super.key});

  @override
  State<ProfileSettingsWidget> createState() => _ProfileSettingsWidgetState();
}

class _ProfileSettingsWidgetState extends State<ProfileSettingsWidget> {
  bool _notificationsEnabled = true;
  bool _locationSharing = true;
  bool _darkMode = false;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing4),
        
        // Settings sections
        _buildSettingsSection(
          'Notificaciones',
          [
            _buildSwitchTile(
              'Notificaciones push',
              'Recibir alertas y actualizaciones',
              Icons.notifications_rounded,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
          ],
          theme,
        ),
        
        SizedBox(height: DesignTokens.spacing4),
        
        _buildSettingsSection(
          'Privacidad',
          [
            _buildSwitchTile(
              'Compartir ubicación',
              'Permitir compartir ubicación para alertas',
              Icons.location_on_rounded,
              _locationSharing,
              (value) => setState(() => _locationSharing = value),
            ),
            _buildSwitchTile(
              'Respaldo automático',
              'Guardar datos automáticamente',
              Icons.backup_rounded,
              _autoBackup,
              (value) => setState(() => _autoBackup = value),
            ),
          ],
          theme,
        ),
        
        SizedBox(height: DesignTokens.spacing4),
        
        _buildSettingsSection(
          'Apariencia',
          [
            _buildSwitchTile(
              'Modo oscuro',
              'Usar tema oscuro en la aplicación',
              Icons.dark_mode_rounded,
              _darkMode,
              (value) => setState(() => _darkMode = value),
            ),
          ],
          theme,
        ),
        
        SizedBox(height: DesignTokens.spacing4),
        
        _buildSettingsSection(
          'Cuenta',
          [
            _buildActionTile(
              'Cambiar contraseña',
              'Actualizar tu contraseña de acceso',
              Icons.lock_rounded,
              () => _changePassword(context),
            ),
            _buildActionTile(
              'Datos de la cuenta',
              'Ver y editar información personal',
              Icons.person_rounded,
              () => _editAccountData(context),
            ),
            _buildActionTile(
              'Eliminar cuenta',
              'Eliminar permanentemente tu cuenta',
              Icons.delete_rounded,
              () => _deleteAccount(context),
              isDestructive: true,
            ),
          ],
          theme,
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    String title,
    List<Widget> children,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: DesignTokens.radiusL,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: DesignTokens.spacingM,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
      contentPadding: DesignTokens.spacingM,
    );
  }

  void _changePassword(BuildContext context) {
    // TODO: Implement change password
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambio de contraseña en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _editAccountData(BuildContext context) {
    // TODO: Implement edit account data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edición de datos en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar cuenta'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}