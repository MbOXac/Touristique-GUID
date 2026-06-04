import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/splash_page.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';
import 'services/theme_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TouristiqueApp());
}

class TouristiqueApp extends StatefulWidget {
  const TouristiqueApp({super.key});

  @override
  State<TouristiqueApp> createState() => _TouristiqueAppState();
}

class _TouristiqueAppState extends State<TouristiqueApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touristique GUID',
      debugShowCheckedModeBanner: false,
      theme: _themeService.themeData,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ThemeService().loadTheme();
          return const SplashPage();
        }
        return const LoginPage();
      },
    );
  }
}