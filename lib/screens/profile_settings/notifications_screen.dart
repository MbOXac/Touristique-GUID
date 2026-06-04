import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionHeader('General'),
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications on your device',
                  value: _pushNotifications,
                  onChanged: (val) {
                    setState(() => _pushNotifications = val);
                    _savePreferences();
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Get updates via email',
                  value: _emailNotifications,
                  onChanged: (val) {
                    setState(() => _emailNotifications = val);
                    _savePreferences();
                  },
                ),
                const SizedBox(height: 16),
                _sectionHeader('Travel'),
                _buildSwitchTile(
                  icon: Icons.luggage_outlined,
                  title: 'Trip Reminders',
                  subtitle: 'Reminders about upcoming trips',
                  value: _tripReminders,
                  onChanged: (val) {
                    setState(() => _tripReminders = val);
                    _savePreferences();
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.explore_outlined,
                  title: 'New Destinations',
                  subtitle: 'Discover new places in Morocco',
                  value: _newDestinations,
                  onChanged: (val) {
                    setState(() => _newDestinations = val);
                    _savePreferences();
                  },
                ),
                const SizedBox(height: 16),
                _sectionHeader('Other'),
                _buildSwitchTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'AI Chat Responses',
                  subtitle: 'Notifications for AI assistant replies',
                  value: _aiChatResponses,
                  onChanged: (val) {
                    setState(() => _aiChatResponses = val);
                    _savePreferences();
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Promotional Offers',
                  subtitle: 'Special deals and discounts',
                  value: _promotionalOffers,
                  onChanged: (val) {
                    setState(() => _promotionalOffers = val);
                    _savePreferences();
                  },
                ),
              ],
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primaryOrange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryOrange,
      ),
    );
  }
}