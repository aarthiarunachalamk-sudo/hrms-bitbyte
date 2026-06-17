import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeepOceanTheme {
  // Brand Colors (Light Theme styled according to Mockup)
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF1F5F9);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFFFFFFF); // White cards
  static const Color surfaceContainerHigh = Color(0xFFF1F5F9);
  static const Color surfaceContainerHighest = Color(0xFFE2E8F0); // For progress bar background
  
  static const Color primary = Color(0xFF0284C7); // Corporate Accent Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE0F2FE); // Soft light blue capsule background
  static const Color onPrimaryContainer = Color(0xFF0369A1); // Dark blue text for active capsule
  
  static const Color secondary = Color(0xFF0077B6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF0F9FF);
  static const Color onSecondaryContainer = Color(0xFF0077B6);
  
  static const Color tertiary = Color(0xFF0EA5E9);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFE0F2FE);
  static const Color onTertiaryContainer = Color(0xFF0369A1);
  
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFFEF4444);

  static const Color onSurface = Color(0xFF0F172A); // Dark Slate/Navy for titles
  static const Color onSurfaceVariant = Color(0xFF64748B); // Slate Gray for subtitles/inactive items
  static const Color outline = Color(0xFFE2E8F0); // Soft outline
  static const Color outlineVariant = Color(0xFFF1F5F9);

  // Spacing constants based on 8px scale
  static const double spacingBase = 8.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double gutter = 16.0;
  static const double margin = 24.0;

  // Shapes & Corner Radii
  static final BorderRadius roundedSm = BorderRadius.circular(4.0);
  static final BorderRadius roundedDefault = BorderRadius.circular(8.0);
  static final BorderRadius roundedMd = BorderRadius.circular(12.0);
  static final BorderRadius roundedLg = BorderRadius.circular(16.0);
  static final BorderRadius roundedXl = BorderRadius.circular(24.0);
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(9999.0));

  // Light Theme Configuration (Matches Mockup)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        surface: surface,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
          color: onSurface,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 26 / 18,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: onSurfaceVariant,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 16 / 11,
          color: onSurfaceVariant,
        ),
      ),
      canvasColor: background,
      cardColor: surfaceContainer,
      dialogBackgroundColor: surfaceContainer,
      dividerColor: outlineVariant,
      indicatorColor: primary,
      splashColor: primary.withOpacity(0.12),
      hoverColor: primary.withOpacity(0.08),
      focusColor: primary.withOpacity(0.18),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
      ),
    );
  }

  // Dark Theme Configuration (Original Deep Ocean colors)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF12131C),
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF12131C),
        surfaceContainerHighest: Color(0xFF1F1F28),
        primary: Color(0xFF7AD0FF),
        onPrimary: Color(0xFF003549),
        primaryContainer: Color(0xFF004C68),
        onPrimaryContainer: Color(0xFFC3E8FF),
        secondary: Color(0xFF8FCEF3),
        onSecondary: Color(0xFF003549),
        secondaryContainer: Color(0xFF004C68),
        onSecondaryContainer: Color(0xFFC3E8FF),
        tertiary: Color(0xFFC0C1FF),
        onTertiary: Color(0xFF292A60),
        tertiaryContainer: Color(0xFF3F4178),
        onTertiaryContainer: Color(0xFFE1E0FF),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        onSurface: Color(0xFFE3E1EF),
        onSurfaceVariant: Color(0xFFC5C4DD),
        outline: Color(0xFF8F8FA5),
        outlineVariant: Color(0xFF454559),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
          color: const Color(0xFFE3E1EF),
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
          color: const Color(0xFFE3E1EF),
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 26 / 18,
          color: const Color(0xFFE3E1EF),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: const Color(0xFFC5C4DD),
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: const Color(0xFFE3E1EF),
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 16 / 11,
          color: const Color(0xFFC5C4DD),
        ),
      ),
      canvasColor: const Color(0xFF12131C),
      cardColor: const Color(0xFF1F1F28),
      dialogBackgroundColor: const Color(0xFF1F1F28),
      dividerColor: const Color(0xFF454559),
      indicatorColor: const Color(0xFF7AD0FF),
      splashColor: const Color(0xFF7AD0FF).withOpacity(0.12),
      hoverColor: const Color(0xFF7AD0FF).withOpacity(0.08),
      focusColor: const Color(0xFF7AD0FF).withOpacity(0.18),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFE3E1EF)),
      ),
    );
  }
}
