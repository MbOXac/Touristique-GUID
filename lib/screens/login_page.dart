import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_radius.dart';
import '../widgets/settings_group.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLogin = true;
  String? error;
  bool isLoading = false;

  // --- GOOGLE SIGN-IN FUNCTION ---
  static const _webClientId =
      '202821805924-7038jg7f4183lei3ad7rtg2pf8an71bi.apps.googleusercontent.com';

  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = kIsWeb
          ? GoogleSignIn(clientId: _webClientId)
          : GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // L'utilisateur a annulé

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Optionally save info to Firestore if first sign-in
      final doc = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
      if (!(await doc.get()).exists) {
        await doc.set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'photoURL': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Google: $e")),
      );
    }
  }

  // --- EMAIL/PASSWORD LOGIN/REGISTER ---
  Future<void> submit() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      if (isLogin) {
        // LOGIN
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // REGISTER
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        // Save extra user info in Firestore
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? "Firebase error");
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- THE REAL BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LargeTitleBar(title: isLogin ? 'Sign In' : 'Register'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.cardLarge)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLogin)
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (val) => val == null || val.isEmpty ? "Enter your name" : null,
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val != null && val.contains('@') ? null : "Enter a valid email",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (val) => val != null && val.length >= 6 ? null : "Enter min 6 char password",
                    ),
                    const SizedBox(height: 24),
                    if (error != null)
                      Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                submit();
                              }
                            },
                            child: Text(isLogin ? 'Sign In' : 'Register'),
                          ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          error = null;
                        });
                      },
                      child: Text(isLogin
                          ? "Don't have an account? Register"
                          : "I already have an account. Sign In"),
                    ),
                    const Divider(height: 32),
                    // GOOGLE SIGN-IN BUTTON (visible for both login/register)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Se connecter avec Google'),
                        onPressed: signInWithGoogle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}