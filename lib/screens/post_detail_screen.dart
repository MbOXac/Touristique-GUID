import 'package:flutter/material.dart';
import '../models/social_post_ui.dart';

class PostDetailScreen extends StatefulWidget {
  final SocialPostUi post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late SocialPostUi post;
  final _commentCtrl = TextEditingController();
  final List<String> _comments = ['Awesome!', 'Great shot 🔥'];

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  void _addComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(text);
      post = post.copyWith(commentsCount: post.commentsCount + 1);
    });
    _commentCtrl.clear();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, post),
        ),
      ),
      body: Column(
        children: [
          Image.network(post.imageUrl, height: 260, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(post.caption, style: theme.textTheme.bodyLarge),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (_, i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.cardColor,
                  child: Icon(Icons.person, size: 18, color: theme.iconTheme.color),
                ),
                title: Text(_comments[i]),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addComment,
                    icon: Icon(Icons.send, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}