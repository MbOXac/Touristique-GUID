import 'package:flutter/material.dart';
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
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Stack(
          children: [
            Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (rating != null) ...[
                    const SizedBox(height: 3),
                    RatingBadge(rating: rating!),
                  ],
                ],
              ),
            ),
            if (badge != null) Positioned(top: 8, right: 8, child: badge!),
          ],
        ),
      ),
    );
  }
}
