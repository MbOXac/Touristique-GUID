import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/settings_group.dart';
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
      appBar: const LargeTitleBar(title: 'Privacy'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SettingsSectionLabel('Preferences'),
          SettingsGroupCard(children: [
            SettingsRow(
              icon: Icons.location_on_outlined,
              iconColor: AppTheme.oasisGreen,
              label: 'Location Sharing',
              subtitle: 'Allow app to access your location',
              onTap: () => setState(() => _locationSharing = !_locationSharing),
              trailing: Switch(
                value: _locationSharing,
                onChanged: (val) => setState(() => _locationSharing = val),
              ),
            ),
            SettingsRow(
              icon: Icons.analytics_outlined,
              iconColor: AppTheme.deepBlue,
              label: 'Usage Analytics',
              subtitle: 'Help us improve the app',
              onTap: () => setState(() => _analytics = !_analytics),
              trailing: Switch(
                value: _analytics,
                onChanged: (val) => setState(() => _analytics = val),
              ),
            ),
            SettingsRow(
              icon: Icons.visibility_outlined,
              iconColor: AppTheme.goldAccent,
              label: 'Profile Visibility',
              subtitle: 'Make your profile public',
              onTap: () => setState(() => _profileVisibility = !_profileVisibility),
              trailing: Switch(
                value: _profileVisibility,
                onChanged: (val) => setState(() => _profileVisibility = val),
              ),
            ),
          ]),
          const SettingsSectionLabel('Data'),
          SettingsGroupCard(children: [
            SettingsRow(
              icon: Icons.download_outlined,
              iconColor: AppTheme.primaryOrange,
              label: 'Download My Data',
              subtitle: 'Get a copy of your data',
              showChevron: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your data will be sent to your email')),
                );
              },
            ),
            SettingsRow(
              icon: Icons.description_outlined,
              iconColor: AppTheme.earthBrown,
              label: 'Privacy Policy',
              showChevron: true,
              onTap: () {},
            ),
          ]),
          const SettingsSectionLabel('Account'),
          SettingsGroupCard(children: [
            SettingsRow(
              icon: Icons.delete_forever,
              iconColor: Theme.of(context).colorScheme.error,
              labelColor: Theme.of(context).colorScheme.error,
              label: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: _deleteAccount,
            ),
          ]),
        ],
      ),
    );
  }
}
