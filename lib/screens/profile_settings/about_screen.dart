import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/settings_group.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.deepBlue;

    return Scaffold(
      appBar: const LargeTitleBar(title: 'About'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 12),
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
          Center(
            child: Text(
              'Touristique GUID',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
          Center(
            child: Text('Version 1.0.0', style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your AI-powered companion for exploring the beauty of Southeast Morocco.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SettingsGroupCard(children: [
            SettingsRow(
              icon: Icons.description_outlined,
              iconColor: AppTheme.primaryOrange,
              label: 'Terms of Service',
              showChevron: true,
              onTap: () {},
            ),
            SettingsRow(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppTheme.deepBlue,
              label: 'Privacy Policy',
              showChevron: true,
              onTap: () {},
            ),
            SettingsRow(
              icon: Icons.code,
              iconColor: AppTheme.earthBrown,
              label: 'Open Source Licenses',
              showChevron: true,
              onTap: () => showLicensePage(context: context),
            ),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text('Made with ❤️ in Morocco', style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '© 2025 Touristique. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
