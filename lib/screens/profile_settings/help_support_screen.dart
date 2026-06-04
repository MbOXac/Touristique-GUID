import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined, color: AppTheme.primaryOrange),
              title: const Text('Contact Us'),
              subtitle: const Text('support@touristique.ma'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email app...')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined, color: AppTheme.primaryOrange),
              title: const Text('Report a Bug'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.star_outline, color: AppTheme.primaryOrange),
              title: const Text('Rate the App'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'FREQUENTLY ASKED QUESTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline, color: AppTheme.primaryOrange),
                  title: Text(faq['question']!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(faq['answer']!, style: const TextStyle(color: Colors.black54)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}