import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gallery_item.dart';
import '../services/gallery_service.dart';

class ImageCard extends StatefulWidget {
  final GalleryItem item;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onUserTap;

  const ImageCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLike,
    this.onSave,
    this.onUserTap,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  final galleryService = GalleryService();
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkLikeAndSave();
  }

  void _checkLikeAndSave() {
    final userId = galleryService.currentUserId;
    if (userId != null) {
      setState(() {
        _isLiked = widget.item.isLikedBy(userId);
        _isSaved = widget.item.isSavedBy(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: widget.item.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                // Category Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.item.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Save Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isSaved = !_isSaved);
                      widget.onSave?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // User Info
                  GestureDetector(
                    onTap: widget.onUserTap,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: widget.item.uploaderAvatar.isNotEmpty
                              ? CachedNetworkImageProvider(widget.item.uploaderAvatar)
                              : null,
                          child: widget.item.uploaderAvatar.isEmpty
                              ? const Icon(Icons.person, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.item.uploaderName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stats
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _isLiked = !_isLiked);
                          widget.onLike?.call();
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: _isLiked ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.item.likes}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 18, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.item.views}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}