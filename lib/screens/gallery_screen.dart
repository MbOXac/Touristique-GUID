import 'package:flutter/material.dart';
import '../models/gallery_item.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gallery_grid.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GalleryItem> _allItems = MockDataService.getGalleryItems();

  final List<String> _tabs = ['All', 'Destination', 'User', 'Memory'];

  List<GalleryItem> _filtered(String tab) {
    if (tab == 'All') return _allItems;
    return _allItems.where((i) => i.category == tab.toLowerCase()).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
        title: const Text('Gallery'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.primaryOrange,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          final items = _filtered(tab);
          return Padding(
            padding: const EdgeInsets.all(8),
            child: items.isEmpty
                ? const Center(child: Text('No photos in this category'))
                : GalleryGrid(items: items, crossAxisCount: 2, shrinkWrap: false),
          );
        }).toList(),
      ),
    );
  }
}
