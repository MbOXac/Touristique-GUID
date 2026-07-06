import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/settings_group.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _tripReminders = true;
  bool _promotionalOffers = false;
  bool _aiChatResponses = true;
  bool _newDestinations = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final prefs = doc.data()?['notifications'] as Map<String, dynamic>?;
    if (prefs != null) {
      setState(() {
        _pushNotifications = prefs['push'] ?? true;
        _emailNotifications = prefs['email'] ?? true;
        _tripReminders = prefs['tripReminders'] ?? true;
        _promotionalOffers = prefs['promotional'] ?? false;
        _aiChatResponses = prefs['aiChat'] ?? true;
        _newDestinations = prefs['newDestinations'] ?? true;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'notifications': {
        'push': _pushNotifications,
        'email': _emailNotifications,
        'tripReminders': _tripReminders,
        'promotional': _promotionalOffers,
        'aiChat': _aiChatResponses,
        'newDestinations': _newDestinations,
      },
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LargeTitleBar(title: 'Notifications'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SettingsSectionLabel('General'),
                SettingsGroupCard(children: [
                  SettingsRow(
                    icon: Icons.notifications_active_outlined,
                    iconColor: AppTheme.primaryOrange,
                    label: 'Push Notifications',
                    subtitle: 'Receive notifications on your device',
                    onTap: () {
                      setState(() => _pushNotifications = !_pushNotifications);
                      _savePreferences();
                    },
                    trailing: Switch(
                      value: _pushNotifications,
                      onChanged: (val) {
                        setState(() => _pushNotifications = val);
                        _savePreferences();
                      },
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.email_outlined,
                    iconColor: AppTheme.deepBlue,
                    label: 'Email Notifications',
                    subtitle: 'Get updates via email',
                    onTap: () {
                      setState(() => _emailNotifications = !_emailNotifications);
                      _savePreferences();
                    },
                    trailing: Switch(
                      value: _emailNotifications,
                      onChanged: (val) {
                        setState(() => _emailNotifications = val);
                        _savePreferences();
                      },
                    ),
                  ),
                ]),
                const SettingsSectionLabel('Travel'),
                SettingsGroupCard(children: [
                  SettingsRow(
                    icon: Icons.luggage_outlined,
                    iconColor: AppTheme.oasisGreen,
                    label: 'Trip Reminders',
                    subtitle: 'Reminders about upcoming trips',
                    onTap: () {
                      setState(() => _tripReminders = !_tripReminders);
                      _savePreferences();
                    },
                    trailing: Switch(
                      value: _tripReminders,
                      onChanged: (val) {
                        setState(() => _tripReminders = val);
                        _savePreferences();
                      },
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.explore_outlined,
                    iconColor: AppTheme.goldAccent,
                    label: 'New Destinations',
                    subtitle: 'Discover new places in Morocco',
                    onTap: () {
                      setState(() => _newDestinations = !_newDestinations);
                      _savePreferences();
                    },
                    trailing: Switch(
                      value: _newDestinations,
                      onChanged: (val) {
                        setState(() => _newDestinations = val);
                        _savePreferences();
                      },
                    ),
                  ),
                ]),
                const SettingsSectionLabel('Other'),
                SettingsGroupCard(children: [
                  SettingsRow(
                    icon: Icons.chat_bubble_outline,
                    iconColor: AppTheme.deepBlue,
                    label: 'AI Chat Responses',
                    subtitle: 'Notifications for AI assistant replies',
                    onTap: () {
                      setState(() => _aiChatResponses = !_aiChatResponses);
                      _savePreferences();
                    },
                    trailing: Switch(
                      value: _aiChatResponses,
                      onChanged: (val) {
                        setState(() => _aiChatResponses = val);
                        _savePreferences();
                      },
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.local_offer_outlined,
                    iconColor: AppTheme.earthBrown,
                    label: 'Promotional Offers',
                    subtitle: 'Special deals and discounts',
                    onTap: () {
                      setState(() => _promotionalOffers = !_promotionalOffers);
                      _savePreferences();
                    },
                    trailing: Switch(
                      value: _promotionalOffers,
                      onChanged: (val) {
                        setState(() => _promotionalOffers = val);
                        _savePreferences();
                      },
                    ),
                  ),
                ]),
              ],
            ),
    );
  }
}
