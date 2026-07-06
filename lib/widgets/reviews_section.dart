import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';
import 'review_dialog.dart';
import 'review_tile.dart';
import 'star_rating.dart';

/// Drop-in "Reviews" block: aggregate rating + star breakdown + write/edit
/// CTA + live list of reviews. Used by screens that don't already have a
/// bespoke reviews tab (destinations, activities).
class ReviewsSection extends StatelessWidget {
  final ReviewEntityType entityType;
  final String entityId;
  final double fallbackRating;

  const ReviewsSection({
    super.key,
    required this.entityType,
    required this.entityId,
    this.fallbackRating = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final reviewService = ReviewService();

    return StreamBuilder<List<Review>>(
      stream: reviewService.streamReviews(entityType, entityId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <Review>[];
        final avg = reviews.isEmpty
            ? fallbackRating
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

        return StreamBuilder<Review?>(
          stream: reviewService.streamMyReview(entityType, entityId),
          builder: (context, myReviewSnapshot) {
            final myReview = myReviewSnapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AggregateCard(rating: avg, reviews: reviews),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ReviewDialog.show(
                      context,
                      entityType: entityType,
                      entityId: entityId,
                      existingReview: myReview,
                    ),
                    icon: Icon(myReview != null ? Icons.edit_rounded : Icons.rate_review_outlined,
                        size: 18),
                    label: Text(myReview != null ? 'Edit your Review' : 'Write a Review'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryOrange,
                      side: const BorderSide(color: AppTheme.primaryOrange),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (reviews.isEmpty)
                  _EmptyReviews(theme: Theme.of(context))
                else
                  ...reviews.map((r) => ReviewTile(
                        review: r,
                        isOwnReview: r.userId == reviewService.currentUserId,
                      )),
              ],
            );
          },
        );
      },
    );
  }
}

class _AggregateCard extends StatelessWidget {
  final double rating;
  final List<Review> reviews;

  const _AggregateCard({required this.rating, required this.reviews});

  double _starFraction(Map<int, double> breakdown, int star) => breakdown[star] ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final breakdown = ReviewService.ratingBreakdown(reviews);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              StarRatingDisplay(rating: rating, size: 16),
              const SizedBox(height: 4),
              Text(
                '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final fraction = _starFraction(breakdown, star);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: TextStyle(
                              fontSize: 11, color: theme.textTheme.bodyMedium?.color)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 6,
                            backgroundColor: theme.dividerColor,
                            valueColor:
                                const AlwaysStoppedAnimation(AppTheme.goldAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  final ThemeData theme;
  const _EmptyReviews({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined,
              size: 48, color: theme.textTheme.bodyMedium?.color?.withAlpha(120)),
          const SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to share your experience',
            style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }
}
