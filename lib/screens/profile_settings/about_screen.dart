import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.orangeGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.travel_explore, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Touristique GUID',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepBlue,
              ),
            ),
          ),
          const Center(
            child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your AI-powered companion for exploring the beauty of Southeast Morocco.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppTheme.primaryOrange),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryOrange),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code, color: AppTheme.primaryOrange),
                  title: const Text('Open Source Licenses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Made with ❤️ in Morocco',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '© 2025 Touristique. All rights reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}