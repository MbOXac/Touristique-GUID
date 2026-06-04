import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/destination_card.dart';
import '../widgets/section_header.dart';
import '../widgets/preview_card.dart';
import '../widgets/horizontal_carousel.dart';
import '../widgets/rating_badge.dart';
import 'gallery_screen.dart';
import 'favorites_screen.dart';
import 'bookings_screen.dart';
import 'top_rated_screen.dart';
import 'trip_memories_screen.dart';
import 'all_destinations_screen.dart';

class HomePage extends StatefulWidget {
  final void Function(int)? onTabChange;

  const HomePage({super.key, this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DestinationService _destinationService = DestinationService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topRated = MockDataService.getTopRatedPlaces().take(4).toList();
    final gallery = MockDataService.getGalleryItems().take(6).toList();
    final favorites = MockDataService.getFavoritePlaces().take(4).toList();
    final memories = MockDataService.getTripMemories().take(3).toList();
    final bookings = MockDataService.getBookings().take(2).toList();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, theme),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSearchBar(context, theme),
                const SizedBox(height: 16),
                _buildQuickActions(context, theme),
                const SizedBox(height: 16),
                _buildAiCard(context, theme),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Top Rated',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopRatedScreen())),
                ),
                HorizontalCarousel(
                  height: 180,
                  itemWidth: 160,
                  items: topRated.map((p) => PreviewCard(
                    imagePath: p.imagePath,
                    title: p.name,
                    subtitle: p.category,
                    rating: p.rating,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopRatedScreen())),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Gallery',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 290,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: gallery.length,
                      itemBuilder: (context, index) {
                        final item = gallery[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(item.imagePath, fit: BoxFit.cover),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Color(0xAA000000)],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    left: 5,
                                    child: RatingBadge(rating: item.rating),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'My Favorites',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                ),
                HorizontalCarousel(
                  height: 180,
                  itemWidth: 160,
                  items: favorites.map((p) => PreviewCard(
                    imagePath: p.imagePath,
                    title: p.name,
                    subtitle: p.address,
                    rating: p.rating,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Trip Memories',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: memories.map((m) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 40 : 15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(m.photos.first, width: 70, height: 70, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(m.mood, style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            m.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: theme.textTheme.titleLarge?.color,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_rounded, size: 12, color: theme.colorScheme.primary),
                                        const SizedBox(width: 2),
                                        Text(
                                          m.location,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.textTheme.bodyMedium?.color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textTheme.bodyMedium?.color,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Bookings',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: bookings.map((b) {
                      final statusColor = b.status.toString().contains('confirmed')
                          ? AppTheme.oasisGreen
                          : b.status.toString().contains('pending')
                              ? const Color(0xFFFF9F43)
                              : Colors.red;
                      final statusLabel = b.status.toString().split('.').last;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 40 : 15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_bookingIcon(b.type), color: Colors.white, size: 22),
                          ),
                          title: Text(
                            b.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: theme.textTheme.titleLarge?.color,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              b.details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${b.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: statusColor.withAlpha(80),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
SectionHeader(
  title: 'Explore Destinations',
  onSeeAll: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AllDestinationsScreen()),
  ),
),
              ],
            ),
          ),
          // DESTINATIONS FROM FIRESTORE - LIMIT TO 5
StreamBuilder<List<Destination>>(
  stream: _destinationService.streamAllDestinations(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading destinations...',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    if (snapshot.hasError) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text('Error: ${snapshot.error}'),
          ),
        ),
      );
    }

    var destinations = snapshot.data ?? [];

    // FILTER DESTINATIONS BY SEARCH QUERY
    if (_searchQuery.isNotEmpty) {
      destinations = destinations
          .where((dest) => dest.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (destinations.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.explore_off_rounded, size: 38, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  _searchQuery.isEmpty
                      ? 'No destinations available'
                      : 'No results for "$_searchQuery"',
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchQuery.isEmpty
                      ? 'Check back soon for new destinations'
                      : 'Try a different search term',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ⭐ LIMIT TO 5 DESTINATIONS ON HOME PAGE
    final hasMore = destinations.length > 5;
    final displayedDestinations = destinations.take(5).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // After the last destination, show the "View All" button
            if (index == displayedDestinations.length) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 4),
                child: _buildViewAllButton(context, theme, destinations.length),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DestinationCard(destination: displayedDestinations[index]),
            );
          },
          childCount: displayedDestinations.length + (hasMore ? 1 : 0),
        ),
      ),
    );
  },
),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/welcome.jpg', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xCC000000)],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(220),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '🇲🇦 Southeast Morocco',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hello, Traveller! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover breathtaking destinations',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
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

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 50 : 18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: theme.textTheme.bodyMedium?.color, size: 14),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _quickAction(
            context,
            Icons.photo_library_rounded,
            'Gallery',
            theme.colorScheme.primary,
            theme,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
          ),
          const SizedBox(width: 10),
          _quickAction(
            context,
            Icons.favorite_rounded,
            'Favorites',
            const Color(0xFFE74C3C),
            theme,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          const SizedBox(width: 10),
          _quickAction(
            context,
            Icons.book_online_rounded,
            'Bookings',
            theme.colorScheme.secondary,
            theme,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, ThemeData theme, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(theme.brightness == Brightness.dark ? 50 : 25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => widget.onTabChange?.call(2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(70),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(40), width: 1),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Travel Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ask me anything about Southeast Morocco!',
                    style: TextStyle(
                      color: Color(0xAAFFFFFF),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  IconData _bookingIcon(dynamic type) {
    switch (type.toString()) {
      case 'BookingType.hotel':
        return Icons.hotel;
      case 'BookingType.restaurant':
        return Icons.restaurant;
      case 'BookingType.tour':
        return Icons.explore;
      default:
        return Icons.directions_car;
    }
  }
  Widget _buildViewAllButton(BuildContext context, ThemeData theme, int totalCount) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllDestinationsScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryOrange, Color(0xFFE8830A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(60)),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore All Destinations',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View all $totalCount amazing places & search',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}