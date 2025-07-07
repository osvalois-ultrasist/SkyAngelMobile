import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// Tema especializado para headers de la aplicación
class HeaderTheme {
  static const Map<HeaderType, _HeaderStyle> _styles = {
    HeaderType.primary: _HeaderStyle(
      gradientColors: [Color(0xFF2196F3), Color(0xFF1976D2)],
      onSurfaceColor: Colors.white,
      overlayStyle: SystemUiOverlayStyle.light,
      elevation: 2.0,
    ),
    HeaderType.secondary: _HeaderStyle(
      gradientColors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      onSurfaceColor: Colors.white,
      overlayStyle: SystemUiOverlayStyle.light,
      elevation: 2.0,
    ),
    HeaderType.surface: _HeaderStyle(
      gradientColors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
      onSurfaceColor: Color(0xFF212121),
      overlayStyle: SystemUiOverlayStyle.dark,
      elevation: 1.0,
    ),
    HeaderType.warning: _HeaderStyle(
      gradientColors: [Color(0xFFFF9800), Color(0xFFF57C00)],
      onSurfaceColor: Colors.white,
      overlayStyle: SystemUiOverlayStyle.light,
      elevation: 2.0,
    ),
    HeaderType.error: _HeaderStyle(
      gradientColors: [Color(0xFFF44336), Color(0xFFD32F2F)],
      onSurfaceColor: Colors.white,
      overlayStyle: SystemUiOverlayStyle.light,
      elevation: 2.0,
    ),
  };

  static AppHeaderTheme getTheme(
    BuildContext context, 
    HeaderType type, {
    Color? customBackgroundColor,
    bool isDarkMode = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = _styles[type] ?? _styles[HeaderType.primary]!;
    
    // Adjust colors for dark mode
    final gradientColors = isDarkMode 
        ? _getDarkModeGradient(style.gradientColors)
        : style.gradientColors;
    
    final onSurfaceColor = isDarkMode 
        ? _getDarkModeTextColor(type)
        : style.onSurfaceColor;

    return AppHeaderTheme(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: customBackgroundColor != null 
            ? [customBackgroundColor, customBackgroundColor.withOpacity(0.9)]
            : gradientColors,
        stops: const [0.0, 1.0],
      ),
      onSurfaceColor: onSurfaceColor,
      primaryColor: gradientColors.first,
      shadowColor: colorScheme.shadow,
      systemOverlayStyle: isDarkMode 
          ? SystemUiOverlayStyle.light 
          : style.overlayStyle,
      elevation: style.elevation,
      borderColor: onSurfaceColor.withOpacity(0.1),
    );
  }

  static List<Color> _getDarkModeGradient(List<Color> lightGradient) {
    return lightGradient.map((color) {
      final hsl = HSLColor.fromColor(color);
      return hsl.withLightness((hsl.lightness * 0.3).clamp(0.0, 1.0)).toColor();
    }).toList();
  }

  static Color _getDarkModeTextColor(HeaderType type) {
    switch (type) {
      case HeaderType.surface:
        return Colors.white70;
      default:
        return Colors.white;
    }
  }
}

class AppHeaderTheme {
  final Gradient gradient;
  final Color onSurfaceColor;
  final Color primaryColor;
  final Color shadowColor;
  final SystemUiOverlayStyle systemOverlayStyle;
  final double elevation;
  final Color borderColor;

  const AppHeaderTheme({
    required this.gradient,
    required this.onSurfaceColor,
    required this.primaryColor,
    required this.shadowColor,
    required this.systemOverlayStyle,
    required this.elevation,
    required this.borderColor,
  });
}

class _HeaderStyle {
  final List<Color> gradientColors;
  final Color onSurfaceColor;
  final SystemUiOverlayStyle overlayStyle;
  final double elevation;

  const _HeaderStyle({
    required this.gradientColors,
    required this.onSurfaceColor,
    required this.overlayStyle,
    required this.elevation,
  });
}

enum HeaderType {
  primary,
  secondary,
  surface,
  warning,
  error,
}