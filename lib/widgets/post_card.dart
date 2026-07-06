import 'package:flutter/material.dart';
import '../models/social_post_ui.dart';
import '../theme/app_theme.dart';

class PostCard extends StatelessWidget {
  final SocialPostUi post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 70 : 30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(post.userPhotoUrl),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    post.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 260,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onLike,
                    icon: Icon(
                      post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: post.isLiked ? AppTheme.terracotta : theme.iconTheme.color,
                    ),
                  ),
                  Text('${post.likesCount}', style: theme.textTheme.bodyMedium),
                  IconButton(
                    onPressed: onComment,
                    icon: Icon(Icons.mode_comment_outlined, color: theme.iconTheme.color),
                  ),
                  Text('${post.commentsCount}', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: onSave,
                    icon: Icon(
                      post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: post.isSaved ? AppTheme.goldAccent : theme.iconTheme.color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(post.caption, style: theme.textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}
