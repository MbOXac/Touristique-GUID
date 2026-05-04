import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'rating_badge.dart';

class PreviewCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final double? rating;
  final VoidCallback? onTap;
  final Widget? badge;

  const PreviewCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.rating,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image fills full card
              Positioned.fill(
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(180),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
              ),
              // Content at bottom
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (rating != null) ...[
                      const SizedBox(height: 4),
                      RatingBadge(rating: rating!),
                    ],
                  ],
                ),
              ),
              // Badge top right
              if (badge != null) Positioned(top: 8, right: 8, child: badge!),
            ],
          ),
        ),
      ),
    );
  }
}
