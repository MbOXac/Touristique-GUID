import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime createdAt;
  final int likes;

  ImageComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
    this.likes = 0,
  });
}

class ImageCommentTile extends StatefulWidget {
  final ImageComment comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;

  const ImageCommentTile({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
  });

  @override
  State<ImageCommentTile> createState() => _ImageCommentTileState();
}

class _ImageCommentTileState extends State<ImageCommentTile> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: widget.comment.userAvatar.isNotEmpty
                ? CachedNetworkImageProvider(widget.comment.userAvatar)
                : null,
            child: widget.comment.userAvatar.isEmpty
                ? const Icon(Icons.person, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.comment.text,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _isLiked = !_isLiked);
                        widget.onLike?.call();
                      },
                      child: Text(
                        _isLiked ? '❤️ Liked' : 'Like',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isLiked ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: widget.onReply,
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}