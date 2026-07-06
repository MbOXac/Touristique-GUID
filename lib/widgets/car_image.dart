import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget image;

    if (_isNetwork) {
      image = Image.network(
        imageUrl,
        height: height,
        width: width,
        cacheWidth: cacheWidth,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(isDark),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loading(isDark);
        },
      );
    } else {
      image = Image.asset(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(isDark),
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

  Widget _placeholder(bool isDark) {
    return Container(
      height: height,
      width: width,
      color: isDark ? AppTheme.darkCard : AppTheme.sandBeige.withAlpha(120),
      child: Icon(
        Icons.directions_car,
        size: 60,
        color: isDark ? Colors.grey.shade600 : AppTheme.earthBrown.withAlpha(150),
      ),
    );
  }

  Widget _loading(bool isDark) {
    return Container(
      height: height,
      width: width,
      color: isDark ? AppTheme.darkCard : AppTheme.softBackground,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryOrange,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
