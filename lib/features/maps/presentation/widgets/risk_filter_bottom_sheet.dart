import 'package:flutter/material.dart';

import '../../domain/entities/risk_polygon.dart';
import '../../domain/entities/risk_level.dart';

class RiskFilterBottomSheet extends StatefulWidget {
  final RiskFilter? currentFilter;
  final void Function(RiskFilter?) onApplyFilter;

  const RiskFilterBottomSheet({
    super.key,
    this.currentFilter,
    required this.onApplyFilter,
  });

  @override
  State<RiskFilterBottomSheet> createState() => _RiskFilterBottomSheetState();
}

class _RiskFilterBottomSheetState extends State<RiskFilterBottomSheet> {
  Set<DataSource> _selectedDataSources = {};
  Set<CrimeType> _selectedCrimeTypes = {};
  Set<RiskLevelType> _selectedRiskLevels = {};
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    if (widget.currentFilter != null) {
      _selectedDataSources = widget.currentFilter!.dataSources.toSet();
      _selectedCrimeTypes = widget.currentFilter!.crimeTypes.toSet();
      _selectedRiskLevels = widget.currentFilter!.riskLevels.toSet();
      if (widget.currentFilter!.startDate != null && widget.currentFilter!.endDate != null) {
        _dateRange = DateTimeRange(
          start: widget.currentFilter!.startDate!,
          end: widget.currentFilter!.endDate!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros de Riesgo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Risk Levels
                  Text(
                    'Niveles de Riesgo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: RiskLevelType.values.map((level) => FilterChip(
                      label: Text(level.label),
                      selected: _selectedRiskLevels.contains(level),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedRiskLevels.add(level);
                          } else {
                            _selectedRiskLevels.remove(level);
                          }
                        });
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Data Sources
                  Text(
                    'Fuentes de Datos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: DataSource.values.map((source) => FilterChip(
                      label: Text(source.label),
                      selected: _selectedDataSources.contains(source),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDataSources.add(source);
                          } else {
                            _selectedDataSources.remove(source);
                          }
                        });
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Crime Types
                  Text(
                    'Tipos de Crimen',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: CrimeType.values.map((type) => FilterChip(
                      label: Text(type.label),
                      selected: _selectedCrimeTypes.contains(type),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCrimeTypes.add(type);
                          } else {
                            _selectedCrimeTypes.remove(type);
                          }
                        });
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date Range
                  Text(
                    'Rango de Fechas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDateRange,
                          icon: const Icon(Icons.date_range),
                          label: Text(_dateRange == null 
                              ? 'Seleccionar fechas'
                              : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'),
                        ),
                      ),
                      if (_dateRange != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setState(() => _dateRange = null),
                          icon: const Icon(Icons.clear),
                        ),
                      ],
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

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedDataSources.clear();
      _selectedCrimeTypes.clear();
      _selectedRiskLevels.clear();
      _dateRange = null;
    });
  }

  void _applyFilters() {
    final filter = _hasActiveFilters() ? RiskFilter(
      dataSources: _selectedDataSources.toList(),
      crimeTypes: _selectedCrimeTypes.toList(),
      riskLevels: _selectedRiskLevels.toList(),
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    ) : null;
    
    widget.onApplyFilter(filter);
  }

  bool _hasActiveFilters() {
    return _selectedDataSources.isNotEmpty ||
           _selectedCrimeTypes.isNotEmpty ||
           _selectedRiskLevels.isNotEmpty ||
           _dateRange != null;
  }
}