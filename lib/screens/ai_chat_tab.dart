import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';

class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab> {
  late final GeminiService _gemini;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    try {
      _gemini = GeminiService();
      _messages.add(_ChatMessage(
        text: "👋 Welcome! I'm your AI Travel Assistant for Southeast Morocco!\n\n"
            "I can help you with:\n"
            "• 🗺️ Itinerary planning\n"
            "• 🏨 Accommodation advice\n"
            "• 🍽️ Restaurant recommendations\n"
            "• 🐪 Activity suggestions\n"
            "• 🌤️ Best travel times\n\n"
            "What would you like to explore today?",
        isUser: false,
      ));
    } catch (e) {
      _initError = e.toString();
    }
  }

  // ... (Keep your _sendMessage, _scrollToBottom, _resetChat, _showInfoDialog, and dispose methods exactly as they were)
  Future<void> _sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty || _isLoading) return;
    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();
    final response = await _gemini.sendMessage(message);
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: response, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _gemini.resetChat();
      _messages.add(_ChatMessage(
        text: "✨ Chat reset! How can I help you plan your Morocco trip?",
        isUser: false,
      ));
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About AI Assistant'),
        content: const Text(
          'This AI travel assistant is powered by Google Gemini.\n\n'
          'Ask anything about Southeast Morocco — itineraries, riads, '
          'activities, food, culture, or hidden gems!',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) return _buildErrorScreen();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
              child: const Icon(Icons.explore, color: AppTheme.primaryOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Travel Guide', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('Online Now', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.grey), onPressed: _resetChat),
          IconButton(icon: const Icon(Icons.info_outline_rounded, color: Colors.grey), onPressed: _showInfoDialog),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_messages.length == 1 ? 1 : 0),
              itemBuilder: (context, index) {
                if (_messages.length == 1 && index == 1) return _buildSuggestions(theme);
                final msg = _messages[index];
                return _buildChatBubble(msg, theme);
              },
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.isUser) _buildAvatar(Icons.auto_awesome, AppTheme.deepBlue),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: msg.isUser 
                        ? AppTheme.primaryOrange 
                        : (isDark ? AppTheme.darkCard : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: msg.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (msg.isUser) _buildAvatar(Icons.person, AppTheme.sandBeige),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(IconData icon, Color bgColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return FadeInUp( // Custom animation feel
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _suggestionChip('🐪 Best camel treks', theme),
              _suggestionChip('🏨 Top riads', theme),
              _suggestionChip('🌅 Sahara tips', theme),
              _suggestionChip('🍽️ Local food', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionChip(String label, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: TextStyle(fontSize: 12, color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
        onPressed: () => _sendMessage(label),
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        side: BorderSide(color: AppTheme.primaryOrange.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: _isLoading ? 'AI is thinking...' : 'Plan your trip...',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    prefixIcon: _isLoading 
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)))
                      : const Icon(Icons.chat_bubble_outline, size: 20),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isLoading ? null : () => _sendMessage(_controller.text),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryOrange,
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text('Connection Error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(_initError ?? "Please check your settings"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Simple animation helper (Optional: You can replace with your own or remove)
class FadeInUp extends StatelessWidget {
  final Widget child;
  const FadeInUp({required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Opacity(opacity: value, child: Padding(padding: EdgeInsets.only(top: (1 - value) * 20), child: child));
      },
      child: child,
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}