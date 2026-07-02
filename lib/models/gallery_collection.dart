import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryCollection {
  final String id;
  final String name;
  final String description;
  final String coverImageUrl;
  final String userId;
  final List<String> imageIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GalleryCollection({
    required this.id,
    required this.name,
    this.description = '',
    this.coverImageUrl = '',
    required this.userId,
    this.imageIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryCollection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryCollection(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      userId: data['userId'] ?? '',
      imageIds: List<String>.from(data['imageIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'userId': userId,
      'imageIds': imageIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}