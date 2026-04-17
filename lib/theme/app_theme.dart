import 'package:flutter/material.dart';

/// Material 3 design system for FocusGuard AI.
class AppTheme {
  AppTheme._();

  // ════════════════════════════════════════
  //  SPACING (4px grid)
  // ════════════════════════════════════════
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space14 = 14;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;

  // ════════════════════════════════════════
  //  RADIUS
  // ════════════════════════════════════════
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 999;

  // ════════════════════════════════════════
  //  BRAND
  // ════════════════════════════════════════
  static const Color accent = Color(0xFFFBC02D);        // amber/yellow
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color accentSoft = Color(0xFFFFF59D);
  static const Color accentDark = Color(0xFFF9A825);
  static const Color onAccent = Color(0xFF1A1D20);      // text on yellow
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

  // ════════════════════════════════════════
  //  DARK COLORS
  // ════════════════════════════════════════
  static const Color _darkBg = Color(0xFF0A0D13);
  static const Color _darkSurface = Color(0xFF131820);
  static const Color _darkSurfaceElev = Color(0xFF1A1F2A);
  static const Color _darkSurfaceLight = Color(0xFF222835);
  static const Color _darkOutline = Color(0xFF2A3140);
  static const Color _darkText = Color(0xFFF2F4F8);
  static const Color _darkTextSecondary = Color(0xFF9AA3B3);
  static const Color _darkTextHint = Color(0xFF5A6274);

  // ════════════════════════════════════════
  //  LIGHT COLORS
  // ════════════════════════════════════════
  static const Color _lightBg = Color(0xFFF7F9FD);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceElev = Color(0xFFFBFCFE);
  static const Color _lightSurfaceLight = Color(0xFFEEF1F7);
  static const Color _lightOutline = Color(0xFFE1E5EE);
  static const Color _lightText = Color(0xFF131720);
  static const Color _lightTextSecondary = Color(0xFF5B6478);
  static const Color _lightTextHint = Color(0xFF98A0B0);

  // ════════════════════════════════════════
  //  THEME-AWARE ACCESSORS
  // ════════════════════════════════════════
  static bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color bg(BuildContext c) => _isDark(c) ? _darkBg : _lightBg;
  static Color card(BuildContext c) => _isDark(c) ? _darkSurface : _lightSurface;
  static Color cardElev(BuildContext c) => _isDark(c) ? _darkSurfaceElev : _lightSurfaceElev;
  static Color sl(BuildContext c) => _isDark(c) ? _darkSurfaceLight : _lightSurfaceLight;
  static Color outline(BuildContext c) => _isDark(c) ? _darkOutline : _lightOutline;
  static Color tp(BuildContext c) => _isDark(c) ? _darkText : _lightText;
  static Color ts(BuildContext c) => _isDark(c) ? _darkTextSecondary : _lightTextSecondary;
  static Color th(BuildContext c) => _isDark(c) ? _darkTextHint : _lightTextHint;

  // ════════════════════════════════════════
  //  BACK-COMPAT STATIC CONSTANTS
  // ════════════════════════════════════════
  static const Color primary = accent;
  static const Color primaryLight = accentLight;
  static const Color background = _darkBg;
  static const Color surface = _darkSurface;
  static const Color surfaceLight = _darkSurfaceLight;
  static const Color textPrimary = _darkText;
  static const Color textSecondary = _darkTextSecondary;
  static const Color textHint = _darkTextHint;

  // ════════════════════════════════════════
  //  COLOR HELPERS
  // ════════════════════════════════════════
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

  // ════════════════════════════════════════
  //  DECORATIONS
  // ════════════════════════════════════════
  static BoxDecoration glassCard(BuildContext context) {
    final dark = _isDark(context);
    return BoxDecoration(
      color: dark ? _darkSurface : _lightSurface,
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: dark ? _darkOutline : _lightOutline,
        width: 1,
      ),
      boxShadow: dark
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  static BoxDecoration elevatedCard(BuildContext context) {
    final dark = _isDark(context);
    return BoxDecoration(
      color: dark ? _darkSurfaceElev : _lightSurface,
      borderRadius: BorderRadius.circular(radiusLg),
      boxShadow: [
        BoxShadow(
          color: dark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static LinearGradient accentGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  static LinearGradient cardGradient(BuildContext context) {
    final dark = _isDark(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? [_darkSurface, _darkSurfaceElev]
          : [_lightSurface, _lightSurfaceElev],
    );
  }

  // ════════════════════════════════════════
  //  DARK THEME
  // ════════════════════════════════════════
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        bg: _darkBg,
        surface: _darkSurface,
        surfaceLight: _darkSurfaceLight,
        outline: _darkOutline,
        text: _darkText,
        textSecondary: _darkTextSecondary,
        textHint: _darkTextHint,
      );

  // ════════════════════════════════════════
  //  LIGHT THEME
  // ════════════════════════════════════════
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        bg: _lightBg,
        surface: _lightSurface,
        surfaceLight: _lightSurfaceLight,
        outline: _lightOutline,
        text: _lightText,
        textSecondary: _lightTextSecondary,
        textHint: _lightTextHint,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceLight,
    required Color outline,
    required Color text,
    required Color textSecondary,
    required Color textHint,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: accent,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      fontFamily: 'Poppins',

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: onAccent,
        secondary: mintAccent,
        onSecondary: Colors.white,
        tertiary: warmAccent,
        onTertiary: Colors.white,
        error: riskCritical,
        onError: Colors.white,
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: surfaceLight,
        outline: outline,
        outlineVariant: outline,
      ),

      // Material 3 Typography Scale (Poppins)
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: text, height: 1.2, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: text, height: 1.25, letterSpacing: -0.4),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: text, height: 1.3, letterSpacing: -0.3),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text, height: 1.3, letterSpacing: -0.2),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: text, height: 1.3, letterSpacing: -0.2),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: text, height: 1.35),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text, height: 1.4),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text, height: 1.4),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: text, height: 1.4),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: text, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text, letterSpacing: 0.1),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.1),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textHint, letterSpacing: 0.5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: text, fontFamily: 'Poppins'),
        iconTheme: IconThemeData(color: textSecondary, size: 22),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: space24, vertical: space16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: space24, vertical: space14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: space24, vertical: space14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        hintStyle: TextStyle(color: textHint, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: space16, vertical: space14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: riskCritical, width: 1),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: surfaceLight,
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, pressedElevation: 2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        labelStyle: TextStyle(fontSize: 12, color: textSecondary, fontFamily: 'Poppins'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusFull)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: space10, vertical: space4),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceLight : text,
        contentTextStyle: TextStyle(
          color: isDark ? text : surface,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),

      iconTheme: IconThemeData(color: textSecondary, size: 22),
    );
  }
}

// ════════════════════════════════════════
//  SHARED UI COMPONENTS
// ════════════════════════════════════════

/// Section header with title, optional subtitle and trailing.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.space8),
              child: Icon(icon, size: 16, color: AppTheme.th(context)),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Reusable glass card with consistent styling.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.space16),
      decoration: AppTheme.glassCard(context),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: content,
      ),
    );
  }
}

/// Section wrapper: header + card body.
class AppSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets? bodyPadding;

  const AppSection({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    required this.child,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          SectionHeader(
              title: title!, subtitle: subtitle, icon: icon, trailing: trailing),
        AppCard(padding: bodyPadding, child: child),
      ],
    );
  }
}
