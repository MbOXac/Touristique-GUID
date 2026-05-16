import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';
// Make sure the LoginPage class exists in login_page.dart and is exported as:
// class LoginPage extends StatelessWidget { ... }

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const String _privacyPolicyUrl = 'https://example.com/privacy';
  static const String _termsUrl = 'https://example.com/terms';
  String? name;
  String? email;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        email = user.email;
        _emailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      });
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        name = doc.data()?['name'] ?? user.displayName ?? "No name";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.deepBlue, Color(0xFF2A5A8C)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppTheme.sandBeige,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryOrange, width: 3),
                    ),
                    child: const Icon(Icons.person_rounded, size: 52, color: AppTheme.earthBrown),
                  ),
                  const SizedBox(height: 12),
                  // Display real name and email here
                  Text(
                    name ?? 'Loading...',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (!_emailVerified)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        await user?.sendEmailVerification();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification email sent'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.mark_email_read_rounded, color: Colors.white),
                      label: const Text(
                        'Verify email',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statBadge('12', 'Trips'),
                      const SizedBox(width: 24),
                      _statBadge('34', 'Favorites'),
                      const SizedBox(width: 24),
                      _statBadge('8', 'Memories'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingsSection(context, 'Account', [
              _SettingItem(Icons.manage_accounts_outlined, 'Account Settings', 'Manage your account'),
              _SettingItem(Icons.notifications_outlined, 'Notifications', 'Push & email preferences'),
              _SettingItem(Icons.privacy_tip_outlined, 'Privacy', 'Control your data'),
            ]),
            _buildSettingsSection(context, 'App', [
              _SettingItem(Icons.language_outlined, 'Language', 'English'),
              _SettingItem(Icons.help_outline_rounded, 'Help & Support', 'FAQ, contact us'),
              _SettingItem(Icons.info_outline_rounded, 'About', 'Version 1.0.0'),
            ]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
            child:  OutlinedButton.icon(
                      onPressed: () async {
                  final ctx = context;
                  try {
                    await GoogleSignIn().signOut();
                  } catch (_) {}
                  await FirebaseAuth.instance.signOut();
                       Navigator.of(ctx).pushAndRemoveUntil(
                         MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                          );
},
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                 label: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
               padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
             ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    try {
                      await user?.delete();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not delete account: $e'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  label: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.deepBlue),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text(_privacyPolicyUrl),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Update this URL before release')),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_rounded, color: AppTheme.deepBlue),
                    title: const Text('Terms of Service'),
                    subtitle: const Text(_termsUrl),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Update this URL before release')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, String sectionTitle, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            sectionTitle,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.0),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppTheme.primaryOrange, size: 22),
                    title: Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.title} – Coming soon!'), behavior: SnackBarBehavior.floating),
                    ),
                  ),
                  if (index < items.length - 1) const Divider(height: 1, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SettingItem(this.icon, this.title, this.subtitle);
}
