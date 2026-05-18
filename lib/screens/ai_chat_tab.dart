import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiChatTab extends StatelessWidget {
  const AiChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Travel Assistant'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAssistantMessage(
                  "👋 Welcome! I'm your AI Travel Assistant for Southeast Morocco!\n\nI can help you with:\n• 🗺️ Itinerary planning\n• 🏨 Accommodation advice\n• 🍽️ Restaurant recommendations\n• 🐪 Activity suggestions\n• 🌤️ Best travel times",
                ),
                const SizedBox(height: 12),
                _buildAssistantMessage("What would you like to explore today?"),
                const SizedBox(height: 16),
                const Text('Quick suggestions:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _suggestionChip(context, '🐪 Best camel treks'),
                    _suggestionChip(context, '🏨 Top riads to stay'),
                    _suggestionChip(context, '🌅 Sahara sunrise tips'),
                    _suggestionChip(context, '📅 3-day itinerary'),
                    _suggestionChip(context, '🍽️ Local food guide'),
                    _suggestionChip(context, '🗺️ Hidden gems'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildUserMessage("What's the best time to visit Merzouga?"),
                const SizedBox(height: 8),
                _buildAssistantMessage("🌟 The best time to visit Merzouga is:\n\n🍂 **October–November**: Perfect temperatures (20-25°C), stunning light on the dunes.\n\n🌸 **February–April**: Mild weather, great for trekking.\n\n❄️ Avoid July–August: Temperatures can exceed 45°C!\n\nPro tip: Plan your camel trek for golden hour – the shadows on Erg Chebbi are absolutely magical! 🐪✨"),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withAlpha(76))),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask about Southeast Morocco...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('AI responses coming soon!'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryOrange,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI responses coming soon!'), behavior: SnackBarBehavior.floating),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: AppTheme.deepBlue, shape: BoxShape.circle),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FF),
              borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildUserMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
            ),
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: AppTheme.sandBeige, shape: BoxShape.circle),
          child: const Icon(Icons.person_rounded, color: AppTheme.earthBrown, size: 20),
        ),
      ],
    );
  }

  Widget _suggestionChip(BuildContext context, String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label – AI responses coming soon!'), behavior: SnackBarBehavior.floating),
      ),
      backgroundColor: AppTheme.sandBeige,
      side: const BorderSide(color: AppTheme.primaryOrange),
    );
  }
}
