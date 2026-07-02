import 'package:flutter/material.dart';
import '../models/circuit.dart';
import '../screens/circuit_detail_screen.dart';
import '../theme/app_theme.dart';
import 'rating_badge.dart';

class CircuitCard extends StatelessWidget {
  final Circuit circuit;

  const CircuitCard({super.key, required this.circuit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final placeholderBg = isDark ? AppTheme.darkCard : Colors.grey.shade200;
    final placeholderIconColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CircuitDetailScreen(circuit: circuit),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 70 : 30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Image + type badge ──────────────────────────
                Stack(
                  children: [
                    SizedBox(
                      width: 130,
                      height: double.infinity,
                      child: Hero(
                        tag: 'circuit-${circuit.id}',
                        child: circuit.imageUrl.isNotEmpty
                            ? Image.network(
                                circuit.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: placeholderBg,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryOrange,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: placeholderBg,
                                  child: Icon(circuit.typeIcon,
                                      color: placeholderIconColor, size: 40),
                                ),
                              )
                            : Container(
                                color: placeholderBg,
                                child: Icon(circuit.typeIcon,
                                    color: placeholderIconColor, size: 40),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(circuit.typeIcon,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              _capitalize(circuit.type),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ─── Details ─────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              circuit.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.titleLarge?.color,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 13,
                                    color: theme.textTheme.bodyMedium?.color),
                                const SizedBox(width: 4),
                                Text(
                                  circuit.durationText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                RatingBadge(
                                  rating: circuit.rating,
                                  reviewCount: circuit.reviewsCount,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _difficultyBadge(),
                            Text(
                              circuit.formattedPrice,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _difficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: circuit.difficultyColor.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: circuit.difficultyColor.withAlpha(90)),
      ),
      child: Text(
        _capitalize(circuit.difficulty),
        style: TextStyle(
          color: circuit.difficultyColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
