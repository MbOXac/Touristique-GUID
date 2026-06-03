import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart'; // <--- Make sure this import is present
import 'screens/splash_page.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    if (kIsWeb) {
      debugPrint(
        'Debug mode: connected Firebase Auth emulator at 127.0.0.1:9099 and Firestore emulator at 127.0.0.1:8080',
      );
    }
  }

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
