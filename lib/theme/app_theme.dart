import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  Shadow Monarch Color Palette
// ─────────────────────────────────────────────
class ShadowColors {
  ShadowColors._();

  // Backgrounds
  static const Color obsidian = Color(0xFF000000);       // True OLED black
  static const Color voidDark  = Color(0xFF0A0A0A);      // Near-black canvas
  static const Color surface   = Color(0xFF111118);      // Card / surface base
  static const Color surfaceAlt= Color(0xFF1A1A26);      // Elevated card layer

  // Accents
  static const Color amethyst       = Color(0xFF8A2BE2); // Primary – glowing purple
  static const Color amethystLight  = Color(0xFFAB5CF7); // Hover / highlight
  static const Color amethystGlow   = Color(0x448A2BE2); // Shadow / glow tint
  static const Color icyCyan        = Color(0xFF00FFFF); // Secondary – mana / MP
  static const Color icyCyanGlow    = Color(0x3300FFFF); // Cyan glow tint

  // Text
  static const Color textPrimary    = Color(0xFFE8E8F0); // Off-white headlines
  static const Color textSecondary  = Color(0xFF8888A8); // Muted body text
  static const Color textDisabled   = Color(0xFF44445A); // Disabled / inactive

  // Status
  static const Color hpRed          = Color(0xFFE53935); // Health bar
  static const Color mpBlue         = icyCyan;           // Mana bar
  static const Color xpGold         = Color(0xFFFFD700); // XP / reward
  static const Color success        = Color(0xFF4CAF50);
  static const Color warning        = Color(0xFFFFA726);
}

// ─────────────────────────────────────────────
//  Shadow Monarch Typography
// ─────────────────────────────────────────────
class ShadowTextTheme {
  ShadowTextTheme._();

  // Orbitron – sharp, aggressive sans-serif for headings
  static TextStyle headline(double size, {FontWeight weight = FontWeight.bold}) =>
      GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: weight,
        color: ShadowColors.textPrimary,
        letterSpacing: 1.5,
      );

  // Roboto Mono – clean monospace for stats & numbers
  static TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: weight,
        color: color ?? ShadowColors.textPrimary,
      );

  // Rajdhani – body text, readable but slightly techy
  static TextStyle body(double size, {Color? color}) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        color: color ?? ShadowColors.textSecondary,
        letterSpacing: 0.5,
      );
}

// ─────────────────────────────────────────────
//  Shadow Monarch ThemeData
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get shadowMonarch {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary:          ShadowColors.amethyst,
        onPrimary:        ShadowColors.textPrimary,
        secondary:        ShadowColors.icyCyan,
        onSecondary:      ShadowColors.obsidian,
        surface:          ShadowColors.surface,
        onSurface:        ShadowColors.textPrimary,
        error:            ShadowColors.hpRed,
        onError:          ShadowColors.textPrimary,
        surfaceContainerHighest: ShadowColors.surfaceAlt,
      ),

      scaffoldBackgroundColor: ShadowColors.voidDark,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: ShadowColors.obsidian,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ShadowTextTheme.headline(18),
        iconTheme: const IconThemeData(color: ShadowColors.amethystLight),
      ),

      // Cards – borderless, shadow-glow only
      cardTheme: CardThemeData(
        color: ShadowColors.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: ShadowColors.surfaceAlt,
        thickness: 1,
        space: 1,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShadowColors.amethyst,
          foregroundColor: ShadowColors.textPrimary,
          elevation: 8,
          shadowColor: ShadowColors.amethystGlow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: ShadowTextTheme.mono(14, weight: FontWeight.bold),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ShadowColors.amethystLight,
          side: const BorderSide(color: ShadowColors.amethyst, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(color: ShadowColors.amethystLight, size: 24),

      // Text theme
      textTheme: TextTheme(
        // Headlines use Cinzel (serif)
        displayLarge:  ShadowTextTheme.headline(57),
        displayMedium: ShadowTextTheme.headline(45),
        displaySmall:  ShadowTextTheme.headline(36),
        headlineLarge: ShadowTextTheme.headline(32),
        headlineMedium:ShadowTextTheme.headline(28),
        headlineSmall: ShadowTextTheme.headline(24),
        titleLarge:    ShadowTextTheme.headline(22),
        titleMedium:   ShadowTextTheme.headline(16, weight: FontWeight.w600),
        titleSmall:    ShadowTextTheme.headline(14, weight: FontWeight.w500),
        // Body uses Rajdhani
        bodyLarge:  ShadowTextTheme.body(16, color: ShadowColors.textPrimary),
        bodyMedium: ShadowTextTheme.body(14),
        bodySmall:  ShadowTextTheme.body(12),
        // Labels / numbers use Roboto Mono
        labelLarge:  ShadowTextTheme.mono(14, weight: FontWeight.bold),
        labelMedium: ShadowTextTheme.mono(12),
        labelSmall:  ShadowTextTheme.mono(10, color: ShadowColors.textSecondary),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ShadowColors.amethyst,
        linearTrackColor: ShadowColors.surfaceAlt,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShadowColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ShadowColors.amethyst, width: 1.5),
        ),
        labelStyle: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
        hintStyle: ShadowTextTheme.body(14, color: ShadowColors.textDisabled),
      ),

      // Bottom nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ShadowColors.obsidian,
        selectedItemColor: ShadowColors.amethystLight,
        unselectedItemColor: ShadowColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Snack bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ShadowColors.surfaceAlt,
        contentTextStyle: ShadowTextTheme.body(14, color: ShadowColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
