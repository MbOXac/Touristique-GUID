import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/destination.dart';
import '../models/circuit.dart';
import '../models/gallery_item.dart';
import '../models/favorite_item.dart';
import '../services/destination_service.dart';
import '../services/circuit_service.dart';
import '../services/gallery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/rating_badge.dart';
import '../widgets/circuit_card.dart';
import '../widgets/image_card.dart';
import 'destination_detail_screen.dart';
import 'image_viewer_screen.dart';

class TopRatedScreen extends StatefulWidget {
  const TopRatedScreen({super.key});

  @override
  State<TopRatedScreen> createState() => _TopRatedScreenState();
}

class _TopRatedScreenState extends State<TopRatedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final DestinationService _destinationService = DestinationService();
  final CircuitService _circuitService = CircuitService();
  final GalleryService _galleryService = GalleryService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Rated'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryOrange,
          labelColor: AppTheme.primaryOrange,
          tabs: const [
            Tab(text: 'Destinations'),
            Tab(text: 'Circuits'),
            Tab(text: 'Gallery Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TopDestinationsTab(destinationService: _destinationService),
          _TopCircuitsTab(circuitService: _circuitService),
          _TopGalleryTab(galleryService: _galleryService),
        ],
      ),
    );
  }
}

/// Small "🏆 #N" rank chip used across all three tabs.
class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            '#$rank',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// DESTINATIONS TAB — sorted by rating
// =====================================================================

class _TopDestinationsTab extends StatelessWidget {
  final DestinationService destinationService;

  const _TopDestinationsTab({required this.destinationService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Destination>>(
      stream: destinationService.streamAllDestinations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
        }

        final destinations = [...(snapshot.data ?? [])]
          ..sort((a, b) => b.rating.compareTo(a.rating));

        if (destinations.isEmpty) {
          return _emptyState(context, 'No destinations yet', Icons.landscape_outlined);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            final destination = destinations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TopDestinationCard(destination: destination, rank: index + 1),
            );
          },
        );
      },
    );
  }
}

class _TopDestinationCard extends StatelessWidget {
  final Destination destination;
  final int rank;

  const _TopDestinationCard({required this.destination, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = destination.imageURLs.isNotEmpty ? destination.imageURLs.first : '';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: destination)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                imageUrl.isEmpty
                    ? Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.landscape_outlined, size: 40, color: Colors.grey),
                      )
                    : Image.network(
                        imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.landscape_outlined, size: 40, color: Colors.grey),
                        ),
                      ),
                Positioned(top: 12, left: 12, child: _RankBadge(rank: rank)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    type: FavoriteType.destination,
                    itemId: destination.id,
                    title: destination.name,
                    subtitle: destination.tags,
                    imageUrl: imageUrl,
                    rating: destination.rating,
                    background: Colors.black.withAlpha(120),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                      RatingBadge(rating: destination.rating),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    destination.description,
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.near_me_rounded, size: 14, color: AppTheme.primaryOrange),
                      const SizedBox(width: 4),
                      Text(
                        destination.distance,
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// CIRCUITS TAB — sorted by rating, reuses the existing CircuitCard
// =====================================================================

class _TopCircuitsTab extends StatelessWidget {
  final CircuitService circuitService;

  const _TopCircuitsTab({required this.circuitService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Circuit>>(
      stream: circuitService.streamAllCircuits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
        }

        final circuits = [...(snapshot.data ?? [])]
          ..sort((a, b) => b.rating.compareTo(a.rating));

        if (circuits.isEmpty) {
          return _emptyState(context, 'No circuits yet', Icons.route_rounded);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: circuits.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Stack(
                children: [
                  CircuitCard(circuit: circuits[index]),
                  Positioned(top: 8, left: 8, child: _RankBadge(rank: index + 1)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// =====================================================================
// GALLERY TAB — sorted by likes then views (getTrendingImages)
// =====================================================================

class _TopGalleryTab extends StatelessWidget {
  final GalleryService galleryService;

  const _TopGalleryTab({required this.galleryService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GalleryItem>>(
      stream: galleryService.getTrendingImages(limit: 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _emptyState(context, 'No gallery posts yet', Icons.photo_library_outlined);
        }

        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                ImageCard(
                  item: items[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageViewerScreen(items: items, initialIndex: index),
                    ),
                  ),
                  onLike: () => galleryService.toggleLike(items[index].id),
                  onSave: () => galleryService.toggleSave(items[index].id),
                ),
                Positioned(top: 6, left: 6, child: _RankBadge(rank: index + 1)),
              ],
            );
          },
        );
      },
    );
  }
}

Widget _emptyState(BuildContext context, String message, IconData icon) {
  final theme = Theme.of(context);
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: theme.textTheme.bodyMedium?.color?.withAlpha(120)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    ),
  );
}
