import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../models/gallery_item.dart';
import '../theme/app_theme.dart';

class FullImageViewer extends StatefulWidget {
  final GalleryItem item;
  final VoidCallback? onLike;
  final VoidCallback? onSave;

  const FullImageViewer({
    super.key,
    required this.item,
    this.onLike,
    this.onSave,
  });

  @override
  State<FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<FullImageViewer> {
  bool _showUI = true;

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
            )
          : null,
      body: GestureDetector(
        onTap: () {
          setState(() => _showUI = !_showUI);
        },
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(widget.item.imageUrl),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              color: AppTheme.goldAccent,
            ),
          ),
        ),
      ),
    );
  }
}