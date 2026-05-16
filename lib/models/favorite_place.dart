class FavoritePlace {
  final String uid;
  final String id;
  final String name;
  final String category; // 'restaurant', 'monument', 'activity', 'hotel'
  final String imagePath;
  final double rating;
  final String address;
  bool isFavorited;

  FavoritePlace({
    required this.uid,
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.rating,
    required this.address,
    this.isFavorited = true,
  });

  factory FavoritePlace.fromFirestore(Map<String, dynamic> data, String docId) {
    return FavoritePlace(
      uid: data['uid'] ?? '',
      id: docId,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      imagePath: data['imagePath'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      isFavorited: data['isFavorited'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'rating': rating,
      'address': address,
      'isFavorited': isFavorited,
    };
  }

  FavoritePlace copyWith({
    String? uid,
    String? id,
    String? name,
    String? category,
    String? imagePath,
    double? rating,
    String? address,
    bool? isFavorited,
  }) {
    return FavoritePlace(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      rating: rating ?? this.rating,
      address: address ?? this.address,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}
