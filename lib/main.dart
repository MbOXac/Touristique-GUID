import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <--- Make sure this import is present
import 'screens/splash_page.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- Required for async before runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home:AuthGate(),
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
        // User logged in
        if (snapshot.hasData) {
          return const SplashPage(); // Or HomePage, your real app!
        }
        // Not logged in
        return const LoginPage();
      },
    );
  }
}