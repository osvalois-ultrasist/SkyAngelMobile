import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateAlertFAB extends StatelessWidget {
  const CreateAlertFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateAlertDialog(context),
      icon: const Icon(Icons.add_alert),
      label: const Text('Nueva Alerta'),
      backgroundColor: Theme.of(context).colorScheme.error,
      foregroundColor: Theme.of(context).colorScheme.onError,
    );
  }

  void _showCreateAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nueva Alerta'),
        content: const Text(
          '¿Deseas reportar una nueva alerta de seguridad?\n\n'
          'Podrás seleccionar el tipo de incidencia y proporcionar '
          'detalles en la siguiente pantalla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/sky/alerts/create');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
