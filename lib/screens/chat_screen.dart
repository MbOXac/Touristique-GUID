import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    const ChatMessage.bot(
      "Hi! I'm your AI travel assistant for Southeast Morocco.\n\nAsk me about itineraries, riads, activities, or hidden gems.",
    ),
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? presetMessage}) async {
    final text = (presetMessage ?? _messageController.text).trim();
    if (text.isEmpty) {
      _showSnackBar('Please enter a message.');
      return;
    }
    if (_isSending) {
      _showSnackBar('Please wait for the current response.');
      return;
    }

    setState(() {
      _isSending = true;
      _messages.add(ChatMessage.user(text));
      _messages.add(const ChatMessage.loading());
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final aiChatService = AiChatService.instance;
      final reply = await aiChatService.sendMessage(text);
      setState(() {
        _replaceLoadingMessage(ChatMessage.bot(reply));
      });
    } catch (error) {
      String errorMessage = 'Something went wrong...';
      if (error is AiChatException) {
        if (error.code == 'auth_error') {
          errorMessage = 'Authentication failed. Please log in again.';
        } else if (error.code == 'network_error') {
          errorMessage = 'Network error. Check your connection.';
        } else if (error.code == 'api_error') {
          errorMessage = 'Service temporarily unavailable. Try again.';
        } else {
          errorMessage = error.message;
        }
      } else {
        errorMessage = error.toString();
      }
      setState(() {
        _replaceLoadingMessage(ChatMessage.error(errorMessage));
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _replaceLoadingMessage(ChatMessage message) {
    final index = _messages.lastIndexWhere((message) => message.isLoading);
    if (index == -1) {
      _messages.add(message);
    } else {
      _messages[index] = message;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Travel Assistant'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMessageBubble(_messages[index]),
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final bubbleColor = message.isError
        ? const Color(0xFFFFEBEE)
        : (isUser ? AppTheme.primaryOrange : const Color(0xFFF0F4FF));
    final textColor = isUser ? Colors.white : Colors.black87;
    final errorColor = message.isError ? const Color(0xFFC62828) : textColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) _buildAssistantAvatar(),
        if (!isUser) const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: message.isError
                  ? Border.all(color: const Color(0xFFFFCDD2))
                  : null,
            ),
            child: message.isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thinking...',
                        style: TextStyle(fontSize: 13, color: errorColor),
                      ),
                    ],
                  )
                : Text(
                    message.text,
                    style: TextStyle(fontSize: 14, height: 1.5, color: errorColor),
                  ),
          ),
        ),
        if (isUser) const SizedBox(width: 10),
        if (isUser) _buildUserAvatar(),
      ],
    );
  }

  Widget _buildAssistantAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(color: AppTheme.deepBlue, shape: BoxShape.circle),
      child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(color: AppTheme.sandBeige, shape: BoxShape.circle),
      child: const Icon(Icons.person_rounded, color: AppTheme.earthBrown, size: 20),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withAlpha(76))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Ask about Southeast Morocco...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isSending ? Colors.grey.shade400 : AppTheme.primaryOrange,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _isSending ? null : () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.isLoading = false,
  });

  const ChatMessage.user(String message)
      : text = message,
        isUser = true,
        isError = false,
        isLoading = false;

  const ChatMessage.bot(String message)
      : text = message,
        isUser = false,
        isError = false,
        isLoading = false;

  const ChatMessage.error(String message)
      : text = message,
        isUser = false,
        isError = true,
        isLoading = false;

  const ChatMessage.loading()
      : text = '',
        isUser = false,
        isError = false,
        isLoading = true;

  final String text;
  final bool isUser;
  final bool isError;
  final bool isLoading;
}
