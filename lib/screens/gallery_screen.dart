import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/gallery_item.dart';
import '../services/gallery_service.dart';
import 'image_viewer_screen.dart';
import 'upload_image_screen.dart';
import 'user_gallery_screen.dart';
import '../widgets/image_card.dart';
import '../widgets/category_chips.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search images...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
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
            icon: const Icon(Icons.bookmark_border),
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
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Explore'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Recent'),
                ],
              ),
              CategoryChips(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadImageScreen()),
          );
        },
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Upload'),
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
          return _buildEmptyState();
        }

        return _buildMasonryGrid(items);
      },
    );
  }

  Widget _buildTrendingTab() {
    return StreamBuilder<List<GalleryItem>>(
      stream: _galleryService.getTrendingImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
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
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ImageCard(
            item: items[index],
            onTap: () => _openImageViewer(items, index),
            onLike: () => _galleryService.toggleLike(items[index].id),
            onSave: () => _galleryService.toggleSave(items[index].id),
            onUserTap: () => _openUserGallery(items[index].uploadedBy),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          height: (index % 2 == 0) ? 200 : 300,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({String message = 'No images yet'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadImageScreen()),
              );
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Upload First Image'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Images'),
      ),
      body: StreamBuilder<List<GalleryItem>>(
        stream: galleryService.getSavedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('No saved images'),
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