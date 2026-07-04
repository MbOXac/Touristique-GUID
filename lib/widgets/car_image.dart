import 'package:flutter/material.dart';

/// Reusable car image widget.
/// Automatically loads network URLs (http/https) or local assets.
class CarImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final int? cacheWidth;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CarImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.cacheWidth,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  bool get _isNetwork =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (_isNetwork) {
      image = Image.network(
        imageUrl,
        height: height,
        width: width,
        cacheWidth: cacheWidth,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loading();
        },
      );
    } else {
      image = Image.asset(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Icon(
        Icons.directions_car,
        size: 60,
        color: Colors.grey,
      ),
    );
  }

  Widget _loading() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
