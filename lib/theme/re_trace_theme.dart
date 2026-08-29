import 'package:flutter/material.dart';

class ReTraceColors {
  static const Color background = Color(0xFFF7F9F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primarySage = Color(0xFF6FAFA3);
  static const Color softTeal = Color(0xFF82B8AE);
  static const Color softBlue = Color(0xFF8CB9D9);
  static const Color softLavender = Color(0xFFA8A0D8);
  static const Color softGreen = Color(0xFFDCEDE7);
  static const Color softBlueAlt = Color(0xFFDFEDF5);
  static const Color softLavenderAlt = Color(0xFFE9E5F5);
  static const Color warmNeutral = Color(0xFFF2EEE8);
  static const Color primaryText = Color(0xFF263536);
  static const Color secondaryText = Color(0xFF667574);
  static const Color success = Color(0xFF79A88F);
  static const Color warning = Color(0xFFD5AA70);
  static const Color border = Color.fromARGB(255, 229, 234, 231);
}

class ReTraceTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ReTraceColors.background,
      colorScheme: const ColorScheme.light(
        primary: ReTraceColors.primarySage,
        secondary: ReTraceColors.softTeal,
        tertiary: ReTraceColors.softBlue,
        surface: ReTraceColors.surface,
        onPrimary: Colors.white,
        onSecondary: ReTraceColors.primaryText,
        onSurface: ReTraceColors.primaryText,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: ReTraceColors.primaryText,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: ReTraceColors.primaryText,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ReTraceColors.primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ReTraceColors.primaryText,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ReTraceColors.secondaryText,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ReTraceColors.primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: ReTraceColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: ReTraceColors.border),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ReTraceColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ReTraceColors.primaryText,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ReTraceColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: ReTraceColors.softGreen,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: ReTraceColors.primaryText),
        ),
      ),
    );

    return base.copyWith(
      dividerColor: ReTraceColors.border,
      scaffoldBackgroundColor: ReTraceColors.background,
      splashColor: ReTraceColors.softGreen,
      highlightColor: ReTraceColors.softGreen,
    );
  }
}
