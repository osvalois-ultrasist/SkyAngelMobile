import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/routes_repository.dart';

/// Bottom sheet para filtros de rutas siguiendo el patrón de mapas
/// Permite filtrar por tipo de ruta, nivel de riesgo, duración, etc.
class RouteFilterBottomSheet extends StatefulWidget {
  final RouteFilter? currentFilter;
  final Function(RouteFilter?) onApplyFilter;

  const RouteFilterBottomSheet({
    super.key,
    this.currentFilter,
    required this.onApplyFilter,
  });

  @override
  State<RouteFilterBottomSheet> createState() => _RouteFilterBottomSheetState();
}

class _RouteFilterBottomSheetState extends State<RouteFilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Filter state
  Set<RouteType> _selectedRouteTypes = {};
  Set<RiskLevelType> _selectedRiskLevels = {};
  RangeValues _durationRange = const RangeValues(0, 120); // 0-120 minutes
  RangeValues _distanceRange = const RangeValues(0, 100); // 0-100 km
  double _maxRiskScore = 1.0;
  bool _includeAlternatives = true;
  bool _prioritizeSafety = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFiltersFromCurrent();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _initializeFiltersFromCurrent() {
    if (widget.currentFilter != null) {
      final filter = widget.currentFilter!;
      _selectedRouteTypes = filter.routeTypes?.toSet() ?? {};
      _selectedRiskLevels = filter.riskLevels?.toSet() ?? {};
      
      if (filter.maxDurationMinutes != null) {
        _durationRange = RangeValues(0, filter.maxDurationMinutes!.toDouble());
      }
      
      if (filter.maxDistanceKm != null) {
        _distanceRange = RangeValues(0, filter.maxDistanceKm!);
      }
      
      _maxRiskScore = filter.maxRiskScore ?? 1.0;
      _includeAlternatives = filter.includeAlternatives ?? true;
      _prioritizeSafety = filter.prioritizeSafety ?? true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: DesignTokens.radiusXL.copyWith(
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
                boxShadow: [
                  ShadowTokens.createShadow(
                    color: Colors.black,
                    opacity: 0.2,
                    blurRadius: DesignTokens.blurRadiusXL,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(theme, colorScheme),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: DesignTokens.spacingL,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRouteTypeSection(theme, colorScheme),
                          SizedBox(height: DesignTokens.spacing6),
                          _buildRiskLevelSection(theme, colorScheme),
                          SizedBox(height: DesignTokens.spacing6),
                          _buildDurationSection(theme, colorScheme),
                          SizedBox(height: DesignTokens.spacing6),
                          _buildDistanceSection(theme, colorScheme),
                          SizedBox(height: DesignTokens.spacing6),
                          _buildRiskScoreSection(theme, colorScheme),
                          SizedBox(height: DesignTokens.spacing6),
                          _buildOptionsSection(theme, colorScheme),
                        ],
                      ),
                    ),
                  ),
                  _buildActionButtons(theme, colorScheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.8),
            colorScheme.primaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: DesignTokens.radiusXL.copyWith(
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: DesignTokens.spacingS,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: DesignTokens.radiusM,
            ),
            child: Icon(
              Icons.tune_rounded,
              color: colorScheme.onPrimary,
              size: DesignTokens.iconSizeL,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros de Rutas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Personaliza tus criterios de búsqueda',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTypeSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Ruta',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing3),
        Wrap(
          spacing: DesignTokens.spacing2,
          runSpacing: DesignTokens.spacing2,
          children: RouteType.values.map((type) {
            final isSelected = _selectedRouteTypes.contains(type);
            return FilterChip(
              label: Text(type.label),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (selected) {
                    _selectedRouteTypes.add(type);
                  } else {
                    _selectedRouteTypes.remove(type);
                  }
                });
              },
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected 
                    ? colorScheme.primary 
                    : colorScheme.outline.withOpacity(0.5),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRiskLevelSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de Riesgo Aceptable',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing3),
        Wrap(
          spacing: DesignTokens.spacing2,
          runSpacing: DesignTokens.spacing2,
          children: RiskLevelType.values.map((level) {
            final isSelected = _selectedRiskLevels.contains(level);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: level.color,
                  ),
                  SizedBox(width: DesignTokens.spacing1),
                  Text(level.label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (selected) {
                    _selectedRiskLevels.add(level);
                  } else {
                    _selectedRiskLevels.remove(level);
                  }
                });
              },
              backgroundColor: colorScheme.surface,
              selectedColor: level.color.withOpacity(0.2),
              checkmarkColor: level.color,
              side: BorderSide(
                color: isSelected ? level.color : colorScheme.outline.withOpacity(0.5),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración Máxima',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Text(
          '${_durationRange.end.toInt()} minutos',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
        Slider(
          value: _durationRange.end,
          min: 5,
          max: 180,
          divisions: 35,
          onChanged: (value) {
            setState(() {
              _durationRange = RangeValues(_durationRange.start, value);
            });
          },
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.primary.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildDistanceSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distancia Máxima',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Text(
          '${_distanceRange.end.toInt()} km',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
        Slider(
          value: _distanceRange.end,
          min: 1,
          max: 200,
          divisions: 40,
          onChanged: (value) {
            setState(() {
              _distanceRange = RangeValues(_distanceRange.start, value);
            });
          },
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.primary.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildRiskScoreSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Puntuación de Riesgo Máxima',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Text(
          '${(_maxRiskScore * 10).toInt()}/10',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: _getRiskScoreColor(_maxRiskScore),
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
        Slider(
          value: _maxRiskScore,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          onChanged: (value) {
            setState(() {
              _maxRiskScore = value;
            });
          },
          activeColor: _getRiskScoreColor(_maxRiskScore),
          inactiveColor: _getRiskScoreColor(_maxRiskScore).withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones Adicionales',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing3),
        SwitchListTile(
          title: Text('Incluir rutas alternativas'),
          subtitle: Text('Mostrar múltiples opciones de ruta'),
          value: _includeAlternatives,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _includeAlternatives = value;
            });
          },
          activeColor: colorScheme.primary,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text('Priorizar seguridad'),
          subtitle: Text('Dar mayor peso a rutas más seguras'),
          value: _prioritizeSafety,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _prioritizeSafety = value;
            });
          },
          activeColor: colorScheme.primary,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _clearFilters();
              },
              child: Text('Limpiar Filtros'),
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _applyFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: DesignTokens.spacingL,
                shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.radiusM,
                ),
              ),
              child: Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskScoreColor(double score) {
    if (score <= 0.3) return Colors.green;
    if (score <= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _clearFilters() {
    setState(() {
      _selectedRouteTypes.clear();
      _selectedRiskLevels.clear();
      _durationRange = const RangeValues(0, 120);
      _distanceRange = const RangeValues(0, 100);
      _maxRiskScore = 1.0;
      _includeAlternatives = true;
      _prioritizeSafety = true;
    });
  }

  void _applyFilters() {
    final filter = RouteFilter(
      routeTypes: _selectedRouteTypes.isEmpty ? null : _selectedRouteTypes.toList(),
      riskLevels: _selectedRiskLevels.isEmpty ? null : _selectedRiskLevels.toList(),
      maxDurationMinutes: _durationRange.end == 120 ? null : _durationRange.end.toInt(),
      maxDistanceKm: _distanceRange.end == 100 ? null : _distanceRange.end,
      maxRiskScore: _maxRiskScore == 1.0 ? null : _maxRiskScore,
      includeAlternatives: _includeAlternatives,
      prioritizeSafety: _prioritizeSafety,
    );

    widget.onApplyFilter(filter);
    Navigator.of(context).pop();
  }
}

/// Clase de utilidad para sombras siguiendo el design system
class ShadowTokens {
  static BoxShadow createShadow({
    required Color color,
    double opacity = 0.1,
    double blurRadius = 4.0,
    Offset offset = const Offset(0, 2),
  }) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blurRadius,
      offset: offset,
    );
  }
}

// Extensions para obtener colores y labels de enums
extension RouteTypeExtension on RouteType {
  String get label {
    switch (this) {
      case RouteType.fastest:
        return 'Más Rápida';
      case RouteType.shortest:
        return 'Más Corta';
      case RouteType.safest:
        return 'Más Segura';
      case RouteType.mostEconomical:
        return 'Más Económica';
      case RouteType.balanced:
        return 'Balanceada';
      case RouteType.custom:
        return 'Personalizada';
    }
  }
}

extension RiskLevelTypeExtension on RiskLevelType {
  String get label {
    switch (this) {
      case RiskLevelType.veryLow:
        return 'Muy Bajo';
      case RiskLevelType.low:
        return 'Bajo';
      case RiskLevelType.medium:
        return 'Medio';
      case RiskLevelType.high:
        return 'Alto';
      case RiskLevelType.veryHigh:
        return 'Muy Alto';
      case RiskLevelType.extreme:
        return 'Extremo';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevelType.veryLow:
        return Colors.green[700]!;
      case RiskLevelType.low:
        return Colors.green;
      case RiskLevelType.medium:
        return Colors.yellow[700]!;
      case RiskLevelType.high:
        return Colors.orange;
      case RiskLevelType.veryHigh:
        return Colors.red;
      case RiskLevelType.extreme:
        return Colors.red[900]!;
    }
  }
}