import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/destination.dart';
import '../models/circuit.dart';
import '../services/destination_service.dart';
import '../services/circuit_service.dart';
import '../theme/app_theme.dart';
import '../widgets/destination_card.dart';
import '../widgets/circuit_mini_card.dart';
import '../widgets/section_header.dart';
import '../widgets/preview_card.dart';
import '../widgets/horizontal_carousel.dart';
import 'circuits_list_screen.dart';
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
          _buildAppBar(context, theme),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSearchBar(context, theme),
                const SizedBox(height: 16),

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

                // ✅ Popular Circuits Section
                SectionHeader(
                  title: 'Popular Circuits',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  CircuitsListScreen(),
                    ),
                  ),
                ),
                _buildPopularCircuits(context, theme),
                const SizedBox(height: 16),

                // ✅ Explore Destinations Section Header
                SectionHeader(
                  title: 'Explore Destinations',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllDestinationsScreen(),
                    ),
                  ),
                ),
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
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DestinationCard(
                          destination: displayedDestinations[index],
                        ),
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

  // ─── App Bar ──────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context, ThemeData theme) {
     final user = FirebaseAuth.instance.currentUser;
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withAlpha(220),
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
                      Text(
                       'Hello, ${_userName(user)}! 👋',
                                     style: const TextStyle(
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
                hintText: 'Search destinations...',
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
      onTap: () => widget.onTabChange?.call(3),
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