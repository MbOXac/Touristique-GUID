import 'package:flutter/material.dart';

enum AppThemeType { light, dark }

class AppTheme {
  // ============ DESERT LUXE COLORS ============
  // primaryOrange stays the name most of the codebase already references
  // (44 usages) but is now tuned to the Desert Luxe terracotta, since that's
  // the color actually used for CTAs/prices/accents throughout the app.
  static const Color primaryOrange = Color(0xFFC1592E);
  static const Color terracotta = Color(0xFFB8532A);
  static const Color goldAccent = Color(0xFFD9A441);
  static const Color deepBlue = Color(0xFF1B2E45);
  static const Color earthBrown = Color(0xFF8B5A2B);
  static const Color sandBeige = Color(0xFFEFDFC0);
  static const Color oasisGreen = Color(0xFF2E7D32);
  static const Color softBackground = Color(0xFFF7F1E6);

  // Semantic aliases for new/updated code — same values as above, clearer names.
  static const Color navy = deepBlue;
  static const Color gold = goldAccent;
  static const Color cream = softBackground;

  // Dark colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkAppBar = Color(0xFF0F2438);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Light-mode text roles (large-title iOS-native headings in navy).
  static const Color lightTextPrimary = Color(0xFF1B2E45);
  static const Color lightTextSecondary = Color(0xFF6B6459);
  static const Color lightBorder = Color(0xFFEEEAE4);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B2E45), Color(0xFF2A4864)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC1592E), Color(0xFFDE7A4A)],
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

  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displayMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displaySmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.4),
    headlineLarge: TextStyle(color: lightTextPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.6),
    headlineMedium: TextStyle(color: lightTextPrimary, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.4),
    headlineSmall: TextStyle(color: lightTextPrimary, fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 18),
    titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: lightTextPrimary, height: 1.5),
    bodyMedium: TextStyle(color: lightTextSecondary, height: 1.5),
    bodySmall: TextStyle(color: lightTextSecondary),
    labelLarge: TextStyle(color: lightTextPrimary),
    labelMedium: TextStyle(color: lightTextSecondary),
    labelSmall: TextStyle(color: lightTextSecondary),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displayMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displaySmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.4),
    headlineLarge: TextStyle(color: darkTextPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.6),
    headlineMedium: TextStyle(color: darkTextPrimary, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.4),
    headlineSmall: TextStyle(color: darkTextPrimary, fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 18),
    titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: darkTextPrimary, height: 1.5),
    bodyMedium: TextStyle(color: darkTextSecondary, height: 1.5),
    bodySmall: TextStyle(color: darkTextSecondary),
    labelLarge: TextStyle(color: darkTextPrimary),
    labelMedium: TextStyle(color: darkTextSecondary),
    labelSmall: TextStyle(color: darkTextSecondary),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: goldAccent,
      side: const BorderSide(color: goldAccent, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );

  // ============ LIGHT THEME ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: deepBlue,
        tertiary: goldAccent,
        surface: lightCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      scaffoldBackgroundColor: softBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withAlpha(30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: lightCard,
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textTheme: _lightTextTheme,
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),
      iconTheme: const IconThemeData(color: lightTextPrimary),
      listTileTheme: const ListTileThemeData(
        textColor: lightTextPrimary,
        iconColor: lightTextPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: lightTextSecondary),
        hintStyle: const TextStyle(color: lightTextSecondary),
        prefixIconColor: primaryOrange,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: deepBlue,
        unselectedLabelColor: lightTextSecondary,
        indicatorColor: primaryOrange,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sandBeige.withAlpha(140),
        labelStyle: const TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: lightTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepBlue,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primaryOrange : Colors.grey.shade300,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
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
        tertiary: goldAccent,
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
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withAlpha(120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: darkCard,
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textTheme: _darkTextTheme,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkCard,
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: TextStyle(color: darkTextPrimary),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primaryOrange : Colors.grey.shade700,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
    );
  }

  static ThemeData getTheme(AppThemeType type) {
    return type == AppThemeType.dark ? darkTheme : lightTheme;
  }
}
