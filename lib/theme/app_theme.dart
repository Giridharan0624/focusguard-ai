import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Shared Brand Colors ──
  static const Color accent = Color(0xFF5B6EF5);
  static const Color accentLight = Color(0xFF8B9AFF);
  static const Color accentSoft = Color(0xFFDDE1FF);
  static const Color warmAccent = Color(0xFFE8A87C);
  static const Color mintAccent = Color(0xFF41D4A8);

  // ── Risk Levels ──
  static const Color riskLow = Color(0xFF41D4A8);
  static const Color riskModerate = Color(0xFFE8A87C);
  static const Color riskHigh = Color(0xFFE07C54);
  static const Color riskCritical = Color(0xFFE05B5B);

  // ── Cause Chart ──
  static const Color colorSleep = Color(0xFF6B8FE8);
  static const Color colorWork = Color(0xFFE07C54);
  static const Color colorMood = Color(0xFFB377D9);
  static const Color colorScreenTime = Color(0xFFE8A87C);
  static const Color colorCaffeine = Color(0xFF41D4A8);

  // ── Nutrition Progress ──
  static const Color nutrientGood = Color(0xFF41D4A8);
  static const Color nutrientWarning = Color(0xFFE8A87C);
  static const Color nutrientLow = Color(0xFFE05B5B);

  // ── Dark Theme Colors ──
  static const Color _darkBg = Color(0xFF0D1117);
  static const Color _darkSurface = Color(0xFF161B22);
  static const Color _darkSurfaceLight = Color(0xFF21262D);
  static const Color _darkText = Color(0xFFF0F6FC);
  static const Color _darkTextSecondary = Color(0xFF8B949E);
  static const Color _darkTextHint = Color(0xFF484F58);

  // ── Light Theme Colors ──
  static const Color _lightBg = Color(0xFFF6F8FC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceLight = Color(0xFFEEF1F6);
  static const Color _lightText = Color(0xFF1A1D26);
  static const Color _lightTextSecondary = Color(0xFF5E6478);
  static const Color _lightTextHint = Color(0xFF9DA3B0);

  // ── Theme-aware accessors ──
  static Color bg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color card(BuildContext context) =>
      Theme.of(context).cardColor;
  static Color sl(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkSurfaceLight : _lightSurfaceLight;
  static Color tp(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkText : _lightText;
  static Color ts(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkTextSecondary : _lightTextSecondary;
  static Color th(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkTextHint : _lightTextHint;

  // ── Static constants (backward compat for existing code) ──
  static const Color primary = accent;
  static const Color primaryLight = accentLight;
  static const Color background = _darkBg;
  static const Color surface = _darkSurface;
  static const Color surfaceLight = _darkSurfaceLight;
  static const Color textPrimary = _darkText;
  static const Color textSecondary = _darkTextSecondary;
  static const Color textHint = _darkTextHint;

  // ── Cause colors by key ──
  static Color causeColor(String cause) {
    switch (cause) {
      case 'Sleep': return colorSleep;
      case 'Work': return colorWork;
      case 'Mood': return colorMood;
      case 'Screen Time': return colorScreenTime;
      case 'Caffeine': return colorCaffeine;
      default: return accentLight;
    }
  }

  static Color riskColor(String level) {
    switch (level) {
      case 'low': return riskLow;
      case 'moderate': return riskModerate;
      case 'high': return riskHigh;
      case 'critical': return riskCritical;
      default: return riskModerate;
    }
  }

  static Color nutrientColor(double percent) {
    if (percent >= 70) return nutrientGood;
    if (percent >= 40) return nutrientWarning;
    return nutrientLow;
  }

  // ── Gradient helpers ──
  static LinearGradient cardGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [_darkSurface, _darkSurfaceLight.withValues(alpha: 0.6)]
          : [_lightSurface, _lightSurfaceLight.withValues(alpha: 0.4)],
    );
  }

  static LinearGradient accentGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B6EF5), Color(0xFF8B5CF6)],
  );

  // ── Glass card decoration ──
  static BoxDecoration glassCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? _darkSurface.withValues(alpha: 0.7)
          : _lightSurface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  //  DARK THEME
  // ══════════════════════════════════════════
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: accent,
        scaffoldBackgroundColor: _darkBg,
        cardColor: _darkSurface,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentLight,
          surface: _darkSurface,
          onPrimary: Colors.white,
          onSurface: _darkText,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _darkText, letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _darkText, letterSpacing: -0.3),
          titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _darkText),
          bodyLarge: TextStyle(fontSize: 15, color: _darkText, height: 1.5),
          bodyMedium: TextStyle(fontSize: 13, color: _darkTextSecondary, height: 1.5),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _darkText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _darkText),
          iconTheme: IconThemeData(color: _darkTextSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _darkSurface,
          selectedItemColor: accent,
          unselectedItemColor: _darkTextHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: _darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: accent),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          inactiveTrackColor: _darkSurfaceLight,
          thumbColor: accent,
          overlayColor: accent.withValues(alpha: 0.12),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: _darkTextHint, fontSize: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        dividerTheme: DividerThemeData(color: _darkSurfaceLight),
        chipTheme: ChipThemeData(
          backgroundColor: _darkSurfaceLight,
          labelStyle: const TextStyle(fontSize: 12, color: _darkTextSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
      );

  // ══════════════════════════════════════════
  //  LIGHT THEME
  // ══════════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: accent,
        scaffoldBackgroundColor: _lightBg,
        cardColor: _lightSurface,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          primary: accent,
          secondary: accentLight,
          surface: _lightSurface,
          onPrimary: Colors.white,
          onSurface: _lightText,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _lightText, letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _lightText, letterSpacing: -0.3),
          titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _lightText),
          bodyLarge: TextStyle(fontSize: 15, color: _lightText, height: 1.5),
          bodyMedium: TextStyle(fontSize: 13, color: _lightTextSecondary, height: 1.5),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _lightText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _lightText),
          iconTheme: IconThemeData(color: _lightTextSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _lightSurface,
          selectedItemColor: accent,
          unselectedItemColor: _lightTextHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: _lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: accent),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          inactiveTrackColor: _lightSurfaceLight,
          thumbColor: accent,
          overlayColor: accent.withValues(alpha: 0.12),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lightSurfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: _lightTextHint, fontSize: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        dividerTheme: DividerThemeData(color: _lightSurfaceLight),
        chipTheme: ChipThemeData(
          backgroundColor: _lightSurfaceLight,
          labelStyle: const TextStyle(fontSize: 12, color: _lightTextSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
      );
}
