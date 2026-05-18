import 'package:flutter/material.dart';

class HorizontalCarousel extends StatelessWidget {
  final List<Widget> items;
  final double itemWidth;
  final double height;

  const HorizontalCarousel({
    super.key,
    required this.items,
    this.itemWidth = 160,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(width: itemWidth, child: items[index]),
      ),
    );
  }
}
