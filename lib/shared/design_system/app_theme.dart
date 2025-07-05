import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Tema unificado de la aplicación basado en Material Design 3
/// Implementa el sistema de tokens de diseño para consistencia visual
class AppTheme {
  AppTheme._();

  /// Tema claro de la aplicación
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme basado en Material Design 3
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Indigo primary
      brightness: Brightness.light,
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF10B981), // Emerald
      tertiary: const Color(0xFF8B5CF6), // Violet
      error: const Color(0xFFEF4444), // Red
      surface: Colors.white,
      background: const Color(0xFFFAFAFA),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1F2937),
      elevation: DesignTokens.elevationS,
      surfaceTintColor: const Color(0xFF6366F1),
      shadowColor: Colors.black.withOpacity(DesignTokens.shadowOpacityLight),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppBarTokens.titleFontSize,
        fontWeight: AppBarTokens.titleFontWeight,
        letterSpacing: AppBarTokens.titleLetterSpacing,
        color: const Color(0xFF1F2937),
      ),
      toolbarHeight: kToolbarHeight,
      scrolledUnderElevation: DesignTokens.elevationM,
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: DesignTokens.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.radiusM,
      ),
      margin: DesignTokens.spacingL,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: DesignTokens.elevationS,
        padding: DesignTokens.spacingL,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusM,
        ),
        textStyle: const TextStyle(
          fontWeight: DesignTokens.fontWeightSemiBold,
          fontSize: DesignTokens.fontSizeL,
          letterSpacing: DesignTokens.letterSpacingRelaxed,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: DesignTokens.spacingL,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusM,
        ),
        textStyle: const TextStyle(
          fontWeight: DesignTokens.fontWeightSemiBold,
          fontSize: DesignTokens.fontSizeL,
          letterSpacing: DesignTokens.letterSpacingRelaxed,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: DesignTokens.spacingL,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusM,
        ),
        textStyle: const TextStyle(
          fontWeight: DesignTokens.fontWeightSemiBold,
          fontSize: DesignTokens.fontSizeL,
          letterSpacing: DesignTokens.letterSpacingRelaxed,
        ),
      ),
    ),

    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        iconSize: DesignTokens.iconSizeL,
        padding: DesignTokens.spacingS,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: DesignTokens.radiusM,
      ),
      contentPadding: DesignTokens.spacingL,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      padding: DesignTokens.spacingS,
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.radiusM,
      ),
      elevation: DesignTokens.elevationXS,
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.radiusL,
      ),
      elevation: DesignTokens.elevationXL,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: DesignTokens.elevationM,
      selectedItemColor: Color(0xFF6366F1),
      unselectedItemColor: Color(0xFF6B7280),
      selectedLabelStyle: TextStyle(
        fontWeight: DesignTokens.fontWeightSemiBold,
        fontSize: DesignTokens.fontSizeS,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: DesignTokens.fontWeightMedium,
        fontSize: DesignTokens.fontSizeS,
      ),
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelColor: const Color(0xFF6366F1),
      unselectedLabelColor: const Color(0xFF6B7280),
      labelStyle: const TextStyle(
        fontWeight: DesignTokens.fontWeightSemiBold,
        fontSize: DesignTokens.fontSizeM,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: DesignTokens.fontWeightMedium,
        fontSize: DesignTokens.fontSizeM,
      ),
      indicator: BoxDecoration(
        borderRadius: DesignTokens.radiusS,
        color: const Color(0xFF6366F1).withOpacity(0.1),
      ),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: DesignTokens.elevationM,
      shape: CircleBorder(),
      iconSize: DesignTokens.iconSizeL,
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: DesignTokens.fontSizeGigantic,
        fontWeight: DesignTokens.fontWeightBold,
        letterSpacing: DesignTokens.letterSpacingTight,
      ),
      displayMedium: TextStyle(
        fontSize: DesignTokens.fontSizeHuge,
        fontWeight: DesignTokens.fontWeightBold,
        letterSpacing: DesignTokens.letterSpacingNormal,
      ),
      displaySmall: TextStyle(
        fontSize: DesignTokens.fontSizeXXXL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        letterSpacing: DesignTokens.letterSpacingNormal,
      ),
      headlineLarge: TextStyle(
        fontSize: DesignTokens.fontSizeXXL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      headlineMedium: TextStyle(
        fontSize: DesignTokens.fontSizeXL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      headlineSmall: TextStyle(
        fontSize: DesignTokens.fontSizeL,
        fontWeight: DesignTokens.fontWeightMedium,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      titleLarge: TextStyle(
        fontSize: DesignTokens.fontSizeL,
        fontWeight: DesignTokens.fontWeightMedium,
        letterSpacing: DesignTokens.letterSpacingNormal,
      ),
      titleMedium: TextStyle(
        fontSize: DesignTokens.fontSizeM,
        fontWeight: DesignTokens.fontWeightMedium,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      titleSmall: TextStyle(
        fontSize: DesignTokens.fontSizeS,
        fontWeight: DesignTokens.fontWeightMedium,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      bodyLarge: TextStyle(
        fontSize: DesignTokens.fontSizeL,
        fontWeight: DesignTokens.fontWeightRegular,
        letterSpacing: DesignTokens.letterSpacingNormal,
      ),
      bodyMedium: TextStyle(
        fontSize: DesignTokens.fontSizeM,
        fontWeight: DesignTokens.fontWeightRegular,
        letterSpacing: DesignTokens.letterSpacingNormal,
      ),
      bodySmall: TextStyle(
        fontSize: DesignTokens.fontSizeS,
        fontWeight: DesignTokens.fontWeightRegular,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      labelLarge: TextStyle(
        fontSize: DesignTokens.fontSizeM,
        fontWeight: DesignTokens.fontWeightMedium,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      labelMedium: TextStyle(
        fontSize: DesignTokens.fontSizeS,
        fontWeight: DesignTokens.fontWeightMedium,
        letterSpacing: DesignTokens.letterSpacingRelaxed,
      ),
      labelSmall: TextStyle(
        fontSize: DesignTokens.fontSizeXS,
        fontWeight: DesignTokens.fontWeightMedium,
        letterSpacing: DesignTokens.letterSpacingLoose,
      ),
    ),
  );

  /// Tema oscuro de la aplicación
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme basado en Material Design 3
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8),
      secondary: const Color(0xFF34D399),
      tertiary: const Color(0xFFA78BFA),
      error: const Color(0xFFF87171),
      surface: const Color(0xFF1F2937),
      background: const Color(0xFF111827),
    ),

    // AppBar Theme para modo oscuro
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1F2937),
      foregroundColor: const Color(0xFFF9FAFB),
      elevation: DesignTokens.elevationS,
      surfaceTintColor: const Color(0xFF818CF8),
      shadowColor: Colors.black.withOpacity(DesignTokens.shadowOpacityMedium),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppBarTokens.titleFontSize,
        fontWeight: AppBarTokens.titleFontWeight,
        letterSpacing: AppBarTokens.titleLetterSpacing,
        color: const Color(0xFFF9FAFB),
      ),
      toolbarHeight: kToolbarHeight,
      scrolledUnderElevation: DesignTokens.elevationM,
    ),

    // Card Theme para modo oscuro
    cardTheme: CardTheme(
      elevation: DesignTokens.elevationS,
      color: const Color(0xFF374151),
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.radiusM,
      ),
      margin: DesignTokens.spacingL,
    ),

    // Bottom Navigation Bar Theme para modo oscuro
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: DesignTokens.elevationM,
      backgroundColor: Color(0xFF1F2937),
      selectedItemColor: Color(0xFF818CF8),
      unselectedItemColor: Color(0xFF9CA3AF),
      selectedLabelStyle: TextStyle(
        fontWeight: DesignTokens.fontWeightSemiBold,
        fontSize: DesignTokens.fontSizeS,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: DesignTokens.fontWeightMedium,
        fontSize: DesignTokens.fontSizeS,
      ),
    ),
  );
}

/// Extensión para obtener colores semánticos
extension AppColors on ColorScheme {
  /// Color para elementos de éxito
  Color get success => brightness == Brightness.light 
    ? const Color(0xFF10B981) 
    : const Color(0xFF34D399);

  /// Color para elementos de advertencia
  Color get warning => brightness == Brightness.light 
    ? const Color(0xFFF59E0B) 
    : const Color(0xFFFBBF24);

  /// Color para elementos informativos
  Color get info => brightness == Brightness.light 
    ? const Color(0xFF3B82F6) 
    : const Color(0xFF60A5FA);

  /// Color para superficies elevadas
  Color get surfaceElevated => brightness == Brightness.light 
    ? Colors.white 
    : const Color(0xFF374151);

  /// Color para bordes
  Color get border => brightness == Brightness.light 
    ? const Color(0xFFE5E7EB) 
    : const Color(0xFF4B5563);

  /// Color para texto secundario
  Color get textSecondary => brightness == Brightness.light 
    ? const Color(0xFF6B7280) 
    : const Color(0xFF9CA3AF);

  /// Color para fondos de contenedores
  Color get containerBackground => brightness == Brightness.light 
    ? const Color(0xFFF9FAFB) 
    : const Color(0xFF1F2937);
}