import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const RatingBadge({super.key, required this.rating, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: AppTheme.goldAccent, size: 16),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.goldAccent,
            fontSize: 13,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}