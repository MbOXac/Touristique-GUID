import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_console.dart';

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
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
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x55000000), Color(0xCC000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GestureDetector(
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
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.destination.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [Shadow(offset: Offset(0, 2), blurRadius: 6, color: Color(0x88000000))],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldAccent.withAlpha(230),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.destination.rating.toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(120),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withAlpha(50)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.near_me_rounded, color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.destination.distance,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                  ],
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('About this destination', theme),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 60 : 12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'This is a beautiful and culturally rich destination in Southeast Morocco. Experience authentic Moroccan culture, stunning landscapes, and unforgettable adventures.',
                      style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color, height: 1.65),
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
}