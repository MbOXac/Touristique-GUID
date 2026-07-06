import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gallery_item.dart';
import '../services/gallery_service.dart';
import 'image_viewer_screen.dart';
import '../widgets/image_card.dart';
import '../theme/app_theme.dart';

class UserGalleryScreen extends StatefulWidget {
  final String userId;

  const UserGalleryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserGalleryScreen> createState() => _UserGalleryScreenState();
}

class _UserGalleryScreenState extends State<UserGalleryScreen> {
  final GalleryService _galleryService = GalleryService();
  late Future<Map<String, dynamic>> _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _getUserInfo();
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.uid == widget.userId) {
        return {
          'name': user?.displayName ?? 'Anonymous',
          'avatar': user?.photoURL ?? '',
          'email': user?.email ?? '',
        };
      }
      return {
        'name': 'User',
        'avatar': '',
        'email': '',
      };
    } catch (e) {
      return {
        'name': 'User',
        'avatar': '',
        'email': '',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: FutureBuilder<Map<String, dynamic>>(
                future: _userInfoFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final userInfo = snapshot.data!;
                  return Container(
                    color: isDark ? AppTheme.darkSurface : AppTheme.sandBeige.withAlpha(140),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                          backgroundImage: userInfo['avatar'].isNotEmpty
                              ? CachedNetworkImageProvider(userInfo['avatar'])
                              : null,
                          child: userInfo['avatar'].isEmpty
                              ? Icon(Icons.person, size: 40, color: theme.iconTheme.color)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userInfo['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Images
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: StreamBuilder<List<GalleryItem>>(
              stream: _galleryService.getUserImages(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          height: (index % 2 == 0) ? 200 : 300,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : const Color(0xFFEDE6D9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary.withAlpha(22),
                              ),
                              child: Icon(
                                Icons.photo_library_outlined,
                                size: 56,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No images yet',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: items.length,
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
                      onLike: () =>
                          _galleryService.toggleLike(items[index].id),
                      onSave: () =>
                          _galleryService.toggleSave(items[index].id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}