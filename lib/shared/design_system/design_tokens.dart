import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design Tokens para el sistema de diseño unificado de SkyAngel
/// Basado en Material Design 3 y mejores prácticas de UX/UI
class DesignTokens {
  DesignTokens._();

  // SPACING TOKENS
  static const EdgeInsets spacingNone = EdgeInsets.zero;
  static const EdgeInsets spacingXS = EdgeInsets.all(4.0);
  static const EdgeInsets spacingS = EdgeInsets.all(8.0);
  static const EdgeInsets spacingM = EdgeInsets.all(12.0);
  static const EdgeInsets spacingL = EdgeInsets.all(16.0);
  static const EdgeInsets spacingXL = EdgeInsets.all(20.0);
  static const EdgeInsets spacingXXL = EdgeInsets.all(24.0);
  static const EdgeInsets spacingXXXL = EdgeInsets.all(32.0);

  // SIMPLE SPACING VALUES
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;

  // PADDING VERTICAL TOKENS
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: 2.0);
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: 4.0);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: 16.0);

  // PADDING HORIZONTAL TOKENS
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: 2.0);
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: 4.0);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: 16.0);

  // BORDER RADIUS TOKENS
  static const BorderRadius radiusNone = BorderRadius.zero;
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius radiusS = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius radiusM = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius radiusL = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(20.0));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(24.0));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(100.0));

  // ELEVATION TOKENS
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 6.0;
  static const double elevationXL = 8.0;
  static const double elevationXXL = 12.0;
  static const double elevationXXXL = 16.0;

  // ICON SIZE TOKENS
  static const double iconSizeXS = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 28.0;
  static const double iconSizeXXL = 32.0;
  static const double iconSizeXXXL = 40.0;
  static const double iconSizeHuge = 48.0;

  // TYPOGRAPHY TOKENS
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 22.0;
  static const double fontSizeHuge = 24.0;
  static const double fontSizeGigantic = 28.0;

  // FONT WEIGHT TOKENS
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;
  static const FontWeight fontWeightBlack = FontWeight.w900;

  // LETTER SPACING TOKENS
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingRelaxed = 0.25;
  static const double letterSpacingLoose = 0.5;
  static const double letterSpacingExtraLoose = 1.0;

  // OPACITY TOKENS
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // CONTAINER BACKGROUND OPACITY
  static const double backgroundOpacityLight = 0.08;
  static const double backgroundOpacityMedium = 0.12;
  static const double backgroundOpacityStrong = 0.16;
  static const double backgroundOpacityDense = 0.20;

  // SHADOW OPACITY
  static const double shadowOpacityLight = 0.10;
  static const double shadowOpacityMedium = 0.15;
  static const double shadowOpacityStrong = 0.20;
  static const double shadowOpacityDense = 0.25;

  // ANIMATION DURATION TOKENS
  static const Duration animationDurationQuick = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 250);
  static const Duration animationDurationSlow = Duration(milliseconds: 350);
  static const Duration animationDurationExtraSlow = Duration(milliseconds: 500);

  // SHADOW OFFSET TOKENS
  static const Offset shadowOffsetS = Offset(0, 1);
  static const Offset shadowOffsetM = Offset(0, 2);
  static const Offset shadowOffsetL = Offset(0, 4);
  static const Offset shadowOffsetXL = Offset(0, 6);

  // BLUR RADIUS TOKENS
  static const double blurRadiusS = 2.0;
  static const double blurRadiusM = 4.0;
  static const double blurRadiusL = 8.0;
  static const double blurRadiusXL = 12.0;
  static const double blurRadiusXXL = 16.0;
}

/// Extensión para crear shadows estandarizadas
extension ShadowTokens on DesignTokens {
  static BoxShadow createShadow({
    required Color color,
    double opacity = DesignTokens.shadowOpacityMedium,
    double blurRadius = DesignTokens.blurRadiusL,
    Offset offset = DesignTokens.shadowOffsetM,
  }) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blurRadius,
      offset: offset,
    );
  }

  static List<BoxShadow> createElevatedShadow({
    required Color color,
    double opacity = DesignTokens.shadowOpacityMedium,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity * 0.7),
        blurRadius: DesignTokens.blurRadiusM,
        offset: DesignTokens.shadowOffsetS,
      ),
      BoxShadow(
        color: color.withOpacity(opacity * 0.5),
        blurRadius: DesignTokens.blurRadiusL,
        offset: DesignTokens.shadowOffsetM,
      ),
    ];
  }
}

/// Tokens específicos para AppBar Headers
class AppBarTokens {
  AppBarTokens._();

  // APPBAR SPECIFIC TOKENS
  static const EdgeInsets titleContainerPadding = DesignTokens.paddingVerticalS;
  static const EdgeInsets iconContainerPadding = DesignTokens.spacingM;
  static const BorderRadius iconContainerRadius = DesignTokens.radiusM;
  static const double iconSize = DesignTokens.iconSizeL;
  static const double titleFontSize = DesignTokens.fontSizeXXXL;
  static const FontWeight titleFontWeight = DesignTokens.fontWeightBold;
  static const double titleLetterSpacing = DesignTokens.letterSpacingRelaxed;
  static const double titleSpacing = 16.0;
  static const double appBarElevation = DesignTokens.elevationS;
  static const double backgroundOpacity = DesignTokens.backgroundOpacityMedium;
  static const double shadowOpacity = DesignTokens.shadowOpacityMedium;

  // SEMANTIC COLOR MAPPING
  static Color getSemanticColor(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    switch (type) {
      case AppBarType.primary:
        return theme.colorScheme.primary;
      case AppBarType.secondary:
        return theme.colorScheme.secondary;
      case AppBarType.tertiary:
        return theme.colorScheme.tertiary;
      case AppBarType.error:
      case AppBarType.danger:
        return theme.colorScheme.error;
      case AppBarType.surface:
        return theme.colorScheme.surfaceVariant;
      case AppBarType.success:
        return Colors.green;
      case AppBarType.warning:
        return Colors.orange;
    }
  }

  // APPBAR COLOR METHODS
  static Color getBackgroundColor(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    switch (type) {
      case AppBarType.primary:
      case AppBarType.secondary:
      case AppBarType.tertiary:
      case AppBarType.surface:
        return theme.colorScheme.surface;
      case AppBarType.error:
      case AppBarType.danger:
        return theme.colorScheme.errorContainer;
      case AppBarType.success:
        return Colors.green.withOpacity(0.1);
      case AppBarType.warning:
        return Colors.orange.withOpacity(0.1);
    }
  }

  static Color getForegroundColor(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    switch (type) {
      case AppBarType.primary:
      case AppBarType.secondary:
      case AppBarType.tertiary:
      case AppBarType.surface:
        return theme.colorScheme.onSurface;
      case AppBarType.error:
      case AppBarType.danger:
        return theme.colorScheme.onErrorContainer;
      case AppBarType.success:
        return Colors.green.shade800;
      case AppBarType.warning:
        return Colors.orange.shade800;
    }
  }

  static Color getSurfaceTintColor(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    return theme.colorScheme.surfaceTint;
  }

  static Color getShadowColor(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    return theme.shadowColor;
  }

  // APPBAR STYLE METHODS
  static double getElevation(AppBarType type) {
    return appBarElevation;
  }

  static double getScrolledUnderElevation(AppBarType type) {
    return appBarElevation * 2;
  }

  static double getIconSize(AppBarType type) {
    return iconSize;
  }

  static double getTitleSpacing(AppBarType type) {
    return titleSpacing;
  }

  static TextStyle? getTitleTextStyle(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge?.copyWith(
      fontSize: titleFontSize,
      fontWeight: titleFontWeight,
      letterSpacing: titleLetterSpacing,
      color: getForegroundColor(context, type),
    );
  }

  static TextStyle? getToolbarTextStyle(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(
      color: getForegroundColor(context, type),
    );
  }

  static ShapeBorder? getShape(AppBarType type) {
    return null; // Default shape
  }

  static SystemUiOverlayStyle getSystemOverlayStyle(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }

  static ButtonStyle getIconButtonStyle(BuildContext context, AppBarType type) {
    final theme = Theme.of(context);
    return IconButton.styleFrom(
      foregroundColor: getForegroundColor(context, type),
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.all(8),
    );
  }
}

/// Tipos de AppBar para diferentes contextos
enum AppBarType {
  primary,    // Para páginas principales como Dashboard, Profile
  secondary,  // Para páginas de navegación como Maps
  tertiary,   // Para páginas de acción como Routes
  error,      // Para páginas de alertas
  surface,    // Para páginas neutrales
  danger,     // Para alertas peligrosas
  success,    // Para confirmaciones
  warning,    // Para advertencias
}