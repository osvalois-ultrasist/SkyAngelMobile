import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RouteSearchWidget extends StatefulWidget {
  final Function(LatLng?) onOriginChanged;
  final Function(LatLng?) onDestinationChanged;
  final VoidCallback onSearchPressed;
  final bool isLoading;

  const RouteSearchWidget({
    super.key,
    required this.onOriginChanged,
    required this.onDestinationChanged,
    required this.onSearchPressed,
    this.isLoading = false,
  });

  @override
  State<RouteSearchWidget> createState() => _RouteSearchWidgetState();
}

class _RouteSearchWidgetState extends State<RouteSearchWidget> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  LatLng? _origin;
  LatLng? _destination;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Origin field
            TextField(
              controller: _originController,
              decoration: InputDecoration(
                labelText: 'Origen',
                hintText: 'Ingresa tu ubicación de origen',
                prefixIcon: const Icon(Icons.my_location),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.gps_fixed),
                  onPressed: _useCurrentLocation,
                  tooltip: 'Usar ubicación actual',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onOriginChanged,
            ),
            
            const SizedBox(height: 12),
            
            // Swap button
            Center(
              child: IconButton(
                onPressed: _swapLocations,
                icon: const Icon(Icons.swap_vert),
                tooltip: 'Intercambiar origen y destino',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Destination field
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: 'Destino',
                hintText: 'Ingresa tu destino',
                prefixIcon: const Icon(Icons.place),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _selectFromMap,
                  tooltip: 'Seleccionar en el mapa',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onDestinationChanged,
            ),
            
            const SizedBox(height: 16),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSearch() && !widget.isLoading 
                    ? widget.onSearchPressed 
                    : null,
                icon: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  widget.isLoading ? 'Buscando...' : 'Buscar Rutas',
                ),
              ),
            ),
            
            // Quick suggestions
            if (_originController.text.isEmpty && _destinationController.text.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rutas frecuentes:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildQuickSuggestion('Casa - Trabajo'),
                        _buildQuickSuggestion('Trabajo - Centro'),
                        _buildQuickSuggestion('Casa - Escuela'),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestion(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      onPressed: () => _applyQuickSuggestion(suggestion),
      avatar: const Icon(Icons.history, size: 16),
    );
  }

  void _onOriginChanged(String value) {
    // TODO: Implement geocoding or place search
    // For now, use mock coordinates
    if (value.isNotEmpty) {
      _origin = const LatLng(19.4326, -99.1332); // Mexico City mock
      widget.onOriginChanged(_origin);
    } else {
      _origin = null;
      widget.onOriginChanged(null);
    }
  }

  void _onDestinationChanged(String value) {
    // TODO: Implement geocoding or place search
    // For now, use mock coordinates
    if (value.isNotEmpty) {
      _destination = const LatLng(19.4500, -99.1300); // Mexico City mock
      widget.onDestinationChanged(_destination);
    } else {
      _destination = null;
      widget.onDestinationChanged(null);
    }
  }

  void _useCurrentLocation() {
    // TODO: Implement current location detection
    _originController.text = 'Mi ubicación actual';
    _origin = const LatLng(19.4326, -99.1332);
    widget.onOriginChanged(_origin);
  }

  void _selectFromMap() {
    // TODO: Implement map picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selección en mapa - Funcionalidad en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _swapLocations() {
    final tempText = _originController.text;
    final tempLocation = _origin;
    
    _originController.text = _destinationController.text;
    _destinationController.text = tempText;
    
    _origin = _destination;
    _destination = tempLocation;
    
    widget.onOriginChanged(_origin);
    widget.onDestinationChanged(_destination);
  }

  void _applyQuickSuggestion(String suggestion) {
    final parts = suggestion.split(' - ');
    if (parts.length == 2) {
      _originController.text = parts[0];
      _destinationController.text = parts[1];
      
      // Mock coordinates for quick suggestions
      _origin = const LatLng(19.4326, -99.1332);
      _destination = const LatLng(19.4500, -99.1300);
      
      widget.onOriginChanged(_origin);
      widget.onDestinationChanged(_destination);
    }
  }

  bool _canSearch() {
    return _origin != null && _destination != null;
  }
}