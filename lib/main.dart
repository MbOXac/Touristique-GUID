import 'package:flutter/material.dart';
import 'screens/splash_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TouristiqueApp());
}

class TouristiqueApp extends StatelessWidget {
  const TouristiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touristique GUID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
