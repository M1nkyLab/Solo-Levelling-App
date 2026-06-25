import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  Shadow Monarch Color Palette
// ─────────────────────────────────────────────
class ShadowColors {
  ShadowColors._();

  // Backgrounds - Absolute Obsidian
  static const Color obsidian = Color(0xFF000000);       // Pure Black
  static const Color voidDark  = Color(0xFF050505);      // Slightly elevated black
  static const Color surface   = Color(0xFF0A0A0A);      // Rigid panel base
  static const Color surfaceAlt= Color(0xFF121212);      // Elevated panel layer

  // System Borders (High Intensity, Minimalist)
  static const Color systemBorder    = Color(0xFF1A1A1A); // Standard rigid border
  static const Color systemGlow      = Color(0x338A2BE2); // Very subtle amethyst glow
  static const Color portalBlueBorder = Color(0xFF00B4FF); // Sharp portal blue
  static const Color glassBorder     = Color(0xFFFFFFFF); // Glassmorphic highlight

  // Accents - Pure Magical Energy
  static const Color amethyst       = Color(0xFF8A2BE2); // Monarch Purple
  static const Color amethystLight  = Color(0xFFAB5CF7); // High-frequency energy
  static const Color portalBlue     = Color(0xFF00B4FF); // System Portal Blue
  static const Color mpBlue         = Color(0xFF007BFF); // System MP Blue

  // Text - High Contrast
  static const Color textPrimary    = Color(0xFFFFFFFF); // Pure White for edicts
  static const Color textSecondary  = Color(0xFFAAAAAA); // Muted grey for system logs
  static const Color textDisabled   = Color(0xFF444444); // Inactive protocols

  // Status
  static const Color hpRed          = Color(0xFFFF0000); // Critical Health
  static const Color success        = Color(0xFF00FF44); // System Success
  static const Color warning        = Color(0xFFFFCC00); // System Warning
  static const Color xpGold         = Color(0xFFFFD700); // System Reward

  // Penalty Zone Colors
  static const Color penaltyRed     = Color(0xFFFF0033); // Neon crimson for penalty
  static const Color penaltyBgLight = Color(0xFF220000); // Penalty overlay box
  static const Color penaltyBgDark  = Color(0xFF110000); // Penalty base bg
  static const Color penaltyBorder  = Color(0x66FF0033); // Faded crimson border

  // Custom transparent background
  static Color get blackTransparent => Colors.black.withValues(alpha: 0.9);

  // System Shadows (Rigid & Subtle)
  static List<BoxShadow> get systemPanelShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get weightlessShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];
}

// ─────────────────────────────────────────────
//  Shadow Monarch Typography (Fantasy + System)
// ─────────────────────────────────────────────
class ShadowTextTheme {
  ShadowTextTheme._();

  // Standard system font for edicts and headers
  static TextStyle get _cinzelBase => GoogleFonts.cinzel(
    color: ShadowColors.textPrimary,
    letterSpacing: 2.0,
    fontWeight: FontWeight.bold,
  );

  // Standard system font for stats & logs
  static TextStyle get _rajdhaniBase => GoogleFonts.rajdhani(
    color: ShadowColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle headline(double size, {Color? color, FontWeight weight = FontWeight.bold, double? letterSpacing}) =>
      _cinzelBase.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.normal, double? letterSpacing}) =>
      _rajdhaniBase.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle body(double size, {Color? color, FontWeight? weight, bool italic = false, double? letterSpacing, double? height}) =>
      _rajdhaniBase.copyWith(
        fontSize: size,
        color: color ?? ShadowColors.textSecondary,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: letterSpacing,
        height: height,
      );
}

// ─────────────────────────────────────────────
//  Shadow Monarch ThemeData (Rigid System)
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get shadowMonarch {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary:          ShadowColors.amethyst,
        onPrimary:        ShadowColors.textPrimary,
        secondary:        ShadowColors.portalBlue,
        onSecondary:      ShadowColors.obsidian,
        surface:          ShadowColors.surface,
        onSurface:        ShadowColors.textPrimary,
        error:            ShadowColors.hpRed,
        onError:          ShadowColors.textPrimary,
        surfaceContainerHighest: ShadowColors.surfaceAlt,
      ),

      scaffoldBackgroundColor: ShadowColors.obsidian,

      appBarTheme: AppBarTheme(
        backgroundColor: ShadowColors.obsidian,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ShadowTextTheme.headline(20),
        iconTheme: const IconThemeData(color: ShadowColors.amethyst),
      ),

      // Cards – Sharp, Rigid Panels
      cardTheme: CardThemeData(
        color: ShadowColors.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2), // Sharp Corners
          side: const BorderSide(color: ShadowColors.systemBorder, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: ShadowColors.systemBorder,
        thickness: 1,
        space: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShadowColors.amethyst,
          foregroundColor: ShadowColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: ShadowTextTheme.mono(14, weight: FontWeight.bold, letterSpacing: 2),
        ),
      ),

      iconTheme: const IconThemeData(color: ShadowColors.amethyst, size: 24),

      textTheme: TextTheme(
        displayLarge:  ShadowTextTheme.headline(57),
        displayMedium: ShadowTextTheme.headline(45),
        displaySmall:  ShadowTextTheme.headline(36),
        headlineLarge: ShadowTextTheme.headline(32),
        headlineMedium:ShadowTextTheme.headline(28),
        headlineSmall: ShadowTextTheme.headline(24),
        titleLarge:    ShadowTextTheme.headline(22),
        titleMedium:   ShadowTextTheme.headline(16, weight: FontWeight.w600),
        titleSmall:    ShadowTextTheme.headline(14, weight: FontWeight.w500),
        bodyLarge:  ShadowTextTheme.body(16, color: ShadowColors.textPrimary),
        bodyMedium: ShadowTextTheme.body(14),
        bodySmall:  ShadowTextTheme.body(12),
        labelLarge:  ShadowTextTheme.mono(14, weight: FontWeight.bold, letterSpacing: 1),
        labelMedium: ShadowTextTheme.mono(12),
        labelSmall:  ShadowTextTheme.mono(10, color: ShadowColors.textSecondary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShadowColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: ShadowColors.systemBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: ShadowColors.amethyst, width: 1.5),
        ),
        labelStyle: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
        hintStyle: ShadowTextTheme.body(14, color: ShadowColors.textDisabled),
      ),
    );
  }
}
