import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'services/cloudinary_service.dart';
import 'services/theme_service.dart';
import 'auth_gate.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    
  // Initialize Cloudinary
  CloudinaryService().initialize();
  
  runApp(const MyApp());

   
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    // Rebuild MaterialApp whenever the saved theme preference changes.
    _themeService.addListener(_onThemeChanged);

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _themeService.loadTheme();
      }
    });
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touristique GUID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),
    );
  }
}