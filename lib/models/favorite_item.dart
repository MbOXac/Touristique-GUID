import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of content that can be favorited.
/// Gallery posts are handled separately via GalleryItem.savedBy,
/// so they are not part of this enum — the Favorites screen reads
/// them straight from GalleryService instead of duplicating state here.
enum FavoriteType { destination, trip }

extension FavoriteTypeX on FavoriteType {
  String get key {
    switch (this) {
      case FavoriteType.destination:
        return 'destination';
      case FavoriteType.trip:
        return 'trip';
    }
  }

  String get label {
    switch (this) {
      case FavoriteType.destination:
        return 'Destination';
      case FavoriteType.trip:
        return 'Trip';
    }
  }

  static FavoriteType fromKey(String key) {
    switch (key) {
      case 'trip':
        return FavoriteType.trip;
      case 'destination':
      default:
        return FavoriteType.destination;
    }
  }
}

class FavoriteItem {
  final String id; // Firestore doc id: '{type}_{itemId}'
  final String userId;
  final String itemId;
  final FavoriteType type;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final DateTime createdAt;

  const FavoriteItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.rating = 0.0,
    required this.createdAt,
  });

  factory FavoriteItem.fromFirestore(Map<String, dynamic> data, String docId) {
    return FavoriteItem(
      id: docId,
      userId: data['userId']?.toString() ?? '',
      itemId: data['itemId']?.toString() ?? '',
      type: FavoriteTypeX.fromKey(data['type']?.toString() ?? 'destination'),
      title: data['title']?.toString() ?? '',
      subtitle: data['subtitle']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'type': type.key,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
