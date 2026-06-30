import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';
import 'profile_settings/account_settings_screen.dart';
import 'profile_settings/notifications_screen.dart';
import 'profile_settings/privacy_screen.dart';
import 'profile_settings/language_screen.dart';
import 'profile_settings/help_support_screen.dart';
import 'profile_settings/about_screen.dart';
import 'profile_settings/appearance_screen.dart';
import 'package:flutter/rendering.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onScrollDown;
  final VoidCallback? onScrollUp;

  const ProfileTab({
    super.key,
    this.onScrollDown,
    this.onScrollUp,
  });
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? name;
  String? email;
  String? language = 'English';
  bool _bottomBarHidden = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => email = user.email);
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          name = doc.data()?['name'] ?? user.displayName ?? "No name";
          language = doc.data()?['language'] ?? 'English';
        });
      }
    }
  }

  void _navigateTo(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: NotificationListener<UserScrollNotification>(
  onNotification: (notification) {
    if (notification.direction == ScrollDirection.reverse &&
        !_bottomBarHidden) {
      _bottomBarHidden = true;
      widget.onScrollDown?.call();
    }

    if (notification.direction == ScrollDirection.forward &&
        _bottomBarHidden) {
      _bottomBarHidden = false;
      widget.onScrollUp?.call();
    }

    return false;
  },
  child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppTheme.darkAppBar, const Color(0xFF1A2A40)]
                      : [AppTheme.deepBlue, const Color(0xFF2A5A8C)],
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
                  Text(
                    name ?? 'Loading...',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
              _SettingItem(Icons.manage_accounts_outlined, 'Account Settings', 'Manage your account',
                  () => _navigateTo(const AccountSettingsScreen())),
              _SettingItem(Icons.notifications_outlined, 'Notifications', 'Push & email preferences',
                  () => _navigateTo(const NotificationsScreen())),
              _SettingItem(Icons.privacy_tip_outlined, 'Privacy', 'Control your data',
                  () => _navigateTo(const PrivacyScreen())),
            ]),
            _buildSettingsSection(context, 'App', [
              _SettingItem(Icons.palette_outlined, 'Appearance', 'Themes & colors',
                  () => _navigateTo(const AppearanceScreen())),
              _SettingItem(Icons.language_outlined, 'Language', language ?? 'English',
                  () => _navigateTo(const LanguageScreen())),
              _SettingItem(Icons.help_outline_rounded, 'Help & Support', 'FAQ, contact us',
                  () => _navigateTo(const HelpSupportScreen())),
              _SettingItem(Icons.info_outline_rounded, 'About', 'Version 1.0.0',
                  () => _navigateTo(const AboutScreen())),
            ]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ctx = context;
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Sign Out',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ), 
    );
  }

  Widget _statBadge(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, String sectionTitle, List<_SettingItem> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
              letterSpacing: 1.0,
            ),
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
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                    ),
                    trailing: Icon(Icons.chevron_right, color: theme.textTheme.bodyMedium?.color),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 56, color: theme.dividerColor),
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
  final VoidCallback onTap;
  const _SettingItem(this.icon, this.title, this.subtitle, this.onTap);
}