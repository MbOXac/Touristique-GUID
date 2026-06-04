import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../login_page.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _locationSharing = true;
  bool _analytics = true;
  bool _profileVisibility = true;

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent. All your data, trips, and memories will be deleted forever.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e. Please sign in again first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.location_on_outlined, color: AppTheme.primaryOrange),
              title: const Text('Location Sharing'),
              subtitle: const Text('Allow app to access your location'),
              value: _locationSharing,
              activeThumbColor: AppTheme.primaryOrange,
              onChanged: (val) => setState(() => _locationSharing = val),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.analytics_outlined, color: AppTheme.primaryOrange),
              title: const Text('Usage Analytics'),
              subtitle: const Text('Help us improve the app'),
              value: _analytics,
              activeThumbColor: AppTheme.primaryOrange,
              onChanged: (val) => setState(() => _analytics = val),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.visibility_outlined, color: AppTheme.primaryOrange),
              title: const Text('Profile Visibility'),
              subtitle: const Text('Make your profile public'),
              value: _profileVisibility,
              activeThumbColor: AppTheme.primaryOrange,
              onChanged: (val) => setState(() => _profileVisibility = val),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_outlined, color: AppTheme.primaryOrange),
              title: const Text('Download My Data'),
              subtitle: const Text('Get a copy of your data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your data will be sent to your email')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined, color: AppTheme.primaryOrange),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Permanently delete your account'),
              onTap: _deleteAccount,
            ),
          ),
        ],
      ),
    );
  }
}