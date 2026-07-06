import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/settings_group.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I book a trip?',
      'answer': 'Browse destinations on the Home tab, select one, and tap "Book Now".'
    },
    {
      'question': 'How does the AI Chat work?',
      'answer': 'Our AI assistant helps you plan trips, suggest places, and answer questions about Morocco.'
    },
    {
      'question': 'Can I use the app offline?',
      'answer': 'Yes! Some features like saved destinations work offline.'
    },
    {
      'question': 'How do I save favorite places?',
      'answer': 'Tap the heart icon on any destination to add it to your favorites.'
    },
    {
      'question': 'How do I share trip memories?',
      'answer': 'Go to the Trip tab and use the Memories feature to capture and share moments.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const LargeTitleBar(title: 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SettingsSectionLabel('Support'),
          SettingsGroupCard(children: [
            SettingsRow(
              icon: Icons.email_outlined,
              iconColor: AppTheme.primaryOrange,
              label: 'Contact Us',
              subtitle: 'support@touristique.ma',
              showChevron: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email app...')),
                );
              },
            ),
            SettingsRow(
              icon: Icons.bug_report_outlined,
              iconColor: AppTheme.deepBlue,
              label: 'Report a Bug',
              showChevron: true,
              onTap: () {},
            ),
            SettingsRow(
              icon: Icons.star_outline,
              iconColor: AppTheme.goldAccent,
              label: 'Rate the App',
              showChevron: true,
              onTap: () {},
            ),
          ]),
          const SettingsSectionLabel('Frequently asked questions'),
          SettingsGroupCard(
            children: _faqs
                .map((faq) => Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: theme.textTheme.bodySmall?.color,
                        collapsedIconColor: theme.textTheme.bodySmall?.color,
                        leading: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.earthBrown,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.help_outline, color: Colors.white, size: 17),
                        ),
                        title: Text(
                          faq['question']!,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(faq['answer']!, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
