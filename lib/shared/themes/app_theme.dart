import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/preferences_storage.dart';
import '../../core/di/injection.dart';

class AppTheme {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  const AppTheme({
    required this.lightTheme,
    required this.darkTheme,
    required this.themeMode,
  });

  AppTheme copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
  }) {
    return AppTheme(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

final appThemeProvider = StateNotifierProvider<AppThemeNotifier, AppTheme>((ref) {
  return AppThemeNotifier();
});

class AppThemeNotifier extends StateNotifier<AppTheme> {
  late final PreferencesStorage _preferencesStorage;

  AppThemeNotifier() : super(_createDefaultTheme()) {
    _preferencesStorage = locate<PreferencesStorage>();
    _loadThemeFromPreferences();
  }

  static AppTheme _createDefaultTheme() {
    return AppTheme(
      lightTheme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
    );
  }

  void _loadThemeFromPreferences() {
    final themeModeString = _preferencesStorage.getThemeMode();
    final themeMode = _parseThemeMode(themeModeString);
    
    state = state.copyWith(themeMode: themeMode);
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _preferencesStorage.setThemeMode(themeMode.name);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> updateWithDynamicColors(ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) async {
    state = AppTheme(
      lightTheme: _buildLightTheme(colorScheme: lightColorScheme),
      darkTheme: _buildDarkTheme(colorScheme: darkColorScheme),
      themeMode: state.themeMode,
    );
  }

  static ThemeData _buildLightTheme({ColorScheme? colorScheme}) {
    final baseColorScheme = colorScheme ?? const ColorScheme.light(
      primary: Color(0xFF1976D2),
      primaryContainer: Color(0xFFBBDEFB),
      secondary: Color(0xFF424242),
      secondaryContainer: Color(0xFFE0E0E0),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFFAFAFA),
      error: Color(0xFFD32F2F),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1C1C1C),
      onBackground: Color(0xFF1C1C1C),
      onError: Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: baseColorScheme.surface,
        foregroundColor: baseColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: baseColorScheme.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        color: baseColorScheme.surface,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: baseColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColorScheme.primary,
          foregroundColor: baseColorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: baseColorScheme.primary,
          side: BorderSide(color: baseColorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: baseColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: baseColorScheme.primary,
        foregroundColor: baseColorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: baseColorScheme.surface,
        selectedItemColor: baseColorScheme.primary,
        unselectedItemColor: baseColorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: baseColorScheme.surface,
        selectedColor: baseColorScheme.primaryContainer,
        disabledColor: baseColorScheme.surface.withOpacity(0.5),
        labelStyle: TextStyle(
          color: baseColorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: baseColorScheme.onPrimaryContainer,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: baseColorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: baseColorScheme.onInverseSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: baseColorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: baseColorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: baseColorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: baseColorScheme.onSurface,
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: baseColorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return baseColorScheme.primary;
          }
          return baseColorScheme.outline;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return baseColorScheme.primary.withOpacity(0.5);
          }
          return baseColorScheme.outline.withOpacity(0.3);
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return baseColorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(baseColorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return baseColorScheme.primary;
          }
          return baseColorScheme.outline;
        }),
      ),
    );
  }

  static ThemeData _buildDarkTheme({ColorScheme? colorScheme}) {
    final baseColorScheme = colorScheme ?? const ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      primaryContainer: Color(0xFF1565C0),
      secondary: Color(0xFFBDBDBD),
      secondaryContainer: Color(0xFF424242),
      surface: Color(0xFF121212),
      background: Color(0xFF0A0A0A),
      error: Color(0xFFEF5350),
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFFE0E0E0),
      onBackground: Color(0xFFE0E0E0),
      onError: Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: baseColorScheme.surface,
        foregroundColor: baseColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: baseColorScheme.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        color: baseColorScheme.surface,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: baseColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: baseColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Similar theme configurations as light theme but adapted for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColorScheme.primary,
          foregroundColor: baseColorScheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Continue with other theme configurations...
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: baseColorScheme.primary,
        foregroundColor: baseColorScheme.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: baseColorScheme.surface,
        selectedItemColor: baseColorScheme.primary,
        unselectedItemColor: baseColorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// Custom color extensions
extension AppColors on ColorScheme {
  Color get success => brightness == Brightness.light 
      ? const Color(0xFF4CAF50) 
      : const Color(0xFF81C784);
      
  Color get warning => brightness == Brightness.light 
      ? const Color(0xFFFF9800) 
      : const Color(0xFFFFB74D);
      
  Color get info => brightness == Brightness.light 
      ? const Color(0xFF2196F3) 
      : const Color(0xFF64B5F6);
      
  Color get onSuccess => brightness == Brightness.light 
      ? Colors.white 
      : Colors.black;
      
  Color get onWarning => brightness == Brightness.light 
      ? Colors.white 
      : Colors.black;
      
  Color get onInfo => brightness == Brightness.light 
      ? Colors.white 
      : Colors.black;

  // Risk level colors
  Color get riskLow => success;
  Color get riskMedium => warning;
  Color get riskHigh => const Color(0xFFFF5722);
  Color get riskCritical => error;
}

// Text style extensions
extension AppTextStyles on TextTheme {
  TextStyle get h1 => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  TextStyle get h2 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  TextStyle get h3 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  TextStyle get h4 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  TextStyle get h5 => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  TextStyle get h6 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  TextStyle get body1 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  TextStyle get body2 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  TextStyle get overline => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 1.5,
  );
}