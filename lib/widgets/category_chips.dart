import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const categories = [
    {'id': 'all', 'label': 'All', 'icon': Icons.grid_view},
    {'id': 'destination', 'label': 'Destinations', 'icon': Icons.location_on},
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'culture', 'label': 'Culture', 'icon': Icons.museum},
    {'id': 'adventure', 'label': 'Adventure', 'icon': Icons.hiking},
    {'id': 'nature', 'label': 'Nature', 'icon': Icons.nature},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Text(category['label'] as String),
                ],
              ),
              onSelected: (_) => onCategorySelected(category['id'] as String),
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}