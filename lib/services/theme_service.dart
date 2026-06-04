import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  AppThemeType _currentTheme = AppThemeType.light;
  AppThemeType get currentTheme => _currentTheme;

  ThemeData get themeData => AppTheme.getTheme(_currentTheme);
  bool get isDark => _currentTheme == AppThemeType.dark;

  Future<void> loadTheme() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final themeName = doc.data()?['theme'] as String?;
      _currentTheme = themeName == 'dark' ? AppThemeType.dark : AppThemeType.light;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'theme': theme.name,
    }, SetOptions(merge: true));
  }
}