import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ImageStats extends StatelessWidget {
  final int likes;
  final int views;
  final int comments;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const ImageStats({
    super.key,
    required this.likes,
    required this.views,
    required this.comments,
    required this.isLiked,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatButton(
            theme: theme,
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Likes',
            value: likes.toString(),
            color: isLiked ? AppTheme.terracotta : mutedColor,
            onTap: onLikeTap,
          ),
          _buildStatButton(
            theme: theme,
            icon: Icons.visibility,
            label: 'Views',
            value: views.toString(),
            color: mutedColor,
            onTap: () {},
          ),
          _buildStatButton(
            theme: theme,
            icon: Icons.comment_outlined,
            label: 'Comments',
            value: comments.toString(),
            color: mutedColor,
            onTap: onCommentTap,
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color ?? theme.textTheme.bodyMedium?.color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: theme.textTheme.titleSmall?.color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}