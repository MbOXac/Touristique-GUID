import 'package:flutter/material.dart';
import '../models/favorite_place.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_badge.dart';
import '../widgets/favorite_button.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<FavoritePlace> _places;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Restaurant', 'Monument', 'Activity', 'Hotel'];

  @override
  void initState() {
    super.initState();
    _places = MockDataService.getFavoritePlaces();
  }

  List<FavoritePlace> get _filtered {
    if (_selectedFilter == 'All') return _places.where((p) => p.isFavorited).toList();
    return _places.where((p) => p.isFavorited && p.category == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _filters[index];
                return FilterChip(
                  label: Text(f),
                  selected: _selectedFilter == f,
                  onSelected: (_) => setState(() => _selectedFilter = f),
                  selectedColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(color: _selectedFilter == f ? Colors.white : AppTheme.deepBlue, fontWeight: FontWeight.w600),
                  checkmarkColor: Colors.white,
                );
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.favorite_border,
                    title: 'No favorites yet',
                    message: 'Tap the heart icon on any place to save it here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final place = filtered[index];
                      return _buildPlaceCard(place);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(FavoritePlace place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            child: Image.asset(place.imagePath, width: 100, height: 90, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.sandBeige, borderRadius: BorderRadius.circular(10)),
                    child: Text(place.category, style: const TextStyle(fontSize: 11, color: AppTheme.earthBrown, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text(place.address, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  RatingBadge(rating: place.rating),
                ],
              ),
            ),
          ),
          FavoriteButton(
            isFavorited: place.isFavorited,
            onChanged: (val) => setState(() => place.isFavorited = val),
          ),
        ],
      ),
    );
  }
}
