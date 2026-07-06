import 'package:flutter/material.dart';
import '../models/favorite_item.dart';
import '../services/favorite_service.dart';

/// A self-contained favorite/heart toggle.
/// Give it the item's identity + display data and it handles streaming its
/// own favorited state and persisting toggles to Firestore.
class FavoriteButton extends StatefulWidget {
  final FavoriteType type;
  final String itemId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? background;

  const FavoriteButton({
    super.key,
    required this.type,
    required this.itemId,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.rating = 0.0,
    this.size = 22,
    this.activeColor,
    this.inactiveColor,
    this.background,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  final FavoriteService _service = FavoriteService();
  late final Stream<bool> _favStream;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _favStream = _service.isFavoritedStream(widget.type, widget.itemId);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_busy) return;

    if (_service.currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to save favorites.')),
        );
      }
      return;
    }

    setState(() => _busy = true);
    _controller.forward().then((_) => _controller.reverse());

    try {
      await _service.toggleFavorite(
        type: widget.type,
        itemId: widget.itemId,
        title: widget.title,
        subtitle: widget.subtitle,
        imageUrl: widget.imageUrl,
        rating: widget.rating,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update favorites: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _favStream,
      builder: (context, snapshot) {
        final isFavorited = snapshot.data ?? false;

        final button = ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            onPressed: _toggle,
            icon: Icon(
              isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorited
                  ? (widget.activeColor ?? Colors.red)
                  : (widget.inactiveColor ?? Colors.grey),
              size: widget.size,
            ),
          ),
        );

        if (widget.background == null) return button;

        return Container(
          decoration: BoxDecoration(
            color: widget.background,
            shape: BoxShape.circle,
          ),
          child: button,
        );
      },
    );
  }
}
