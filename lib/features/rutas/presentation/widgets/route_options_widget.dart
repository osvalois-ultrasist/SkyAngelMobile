import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/route_entity.dart';

class RouteOptionsWidget extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final Function(RouteType) onRouteTypeSelected;

  const RouteOptionsWidget({
    super.key,
    required this.origin,
    required this.destination,
    required this.onRouteTypeSelected,
  });

  @override
  State<RouteOptionsWidget> createState() => _RouteOptionsWidgetState();
}

class _RouteOptionsWidgetState extends State<RouteOptionsWidget> {
  RouteType _selectedRouteType = RouteType.safest;
  bool _avoidTolls = false;
  bool _avoidHighways = false;
  bool _prioritizeSafety = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.tune),
          SizedBox(width: 8),
          Text('Opciones de Ruta'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de ruta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Route type selection
            ...RouteType.values.map((type) => RadioListTile<RouteType>(
              title: Text(type.label),
              subtitle: Text(_getRouteTypeDescription(type)),
              value: type,
              groupValue: _selectedRouteType,
              onChanged: (value) {
                setState(() {
                  _selectedRouteType = value!;
                });
              },
              secondary: Icon(
                _getRouteTypeIcon(type),
                color: _getRouteTypeColor(type),
              ),
            )),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              'Preferencias adicionales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Additional preferences
            SwitchListTile(
              title: const Text('Evitar autopistas'),
              subtitle: const Text('Usar vías secundarias cuando sea posible'),
              value: _avoidHighways,
              onChanged: (value) {
                setState(() {
                  _avoidHighways = value;
                });
              },
              secondary: const Icon(Icons.alt_route),
            ),
            
            SwitchListTile(
              title: const Text('Evitar casetas'),
              subtitle: const Text('Buscar rutas sin peajes'),
              value: _avoidTolls,
              onChanged: (value) {
                setState(() {
                  _avoidTolls = value;
                });
              },
              secondary: const Icon(Icons.toll),
            ),
            
            SwitchListTile(
              title: const Text('Priorizar seguridad'),
              subtitle: const Text('Optimizar ruta considerando índices de seguridad'),
              value: _prioritizeSafety,
              onChanged: (value) {
                setState(() {
                  _prioritizeSafety = value;
                });
              },
              secondary: const Icon(Icons.security),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onRouteTypeSelected(_selectedRouteType);
            Navigator.of(context).pop();
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  String _getRouteTypeDescription(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return 'Minimiza el tiempo de viaje';
      case RouteType.shortest:
        return 'Minimiza la distancia a recorrer';
      case RouteType.safest:
        return 'Maximiza la seguridad del trayecto';
      case RouteType.mostEconomical:
        return 'Optimiza el consumo de combustible';
      case RouteType.balanced:
        return 'Balance entre tiempo, distancia y seguridad';
      case RouteType.custom:
        return 'Configuración personalizada';
    }
  }

  IconData _getRouteTypeIcon(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return Icons.speed;
      case RouteType.shortest:
        return Icons.straighten;
      case RouteType.safest:
        return Icons.security;
      case RouteType.mostEconomical:
        return Icons.savings;
      case RouteType.balanced:
        return Icons.balance;
      case RouteType.custom:
        return Icons.tune;
    }
  }

  Color _getRouteTypeColor(RouteType type) {
    switch (type) {
      case RouteType.fastest:
        return Colors.blue;
      case RouteType.shortest:
        return Colors.green;
      case RouteType.safest:
        return Colors.purple;
      case RouteType.mostEconomical:
        return Colors.orange;
      case RouteType.balanced:
        return Colors.teal;
      case RouteType.custom:
        return Colors.grey;
    }
  }
}