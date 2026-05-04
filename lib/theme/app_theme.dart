import 'package:flutter/material.dart';

class AppTheme {
  // Morocco-inspired palette
  static const Color primaryOrange = Color(0xFFD2691E);   // desert orange / chocolate
  static const Color deepBlue = Color(0xFF1A3A5C);        // deep blue
  static const Color earthBrown = Color(0xFF8B5A2B);      // warm earth brown
  static const Color sandBeige = Color(0xFFF5DEB3);       // sand / wheat
  static const Color oasisGreen = Color(0xFF2E7D32);      // oasis green
  static const Color softBackground = Color(0xFFF8F4EE);  // soft beige background
  static const Color goldAccent = Color(0xFFE8A020);      // gold accent
  static const Color terracotta = Color(0xFFB85C38);      // terracotta accent

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
      scaffoldBackgroundColor: softBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black.withAlpha(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          color: deepBlue,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          color: deepBlue,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.black87,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.black54,
          height: 1.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEAE4),
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(20),
        indicatorColor: primaryOrange.withAlpha(40),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primaryOrange,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryOrange, size: 24);
          }
          return IconThemeData(color: Colors.grey.shade500, size: 22);
        }),
      ),
    );
  }
}
