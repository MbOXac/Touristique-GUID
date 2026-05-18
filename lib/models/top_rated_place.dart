class TopRatedPlace {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String category;
  final String imagePath;
  final String description;
  final String distance;

  const TopRatedPlace({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.imagePath,
    required this.description,
    required this.distance,
  });
}
