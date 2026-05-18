import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';
import 'activity_detail_modal.dart';

class ActivityConsole extends StatelessWidget {
  final List<Activity> activities;
  final VoidCallback? onActivityTap;

  const ActivityConsole({
    super.key,
    required this.activities,
    this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryOrange, Color(0xFFE8830A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_activity_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepBlue,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.deepBlue.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activities.length} available',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityCard(context, activity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final categoryColor = _getCategoryColor(activity.category);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ActivityDetailModal(activity: activity),
        );
      },
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withAlpha(30),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: categoryColor.withAlpha(30),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon with gradient background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withAlpha(40),
                      categoryColor.withAlpha(70),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(activity.category),
                  color: categoryColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              // Activity name
              Expanded(
                child: Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepBlue,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              // Duration row
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 11, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      activity.duration,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Price
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withAlpha(18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity.price,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'nature':
        return Icons.eco_rounded;
      case 'adventure':
        return Icons.terrain_rounded;
      case 'cultural':
        return Icons.account_balance_rounded;
      case 'water':
        return Icons.water_rounded;
      case 'hiking':
        return Icons.hiking_rounded;
      case 'sports':
        return Icons.sports_rounded;
      default:
        return Icons.local_activity_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'nature':
        return const Color(0xFF27AE60);
      case 'adventure':
        return const Color(0xFFE74C3C);
      case 'cultural':
        return const Color(0xFF8E44AD);
      case 'water':
        return const Color(0xFF2980B9);
      case 'hiking':
        return const Color(0xFF795548);
      case 'sports':
        return const Color(0xFFFF6B35);
      default:
        return AppTheme.primaryOrange;
    }
  }
}