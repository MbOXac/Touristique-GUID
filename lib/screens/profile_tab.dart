import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../constants/app_radius.dart';
import '../models/gallery_item.dart';
import '../services/favorite_service.dart';
import '../services/gallery_service.dart';
import '../widgets/settings_group.dart';
import 'favorites_screen.dart';
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
  final FavoriteService _favoriteService = FavoriteService();
  final GalleryService _galleryService = GalleryService();

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
                      border: Border.all(color: AppTheme.goldAccent, width: 3),
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
                      GestureDetector(
                        onTap: () => _navigateTo(const FavoritesScreen()),
                        child: StreamBuilder<int>(
                          stream: _favoriteService.streamFavoritesCount(),
                          builder: (context, favSnapshot) {
                            return StreamBuilder<List<GalleryItem>>(
                              stream: _galleryService.getSavedImages(),
                              builder: (context, gallerySnapshot) {
                                final favCount = favSnapshot.data;
                                final galleryCount = gallerySnapshot.data?.length;
                                if (favCount == null || galleryCount == null) {
                                  return _statBadge('—', 'Favorites');
                                }
                                return _statBadge('${favCount + galleryCount}', 'Favorites');
                              },
                            );
                          },
                        ),
                      ),
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
                  () => _navigateTo(const AccountSettingsScreen()),
                  iconColor: AppTheme.primaryOrange),
              _SettingItem(Icons.notifications_outlined, 'Notifications', 'Push & email preferences',
                  () => _navigateTo(const NotificationsScreen()),
                  iconColor: AppTheme.deepBlue),
              _SettingItem(Icons.privacy_tip_outlined, 'Privacy', 'Control your data',
                  () => _navigateTo(const PrivacyScreen()),
                  iconColor: AppTheme.oasisGreen),
            ]),
            _buildSettingsSection(context, 'App', [
              _SettingItem(Icons.palette_outlined, 'Appearance', 'Themes & colors',
                  () => _navigateTo(const AppearanceScreen()),
                  iconColor: AppTheme.goldAccent),
              _SettingItem(Icons.language_outlined, 'Language', language ?? 'English',
                  () => _navigateTo(const LanguageScreen()),
                  iconColor: AppTheme.deepBlue),
              _SettingItem(Icons.help_outline_rounded, 'Help & Support', 'FAQ, contact us',
                  () => _navigateTo(const HelpSupportScreen()),
                  iconColor: AppTheme.earthBrown),
              _SettingItem(Icons.info_outline_rounded, 'About', 'Version 1.0.0',
                  () => _navigateTo(const AboutScreen()),
                  iconColor: AppTheme.primaryOrange),
            ]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // 1. Pop all screens back to AuthGate (the first/home route)
                    //    AuthGate's StreamBuilder will render LoginPage once signed out.
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    // 2. Clear Google session (no-op if user signed in with email)
                    try {
                      const webClientId =
                          '202821805924-7038jg7f4183lei3ad7rtg2pf8an71bi.apps.googleusercontent.com';
                      final googleSignIn = kIsWeb
                          ? GoogleSignIn(clientId: webClientId)
                          : GoogleSignIn();
                      await googleSignIn.signOut();
                    } catch (_) {}
                    // 3. Sign out of Firebase — AuthGate reacts and shows LoginPage
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Sign Out',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
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
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, String sectionTitle, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(sectionTitle),
        SettingsGroupCard(
          children: items
              .map((item) => SettingsRow(
                    icon: item.icon,
                    iconColor: item.iconColor,
                    label: item.title,
                    subtitle: item.subtitle,
                    showChevron: true,
                    onTap: item.onTap,
                  ))
              .toList(),
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
  final Color iconColor;
  const _SettingItem(this.icon, this.title, this.subtitle, this.onTap,
      {this.iconColor = AppTheme.primaryOrange});
}