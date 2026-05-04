class Destination {
  final String id;
  final String name;
  final String description;
  final List<String> imageURLs;
  final double rating;
  final String distance;

  const Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageURLs,
    this.rating = 0.0,
    this.distance = '0 km',
  });

  String get imagePath => imageURLs.isNotEmpty ? imageURLs[0] : '';

  factory Destination.fromFirestore(Map<String, dynamic> data, String docId) {
    List<String> urls = [];

    if (data['imageURL'] != null) {
      if (data['imageURL'] is List) {
        urls = List<String>.from(data['imageURL']);
      } else if (data['imageURL'] is String) {
        urls = [data['imageURL']];
      }
    }

    return Destination(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageURLs: urls,
      rating: (data['rating'] ?? 0).toDouble(),
      distance: data['distance'] ?? '0 km',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageURL': imageURLs,
      'rating': rating,
      'distance': distance,
    };
  }
}