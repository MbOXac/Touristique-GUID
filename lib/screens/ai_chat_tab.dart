import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';
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
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.softBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.softBackground,
        centerTitle: false,
        title: Text(
          'Touristique Guid AI',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.deepBlue,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
            onPressed: _resetChat,
          ),
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? AppTheme.primaryOrange
                        : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.cardLarge),
                      topRight: const Radius.circular(AppRadius.cardLarge),
                      bottomLeft: Radius.circular(msg.isUser ? AppRadius.cardLarge : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : AppRadius.cardLarge),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: msg.isUser
                          ? Colors.white
                          : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (msg.isUser) _buildAvatar(Icons.person, AppTheme.goldAccent),
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
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextPrimary,
        ),
        onPressed: () => _sendMessage(label),
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.chip)),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.softBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.button),
          topRight: Radius.circular(AppRadius.button),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 20)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                  decoration: InputDecoration(
                    hintText: _isLoading ? 'AI is thinking...' : 'Ask about your Sahara trip...',
                    hintStyle: TextStyle(fontSize: 14, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    prefixIcon: _isLoading
                        ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)))
                        : null,
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
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
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