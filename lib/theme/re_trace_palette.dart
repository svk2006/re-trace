import 'package:flutter/material.dart';

@immutable
class ReTracePalette extends ThemeExtension<ReTracePalette> {
  const ReTracePalette({
    required this.background,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceGlass,
    required this.surfaceInteractive,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.accentGlow,
    required this.success,
    required this.warning,
    required this.attention,
    required this.border,
    required this.chartGrid,
    required this.chartBaseline,
    required this.overlay,
    required this.onAccent,
  });

  final Color background;
  final Color backgroundSecondary;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceGlass;
  final Color surfaceInteractive;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSoft;
  final Color accentGlow;
  final Color success;
  final Color warning;
  final Color attention;
  final Color border;
  final Color chartGrid;
  final Color chartBaseline;
  final Color overlay;
  final Color onAccent;

  static const light = ReTracePalette(
    background: Color(0xFFF3EDE4),
    backgroundSecondary: Color(0xFFE8F0EE),
    surface: Color(0xFFFBF7F1),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceGlass: Color(0xCCFBF7F1),
    surfaceInteractive: Color(0xFFE4F1EE),
    textPrimary: Color(0xFF1C2F34),
    textSecondary: Color(0xFF53656A),
    textMuted: Color(0xFF7A8C90),
    accent: Color(0xFF6E9E99),
    accentSoft: Color(0xFFB7D4D0),
    accentGlow: Color(0xFF8BB8C9),
    success: Color(0xFF6F9F86),
    warning: Color(0xFFC9A06A),
    attention: Color(0xFFB97872),
    border: Color(0xD6D7CFC4),
    chartGrid: Color(0x331C2F34),
    chartBaseline: Color(0x556E9E99),
    overlay: Color(0x661C2F34),
    onAccent: Color(0xFFFBF7F1),
  );

  static const dark = ReTracePalette(
    background: Color(0xFF07141C),
    backgroundSecondary: Color(0xFF0C1E28),
    surface: Color(0xFF122632),
    surfaceElevated: Color(0xFF183140),
    surfaceGlass: Color(0x99122632),
    surfaceInteractive: Color(0xFF1D3A4A),
    textPrimary: Color(0xFFEAF4F2),
    textSecondary: Color(0xFFB3C6C8),
    textMuted: Color(0xFF86A0A4),
    accent: Color(0xFF7FB8B1),
    accentSoft: Color(0xFF2A4A52),
    accentGlow: Color(0xFF7CC3D0),
    success: Color(0xFF8FBEA8),
    warning: Color(0xFFD4B07A),
    attention: Color(0xFFD08A80),
    border: Color(0x33233C48),
    chartGrid: Color(0x22EAF4F2),
    chartBaseline: Color(0x557FB8B1),
    overlay: Color(0x9907141C),
    onAccent: Color(0xFF07141C),
  );

  @override
  ReTracePalette copyWith({
    Color? background,
    Color? backgroundSecondary,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceGlass,
    Color? surfaceInteractive,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSoft,
    Color? accentGlow,
    Color? success,
    Color? warning,
    Color? attention,
    Color? border,
    Color? chartGrid,
    Color? chartBaseline,
    Color? overlay,
    Color? onAccent,
  }) {
    return ReTracePalette(
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      surfaceInteractive: surfaceInteractive ?? this.surfaceInteractive,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentGlow: accentGlow ?? this.accentGlow,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      attention: attention ?? this.attention,
      border: border ?? this.border,
      chartGrid: chartGrid ?? this.chartGrid,
      chartBaseline: chartBaseline ?? this.chartBaseline,
      overlay: overlay ?? this.overlay,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  ReTracePalette lerp(ThemeExtension<ReTracePalette>? other, double t) {
    if (other is! ReTracePalette) return this;
    return ReTracePalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      surfaceInteractive: Color.lerp(surfaceInteractive, other.surfaceInteractive, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      attention: Color.lerp(attention, other.attention, t)!,
      border: Color.lerp(border, other.border, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      chartBaseline: Color.lerp(chartBaseline, other.chartBaseline, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

extension ReTracePaletteX on BuildContext {
  ReTracePalette get palette =>
      Theme.of(this).extension<ReTracePalette>() ?? ReTracePalette.light;
}
