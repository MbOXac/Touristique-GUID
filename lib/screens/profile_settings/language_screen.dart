import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguage == lang['name'];
          return Card(
            color: isSelected ? AppTheme.primaryOrange.withAlpha(20) : null,
            child: ListTile(
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
              title: Text(
                lang['name']!,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryOrange : null,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryOrange)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
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
            ),
          );
        },
      ),
    );
  }
}