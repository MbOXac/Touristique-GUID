import 'package:flutter/material.dart';
import '../models/destination.dart';
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

class HomePage extends StatelessWidget {
  final void Function(int)? onTabChange;

  const HomePage({super.key, this.onTabChange});

  static const List<Destination> _destinations = [
    Destination(name: 'Kasbah & Valleys', description: 'Explore centuries-old mud-brick kasbahs nestled among dramatic cliffs and verdant valleys along the Draa River.', imagePath: 'assets/images/destination_1.jpg', rating: 4.8, distance: '120 km'),
    Destination(name: 'Merzouga Desert', description: 'Ride camels across the iconic Erg Chebbi dunes and spend a night under a sky blazing with stars in the Sahara.', imagePath: 'assets/images/destination_2.jpg', rating: 4.9, distance: '340 km'),
    Destination(name: 'Todra Gorge', description: 'Walk through towering 300-metre limestone walls carved by the Todra River – a paradise for hikers and climbers.', imagePath: 'assets/images/destination_3.jpg', rating: 4.7, distance: '175 km'),
    Destination(name: 'Oasis & Palmeraies', description: 'Wander through sprawling date-palm groves irrigated by ancient khettara channels in the lush valleys of Tinghir.', imagePath: 'assets/images/destination_4.jpg', rating: 4.6, distance: '160 km'),
  ];

  @override
  Widget build(BuildContext context) {
    final topRated = MockDataService.getTopRatedPlaces().take(4).toList();
    final gallery = MockDataService.getGalleryItems().take(6).toList();
    final favorites = MockDataService.getFavoritePlaces().take(4).toList();
    final memories = MockDataService.getTripMemories().take(3).toList();
    final bookings = MockDataService.getBookings().take(2).toList();

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSearchBar(context),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildAiCard(context),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Top Rated',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopRatedScreen())),
                ),
                const SizedBox(height: 4),
                HorizontalCarousel(
                  height: 190,
                  itemWidth: 170,
                  items: topRated.map((p) => PreviewCard(
                    imagePath: p.imagePath,
                    title: p.name,
                    subtitle: p.category,
                    rating: p.rating,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopRatedScreen())),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Gallery',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                ),
                const SizedBox(height: 4),
                _buildGalleryGrid(context, gallery),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'My Favorites',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                ),
                const SizedBox(height: 4),
                HorizontalCarousel(
                  height: 190,
                  itemWidth: 170,
                  items: favorites.map((p) => PreviewCard(
                    imagePath: p.imagePath,
                    title: p.name,
                    subtitle: p.address,
                    rating: p.rating,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Trip Memories',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: memories.map((m) => _buildMemoryCard(context, m)).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Bookings',
                  onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: bookings.map((b) => _buildBookingCard(context, b)).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Explore Destinations'),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _destinations.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DestinationCard(destination: d),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.deepBlue,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 18, right: 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Traveller! 👋',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  'Southeast Morocco',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 3),
                  Text(
                    'Morocco',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/welcome.jpg', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(40),
                    Colors.black.withAlpha(170),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Search – Coming soon!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.deepBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.search_rounded, color: AppTheme.primaryOrange, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Search destinations...',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.deepBlue.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune_rounded, color: AppTheme.deepBlue, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _quickAction(
            context,
            Icons.photo_library_rounded,
            'Gallery',
            AppTheme.primaryOrange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
          ),
          const SizedBox(width: 12),
          _quickAction(
            context,
            Icons.favorite_rounded,
            'Favorites',
            const Color(0xFFE05555),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          const SizedBox(width: 12),
          _quickAction(
            context,
            Icons.book_online_rounded,
            'Bookings',
            AppTheme.deepBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
          ),
          const SizedBox(width: 12),
          _quickAction(
            context,
            Icons.photo_album_rounded,
            'Memories',
            AppTheme.earthBrown,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiCard(BuildContext context) {
    return GestureDetector(
      onTap: () => onTabChange?.call(2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.deepBlue, Color(0xFF2A5A8C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepBlue.withAlpha(80),
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
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(50), width: 1),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Travel Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ask me anything about Southeast Morocco!',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context, List galleryItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: galleryItems.length,
        itemBuilder: (context, index) {
          final item = galleryItems[index];
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
                      bottom: 4,
                      left: 4,
                      child: RatingBadge(rating: item.rating),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemoryCard(BuildContext context, dynamic m) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(m.photos.first, width: 70, height: 70, fit: BoxFit.cover),
                ),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.deepBlue,
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
                        const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.primaryOrange),
                        const SizedBox(width: 3),
                        Text(
                          m.location,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.description,
                      style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, dynamic b) {
    final statusColor = b.status.toString().contains('confirmed')
        ? AppTheme.oasisGreen
        : b.status.toString().contains('pending')
            ? Colors.orange
            : Colors.red;
    final statusLabel = b.status.toString().split('.').last;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryOrange, Color(0xFFE8843A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_bookingIcon(b.type), color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.deepBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      b.details,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${b.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withAlpha(80), width: 0.5),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _bookingIcon(dynamic type) {
    switch (type.toString()) {
      case 'BookingType.hotel': return Icons.hotel;
      case 'BookingType.restaurant': return Icons.restaurant;
      case 'BookingType.tour': return Icons.explore;
      default: return Icons.directions_car;
    }
  }
}
