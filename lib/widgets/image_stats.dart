import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Likes',
            value: likes.toString(),
            color: isLiked ? Colors.red : Colors.grey,
            onTap: onLikeTap,
          ),
          _buildStatButton(
            icon: Icons.visibility,
            label: 'Views',
            value: views.toString(),
            onTap: () {},
          ),
          _buildStatButton(
            icon: Icons.comment_outlined,
            label: 'Comments',
            value: comments.toString(),
            onTap: onCommentTap,
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required String label,
    required String value,
    Color color = Colors.grey,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}