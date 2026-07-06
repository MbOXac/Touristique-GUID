import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/favorite_item.dart';
import '../screens/destination_detail_screen.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final placeholderBg = isDark ? AppTheme.darkCard : Colors.grey.shade200;
    final placeholderIconColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(destination: destination),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              SizedBox(
                height: 240,
                width: double.infinity,
                child: destination.imageURLs.isNotEmpty
                    ? Image.network(
                        destination.imageURLs[0],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
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
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: placeholderBg,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.landscape_outlined, color: placeholderIconColor, size: 52),
                              const SizedBox(height: 8),
                              Text(
                                destination.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: placeholderIconColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        color: placeholderBg,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.landscape_outlined, color: placeholderIconColor, size: 52),
                            const SizedBox(height: 8),
                            Text(
                              destination.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: placeholderIconColor),
                            ),
                          ],
                        ),
                      ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppTheme.cardOverlayGradient),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FavoriteButton(
                  type: FavoriteType.destination,
                  itemId: destination.id,
                  title: destination.name,
                  subtitle: destination.tags,
                  imageUrl: destination.imageURLs.isNotEmpty ? destination.imageURLs.first : '',
                  rating: destination.rating,
                  size: 20,
                  background: Colors.black.withAlpha(120),
                ),
              ),
              Positioned(
                top: 58,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded, color: Colors.white, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        destination.distance,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withAlpha(230),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        destination.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        destination.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x88000000))],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        destination.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(200),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildInfoChip(Icons.explore_outlined, destination.distance),
                          const SizedBox(width: 8),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: AppTheme.orangeGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Explore',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
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
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withAlpha(200), size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}