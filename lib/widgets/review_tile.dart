import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';
import 'star_rating.dart';
import 'review_dialog.dart';

class ReviewTile extends StatelessWidget {
  final Review review;
  final bool isOwnReview;

  const ReviewTile({
    super.key,
    required this.review,
    this.isOwnReview = false,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months mo${months == 1 ? '' : 's'} ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOwnReview
              ? AppTheme.primaryOrange.withAlpha(80)
              : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryOrange.withAlpha(40),
                backgroundImage:
                    review.userAvatar.isNotEmpty ? NetworkImage(review.userAvatar) : null,
                child: review.userAvatar.isEmpty
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primaryOrange, fontWeight: FontWeight.w800),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.userName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        if (isOwnReview) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('You',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryOrange)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StarRatingDisplay(rating: review.rating, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          review.wasEdited
                              ? '${_timeAgo(review.updatedAt!)} (edited)'
                              : _timeAgo(review.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwnReview)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      size: 18, color: theme.textTheme.bodyMedium?.color),
                  onSelected: (value) {
                    if (value == 'edit') {
                      ReviewDialog.show(
                        context,
                        entityType: review.entityType,
                        entityId: review.entityId,
                        existingReview: review,
                      );
                    } else if (value == 'delete') {
                      ReviewService().deleteMyReview(review.entityType, review.entityId);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
