class FavoritePlace {
  final String id;
  final String name;
  final String category; // 'restaurant', 'monument', 'activity', 'hotel'
  final String imagePath;
  final double rating;
  final String address;
  bool isFavorited;

  FavoritePlace({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.rating,
    required this.address,
    this.isFavorited = true,
  });
}
