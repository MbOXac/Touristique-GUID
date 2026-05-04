import 'package:flutter/material.dart';

class AppTheme {
  // Morocco-inspired palette
  static const Color primaryOrange = Color(0xFFD2691E);   // desert orange / chocolate
  static const Color deepBlue = Color(0xFF1A3A5C);        // deep blue
  static const Color earthBrown = Color(0xFF8B5A2B);      // warm earth brown
  static const Color sandBeige = Color(0xFFF5DEB3);       // sand / wheat
  static const Color oasisGreen = Color(0xFF2E7D32);      // oasis green
  static const Color softBeige = Color(0xFFF8F4EE);       // soft background beige
  static const Color goldAccent = Color(0xFFC8963E);      // gold/terracotta accent
  static const Color cardWhite = Colors.white;

  // Gradient helpers
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, Color(0xFF2A5A8C)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, Color(0xFFE8843A)],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: deepBlue,
        tertiary: oasisGreen,
        surface: softBeige,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: softBeige,
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryOrange,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: Color(0xFFE0D8CE)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: deepBlue,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: deepBlue,
          fontSize: 22,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: deepBlue,
          fontSize: 18,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: deepBlue,
          fontSize: 17,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: deepBlue,
          fontSize: 15,
        ),
        bodyLarge: TextStyle(
          color: Colors.black87,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Colors.black54,
          fontSize: 13,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      ),
    );
  }
}
