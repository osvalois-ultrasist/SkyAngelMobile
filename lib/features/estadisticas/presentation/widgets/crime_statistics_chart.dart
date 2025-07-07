import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/statistics_entity.dart';

class CrimeStatisticsChart extends StatefulWidget {
  final List<CrimeStatistics> crimeStats;

  const CrimeStatisticsChart({
    super.key,
    required this.crimeStats,
  });

  @override
  State<CrimeStatisticsChart> createState() => _CrimeStatisticsChartState();
}

class _CrimeStatisticsChartState extends State<CrimeStatisticsChart>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _legendController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    
    _chartController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _legendController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _chartController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _legendController.forward();
      }
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
    _legendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: DesignTokens.spacingL,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: DesignTokens.radiusL,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(DesignTokens.shadowOpacityMedium),
                  blurRadius: DesignTokens.blurRadiusL,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: DesignTokens.spacingXL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, colorScheme),
                  const SizedBox(height: DesignTokens.spacing6),
                  _buildChart(),
                  const SizedBox(height: DesignTokens.spacing6),
                  _buildEnhancedLegend(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: DesignTokens.spacingM,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.2),
                colorScheme.primary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: DesignTokens.radiusM,
            boxShadow: [
              ShadowTokens.createShadow(
                color: colorScheme.primary,
                opacity: DesignTokens.shadowOpacityLight,
                blurRadius: DesignTokens.blurRadiusM,
              ),
            ],
          ),
          child: Icon(
            Icons.pie_chart_rounded,
            color: colorScheme.primary,
            size: DesignTokens.iconSizeL,
          ),
        ),
        const SizedBox(width: DesignTokens.spacing4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estadísticas de Crimen',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: DesignTokens.fontWeightBold,
                  color: colorScheme.onSurface,
                  fontSize: DesignTokens.fontSizeXL,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing1),
              Text(
                'Distribución por tipo de delito',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: DesignTokens.fontSizeS,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Show detailed chart info
          },
          child: Container(
            padding: DesignTokens.spacingS,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: DesignTokens.radiusS,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: DesignTokens.iconSizeS,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (widget.crimeStats.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: DesignTokens.radiusM,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: DesignTokens.iconSizeXXL,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: DesignTokens.spacing3),
              Text(
                'No hay datos disponibles',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: DesignTokens.fontWeightMedium,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing1),
              Text(
                'Los datos aparecerán aquí una vez disponibles',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: _buildEnhancedPieSections(),
          centerSpaceRadius: 60,
          sectionsSpace: 3,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildEnhancedPieSections() {
    final total = widget.crimeStats.fold<int>(0, (sum, stat) => sum + stat.totalCount);
    
    return widget.crimeStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final percentage = (stat.totalCount / total) * 100;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 95.0 : 85.0;
      
      return PieChartSectionData(
        value: percentage,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%\n${stat.totalCount}' : '${percentage.toStringAsFixed(1)}%',
        color: _getCrimeTypeColor(stat.crimeType),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? DesignTokens.fontSizeS : DesignTokens.fontSizeXS,
          fontWeight: DesignTokens.fontWeightBold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: isTouched ? _buildBadge(stat) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget? _buildBadge(CrimeStatistics stat) {
    return Container(
      padding: DesignTokens.spacingS,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: DesignTokens.radiusS,
        boxShadow: [
          ShadowTokens.createShadow(
            color: _getCrimeTypeColor(stat.crimeType),
            opacity: DesignTokens.shadowOpacityMedium,
            blurRadius: DesignTokens.blurRadiusM,
          ),
        ],
        border: Border.all(
          color: _getCrimeTypeColor(stat.crimeType),
          width: 2,
        ),
      ),
      child: Text(
        stat.crimeType.label,
        style: TextStyle(
          fontSize: DesignTokens.fontSizeXS,
          fontWeight: DesignTokens.fontWeightSemiBold,
          color: _getCrimeTypeColor(stat.crimeType),
        ),
      ),
    );
  }

  Widget _buildEnhancedLegend() {
    return AnimatedBuilder(
      animation: _legendController,
      builder: (context, child) {
        return Container(
          padding: DesignTokens.spacingL,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: DesignTokens.radiusM,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.legend_toggle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: DesignTokens.iconSizeS,
                  ),
                  const SizedBox(width: DesignTokens.spacing2),
                  Text(
                    'Leyenda',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: DesignTokens.fontWeightSemiBold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacing3),
              Wrap(
                spacing: DesignTokens.spacing4,
                runSpacing: DesignTokens.spacing3,
                children: widget.crimeStats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stat = entry.value;
                  final total = widget.crimeStats.fold<int>(0, (sum, s) => sum + s.totalCount);
                  final percentage = (stat.totalCount / total) * 100;
                  
                  return _EnhancedLegendItem(
                    color: _getCrimeTypeColor(stat.crimeType),
                    label: stat.crimeType.label,
                    count: stat.totalCount,
                    percentage: percentage,
                    animationDelay: Duration(milliseconds: index * 100),
                    controller: _legendController,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCrimeTypeColor(CrimeType type) {
    switch (type) {
      case CrimeType.theft:
        return Colors.blue;
      case CrimeType.assault:
        return Colors.red;
      case CrimeType.robbery:
        return Colors.orange;
      case CrimeType.kidnapping:
        return Colors.purple;
      case CrimeType.homicide:
        return Colors.red[900]!;
      case CrimeType.fraud:
        return Colors.yellow[700]!;
      case CrimeType.vandalism:
        return Colors.brown;
      case CrimeType.drugRelated:
        return Colors.green[700]!;
      case CrimeType.domesticViolence:
        return Colors.pink;
      case CrimeType.other:
        return Colors.grey;
    }
  }
}

class _EnhancedLegendItem extends StatefulWidget {
  final Color color;
  final String label;
  final int count;
  final double percentage;
  final Duration animationDelay;
  final AnimationController controller;

  const _EnhancedLegendItem({
    required this.color,
    required this.label,
    required this.count,
    required this.percentage,
    required this.animationDelay,
    required this.controller,
  });

  @override
  State<_EnhancedLegendItem> createState() => _EnhancedLegendItemState();
}

class _EnhancedLegendItemState extends State<_EnhancedLegendItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _localController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _localController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _localController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _localController,
      curve: Curves.easeOut,
    ));
    
    // Start animation after delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _localController.forward();
      }
    });
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _localController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Show detailed crime type info
              },
              child: Container(
                padding: DesignTokens.spacingM,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: DesignTokens.radiusS,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: DesignTokens.spacing4,
                      height: DesignTokens.spacing4,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: DesignTokens.radiusXS,
                        boxShadow: [
                          ShadowTokens.createShadow(
                            color: widget.color,
                            opacity: DesignTokens.shadowOpacityLight,
                            blurRadius: DesignTokens.blurRadiusS,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: DesignTokens.fontWeightSemiBold,
                            color: theme.colorScheme.onSurface,
                            fontSize: DesignTokens.fontSizeXS,
                          ),
                        ),
                        Text(
                          '${widget.count} (${widget.percentage.toStringAsFixed(1)}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.color,
                            fontWeight: DesignTokens.fontWeightMedium,
                            fontSize: DesignTokens.fontSizeXS,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}