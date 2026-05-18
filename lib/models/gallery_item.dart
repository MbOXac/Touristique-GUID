class GalleryItem {
  final String id;
  final String title;
  final String imagePath;
  final String category; // 'destination', 'user', 'memory'
  final double rating;
  final int likes;
  final String uploadedBy;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.category,
    required this.rating,
    required this.likes,
    required this.uploadedBy,
  });
}
