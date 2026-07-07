import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/main_navigation.dart';
import 'screens/login_page.dart';
import 'screens/admin/admin_dashboard.dart';
import 'services/admin_service.dart';

/// Listens to Firebase auth state and routes the user to:
///  • LoginPage       — not signed in
///  • AdminDashboard  — signed in AND role == "admin" in Firestore
///  • MainNavigation  — signed in, regular user
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Tracks whether we are loading the admin role after login
  bool _checkingAdmin = false;
  bool _isAdmin = false;
  // The last user uid we ran the admin check for — avoids repeated Firestore calls
  String? _checkedUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Waiting for first auth event ──────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;

        // ── Not signed in ─────────────────────────────────────────────────
        if (user == null) {
          // Reset admin state so the next sign-in gets a fresh check
          _checkedUid = null;
          _isAdmin = false;
          _checkingAdmin = false;
          return const LoginPage();
        }

        // ── Signed in — check admin role once per uid ─────────────────────
        if (_checkedUid != user.uid) {
          _checkedUid = user.uid;
          _checkingAdmin = true;
          _isAdmin = false;

          AdminService().isCurrentUserAdmin().then((isAdmin) {
            if (mounted) {
              setState(() {
                _isAdmin = isAdmin;
                _checkingAdmin = false;
              });
            }
          });
        }

        if (_checkingAdmin) {
          return const _LoadingScreen();
        }

        return _isAdmin ? const AdminDashboard() : const MainNavigation();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}