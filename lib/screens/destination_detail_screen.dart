import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination.dart';
import '../models/activity.dart';
import '../models/favorite_item.dart';
import '../models/review.dart';
import '../services/activity_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_radius.dart';
import '../widgets/activity_console.dart';
import '../widgets/favorite_button.dart';
import '../widgets/reviews_section.dart';
import 'add_trip_screen.dart';
import 'hotel_search_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final ActivityService _activityService = ActivityService();
  late Stream<List<Activity>> _activitiesStream;

  @override
  void initState() {
    super.initState();
    _activitiesStream = _activityService.streamActivitiesByLocation(widget.destination.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tags = widget.destination.tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final primaryTag = tags.isNotEmpty ? tags.first : '';
    final secondaryTags = tags.length > 1 ? tags.sublist(1) : <String>[];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomActions(theme),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.destination.imageURLs.isNotEmpty
                      ? Image.network(
                          widget.destination.imageURLs[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(color: AppTheme.primaryOrange, strokeWidth: 3),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                            child: Icon(Icons.landscape_outlined,
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, size: 64),
                          ),
                        )
                      : Container(
                          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                          child: Icon(Icons.landscape_outlined,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, size: 64),
                        ),
                  // Subtle fade at the very bottom only, just enough to seat the
                  // floating buttons — no on-image title/rating text anymore.
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppTheme.cardOverlayGradient),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(120),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withAlpha(60)),
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                            FavoriteButton(
                              type: FavoriteType.destination,
                              itemId: widget.destination.id,
                              title: widget.destination.name,
                              subtitle: widget.destination.tags,
                              imageUrl: widget.destination.imageURLs.isNotEmpty
                                  ? widget.destination.imageURLs.first
                                  : '',
                              rating: widget.destination.rating,
                              background: Colors.black.withAlpha(120),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.destination.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.titleLarge?.color,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 16, color: theme.textTheme.bodyMedium?.color),
                          const SizedBox(width: 4),
                          Text(
                            widget.destination.distance,
                            style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.goldAccent, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.destination.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppTheme.goldAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.destination.reviewsCount})',
                            style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                          ),
                          if (primaryTag.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.terracotta.withAlpha(30),
                                borderRadius: BorderRadius.circular(AppRadius.chip),
                              ),
                              child: Text(
                                primaryTag,
                                style: const TextStyle(
                                  color: AppTheme.terracotta,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (secondaryTags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: secondaryTags
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.sandBeige.withAlpha(isDark ? 60 : 140),
                                      borderRadius: BorderRadius.circular(AppRadius.chip),
                                    ),
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        color: AppTheme.earthBrown,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _sectionTitle('About', theme),
                      const SizedBox(height: 12),
                      Text(
                        widget.destination.description,
                        style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color, height: 1.65),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: theme.dividerColor),
              ],
            ),
          ),
          StreamBuilder<List<Activity>>(
            stream: _activitiesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Activities', theme),
                        const SizedBox(height: 20),
                        const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryOrange, strokeWidth: 3),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Activities', theme),
                        const SizedBox(height: 16),
                        Center(
                          child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red.shade400)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final activities = snapshot.data ?? [];
              if (activities.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Activities', theme),
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.local_activity_outlined,
                                    size: 34, color: theme.textTheme.bodyMedium?.color),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No activities for: ${widget.destination.name}',
                                style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: ActivityConsole(activities: activities, onActivityTap: () {}),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Reviews', theme),
                  const SizedBox(height: 14),
                  ReviewsSection(
                    entityType: ReviewEntityType.destination,
                    entityId: widget.destination.id,
                    fallbackRating: widget.destination.rating,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Location', theme),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _showMapSheet(context, theme),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : AppTheme.sandBeige.withAlpha(110),
                        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.sandBeige,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 40,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.earthBrown,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to view on the map',
                              style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleLarge?.color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  void _showMapSheet(BuildContext context, ThemeData theme) {
    final point = LatLng(widget.destination.lat, widget.destination.lng);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            child: FlutterMap(
              options: MapOptions(initialCenter: point, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.example.touristique_guid',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 46,
                      height: 46,
                      child: const Icon(Icons.location_on_rounded, color: AppTheme.primaryOrange, size: 42),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 80 : 20),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTripScreen()),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add to trip', overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HotelSearchScreen()),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              ),
              icon: const Icon(Icons.hotel_rounded, size: 18),
              label: const Text('Book a stay nearby', overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}