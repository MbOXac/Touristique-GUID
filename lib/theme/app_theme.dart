import 'package:flutter/material.dart';

enum AppThemeType { light, dark }

class AppTheme {
  // ============ COLORS ============
  static const Color primaryOrange = Color(0xFFD2691E);
  static const Color deepBlue = Color(0xFF1A3A5C);
  static const Color earthBrown = Color(0xFF8B5A2B);
  static const Color sandBeige = Color(0xFFF5DEB3);
  static const Color oasisGreen = Color(0xFF2E7D32);
  static const Color softBackground = Color(0xFFF8F4EE);
  static const Color goldAccent = Color(0xFFE8A020);
  static const Color terracotta = Color(0xFFB85C38);

  // Dark colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkAppBar = Color(0xFF0F2438);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A5C), Color(0xFF2E6B9E)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD2691E), Color(0xFFE8830A)],
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xE6000000)],
    stops: [0.35, 1.0],
  );

  static Map<AppThemeType, Map<String, dynamic>> get themeInfo => {
        AppThemeType.light: {
          'name': 'Light',
          'emoji': '☀️',
          'description': 'Bright and warm',
          'primary': primaryOrange,
          'secondary': deepBlue,
          'background': softBackground,
        },
        AppThemeType.dark: {
          'name': 'Dark',
          'emoji': '🌑',
          'description': 'Easy on the eyes',
          'primary': primaryOrange,
          'secondary': goldAccent,
          'background': darkBackground,
        },
      };

  // ============ LIGHT THEME ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: deepBlue,
        tertiary: oasisGreen,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: softBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withAlpha(30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEEEAE4), thickness: 1),
    );
  }

  // ============ DARK THEME ============
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.dark,
        primary: primaryOrange,
        secondary: goldAccent,
        tertiary: oasisGreen,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkAppBar,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withAlpha(120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: darkCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextPrimary, height: 1.5),
        bodyMedium: TextStyle(color: darkTextSecondary, height: 1.5),
        bodySmall: TextStyle(color: darkTextSecondary),
        labelLarge: TextStyle(color: darkTextPrimary),
        labelMedium: TextStyle(color: darkTextSecondary),
        labelSmall: TextStyle(color: darkTextSecondary),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
      iconTheme: const IconThemeData(color: darkTextPrimary),
      listTileTheme: const ListTileThemeData(
        textColor: darkTextPrimary,
        iconColor: darkTextPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextSecondary),
        prefixIconColor: primaryOrange,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: darkTextSecondary,
        indicatorColor: primaryOrange,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        labelStyle: const TextStyle(color: darkTextPrimary),
        side: const BorderSide(color: darkBorder),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkCard,
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: darkTextPrimary),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: TextStyle(color: darkTextPrimary),
      ),
    );
  }

  static ThemeData getTheme(AppThemeType type) {
    return type == AppThemeType.dark ? darkTheme : lightTheme;
  }
}