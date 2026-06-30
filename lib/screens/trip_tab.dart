import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/saved_trip.dart';
import '../services/trip_service.dart';
import '../theme/app_theme.dart';
import 'add_trip_screen.dart';
import 'package:flutter/rendering.dart';

class TripTab extends StatefulWidget {
  final VoidCallback? onScrollDown;
  final VoidCallback? onScrollUp;

  const TripTab({
    super.key,
    this.onScrollDown,
    this.onScrollUp,
  });

  @override
  State<TripTab> createState() => _TripTabState();
}

class _TripTabState extends State<TripTab> {
  final tripService = TripService();
  bool _bottomBarHidden = false;
  String _selectedFilter = 'all'; // all, planned, ongoing, completed

  @override
  Widget build(BuildContext context) {
    final tripService = TripService();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTrip(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Save Trip'),
      ),
      body: StreamBuilder<List<SavedTrip>>(
        stream: _selectedFilter == 'all'
            ? tripService.streamMyTrips()
            : tripService.streamTripsByStatus(_selectedFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _TripErrorState(error: snapshot.error.toString());
          }

          final trips = snapshot.data ?? [];

          return NotificationListener<UserScrollNotification>(
  onNotification: (notification) {
    if (notification.direction == ScrollDirection.reverse &&
        !_bottomBarHidden) {
      _bottomBarHidden = true;
      widget.onScrollDown?.call();
    }

    if (notification.direction == ScrollDirection.forward &&
        _bottomBarHidden) {
      _bottomBarHidden = false;
      widget.onScrollUp?.call();
    }

    return false;
  },
  child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                expandedHeight: 270,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsetsDirectional.only(start: 20, bottom: 18),
                  title: const Text(
                    'My Trips',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  background: _TripHero(trips: trips),
                ),
              ),
              // Filter Chips
              SliverToBoxAdapter(
                child: _FilterChips(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              ),
              if (trips.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      _EmptyTripsState(onAddTrip: () => _openAddTrip(context)),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TripStats(trips: trips),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          title: 'Saved trips',
                          actionText: '${trips.length} total',
                        ),
                        const SizedBox(height: 12),
                        ...trips.map((trip) => _SavedTripCard(
                              trip: trip,
                              onDelete: () =>
                                  _confirmDelete(context, tripService, trip),
                              onStatusChanged: (newStatus) =>
                                  _updateTripStatus(context, trip, newStatus),
                            )),
                      ],
                    ),
                  ),
                ),
            ],
           ), 
          );
        },
      ),
    );
  }

  static void _openAddTrip(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTripScreen()),
    );
  }

  void _updateTripStatus(
    BuildContext context,
    SavedTrip trip,
    String newStatus,
  ) async {
    try {
      await tripService.updateTripStatus(trip.id, newStatus);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip status updated to $newStatus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    TripService service,
    SavedTrip trip,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete trip?'),
        content: Text('This will remove "${trip.title}" and its data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await service.deleteTrip(trip);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip deleted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete trip: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ============ WIDGETS ============

class _FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              value: 'all',
              isSelected: selectedFilter == 'all',
              onTap: () => onFilterChanged('all'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Planned',
              value: 'planned',
              isSelected: selectedFilter == 'planned',
              onTap: () => onFilterChanged('planned'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Ongoing',
              value: 'ongoing',
              isSelected: selectedFilter == 'ongoing',
              onTap: () => onFilterChanged('ongoing'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Completed',
              value: 'completed',
              isSelected: selectedFilter == 'completed',
              onTap: () => onFilterChanged('completed'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.transparent,
      selectedColor: theme.colorScheme.primary.withAlpha(30),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.dividerColor,
        width: isSelected ? 2 : 1,
      ),
    );
  }
}

class _TripHero extends StatelessWidget {
  final List<SavedTrip> trips;

  const _TripHero({required this.trips});

  @override
  Widget build(BuildContext context) {
    final latestTrip = trips.isEmpty ? null : trips.first;
    final imageUrl = latestTrip?.photoUrls.isNotEmpty == true
        ? latestTrip!.photoUrls.first
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl == null)
          Image.asset('assets/images/destination_2.jpg', fit: BoxFit.cover)
        else
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Image.asset('assets/images/destination_2.jpg', fit: BoxFit.cover),
          ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22000000), Color(0xF21A3A5C)],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(34),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                child: Text(
                  trips.isEmpty
                      ? 'Firestore trip planner'
                      : '${trips.length} saved trip${trips.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                latestTrip == null
                    ? 'Plan your next adventure'
                    : latestTrip.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                latestTrip == null
                    ? 'Create trips and upload photos from your phone.'
                    : '${latestTrip.destination}, ${latestTrip.country} • ${_formatDateRange(latestTrip.startDate, latestTrip.endDate)}',
                style: TextStyle(
                  color: Colors.white.withAlpha(225),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripStats extends StatelessWidget {
  final List<SavedTrip> trips;

  const _TripStats({required this.trips});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = trips.where((trip) => !trip.endDate.isBefore(now)).length;
    final completed = trips.where((trip) => trip.status == 'completed').length;
    final totalPhotos =
        trips.fold<int>(0, (total, trip) => total + trip.photoUrls.length);

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.map_rounded,
            label: 'Trips',
            value: '${trips.length}',
            color: AppTheme.primaryOrange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.event_available_rounded,
            label: 'Upcoming',
            value: '$upcoming',
            color: AppTheme.oasisGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.check_circle_rounded,
            label: 'Completed',
            value: '$completed',
            color: AppTheme.deepBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.photo_library_rounded,
            label: 'Photos',
            value: '$totalPhotos',
            color: AppTheme.goldAccent,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
                theme.brightness == Brightness.dark ? 55 : 18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;

  const _SectionTitle({required this.title, this.actionText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (actionText != null)
          Text(
            actionText!,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _SavedTripCard extends StatelessWidget {
  final SavedTrip trip;
  final VoidCallback onDelete;
  final Function(String) onStatusChanged;

  const _SavedTripCard({
    required this.trip,
    required this.onDelete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
                theme.brightness == Brightness.dark ? 55 : 18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 165,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _TripImage(
                      url: trip.photoUrls.isEmpty ? null : trip.photoUrls.first),
                  const DecoratedBox(
                      decoration:
                          BoxDecoration(gradient: AppTheme.cardOverlayGradient)),
                  // Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _StatusBadge(status: trip.status),
                  ),
                  // Mood & Delete
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(100),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(trip.mood,
                              style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          tooltip: 'Delete trip',
                        ),
                      ],
                    ),
                  ),
                  // Title & Location
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Colors.white, size: 15),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${trip.destination}, ${trip.country}',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(225),
                                    fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Details Section
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dates, Photos, Travelers
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_month_rounded,
                      label: _formatDateRange(trip.startDate, trip.endDate),
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.photo_rounded,
                      label: '${trip.photoUrls.length} photos',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.people_rounded,
                      label: '${trip.travelers} travelers',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  trip.description,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 13,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Budget Progress
                if (trip.budget > 0) ...[
                  const SizedBox(height: 12),
                  _BudgetCard(trip: trip),
                ],
                // Trip Progress
                if (trip.status == 'ongoing') ...[
                  const SizedBox(height: 12),
                  _ProgressCard(trip: trip),
                ],
                // Photo Gallery
                if (trip.photoUrls.length > 1) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: trip.photoUrls.skip(1).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 58,
                          height: 58,
                          child: _TripImage(url: trip.photoUrls[index + 1]),
                        ),
                      ),
                    ),
                  ),
                ],
                // Status Change Button
                const SizedBox(height: 12),
                _StatusChangeButton(
                  currentStatus: trip.status,
                  onStatusChanged: onStatusChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      'planned' => (Colors.blue, Icons.calendar_today_rounded, 'Planned'),
      'ongoing' => (Colors.orange, Icons.play_arrow_rounded, 'Ongoing'),
      'completed' => (Colors.green, Icons.check_circle_rounded, 'Completed'),
      _ => (Colors.grey, Icons.info_rounded, 'Unknown'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final SavedTrip trip;

  const _BudgetCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = trip.budgetPercentage;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${trip.spent.toStringAsFixed(0)} / \$${trip.budget.toStringAsFixed(0)}',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.8 ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final SavedTrip trip;

  const _ProgressCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = trip.progressPercentage;
    final daysLeft = trip.daysRemaining;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Progress',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$daysLeft days left',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: theme.dividerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChangeButton extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const _StatusChangeButton({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextStatuses = {
      'planned': ['ongoing', 'completed'],
      'ongoing': ['completed'],
      'completed': ['planned'],
    }[currentStatus] ?? [];

    if (nextStatuses.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change Trip Status',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...nextStatuses.map((status) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onStatusChanged(status);
                            },
                            child: Text(
                              'Mark as ${status.capitalize()}',
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Text('Change status to ${nextStatuses.first.capitalize()}'),
      ),
    );
  }
}

class _TripImage extends StatelessWidget {
  final String? url;

  const _TripImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Image.asset('assets/images/destination_2.jpg', fit: BoxFit.cover);
    }

    if (url!.startsWith('data:image')) {
      try {
        final base64Part = url!.split(',').last;
        final bytes = base64Decode(base64Part);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Image.asset('assets/images/destination_2.jpg', fit: BoxFit.cover);
      }
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Theme.of(context).cardColor,
          child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/images/destination_2.jpg', fit: BoxFit.cover),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTripsState extends StatelessWidget {
  final VoidCallback onAddTrip;

  const _EmptyTripsState({required this.onAddTrip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.travel_explore_rounded,
                size: 46, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 18),
          Text(
            'No saved trips yet',
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first trip, choose dates, and upload photos from your phone or gallery.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color, height: 1.45),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: onAddTrip,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Save your first trip'),
          ),
        ],
      ),
    );
  }
}

class _TripErrorState extends StatelessWidget {
  final String error;

  const _TripErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('My Trips'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load trips:\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

String _formatDateRange(DateTime start, DateTime end) {
  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return _formatShortDate(start);
  }
  return '${_formatShortDate(start)} - ${_formatShortDate(end)}';
}

String _formatShortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}';
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}