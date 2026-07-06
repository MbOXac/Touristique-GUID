import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gallery_item.dart';
import '../services/gallery_service.dart';
import '../theme/app_theme.dart';

class ImageCard extends StatefulWidget {
  final GalleryItem item;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onUserTap;
  final VoidCallback? onDelete;

  const ImageCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLike,
    this.onSave,
    this.onUserTap,
    this.onDelete,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> with SingleTickerProviderStateMixin {
  final galleryService = GalleryService();
  bool _isLiked = false;
  bool _isSaved = false;

  late final AnimationController _likeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.85,
    upperBound: 1.0,
    value: 1.0,
  );

  static const Map<String, IconData> _categoryIcons = {
    'destination': Icons.location_on_rounded,
    'food': Icons.restaurant_rounded,
    'culture': Icons.museum_rounded,
    'adventure': Icons.hiking_rounded,
    'nature': Icons.park_rounded,
  };

  @override
  void initState() {
    super.initState();
    _checkLikeAndSave();
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
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

  void _handleLikeTap() {
    setState(() => _isLiked = !_isLiked);
    _likeController.forward(from: 0.85);
    widget.onLike?.call();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete image?'),
        content: Text('This will permanently remove "${widget.item.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryIcon = _categoryIcons[widget.item.category] ?? Icons.explore_rounded;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onDelete == null ? null : () => _confirmDelete(context),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 140 : 35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.loose,
          children: [
              // Photo, edge to edge — no fixed height, so the grid keeps its
              // masonry rhythm based on each image's real aspect ratio.
              CachedNetworkImage(
                imageUrl: widget.item.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                fadeInDuration: const Duration(milliseconds: 250),
                placeholder: (context, url) => Container(
                  height: 200,
                  color: isDark ? AppTheme.darkCard : const Color(0xFFE9E2D6),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: isDark ? AppTheme.darkCard : const Color(0xFFE9E2D6),
                  child: Icon(Icons.image_not_supported_rounded,
                      color: theme.textTheme.bodyMedium?.color?.withAlpha(120)),
                ),
              ),

              // Permanent bottom scrim so text is always legible over any photo
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppTheme.cardOverlayGradient),
                ),
              ),

              // Category pill, top-left
              Positioned(
                top: 10,
                left: 10,
                child: _GlassPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(categoryIcon, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        widget.item.category.isEmpty
                            ? 'General'
                            : widget.item.category[0].toUpperCase() +
                                widget.item.category.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Save button, top-right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isSaved = !_isSaved);
                    widget.onSave?.call();
                  },
                  child: _GlassCircle(
                    child: Icon(
                      _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),

              // Bottom content, sitting directly on the scrim
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        height: 1.2,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: widget.onUserTap,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.white24,
                            backgroundImage: widget.item.uploaderAvatar.isNotEmpty
                                ? CachedNetworkImageProvider(widget.item.uploaderAvatar)
                                : null,
                            child: widget.item.uploaderAvatar.isEmpty
                                ? const Icon(Icons.person, size: 11, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.item.uploaderName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleLikeTap,
                            child: ScaleTransition(
                              scale: _likeController,
                              child: Icon(
                                _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 15,
                                color: _isLiked ? const Color(0xFFFF5C6C) : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.item.likes}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.visibility_rounded, size: 13, color: Colors.white54),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.item.views}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

/// Small frosted-glass pill used for the category badge.
class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(40)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small frosted-glass circle used for the save button.
class _GlassCircle extends StatelessWidget {
  final Widget child;
  const _GlassCircle({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(90),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(40)),
          ),
          child: child,
        ),
      ),
    );
  }
}
