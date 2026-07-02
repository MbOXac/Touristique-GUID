import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String category; // 'destination', 'food', 'culture', 'adventure', 'nature'
  final double rating;
  final int likes;
  final int views;
  final int comments;
  final String uploadedBy;
  final String uploaderName;
  final String uploaderAvatar;
  final List<String> tags;
  final String? location;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<String> savedBy;
  final String? publicId; // For Cloudinary

  const GalleryItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.category,
    this.rating = 0.0,
    this.likes = 0,
    this.views = 0,
    this.comments = 0,
    required this.uploadedBy,
    required this.uploaderName,
    this.uploaderAvatar = '',
    this.tags = const [],
    this.location,
    required this.createdAt,
    this.likedBy = const [],
    this.savedBy = const [],
    this.publicId,
  });

  // From Firestore
  factory GalleryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? data['imageUrl'] ?? '',
      category: data['category'] ?? 'other',
      rating: (data['rating'] ?? 0.0).toDouble(),
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
      comments: data['comments'] ?? 0,
      uploadedBy: data['uploadedBy'] ?? '',
      uploaderName: data['uploaderName'] ?? 'Unknown',
      uploaderAvatar: data['uploaderAvatar'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      savedBy: List<String>.from(data['savedBy'] ?? []),
      publicId: data['publicId'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'rating': rating,
      'likes': likes,
      'views': views,
      'comments': comments,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'uploaderAvatar': uploaderAvatar,
      'tags': tags,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'savedBy': savedBy,
      if (publicId != null) 'publicId': publicId,
    };
  }

  GalleryItem copyWith({
    String? title,
    String? description,
    int? likes,
    int? views,
    int? comments,
    List<String>? likedBy,
    List<String>? savedBy,
  }) {
    return GalleryItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      category: category,
      rating: rating,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      comments: comments ?? this.comments,
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      uploaderAvatar: uploaderAvatar,
      tags: tags,
      location: location,
      createdAt: createdAt,
      likedBy: likedBy ?? this.likedBy,
      savedBy: savedBy ?? this.savedBy,
      publicId: publicId,
    );
  }

  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isSavedBy(String userId) => savedBy.contains(userId);
}