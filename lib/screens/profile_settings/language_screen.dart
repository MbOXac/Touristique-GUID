import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/settings_group.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'flag': '🇬🇧', 'code': 'en'},
    {'name': 'Français', 'flag': '🇫🇷', 'code': 'fr'},
    {'name': 'العربية', 'flag': '🇲🇦', 'code': 'ar'},
    {'name': 'Español', 'flag': '🇪🇸', 'code': 'es'},
    {'name': 'Deutsch', 'flag': '🇩🇪', 'code': 'de'},
    {'name': 'Italiano', 'flag': '🇮🇹', 'code': 'it'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final lang = doc.data()?['language'];
    if (lang != null) setState(() => _selectedLanguage = lang);
  }

  Future<void> _saveLanguage(String lang) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'language': lang,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const LargeTitleBar(title: 'Language'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SettingsSectionLabel('Available languages'),
          SettingsGroupCard(
            children: _languages.map((lang) {
              final isSelected = _selectedLanguage == lang['name'];
              return InkWell(
                onTap: () {
                  setState(() => _selectedLanguage = lang['name']!);
                  _saveLanguage(lang['name']!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${lang['name']}'),
                      backgroundColor: AppTheme.oasisGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          lang['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primaryOrange
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? AppTheme.primaryOrange
                            : theme.textTheme.bodySmall?.color,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
