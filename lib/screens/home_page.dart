import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/destination.dart';
import '../models/circuit.dart';
import '../services/destination_service.dart';
import '../services/circuit_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_radius.dart';
import '../widgets/circuit_mini_card.dart';
import '../widgets/section_header.dart';
import '../widgets/preview_card.dart';
import '../widgets/rating_badge.dart';
import '../widgets/horizontal_carousel.dart';
import 'circuits_list_screen.dart';
import 'circuit_detail_screen.dart';
import 'destination_detail_screen.dart';
import 'gallery_screen.dart';
import 'favorites_screen.dart';
import 'bookings_screen.dart';
import 'top_rated_screen.dart';
import 'all_destinations_screen.dart';
import 'hotel_search_screen.dart';
import 'activity_search_screen.dart';
import 'car_search_screen.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  final void Function(int)? onTabChange;
  final VoidCallback? onScrollDown;
  final VoidCallback? onScrollUp;

  const HomePage({
    super.key,
    this.onTabChange,
    this.onScrollDown,
    this.onScrollUp,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DestinationService _destinationService = DestinationService();
  final CircuitService _circuitService = CircuitService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  static const List<String> _discoverCategories = [
    'All',
    'Desert',
    'Village',
    'Canyon',
    'Oasis',
    'Camp',
  ];
bool _bottomBarHidden = false;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<UserScrollNotification>(
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
          _buildHeader(context, theme),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _buildSearchBar(context, theme),
                const SizedBox(height: 20),

                // ✅ Featured Circuit hero banner
                _buildFeaturedCircuitHero(context, theme),
                const SizedBox(height: 20),

                // ✅ Quick Actions (Gallery, Favorites, Bookings)
                _buildQuickActions(context, theme),
                const SizedBox(height: 16),

                // ✅ AI Card
                _buildAiCard(context, theme),
                const SizedBox(height: 16),

                // ✅ Services Section (Hotels, Activities, Cars)
                _buildServicesSection(context, theme),
                const SizedBox(height: 16),

                // ✅ Top Rated Section
                SectionHeader(
                  title: 'Top Rated',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TopRatedScreen(),
                    ),
                  ),
                ),
                StreamBuilder<List<Destination>>(
                  stream: _destinationService.streamAllDestinations(),
                  builder: (context, snapshot) {
                    final topRated = [...(snapshot.data ?? [])]
                      ..sort((a, b) => b.rating.compareTo(a.rating));
                    final top4 = topRated.take(4).toList();

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 180,
                        child: Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                        ),
                      );
                    }

                    if (top4.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return HorizontalCarousel(
                      height: 180,
                      itemWidth: 160,
                      items: top4
                          .map((d) => PreviewCard(
                                imagePath: d.imageURLs.isNotEmpty ? d.imageURLs.first : '',
                                title: d.name,
                                subtitle: d.tags,
                                rating: d.rating,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DestinationDetailScreen(destination: d),
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ✅ Circuits Section
                SectionHeader(
                  title: 'Circuits',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  CircuitsListScreen(),
                    ),
                  ),
                ),
                _buildPopularCircuits(context, theme),
                const SizedBox(height: 16),

                // ✅ Discover Section Header
                SectionHeader(
                  title: 'Discover',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllDestinationsScreen(),
                    ),
                  ),
                ),
                _buildCategoryChips(context, theme),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ✅ Destinations from Firestore
          StreamBuilder<List<Destination>>(
            stream: _destinationService.streamAllDestinations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
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

              if (_searchQuery.isNotEmpty) {
                destinations = destinations
                    .where((dest) => dest.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              if (_selectedCategory != 'All') {
                destinations = destinations
                    .where((dest) =>
                        dest.tags.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
                        dest.description.toLowerCase().contains(_selectedCategory.toLowerCase()))
                    .toList();
              }

              if (destinations.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.explore_off_rounded,
                              size: 38,
                              color: theme.colorScheme.primary,
                            ),
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

              final hasMore = destinations.length > 5;
              final displayedDestinations = destinations.take(5).toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == displayedDestinations.length) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 16, top: 4),
                          child: _buildViewAllButton(
                              context, theme, destinations.length),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDestinationRow(
                            context, theme, displayedDestinations[index]),
                      );
                    },
                    childCount: displayedDestinations.length +
                        (hasMore ? 1 : 0),
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      ),
    );
  }

  // ─── Services Section ─────────────────────────────────────────
  Widget _buildServicesSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore & Book',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _serviceCard(
                  context: context,
                  icon: Icons.hotel_rounded,
                  label: 'Hotels',
                  subtitle: 'Find & Book',
                  color: const Color(0xFF2980B9),
                  theme: theme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HotelSearchScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _serviceCard(
                  context: context,
                  icon: Icons.paragliding_rounded,
                  label: 'Activities',
                  subtitle: 'Explore',
                  color: const Color(0xFF27AE60),
                  theme: theme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivitySearchScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _serviceCard(
                  context: context,
                  icon: Icons.directions_car_rounded,
                  label: 'Cars',
                  subtitle: 'Rent',
                  color: const Color(0xFFE74C3C),
                  theme: theme,
                       onTap: () => Navigator.push(
                         context,
                       MaterialPageRoute(
                      builder: (_) => const CarSearchScreen(),
                    ),
                 ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(isDark ? 40 : 25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withAlpha(40), width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withAlpha(180), color],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleLarge?.color,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header (plain cream, iOS large-title style) ───────────────
  Widget _buildHeader(BuildContext context, ThemeData theme) {
     final user = FirebaseAuth.instance.currentUser;
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${_userName(user)} 👋',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Explore Southeast Morocco',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
                theme.brightness == Brightness.dark ? 50 : 18),
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
              style:
                  TextStyle(color: theme.textTheme.bodyLarge?.color),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search dunes, kasbahs, oases...',
                hintStyle: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: theme.colorScheme.primary, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 16),
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
                          child: Icon(Icons.close_rounded,
                              color: theme.textTheme.bodyMedium?.color,
                              size: 14),
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
            child: Icon(Icons.tune_rounded,
                color: theme.colorScheme.primary, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Featured Circuit hero banner ──────────────────────────────
  Widget _buildFeaturedCircuitHero(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<Circuit>>(
        future: _circuitService.getPopularCircuits(limit: 1),
        builder: (context, snapshot) {
          final circuits = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting || circuits.isEmpty) {
            return const SizedBox.shrink();
          }

          final circuit = circuits.first;
          final stopsCount = circuit.destinationIds.isNotEmpty ? circuit.destinationIds.length : circuit.itinerary.length;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CircuitDetailScreen(circuit: circuit)),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepBlue.withAlpha(90),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FEATURED CIRCUIT',
                          style: TextStyle(
                            color: AppTheme.goldAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          circuit.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stopsCount > 0
                              ? '${circuit.durationText} · $stopsCount stops'
                              : circuit.durationText,
                          style: TextStyle(
                            color: Colors.white.withAlpha(210),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CircuitDetailScreen(circuit: circuit)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.goldAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('View circuit'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: SizedBox(
                      width: 84,
                      height: 104,
                      child: circuit.imageUrl.isNotEmpty
                          ? Image.network(
                              circuit.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white.withAlpha(30),
                                child: Icon(circuit.typeIcon, color: Colors.white, size: 28),
                              ),
                            )
                          : Container(
                              color: Colors.white.withAlpha(30),
                              child: Icon(circuit.typeIcon, color: Colors.white, size: 28),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Popular Circuits ─────────────────────────────────────────
  Widget _buildPopularCircuits(BuildContext context, ThemeData theme) {
    return FutureBuilder<List<Circuit>>(
      future: _circuitService.getPopularCircuits(limit: 6),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 210,
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 3,
                ),
              ),
            ),
          );
        }

        final circuits = snapshot.data ?? [];
        if (circuits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route_rounded,
                      color: AppTheme.primaryOrange, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No circuits yet — check back soon!',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 215,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: circuits.length,
            itemBuilder: (context, index) =>
                CircuitMiniCard(circuit: circuits[index]),
          ),
        );
      },
    );
  }

  // ─── Discover: category filter chips ───────────────────────────
  Widget _buildCategoryChips(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _discoverCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _discoverCategories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryOrange : theme.cardColor,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryOrange
                      : (isDark ? AppTheme.darkBorder : Colors.grey.shade300),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Discover: destination row ──────────────────────────────────
  Widget _buildDestinationRow(BuildContext context, ThemeData theme, Destination destination) {
    final isDark = theme.brightness == Brightness.dark;
    final placeholderBg = isDark ? AppTheme.darkCard : Colors.grey.shade200;
    final placeholderIconColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: destination)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 60 : 15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.badge),
              child: SizedBox(
                width: 56,
                height: 56,
                child: destination.imageURLs.isNotEmpty
                    ? Image.network(
                        destination.imageURLs.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: placeholderBg,
                          child: Icon(Icons.landscape_outlined, color: placeholderIconColor, size: 22),
                        ),
                      )
                    : Container(
                        color: placeholderBg,
                        child: Icon(Icons.landscape_outlined, color: placeholderIconColor, size: 22),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleLarge?.color,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination.tags.isNotEmpty ? destination.tags : destination.distance,
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RatingBadge(rating: destination.rating),
            const SizedBox(width: 8),
            const Icon(Icons.attach_money_rounded, color: AppTheme.goldAccent, size: 18),
          ],
        ),
      ),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────
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
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GalleryScreen()),
            ),
          ),
          const SizedBox(width: 10),
          _quickAction(
            context,
            Icons.favorite_rounded,
            'Favorites',
            const Color(0xFFE74C3C),
            theme,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          const SizedBox(width: 10),
          _quickAction(
            context,
            Icons.book_online_rounded,
            'Bookings',
            theme.colorScheme.secondary,
            theme,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    ThemeData theme,
    VoidCallback onTap,
  ) {
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
                color: color.withAlpha(
                    theme.brightness == Brightness.dark ? 50 : 25),
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

  // ─── AI Card ──────────────────────────────────────────────────
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
                border: Border.all(
                    color: Colors.white.withAlpha(40), width: 1),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 28),
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
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ─── View All Button ──────────────────────────────────────────
  Widget _buildViewAllButton(
      BuildContext context, ThemeData theme, int totalCount) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AllDestinationsScreen()),
        ),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppTheme.orangeGradient,
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
                  border:
                      Border.all(color: Colors.white.withAlpha(60)),
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
  String _userName(User? user) {
  if (user == null) return 'Traveller';

  if (user.displayName != null &&
      user.displayName!.trim().isNotEmpty) {
    return user.displayName!;
  }

  if (user.email != null) {
    return user.email!.split('@').first;
  }

  return 'Traveller';
}
}