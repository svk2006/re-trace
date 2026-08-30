import 'package:flutter/material.dart';
import 'package:re_trace/theme/re_trace_palette.dart';

class ReTraceColors {
  static const Color background = Color(0xFFF3EDE4);
  static const Color backgroundSecondary = Color(0xFFE8F0EE);
  static const Color surface = Color(0xFFFBF7F1);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xFFF7F9F8);
  static const Color primarySage = Color(0xFF6E9E99);
  static const Color softTeal = Color(0xFF8BB8C9);
  static const Color softBlue = Color(0xFF9CC4E9);
  static const Color softLavender = Color(0xFFB5A7D9);
  static const Color softGreen = Color(0xFFE0F0EA);
  static const Color softBlueAlt = Color(0xFFE7F4FB);
  static const Color softLavenderAlt = Color(0xFFF1EEF9);
  static const Color warmNeutral = Color(0xFFF4E9DE);
  static const Color primaryText = Color(0xFF1C2F34);
  static const Color secondaryText = Color(0xFF53656A);
  static const Color mutedText = Color(0xFF7A8C90);
  static const Color success = Color(0xFF6F9F86);
  static const Color warning = Color(0xFFC9A06A);
  static const Color attention = Color(0xFFB97872);
  static const Color border = Color(0xD6D7CFC4);
}

class ReTraceDarkColors {
  static const Color background = Color(0xFF07141C);
  static const Color backgroundSecondary = Color(0xFF0C1E28);
  static const Color surface = Color(0xFF122632);
  static const Color surfaceElevated = Color(0xFF183140);
  static const Color surfaceGlass = Color(0xFF1B3038);
  static const Color card = Color(0xFF122632);
  static const Color primarySage = Color(0xFF7FB8B1);
  static const Color softTeal = Color(0xFF7CC3D0);
  static const Color softBlue = Color(0xFF9DC0E8);
  static const Color softLavender = Color(0xFFB4A9D8);
  static const Color softGreen = Color(0xFF1E3B3D);
  static const Color softBlueAlt = Color(0xFF1D3144);
  static const Color softLavenderAlt = Color(0xFF2C2A47);
  static const Color warmNeutral = Color(0xFF2B2A25);
  static const Color primaryText = Color(0xFFEAF4F2);
  static const Color secondaryText = Color(0xFFB3C6C8);
  static const Color mutedText = Color(0xFF86A0A4);
  static const Color success = Color(0xFF8FBEA8);
  static const Color warning = Color(0xFFD4B07A);
  static const Color attention = Color(0xFFD08A80);
  static const Color border = Color(0x33233C48);
}

class ReTraceTheme {
  static ThemeData build({bool dark = false}) {
    final palette = dark ? ReTracePalette.dark : ReTracePalette.light;
    final textColor = palette.textPrimary;

    final base = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: palette.background,
      colorScheme: dark
          ? ColorScheme.dark(
              primary: palette.accent,
              secondary: palette.accentGlow,
              tertiary: ReTraceDarkColors.softBlue,
              surface: palette.surface,
              onPrimary: palette.onAccent,
              onSecondary: palette.textPrimary,
              onSurface: palette.textPrimary,
            )
          : ColorScheme.light(
              primary: palette.accent,
              secondary: palette.accentGlow,
              tertiary: ReTraceColors.softBlue,
              surface: palette.surface,
              onPrimary: palette.onAccent,
              onSecondary: palette.textPrimary,
              onSurface: palette.textPrimary,
            ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.12,
          letterSpacing: -1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.2,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: palette.textSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: textColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: palette.border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.accentSoft,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.all(IconThemeData(color: textColor)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? palette.accent : palette.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? palette.accent.withValues(alpha: 0.45)
              : palette.border;
        }),
      ),
    );

    return base.copyWith(
      extensions: [palette],
      dividerColor: palette.border,
      splashColor: palette.accent.withValues(alpha: 0.12),
      highlightColor: palette.accent.withValues(alpha: 0.08),
    );
  }
}
