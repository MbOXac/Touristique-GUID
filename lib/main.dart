import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <--- Make sure this import is present
import 'screens/splash_page.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
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
      home: const AuthGate(),
    );
  }
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // User logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;
          final isPasswordUser = user.providerData.any((p) => p.providerId == 'password');
          if (isPasswordUser && !user.emailVerified) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mark_email_unread_outlined, size: 56),
                      const SizedBox(height: 12),
                      const Text(
                        'Please verify your email before continuing.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await user.sendEmailVerification();
                        },
                        child: const Text('Resend verification email'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await user.reload();
                        },
                        child: const Text('I have verified, refresh'),
                      ),
                      TextButton(
                        onPressed: () async => FirebaseAuth.instance.signOut(),
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SplashPage(); // Or HomePage, your real app!
        }
        // Not logged in
        return const LoginPage();
      },
    );
  }
}
