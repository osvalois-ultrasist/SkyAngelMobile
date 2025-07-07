import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/statistics_entity.dart';

class SecurityOverviewCard extends StatefulWidget {
  final SecurityOverview overview;

  const SecurityOverviewCard({
    super.key,
    required this.overview,
  });

  @override
  State<SecurityOverviewCard> createState() => _SecurityOverviewCardState();
}

class _SecurityOverviewCardState extends State<SecurityOverviewCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _statsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: DesignTokens.animationDurationNormal,
      vsync: this,
    );
    
    _statsController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _statsController.forward();
      }
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _statsController.dispose();
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
                  _buildStatisticsGrid(),
                  const SizedBox(height: DesignTokens.spacing6),
                  _buildRiskScore(theme, colorScheme),
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildImprovementIndicator(theme, colorScheme),
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
        // Enhanced icon container
        Container(
          padding: DesignTokens.spacingM,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getSecurityLevelColor(widget.overview.currentSecurityLevel).withValues(alpha: 0.2),
                _getSecurityLevelColor(widget.overview.currentSecurityLevel).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: DesignTokens.radiusM,
            border: Border.all(
              color: _getSecurityLevelColor(widget.overview.currentSecurityLevel).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              ShadowTokens.createShadow(
                color: _getSecurityLevelColor(widget.overview.currentSecurityLevel),
                opacity: DesignTokens.shadowOpacityLight,
                blurRadius: DesignTokens.blurRadiusM,
              ),
            ],
          ),
          child: Icon(
            Icons.security_rounded,
            color: _getSecurityLevelColor(widget.overview.currentSecurityLevel),
            size: DesignTokens.iconSizeL,
          ),
        ),
        const SizedBox(width: DesignTokens.spacing4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de Seguridad',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: DesignTokens.fontWeightBold,
                  color: colorScheme.onSurface,
                  fontSize: DesignTokens.fontSizeXL,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing1),
              Container(
                padding: DesignTokens.paddingVerticalXS.add(DesignTokens.paddingHorizontalS),
                decoration: BoxDecoration(
                  color: _getSecurityLevelColor(widget.overview.currentSecurityLevel).withValues(alpha: 0.1),
                  borderRadius: DesignTokens.radiusS,
                  border: Border.all(
                    color: _getSecurityLevelColor(widget.overview.currentSecurityLevel).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Nivel: ${widget.overview.currentSecurityLevel.label}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getSecurityLevelColor(widget.overview.currentSecurityLevel),
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    fontSize: DesignTokens.fontSizeS,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid() {
    return AnimatedBuilder(
      animation: _statsController,
      builder: (context, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: DesignTokens.spacing4,
          crossAxisSpacing: DesignTokens.spacing4,
          children: [
            _EnhancedStatisticItem(
              icon: Icons.warning_rounded,
              label: 'Incidentes Totales',
              value: widget.overview.totalIncidents.toString(),
              color: Colors.orange,
              animationDelay: Duration.zero,
              controller: _statsController,
            ),
            _EnhancedStatisticItem(
              icon: Icons.notifications_active_rounded,
              label: 'Alertas Activas',
              value: widget.overview.activeAlerts.toString(),
              color: Colors.red,
              animationDelay: const Duration(milliseconds: 100),
              controller: _statsController,
            ),
            _EnhancedStatisticItem(
              icon: Icons.shield_rounded,
              label: 'Rutas Seguras',
              value: widget.overview.safeRoutes.toString(),
              color: Colors.green,
              animationDelay: const Duration(milliseconds: 200),
              controller: _statsController,
            ),
            _EnhancedStatisticItem(
              icon: Icons.dangerous_rounded,
              label: 'Áreas de Riesgo',
              value: widget.overview.riskAreas.toString(),
              color: Colors.red[700]!,
              animationDelay: const Duration(milliseconds: 300),
              controller: _statsController,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRiskScore(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: DesignTokens.spacingL,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: DesignTokens.radiusM,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puntuación de Riesgo Promedio',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: DesignTokens.fontWeightSemiBold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: DesignTokens.radiusS,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.overview.avgRiskScore / 10.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRiskScoreColor(widget.overview.avgRiskScore),
                      _getRiskScoreColor(widget.overview.avgRiskScore).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: DesignTokens.radiusS,
                  boxShadow: [
                    ShadowTokens.createShadow(
                      color: _getRiskScoreColor(widget.overview.avgRiskScore),
                      opacity: DesignTokens.shadowOpacityLight,
                      blurRadius: DesignTokens.blurRadiusS,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            '${widget.overview.avgRiskScore.toStringAsFixed(1)}/10.0',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _getRiskScoreColor(widget.overview.avgRiskScore),
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementIndicator(ThemeData theme, ColorScheme colorScheme) {
    final isImproving = widget.overview.improvementPercentage >= 0;
    final color = isImproving ? Colors.green : Colors.red;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Show detailed improvement info
      },
      child: Container(
        padding: DesignTokens.spacingL,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: DesignTokens.radiusM,
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            ShadowTokens.createShadow(
              color: color,
              opacity: DesignTokens.shadowOpacityLight,
              blurRadius: DesignTokens.blurRadiusS,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: DesignTokens.spacingS,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: DesignTokens.radiusS,
              ),
              child: Icon(
                isImproving ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: color,
                size: DesignTokens.iconSizeM,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isImproving ? '+' : ''}${widget.overview.improvementPercentage.toStringAsFixed(1)}% ${widget.overview.improvementPeriod}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: DesignTokens.fontWeightBold,
                      fontSize: DesignTokens.fontSizeM,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing1 / 2),
                  Text(
                    isImproving 
                        ? 'Mejora en la seguridad general'
                        : 'Deterioro en la seguridad general',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: DesignTokens.fontSizeS,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.info_outline_rounded,
              color: color,
              size: DesignTokens.iconSizeS,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSecurityLevelColor(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.veryLow:
      case SecurityLevel.low:
        return Colors.green;
      case SecurityLevel.moderate:
        return Colors.orange;
      case SecurityLevel.high:
      case SecurityLevel.veryHigh:
        return Colors.red;
      case SecurityLevel.critical:
        return Colors.red[900]!;
    }
  }

  Color _getRiskScoreColor(double score) {
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }
}

class _EnhancedStatisticItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Duration animationDelay;
  final AnimationController controller;

  const _EnhancedStatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.animationDelay,
    required this.controller,
  });

  @override
  State<_EnhancedStatisticItem> createState() => _EnhancedStatisticItemState();
}

class _EnhancedStatisticItemState extends State<_EnhancedStatisticItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _localController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _localController = AnimationController(
      duration: DesignTokens.animationDurationSlow,
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
                // Show detailed stats
              },
              child: Container(
                padding: DesignTokens.spacingL,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.15),
                      widget.color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: DesignTokens.radiusM,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    ShadowTokens.createShadow(
                      color: widget.color,
                      opacity: DesignTokens.shadowOpacityLight,
                      blurRadius: DesignTokens.blurRadiusS,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: DesignTokens.spacingS,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.2),
                        borderRadius: DesignTokens.radiusS,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: DesignTokens.iconSizeM,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.value,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: DesignTokens.fontWeightBold,
                              color: widget.color,
                              fontSize: DesignTokens.fontSizeXL,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing1 / 2),
                          Text(
                            widget.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: DesignTokens.fontWeightMedium,
                              fontSize: DesignTokens.fontSizeXS,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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