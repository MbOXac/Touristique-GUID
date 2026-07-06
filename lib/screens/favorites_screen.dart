import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/favorite_item.dart';
import '../models/gallery_item.dart';
import '../services/favorite_service.dart';
import '../services/gallery_service.dart';
import '../services/destination_service.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/rating_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/image_card.dart';
import 'destination_detail_screen.dart';
import 'image_viewer_screen.dart';
import 'trip_tab.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FavoriteService _favoriteService = FavoriteService();
  final GalleryService _galleryService = GalleryService();
  final DestinationService _destinationService = DestinationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('My Favorites'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Destinations'),
            Tab(text: 'Trips'),
            Tab(text: 'Gallery Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllFavoritesTab(
            favoriteService: _favoriteService,
            galleryService: _galleryService,
            destinationService: _destinationService,
            onSeeAllDestinations: () => _tabController.animateTo(1),
            onSeeAllTrips: () => _tabController.animateTo(2),
            onSeeAllGallery: () => _tabController.animateTo(3),
          ),
          _DestinationFavoritesTab(
            favoriteService: _favoriteService,
            destinationService: _destinationService,
          ),
          _TripFavoritesTab(favoriteService: _favoriteService),
          _GalleryFavoritesTab(galleryService: _galleryService),
        ],
      ),
    );
  }
}

// =====================================================================
// ALL TAB — a quick-glance section per category
// =====================================================================

class _AllFavoritesTab extends StatelessWidget {
  final FavoriteService favoriteService;
  final GalleryService galleryService;
  final DestinationService destinationService;
  final VoidCallback onSeeAllDestinations;
  final VoidCallback onSeeAllTrips;
  final VoidCallback onSeeAllGallery;

  const _AllFavoritesTab({
    required this.favoriteService,
    required this.galleryService,
    required this.destinationService,
    required this.onSeeAllDestinations,
    required this.onSeeAllTrips,
    required this.onSeeAllGallery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FavoriteItem>>(
      stream: favoriteService.streamFavorites(),
      builder: (context, allSnapshot) {
        final all = allSnapshot.data ?? [];
        final destinations =
            all.where((f) => f.type == FavoriteType.destination).toList();
        final trips = all.where((f) => f.type == FavoriteType.trip).toList();

        return StreamBuilder<List<GalleryItem>>(
          stream: galleryService.getSavedImages(),
          builder: (context, gallerySnapshot) {
            final galleryItems = gallerySnapshot.data ?? [];

            final isLoading =
                allSnapshot.connectionState == ConnectionState.waiting &&
                    gallerySnapshot.connectionState == ConnectionState.waiting;

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryOrange),
              );
            }

            if (destinations.isEmpty && trips.isEmpty && galleryItems.isEmpty) {
              return const EmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'No favorites yet',
                message:
                    'Tap the heart icon on any destination, trip, or gallery post to save it here.',
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (destinations.isNotEmpty)
                  _FavoritesSection(
                    title: 'Destinations',
                    count: destinations.length,
                    onSeeAll: onSeeAllDestinations,
                    child: SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: destinations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => SizedBox(
                          width: 160,
                          child: _DestinationFavoriteCard(
                            favorite: destinations[index],
                            destinationService: destinationService,
                            compact: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (trips.isNotEmpty)
                  _FavoritesSection(
                    title: 'Trips',
                    count: trips.length,
                    onSeeAll: onSeeAllTrips,
                    child: SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: trips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => SizedBox(
                          width: 160,
                          child: _TripFavoriteCard(
                            favorite: trips[index],
                            compact: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (galleryItems.isNotEmpty)
                  _FavoritesSection(
                    title: 'Gallery Posts',
                    count: galleryItems.length,
                    onSeeAll: onSeeAllGallery,
                    child: SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: galleryItems.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => SizedBox(
                          width: 150,
                          child: _GalleryFavoriteCard(
                            item: galleryItems[index],
                            allItems: galleryItems,
                            index: index,
                            galleryService: galleryService,
                          ),
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
}

class _FavoritesSection extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onSeeAll;
  final Widget child;

  const _FavoritesSection({
    required this.title,
    required this.count,
    required this.onSeeAll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$title ($count)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// =====================================================================
// DESTINATIONS TAB
// =====================================================================

class _DestinationFavoritesTab extends StatelessWidget {
  final FavoriteService favoriteService;
  final DestinationService destinationService;

  const _DestinationFavoritesTab({
    required this.favoriteService,
    required this.destinationService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FavoriteItem>>(
      stream: favoriteService.streamFavorites(type: FavoriteType.destination),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryOrange),
          );
        }

        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return const EmptyState(
            icon: Icons.landscape_outlined,
            title: 'No favorite destinations',
            message: 'Tap the heart icon on any destination to save it here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favorites.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DestinationFavoriteCard(
              favorite: favorites[index],
              destinationService: destinationService,
            ),
          ),
        );
      },
    );
  }
}

class _DestinationFavoriteCard extends StatelessWidget {
  final FavoriteItem favorite;
  final DestinationService destinationService;
  final bool compact;

  const _DestinationFavoriteCard({
    required this.favorite,
    required this.destinationService,
    this.compact = false,
  });

  Future<void> _open(BuildContext context) async {
    final destination =
        await destinationService.getDestinationById(favorite.itemId);

    if (!context.mounted) return;

    if (destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This destination is no longer available.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(destination: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _thumbnail(height: 110, width: double.infinity),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _favoriteToggle(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorite.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RatingBadge(rating: favorite.rating),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  _thumbnail(height: 90, width: 100),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorite.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            favorite.subtitle,
                            style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          RatingBadge(rating: favorite.rating),
                        ],
                      ),
                    ),
                  ),
                  _favoriteToggle(),
                  const SizedBox(width: 4),
                ],
              ),
      ),
    );
  }

  Widget _favoriteToggle() {
    return FavoriteButton(
      type: FavoriteType.destination,
      itemId: favorite.itemId,
      title: favorite.title,
      subtitle: favorite.subtitle,
      imageUrl: favorite.imageUrl,
      rating: favorite.rating,
      background: compact ? Colors.black.withAlpha(110) : null,
      size: compact ? 18 : 22,
    );
  }

  Widget _thumbnail({required double height, required double width}) {
    if (favorite.imageUrl.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade300,
        child: const Icon(Icons.landscape_outlined, color: Colors.grey),
      );
    }
    return Image.network(
      favorite.imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade300,
        child: const Icon(Icons.landscape_outlined, color: Colors.grey),
      ),
    );
  }
}

// =====================================================================
// TRIPS TAB
// =====================================================================

class _TripFavoritesTab extends StatelessWidget {
  final FavoriteService favoriteService;

  const _TripFavoritesTab({required this.favoriteService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FavoriteItem>>(
      stream: favoriteService.streamFavorites(type: FavoriteType.trip),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryOrange),
          );
        }

        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return const EmptyState(
            icon: Icons.travel_explore_rounded,
            title: 'No favorite trips',
            message: 'Tap the heart icon on any of your trips to save it here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favorites.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TripFavoriteCard(favorite: favorites[index]),
          ),
        );
      },
    );
  }
}

class _TripFavoriteCard extends StatelessWidget {
  final FavoriteItem favorite;
  final bool compact;

  const _TripFavoriteCard({required this.favorite, this.compact = false});

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TripTab()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _thumbnail(height: 110, width: double.infinity),
                      Positioned(top: 4, right: 4, child: _favoriteToggle()),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorite.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          favorite.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  _thumbnail(height: 90, width: 100),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorite.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            favorite.subtitle,
                            style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _favoriteToggle(),
                  const SizedBox(width: 4),
                ],
              ),
      ),
    );
  }

  Widget _favoriteToggle() {
    return FavoriteButton(
      type: FavoriteType.trip,
      itemId: favorite.itemId,
      title: favorite.title,
      subtitle: favorite.subtitle,
      imageUrl: favorite.imageUrl,
      background: compact ? Colors.black.withAlpha(110) : null,
      size: compact ? 18 : 22,
    );
  }

  Widget _thumbnail({required double height, required double width}) {
    if (favorite.imageUrl.isEmpty || favorite.imageUrl.startsWith('data:image')) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade300,
        child: const Icon(Icons.travel_explore_rounded, color: Colors.grey),
      );
    }
    return Image.network(
      favorite.imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade300,
        child: const Icon(Icons.travel_explore_rounded, color: Colors.grey),
      ),
    );
  }
}

// =====================================================================
// GALLERY TAB — reads straight from GalleryService's savedBy field
// =====================================================================

class _GalleryFavoritesTab extends StatelessWidget {
  final GalleryService galleryService;

  const _GalleryFavoritesTab({required this.galleryService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GalleryItem>>(
      stream: galleryService.getSavedImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryOrange),
          );
        }

        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.cloud_off_rounded,
            title: "Couldn't load saved posts",
            message: snapshot.error.toString(),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.photo_library_outlined,
            title: 'No saved gallery posts',
            message: 'Tap the bookmark icon on any gallery post to save it here.',
          );
        }

        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ImageCard(
              item: items[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageViewerScreen(items: items, initialIndex: index),
                ),
              ),
              onLike: () => galleryService.toggleLike(items[index].id),
              onSave: () => galleryService.toggleSave(items[index].id),
            );
          },
        );
      },
    );
  }
}

class _GalleryFavoriteCard extends StatelessWidget {
  final GalleryItem item;
  final List<GalleryItem> allItems;
  final int index;
  final GalleryService galleryService;

  const _GalleryFavoriteCard({
    required this.item,
    required this.allItems,
    required this.index,
    required this.galleryService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageViewerScreen(items: allItems, initialIndex: index),
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  item.thumbnailUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => galleryService.toggleSave(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(110),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
