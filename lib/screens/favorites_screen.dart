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
    final theme = Theme.of(context);
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
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
                final selected = _selectedFilter == f;
                return FilterChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = f),
                  selectedColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : theme.textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
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
                    itemBuilder: (context, index) => _buildPlaceCard(filtered[index], theme),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(FavoritePlace place, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
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
                  Text(
                    place.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBackground : AppTheme.sandBeige,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      place.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.goldAccent : AppTheme.earthBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.address,
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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