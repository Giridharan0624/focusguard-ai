import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand ──
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E2C);
  static const Color surfaceLight = Color(0xFF2A2A3C);

  // ── Risk Levels ──
  static const Color riskLow = Color(0xFF4CAF50);
  static const Color riskModerate = Color(0xFFFFC107);
  static const Color riskHigh = Color(0xFFFF9800);
  static const Color riskCritical = Color(0xFFF44336);

  // ── Cause Chart ──
  static const Color colorSleep = Color(0xFF42A5F5);
  static const Color colorWork = Color(0xFFEF5350);
  static const Color colorMood = Color(0xFFAB47BC);
  static const Color colorMeetings = Color(0xFFFFA726);
  static const Color colorCaffeine = Color(0xFF66BB6A);

  // ── Nutrition Progress ──
  static const Color nutrientGood = Color(0xFF4CAF50);
  static const Color nutrientWarning = Color(0xFFFFC107);
  static const Color nutrientLow = Color(0xFFF44336);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);

  // ── Cause colors by key ──
  static Color causeColor(String cause) {
    switch (cause) {
      case 'Sleep':
        return colorSleep;
      case 'Work':
        return colorWork;
      case 'Mood':
        return colorMood;
      case 'Meetings':
        return colorMeetings;
      case 'Caffeine':
        return colorCaffeine;
      default:
        return primaryLight;
    }
  }

  // ── Risk color by level ──
  static Color riskColor(String level) {
    switch (level) {
      case 'low':
        return riskLow;
      case 'moderate':
        return riskModerate;
      case 'high':
        return riskHigh;
      case 'critical':
        return riskCritical;
      default:
        return riskModerate;
    }
  }

  // ── Nutrition progress color ──
  static Color nutrientColor(double percent) {
    if (percent >= 70) return nutrientGood;
    if (percent >= 40) return nutrientWarning;
    return nutrientLow;
  }

  // ── Theme Data ──
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        cardColor: surface,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: primaryLight,
          surface: surface,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textPrimary),
          headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textPrimary),
          titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary),
          bodyLarge:
              TextStyle(fontSize: 16, color: textPrimary),
          bodyMedium:
              TextStyle(fontSize: 14, color: textSecondary),
          labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textHint,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textPrimary,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          inactiveTrackColor: surfaceLight,
          thumbColor: primary,
          overlayColor: Color(0x336C63FF),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
