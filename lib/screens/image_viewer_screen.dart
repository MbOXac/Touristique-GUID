import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import '../models/gallery_item.dart';
import '../services/gallery_service.dart';
import '../theme/app_theme.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final GalleryService _galleryService = GalleryService();
  bool _showUI = true;
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _checkLikeAndSave();
    _galleryService.incrementViews(widget.items[_currentIndex].id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkLikeAndSave() {
    final userId = _galleryService.currentUserId;
    if (userId != null) {
      final item = widget.items[_currentIndex];
      setState(() {
        _isLiked = item.isLikedBy(userId);
        _isSaved = item.isSavedBy(userId);
      });
    }
  }

  void _toggleLike() async {
    setState(() => _isLiked = !_isLiked);
    await _galleryService.toggleLike(widget.items[_currentIndex].id);
  }

  void _toggleSave() async {
    setState(() => _isSaved = !_isSaved);
    await _galleryService.toggleSave(widget.items[_currentIndex].id);
  }

  void _shareImage() {
    final item = widget.items[_currentIndex];
    Share.share(
      '${item.title}\n\n${item.imageUrl}',
      subject: item.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showUI
          ? AppBar(
              backgroundColor: Colors.black54,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareImage,
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () {
          setState(() => _showUI = !_showUI);
        },
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: widget.items.length,
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _checkLikeAndSave();
                  _galleryService.incrementViews(widget.items[index].id);
                });
              },
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    widget.items[index].imageUrl,
                  ),
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.items[index].id,
                  ),
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),

            // Bottom Info Panel
            if (_showUI)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: _buildInfoPanel(),
                ),
              ),

            // Action Buttons
            if (_showUI)
              Positioned(
                bottom: 220,
                right: 12,
                child: Column(
                  children: [
                    _buildActionButton(
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                      label: '${widget.items[_currentIndex].likes}',
                      onTap: _toggleLike,
                      color: _isLiked ? AppTheme.terracotta : Colors.white,
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      label: 'Save',
                      onTap: _toggleSave,
                      color: _isSaved ? AppTheme.goldAccent : Colors.white,
                    ),
                  ],
                ),
              ),

            // Page Counter
            if (_showUI)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.items.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    final item = widget.items[_currentIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Description
        if (item.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              item.description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // User & Location
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: item.uploaderAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(item.uploaderAvatar)
                  : null,
              child: item.uploaderAvatar.isEmpty
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.uploaderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (item.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          item.location!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Tags
        if (item.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            children: item.tags
                .take(3)
                .map(
                  (tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.white24,
                    labelStyle: const TextStyle(color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}