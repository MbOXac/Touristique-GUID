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
      backgroundColor: const Color(0xFFF8F4EE),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSearchBar(context),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 16),
                _buildAiCard(context),
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
                    height: 280,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: gallery.length,
                      itemBuilder: (context, index) {
                        final item = gallery[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(item.imagePath, fit: BoxFit.cover),
                                Positioned(
                                  bottom: 4, left: 4,
                                  child: RatingBadge(rating: item.rating),
                                ),
                              ],
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
                    children: memories.map((m) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(m.photos.first, width: 64, height: 64, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(m.mood, style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.deepBlue), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(m.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(m.description, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
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
                              ? Colors.orange
                              : Colors.red;
                      final statusLabel = b.status.toString().split('.').last;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: AppTheme.sandBeige, borderRadius: BorderRadius.circular(10)),
                            child: Icon(_bookingIcon(b.type), color: AppTheme.primaryOrange, size: 22),
                          ),
                          title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.deepBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(b.details, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${b.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: statusColor.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                                child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Explore Destinations'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _destinations.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DestinationCard(destination: d),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.deepBlue,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Southeast Morocco', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Hello, Traveller! 👋', style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 11, fontWeight: FontWeight.w400)),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/welcome.jpg', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x44000000), Color(0xBB000000)],
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
        const SnackBar(content: Text('Search – Coming soon!'), behavior: SnackBarBehavior.floating),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey),
            SizedBox(width: 10),
            Text('Search destinations...', style: TextStyle(color: Colors.grey, fontSize: 15)),
            Spacer(),
            Icon(Icons.tune_rounded, color: AppTheme.primaryOrange),
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
          _quickAction(context, Icons.photo_library_rounded, 'Gallery', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()))),
          const SizedBox(width: 12),
          _quickAction(context, Icons.favorite_rounded, 'Favorites', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
          const SizedBox(width: 12),
          _quickAction(context, Icons.book_online_rounded, 'Bookings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()))),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6)],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryOrange, size: 28),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.deepBlue)),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.deepBlue, Color(0xFF2A5A8C)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Travel Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Ask me anything about Southeast Morocco!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
          ],
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
