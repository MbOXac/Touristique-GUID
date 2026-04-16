import 'package:flutter/material.dart';

class AppTheme {
  // Morocco-inspired palette
  static const Color primaryOrange = Color(0xFFD2691E);   // desert orange / chocolate
  static const Color deepBlue = Color(0xFF1A3A5C);        // deep blue
  static const Color earthBrown = Color(0xFF8B5A2B);      // warm earth brown
  static const Color sandBeige = Color(0xFFF5DEB3);       // sand / wheat
  static const Color oasisGreen = Color(0xFF2E7D32);      // oasis green

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: deepBlue,
        tertiary: oasisGreen,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          color: deepBlue,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.black54,
        ),
      ),
    );
  }
}
