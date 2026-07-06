import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const categories = [
    {'id': 'all', 'label': 'All', 'icon': Icons.grid_view_rounded},
    {'id': 'destination', 'label': 'Destinations', 'icon': Icons.location_on_rounded},
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant_rounded},
    {'id': 'culture', 'label': 'Culture', 'icon': Icons.museum_rounded},
    {'id': 'adventure', 'label': 'Adventure', 'icon': Icons.hiking_rounded},
    {'id': 'nature', 'label': 'Nature', 'icon': Icons.park_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Chips sit on top of the AppBar's own background (deepBlue / darkAppBar),
    // so the row stays transparent instead of carrying its own white strip.
    final unselectedBg = isDark
        ? Colors.white.withAlpha(18)
        : Colors.white.withAlpha(30);
    final unselectedBorder = isDark
        ? Colors.white.withAlpha(28)
        : Colors.white.withAlpha(50);
    final unselectedLabel = isDark
        ? AppTheme.darkTextPrimary.withAlpha(210)
        : Colors.white.withAlpha(225);

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onCategorySelected(category['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.orangeGradient : null,
                  color: isSelected ? null : unselectedBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : unselectedBorder,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withAlpha(90),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 15,
                      color: isSelected ? Colors.white : unselectedLabel,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : unselectedLabel,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
