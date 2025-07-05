import 'package:flutter/material.dart';

import '../../domain/entities/poi_entity.dart';

class POIFilterBottomSheet extends StatefulWidget {
  final POIFilter? currentFilter;
  final void Function(POIFilter?) onApplyFilter;

  const POIFilterBottomSheet({
    super.key,
    this.currentFilter,
    required this.onApplyFilter,
  });

  @override
  State<POIFilterBottomSheet> createState() => _POIFilterBottomSheetState();
}

class _POIFilterBottomSheetState extends State<POIFilterBottomSheet> {
  Set<POIType> _selectedTypes = {};
  Set<POIStatus> _selectedStatuses = {};
  double? _minRating;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentFilter != null) {
      _selectedTypes = widget.currentFilter!.types.toSet();
      _selectedStatuses = widget.currentFilter!.statuses.toSet();
      _minRating = widget.currentFilter!.minRating;
      _searchController.text = widget.currentFilter!.searchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros de POI',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search query
                  Text(
                    'Buscar por nombre',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar POIs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // POI Types
                  Text(
                    'Tipos de POI',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: POIType.values.map((type) => FilterChip(
                      avatar: Text(type.icon, style: const TextStyle(fontSize: 16)),
                      label: Text(type.label),
                      selected: _selectedTypes.contains(type),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // POI Statuses
                  Text(
                    'Estado del POI',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: POIStatus.values.map((status) => FilterChip(
                      label: Text(POIStatusExtension(status).label),
                      selected: _selectedStatuses.contains(status),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedStatuses.add(status);
                          } else {
                            _selectedStatuses.remove(status);
                          }
                        });
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Minimum Rating
                  Text(
                    'Calificación mínima',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minRating ?? 0,
                          min: 0,
                          max: 5,
                          divisions: 5,
                          label: _minRating?.toStringAsFixed(1) ?? '0.0',
                          onChanged: (value) {
                            setState(() {
                              _minRating = value == 0 ? null : value;
                            });
                          },
                        ),
                      ),
                      if (_minRating != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setState(() => _minRating = null),
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ],
                  ),
                  if (_minRating != null)
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < _minRating! ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        )),
                        const SizedBox(width: 8),
                        Text('${_minRating!.toStringAsFixed(1)} o más'),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedTypes.clear();
      _selectedStatuses.clear();
      _minRating = null;
      _searchController.clear();
    });
  }

  void _applyFilters() {
    final filter = _hasActiveFilters() ? POIFilter(
      types: _selectedTypes.toList(),
      statuses: _selectedStatuses.toList(),
      minRating: _minRating,
      searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    ) : null;
    
    widget.onApplyFilter(filter);
  }

  bool _hasActiveFilters() {
    return _selectedTypes.isNotEmpty ||
           _selectedStatuses.isNotEmpty ||
           _minRating != null ||
           _searchController.text.trim().isNotEmpty;
  }
}

// Extension for POIStatus
extension POIStatusFilterExtension on POIStatus {
  String get label {
    switch (this) {
      case POIStatus.activo:
        return 'Activo';
      case POIStatus.inactivo:
        return 'Inactivo';
      case POIStatus.mantenimiento:
        return 'Mantenimiento';
      case POIStatus.cerrado:
        return 'Cerrado';
    }
  }
}