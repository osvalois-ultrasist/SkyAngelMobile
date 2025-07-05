import 'package:flutter/material.dart';

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
        return theme.colorScheme.error;
      case AppBarType.surface:
        return theme.colorScheme.surfaceVariant;
    }
  }
}

/// Tipos de AppBar para diferentes contextos
enum AppBarType {
  primary,    // Para páginas principales como Dashboard, Profile
  secondary,  // Para páginas de navegación como Maps
  tertiary,   // Para páginas de acción como Routes
  error,      // Para páginas de alertas
  surface,    // Para páginas neutrales
}