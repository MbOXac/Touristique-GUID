import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/booking.dart';
import '../models/circuit.dart';
import '../models/review.dart';
import '../services/circuit_service.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';
import '../widgets/circuit_day_card.dart';
import '../widgets/circuit_route_map.dart';
import '../widgets/rating_badge.dart';
import '../widgets/review_dialog.dart';
import '../widgets/review_tile.dart';
import 'booking_form_screen.dart';

class CircuitDetailScreen extends StatefulWidget {
  final Circuit circuit;

  const CircuitDetailScreen({super.key, required this.circuit});

  @override
  State<CircuitDetailScreen> createState() => _CircuitDetailScreenState();
}

class _CircuitDetailScreenState extends State<CircuitDetailScreen>
    with SingleTickerProviderStateMixin {
  final CircuitService _circuitService = CircuitService();
  final ReviewService _reviewService = ReviewService();
  late final TabController _tabController;
  final MapController _mapController = MapController();

  bool _isFavorited = false;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFavoriteState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteState() async {
    final fav =
        await _circuitService.isCircuitFavorited(widget.circuit.id, _userId);
    if (mounted) setState(() => _isFavorited = fav);
  }

  Future<void> _toggleFavorite() async {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save circuits')),
      );
      return;
    }
    setState(() => _isFavorited = !_isFavorited);
    await _circuitService.toggleFavoriteCircuit(widget.circuit.id, _userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorited
              ? 'Added to favorites'
              : 'Removed from favorites'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share: ${widget.circuit.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuit = widget.circuit;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(theme, circuit),
          SliverToBoxAdapter(child: _buildHeaderInfo(theme, circuit)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppTheme.primaryOrange,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                indicatorColor: AppTheme.primaryOrange,
                indicatorWeight: 3,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Itinerary'),
                  Tab(text: 'Map'),
                  Tab(text: 'Reviews'),
                ],
              ),
              theme,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(theme, circuit),
            _buildItineraryTab(theme, circuit),
            _buildMapTab(theme, circuit),
            _buildReviewsTab(theme, circuit),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme, circuit),
    );
  }

  // ─── SliverAppBar (hero + parallax) ─────────────────────────
  Widget _buildSliverAppBar(ThemeData theme, Circuit circuit) {
    final isDark = theme.brightness == Brightness.dark;
    return SliverAppBar(
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
            Hero(
              tag: 'circuit-${circuit.id}',
              child: circuit.imageUrl.isNotEmpty
                  ? Image.network(
                      circuit.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryOrange, strokeWidth: 3),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                        child: Icon(circuit.typeIcon,
                            color: Colors.grey, size: 64),
                      ),
                    )
                  : Container(
                      color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                      child: Icon(circuit.typeIcon, color: Colors.grey, size: 64),
                    ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(Icons.arrow_back_rounded,
                          () => Navigator.pop(context)),
                      Row(
                        children: [
                          _circleButton(Icons.share_rounded, _share),
                          const SizedBox(width: 8),
                          _circleButton(
                            _isFavorited
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            _toggleFavorite,
                            iconColor:
                                _isFavorited ? Colors.red : Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap,
      {Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(120),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(60)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // ─── Title / rating / price block ───────────────────────────
  Widget _buildHeaderInfo(ThemeData theme, Circuit circuit) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            circuit.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.titleLarge?.color,
              letterSpacing: -0.4,
            ),
          ),
          if (circuit.titleAr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  circuit.titleAr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              RatingBadge(
                  rating: circuit.rating, reviewCount: circuit.reviewsCount),
              const SizedBox(width: 14),
              Icon(Icons.schedule_rounded,
                  size: 15, color: theme.textTheme.bodyMedium?.color),
              const SizedBox(width: 4),
              Text(
                circuit.durationText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const Spacer(),
              Text(
                circuit.formattedPrice,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(circuit.difficultyColor,
                  Icons.fitness_center_rounded, _capitalize(circuit.difficulty)),
              const SizedBox(width: 8),
              _infoChip(AppTheme.deepBlue, circuit.typeIcon,
                  _capitalize(circuit.type)),
              const SizedBox(width: 8),
              _infoChip(AppTheme.earthBrown, Icons.groups_rounded,
                  'Max ${circuit.maxGroupSize}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: Overview ────────────────────────────────────────
  Widget _buildOverviewTab(ThemeData theme, Circuit circuit) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          circuit.description,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 22),

        // What's included
        if (circuit.includedServices.isNotEmpty) ...[
          _sectionTitle(theme, "What's Included"),
          const SizedBox(height: 10),
          ...circuit.includedServices.map(
            (s) => _bulletRow(theme, Icons.check_circle_rounded,
                AppTheme.oasisGreen, s),
          ),
          const SizedBox(height: 20),
        ],

        // Not included
        if (circuit.notIncluded.isNotEmpty) ...[
          _sectionTitle(theme, 'Not Included'),
          const SizedBox(height: 10),
          ...circuit.notIncluded.map(
            (s) => _bulletRow(theme, Icons.cancel_rounded,
                const Color(0xFFC0392B), s),
          ),
          const SizedBox(height: 20),
        ],

        // Meeting point + mini map
        _sectionTitle(theme, 'Meeting Point'),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: AppTheme.primaryOrange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                circuit.meetingPoint.isEmpty
                    ? 'To be confirmed'
                    : circuit.meetingPoint,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CircuitRouteMap(
          routePoints: [circuit.startLocation],
          height: 150,
          onTap: () => _tabController.animateTo(2),
        ),
        const SizedBox(height: 22),

        // Gallery preview
        if (circuit.gallery.isNotEmpty) ...[
          _sectionTitle(theme, 'Gallery'),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: circuit.gallery.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => _showGalleryImage(circuit.gallery[index]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    circuit.gallery[index],
                    width: 150,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 150,
                      color: theme.cardColor,
                      child: const Icon(Icons.image_not_supported_rounded,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showGalleryImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: Image.network(url, fit: BoxFit.contain)),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 2: Itinerary ───────────────────────────────────────
  Widget _buildItineraryTab(ThemeData theme, Circuit circuit) {
    if (circuit.itinerary.isEmpty) {
      return Center(
        child: Text('No itinerary available',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: circuit.itinerary.length,
      itemBuilder: (context, index) {
        return CircuitDayCard(
          day: circuit.itinerary[index],
          isLast: index == circuit.itinerary.length - 1,
        );
      },
    );
  }

  // ─── TAB 3: Map ─────────────────────────────────────────────
  Widget _buildMapTab(ThemeData theme, Circuit circuit) {
    final points = circuit.routePoints.isNotEmpty
        ? circuit.routePoints
        : [circuit.startLocation, circuit.endLocation];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _centerOf(points),
            initialZoom: _fitZoomOf(points),
            maxZoom: 18,
            minZoom: 3,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
              userAgentPackageName: 'com.example.touristique_guid',
              maxZoom: 20,
              maxNativeZoom: 19,
              retinaMode: true,
            ),
            if (points.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 5,
                    color: AppTheme.primaryOrange,
                    borderColor: Colors.white,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            MarkerLayer(markers: _buildRouteMarkers(points)),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: FloatingActionButton.small(
            heroTag: 'circuit-detail-fit',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            onPressed: () => _mapController.move(
                _centerOf(points), _fitZoomOf(points)),
            child: const Icon(Icons.center_focus_strong_rounded),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildRouteMarkers(List<LatLng> points) {
    final markers = <Marker>[];
    for (var i = 0; i < points.length; i++) {
      final isStart = i == 0;
      final isEnd = i == points.length - 1;
      final color = isStart
          ? AppTheme.oasisGreen
          : isEnd
              ? const Color(0xFFC0392B)
              : AppTheme.primaryOrange;
      markers.add(
        Marker(
          point: points[i],
          width: 36,
          height: 36,
          child: GestureDetector(
            onTap: () => _showStopPopup(i, isStart, isEnd),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(90),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  void _showStopPopup(int index, bool isStart, bool isEnd) {
    String name = 'Stop ${index + 1}';
    if (index < widget.circuit.itinerary.length) {
      name = widget.circuit.itinerary[index].title;
    } else if (isStart) {
      name = 'Start: ${widget.circuit.meetingPoint}';
    } else if (isEnd) {
      name = 'End point';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${index + 1}. $name'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  LatLng _centerOf(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(31.4368, -4.2331);
    double lat = 0, lng = 0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  double _fitZoomOf(List<LatLng> points) {
    if (points.length < 2) return 9;
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }
    final span = (maxLat - minLat).abs() > (maxLng - minLng).abs()
        ? (maxLat - minLat).abs()
        : (maxLng - minLng).abs();
    if (span > 4) return 5.5;
    if (span > 2) return 6.5;
    if (span > 1) return 7.5;
    if (span > 0.4) return 8.5;
    return 9.5;
  }

  // ─── TAB 4: Reviews ─────────────────────────────────────────
  Widget _buildReviewsTab(ThemeData theme, Circuit circuit) {
    return StreamBuilder<List<Review>>(
      stream: _reviewService.streamReviews(ReviewEntityType.circuit, circuit.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <Review>[];
        final avgRating = reviews.isEmpty
            ? circuit.rating
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
        final breakdown = ReviewService.ratingBreakdown(reviews);

        return StreamBuilder<Review?>(
          stream: _reviewService.streamMyReview(ReviewEntityType.circuit, circuit.id),
          builder: (context, myReviewSnapshot) {
            final myReview = myReviewSnapshot.data;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(
                            theme.brightness == Brightness.dark ? 60 : 20),
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
                            avgRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < avgRating.round()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: AppTheme.primaryOrange,
                                size: 16,
                              );
                            }),
                          ),
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
                            final fraction = breakdown[star] ?? 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('$star',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: theme.textTheme.bodyMedium?.color)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: fraction,
                                        minHeight: 6,
                                        backgroundColor: theme.dividerColor,
                                        valueColor: const AlwaysStoppedAnimation(
                                            AppTheme.primaryOrange),
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
                ),
                const SizedBox(height: 24),
                if (reviews.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 48,
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(120)),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...reviews.map((r) => ReviewTile(
                        review: r,
                        isOwnReview: r.userId == _reviewService.currentUserId,
                      )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ReviewDialog.show(
                      context,
                      entityType: ReviewEntityType.circuit,
                      entityId: circuit.id,
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
              ],
            );
          },
        );
      },
    );
  }

  // ─── Bottom book bar ────────────────────────────────────────
  Widget _buildBottomBar(ThemeData theme, Circuit circuit) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
                theme.brightness == Brightness.dark ? 80 : 25),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'From',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                circuit.formattedPrice,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: circuit.isAvailable ? _bookCircuit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                disabledBackgroundColor:
                    AppTheme.primaryOrange.withAlpha(100),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                circuit.isAvailable
                    ? 'Book This Circuit'
                    : 'Currently Unavailable',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _bookCircuit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormScreen(
          name: widget.circuit.title,
          imageUrl: widget.circuit.imageUrl,
          type: BookingType.tour,
          pricePerPerson: widget.circuit.priceMAD,
          isCircuit: true,
          circuitDurationDays: widget.circuit.durationDays,
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────
  Widget _sectionTitle(ThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleLarge?.color,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _bulletRow(ThemeData theme, IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─── Persistent TabBar header delegate ────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final ThemeData theme;

  _TabBarDelegate(this.tabBar, this.theme);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar || oldDelegate.theme != theme;
  }
}
