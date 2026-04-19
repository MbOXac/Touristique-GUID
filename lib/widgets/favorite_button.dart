import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final ValueChanged<bool>? onChanged;

  const FavoriteButton({super.key, required this.isFavorited, this.onChanged});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late bool _isFavorited;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isFavorited = !_isFavorited);
    _controller.forward().then((_) => _controller.reverse());
    widget.onChanged?.call(_isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        onPressed: _toggle,
        icon: Icon(
          _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _isFavorited ? Colors.red : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
