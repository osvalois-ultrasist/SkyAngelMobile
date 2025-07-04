import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/create_alert_request.dart';
import '../providers/alert_provider.dart';
import '../widgets/location_picker_widget.dart';

class CreateAlertPage extends ConsumerStatefulWidget {
  const CreateAlertPage({super.key});

  @override
  ConsumerState<CreateAlertPage> createState() => _CreateAlertPageState();
}

class _CreateAlertPageState extends ConsumerState<CreateAlertPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  AlertType? _selectedType;
  String? _selectedIncidencia;
  Position? _selectedLocation;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  
  final Map<AlertType, List<String>> _incidenciasByType = {
    AlertType.robo: [
      'Robo a transeúnte',
      'Robo de vehículo',
      'Robo a casa habitación',
      'Robo en transporte público',
    ],
    AlertType.accidente: [
      'Accidente vehicular',
      'Atropellamiento',
      'Accidente en transporte público',
      'Accidente de motocicleta',
    ],
    AlertType.violencia: [
      'Agresión física',
      'Amenazas',
      'Violencia doméstica',
      'Riña callejera',
    ],
    AlertType.emergencia: [
      'Emergencia médica',
      'Incendio',
      'Inundación',
      'Persona en peligro',
    ],
    AlertType.otro: [
      'Otra incidencia',
      'Actividad sospechosa',
      'Disturbio público',
      'Problema de tráfico',
    ],
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Alerta'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: theme.colorScheme.onErrorContainer,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reporte de Emergencia',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Completa la información para reportar una incidencia.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Alert Type Selection
            Text(
              'Tipo de Alerta *',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AlertType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(_getTypeDisplayName(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                      _selectedIncidencia = null; // Reset incident when type changes
                    });
                  },
                  selectedColor: _getTypeColor(type).withOpacity(0.3),
                  avatar: isSelected ? null : Icon(_getTypeIcon(type), size: 18),
                );
              }).toList(),
            ),
            
            if (_selectedType != null) ...[
              const SizedBox(height: 24),
              
              // Incident Selection
              Text(
                'Tipo de Incidencia *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedIncidencia,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Selecciona el tipo de incidencia',
                ),
                items: _incidenciasByType[_selectedType]?.map((incidencia) {
                  return DropdownMenuItem(
                    value: incidencia,
                    child: Text(incidencia),
                  );
                }).toList() ?? [],
                onChanged: (value) {
                  setState(() {
                    _selectedIncidencia = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un tipo de incidencia';
                  }
                  return null;
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Location Section
            Text(
              'Ubicación *',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            LocationPickerWidget(
              initialLocation: _selectedLocation,
              onLocationChanged: (location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
              isLoading: _isLoadingLocation,
            ),
            
            const SizedBox(height: 24),
            
            // Comments
            Text(
              'Comentarios Adicionales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Describe la situación con más detalle (opcional)',
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            ElevatedButton(
              onPressed: _canSubmit() ? _submitAlert : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'REPORTAR ALERTA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Disclaimer
            Text(
              'Al reportar esta alerta, confirmas que la información proporcionada es veraz. '
              'Las alertas falsas pueden tener consecuencias legales.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedType != null &&
           _selectedIncidencia != null &&
           _selectedLocation != null &&
           !_isSubmitting;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos de ubicación están permanentemente denegados');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _selectedLocation = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate() || !_canSubmit()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final request = CreateAlertRequest(
        tipo: _selectedType!.name,
        incidencia: _selectedIncidencia!,
        coordenadas: '${_selectedLocation!.latitude},${_selectedLocation!.longitude}',
        comentario: _commentController.text.trim(),
      );
      
      await ref.read(alertNotifierProvider.notifier).createAlert(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta reportada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.pop(); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reportar alerta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _getTypeDisplayName(AlertType type) {
    switch (type) {
      case AlertType.robo:
        return 'Robo';
      case AlertType.accidente:
        return 'Accidente';
      case AlertType.violencia:
        return 'Violencia';
      case AlertType.emergencia:
        return 'Emergencia';
      case AlertType.otro:
        return 'Otro';
    }
  }

  Color _getTypeColor(AlertType type) {
    switch (type) {
      case AlertType.robo:
        return Colors.red;
      case AlertType.accidente:
        return Colors.orange;
      case AlertType.violencia:
        return Colors.purple;
      case AlertType.emergencia:
        return Colors.blue;
      case AlertType.otro:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.robo:
        return Icons.security;
      case AlertType.accidente:
        return Icons.car_crash;
      case AlertType.violencia:
        return Icons.warning;
      case AlertType.emergencia:
        return Icons.local_hospital;
      case AlertType.otro:
        return Icons.info;
    }
  }
}
