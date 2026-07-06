import 'package:flutter/material.dart';
import '../models/circuit.dart';
import '../theme/app_theme.dart';

class CircuitDayCard extends StatefulWidget {
  final CircuitDay day;
  final bool isLast;

  const CircuitDayCard({
    super.key,
    required this.day,
    this.isLast = false,
  });

  @override
  State<CircuitDayCard> createState() => _CircuitDayCardState();
}

class _CircuitDayCardState extends State<CircuitDayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final day = widget.day;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Timeline (line + circle) ────────────────────────
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppTheme.orangeGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withAlpha(90),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${day.dayNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: AppTheme.primaryOrange.withAlpha(70),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // ─── Card content ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day image
                      if (day.imageUrl.isNotEmpty)
                        Stack(
                          children: [
                            SizedBox(
                              height: 130,
                              width: double.infinity,
                              child: Image.network(
                                day.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: isDark
                                      ? AppTheme.darkBackground
                                      : Colors.grey.shade200,
                                  child: Icon(Icons.landscape_outlined,
                                      color: isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                      size: 40),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: _distanceBadge(day),
                            ),
                          ],
                        ),

                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Day ${day.dayNumber}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryOrange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (day.imageUrl.isEmpty) ...[
                                  const Spacer(),
                                  _distanceBadge(day),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.titleLarge?.color,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (day.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                day.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                                maxLines: _expanded ? null : 2,
                                overflow: _expanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 10),

                            // Accommodation + meals
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (day.accommodation.isNotEmpty)
                                  _infoChip(theme, Icons.bed_rounded,
                                      day.accommodation),
                                if (day.meals.isNotEmpty)
                                  _infoChip(theme, Icons.restaurant_rounded,
                                      day.meals),
                              ],
                            ),

                            // Activities (expandable)
                            if (day.activities.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () =>
                                    setState(() => _expanded = !_expanded),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryOrange.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.list_alt_rounded,
                                          size: 16,
                                          color: AppTheme.primaryOrange),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${day.activities.length} activities',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryOrange,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        _expanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons
                                                .keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_expanded) ...[
                                const SizedBox(height: 8),
                                ...day.activities.map(
                                  (a) => _activityRow(theme, a),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _distanceBadge(CircuitDay day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue.withAlpha(220),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_walk_rounded,
              color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            day.distanceText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(ThemeData theme, IconData icon, String label) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackground : AppTheme.softBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.textTheme.bodyMedium?.color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow(ThemeData theme, CircuitActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Text(
              activity.time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon,
                size: 15, color: AppTheme.primaryOrange),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                if (activity.description.isNotEmpty)
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                if (activity.durationMinutes > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _durationText(activity.durationMinutes),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _durationText(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
