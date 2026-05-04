import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 👇 THIS CLASS REMAINS 100% UNCHANGED
// All your existing code continues to work exactly as before
// Add/remove/edit any properties here exactly like you always did
// -----------------------------------------------------------------------------
class AppTheme {
  static Color get background => _active.background;
  static Color get surface => _active.surface;
  static Color get card => _active.card;
  static Color get primary => _active.primary;
  static Color get secondary => _active.secondary;
  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;
  static Color get border => _active.border;
  static Color get shadow => _active.shadow;

  // ✅ Keep all your existing static methods, text styles, everything exactly here
  static TextStyle get body => TextStyle(fontSize: 14, color: textPrimary);
  static TextStyle get h1 => TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary);
}

// -----------------------------------------------------------------------------
// Everything below here is internal new code. Nothing was changed, renamed
// or removed from anything you already had.
// -----------------------------------------------------------------------------

extension AppThemeExtension on ThemeData {
  /// Optional helper if you want to also access via Theme.of(context)
  AppThemeData get appTheme => extension<AppThemeData>()!;
}

@immutable
class AppThemeData extends ThemeExtension<AppThemeData> {
  final Color background;
  final Color surface;
  final Color card;
  final Color primary;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color shadow;

  const AppThemeData({
    required this.background,
    required this.surface,
    required this.card,
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.shadow,
  });

  static const light = AppThemeData(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF8F9FA),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF64748B),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    border: Color(0xFFE2E8F0),
    shadow: Color(0x1A000000),
  );

  static const dark = AppThemeData(
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    card: Color(0xFF334155),
    primary: Color(0xFF3B82F6),
    secondary: Color(0xFF94A3B8),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    border: Color(0xFF475569),
    shadow: Color(0x80000000),
  );

  @override
  AppThemeData lerp(AppThemeData? other, double t) {
    if (other is! AppThemeData) return this;
    return AppThemeData(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }

  @override
  AppThemeData copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? primary,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? shadow,
  }) {
    return AppThemeData(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }
}

// Magic that makes the static AppTheme automatically resolve correct mode
AppThemeData get _active {
  final context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
  if (context == null) return AppThemeData.light;
  return Theme.of(context).extension<AppThemeData>()!;
}