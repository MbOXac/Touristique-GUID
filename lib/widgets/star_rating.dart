import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Read-only row of stars for displaying a rating (e.g. inside a review tile).
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
          color: color ?? AppTheme.goldAccent,
          size: size,
        );
      }),
    );
  }
}

/// Tappable row of stars used to pick a rating in the review dialog.
class StarRatingInput extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        final filled = starValue <= rating.round();
        return GestureDetector(
          onTap: () => onChanged(starValue.toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppTheme.goldAccent,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
