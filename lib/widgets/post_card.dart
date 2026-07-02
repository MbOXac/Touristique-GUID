import 'package:flutter/material.dart';
import '../models/social_post_ui.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(post.userPhotoUrl)),
            title: Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 260,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : null,
                  ),
                ),
                Text('${post.likesCount}'),
                IconButton(onPressed: onComment, icon: const Icon(Icons.mode_comment_outlined)),
                Text('${post.commentsCount}'),
                const Spacer(),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(post.isSaved ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(post.caption),
          ),
        ],
      ),
    );
  }
}