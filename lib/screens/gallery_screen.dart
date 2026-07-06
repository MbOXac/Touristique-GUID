import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/gallery_item.dart';
import '../services/gallery_service.dart';
import 'image_viewer_screen.dart';
import 'upload_image_screen.dart';
import 'user_gallery_screen.dart';
import '../widgets/image_card.dart';
import '../widgets/category_chips.dart';
import '../theme/app_theme.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  final GalleryService _galleryService = GalleryService();
  late TabController _tabController;
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search images...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SavedImagesScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withAlpha(140),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                indicatorColor: theme.colorScheme.primary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: 'Explore'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Recent'),
                ],
              ),
              const SizedBox(height: 10),
              CategoryChips(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExploreTab(),
          _buildTrendingTab(),
          _buildRecentTab(),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: AppTheme.orangeGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withAlpha(110),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadImageScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
          label: const Text('Upload',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return StreamBuilder<List<GalleryItem>>(
      stream: _galleryService.getAllImages(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState(message: _emptyMessageFor(_selectedCategory));
        }

        return _buildMasonryGrid(items);
      },
    );
  }

  String _emptyMessageFor(String category) {
    if (category == 'all') return 'No images yet';
    final match = CategoryChips.categories.firstWhere(
      (c) => c['id'] == category,
      orElse: () => const {'label': 'this category'},
    );
    return 'No ${match['label']} images yet';
  }

  Widget _buildTrendingTab() {
    return StreamBuilder<List<GalleryItem>>(
      stream: _galleryService.getTrendingImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState(message: 'No trending images yet');
        }

        return _buildMasonryGrid(items);
      },
    );
  }

  Widget _buildRecentTab() {
    return StreamBuilder<List<GalleryItem>>(
      stream: _galleryService.getRecentImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState(message: 'No recent images');
        }

        return _buildMasonryGrid(items);
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<GalleryItem>>(
      stream: _galleryService.searchImages(_searchController.text),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState(message: 'No results found');
        }

        return _buildMasonryGrid(items);
      },
    );
  }

  Widget _buildMasonryGrid(List<GalleryItem> items) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 90),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isOwner = item.uploadedBy == _galleryService.currentUserId;
          return ImageCard(
            item: item,
            onTap: () => _openImageViewer(items, index),
            onLike: () => _galleryService.toggleLike(item.id),
            onSave: () => _galleryService.toggleSave(item.id),
            onUserTap: () => _openUserGallery(item.uploadedBy),
            onDelete: isOwner ? () => _deleteImage(item) : null,
          );
        },
      ),
    );
  }

  Future<void> _deleteImage(GalleryItem item) async {
    final success = await _galleryService.deleteImage(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Image deleted' : "Couldn't delete image"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLoadingGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppTheme.darkCard : const Color(0xFFEDE6D9);
    final highlight = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF7F2E9);
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 90),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _ShimmerBlock(
          height: (index % 3 == 0) ? 260 : (index % 3 == 1 ? 190 : 230),
          base: base,
          highlight: highlight,
        );
      },
    );
  }

  Widget _buildEmptyState({String message = 'No images yet'}) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withAlpha(22),
              ),
              child: Icon(Icons.photo_library_outlined,
                  size: 56, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadImageScreen()),
                );
              },
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Upload First Image'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    final theme = Theme.of(context);
    final isIndexError = error.contains('failed-precondition') || error.contains('requires an index');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withAlpha(24),
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            Text(
              isIndexError ? "Couldn't load this category" : "Something went wrong",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isIndexError
                  ? 'The database needs a moment to catch up. Please try again shortly.'
                  : 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(List<GalleryItem> items, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
          items: items,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _openUserGallery(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserGalleryScreen(userId: userId),
      ),
    );
  }
}

// =====================
// SAVED IMAGES SCREEN
// =====================
class SavedImagesScreen extends StatelessWidget {
  const SavedImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final galleryService = GalleryService();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Saved Images', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<GalleryItem>>(
        stream: galleryService.getSavedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withAlpha(22),
                    ),
                    child: Icon(Icons.bookmark_border_rounded,
                        size: 56, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No saved images yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ImageCard(
                item: items[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageViewerScreen(
                        items: items,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                onLike: () => galleryService.toggleLike(items[index].id),
                onSave: () => galleryService.toggleSave(items[index].id),
              );
            },
          );
        },
      ),
    );
  }
}

// =====================
// SHIMMER LOADING BLOCK
// =====================
class _ShimmerBlock extends StatefulWidget {
  final double height;
  final Color base;
  final Color highlight;

  const _ShimmerBlock({
    required this.height,
    required this.base,
    required this.highlight,
  });

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 3, -0.3),
              end: Alignment(0 + _controller.value * 3, 0.3),
              colors: [widget.base, widget.highlight, widget.base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}