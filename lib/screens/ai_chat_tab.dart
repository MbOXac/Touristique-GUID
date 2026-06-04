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

  @override
  Widget build(BuildContext context) {
    if (_initError != null) return _buildErrorScreen();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Travel Assistant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'New conversation', onPressed: _resetChat),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: _showInfoDialog),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_messages.length == 1 ? 1 : 0),
              itemBuilder: (context, index) {
                if (_messages.length == 1 && index == 1) return _buildSuggestions(theme);
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: msg.isUser ? _buildUserMessage(msg.text, theme) : _buildAssistantMessage(msg.text, theme),
                );
              },
            ),
          ),
          if (_isLoading) _buildTypingIndicator(theme),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick suggestions:',
            style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _suggestionChip('🐪 Best camel treks', theme),
              _suggestionChip('🏨 Top riads to stay', theme),
              _suggestionChip('🌅 Sahara sunrise tips', theme),
              _suggestionChip('📅 3-day itinerary', theme),
              _suggestionChip('🍽️ Local food guide', theme),
              _suggestionChip('🗺️ Hidden gems', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantMessage(String text, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.primaryOrange : AppTheme.deepBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : const Color(0xFFF0F4FF),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
            ),
            child: SelectableText(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildUserMessage(String text, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: SelectableText(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: AppTheme.sandBeige, shape: BoxShape.circle),
          child: const Icon(Icons.person_rounded, color: AppTheme.earthBrown, size: 20),
        ),
      ],
    );
  }

  Widget _suggestionChip(String label, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextPrimary : Colors.black87)),
      onPressed: () => _sendMessage(label),
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.sandBeige,
      side: const BorderSide(color: AppTheme.primaryOrange),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.primaryOrange : AppTheme.deepBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryOrange),
          ),
          const SizedBox(width: 12),
          Text(
            'AI is thinking...',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isLoading,
                textInputAction: TextInputAction.send,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Ask about Southeast Morocco...',
                  hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _isLoading ? Colors.grey : AppTheme.primaryOrange,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Travel Assistant'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('Chatbot Configuration Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(_initError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('Make sure you created the .env file with your GEMINI_API_KEY.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About AI Assistant'),
        content: const Text(
          'This AI travel assistant is powered by Google Gemini.\n\n'
          'Ask anything about Southeast Morocco — itineraries, riads, '
          'activities, food, culture, or hidden gems!\n\n'
          'Replies are in the same language you write in.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
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

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}