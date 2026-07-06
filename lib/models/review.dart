import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of content that can be reviewed.
enum ReviewEntityType { destination, circuit, activity }

extension ReviewEntityTypeX on ReviewEntityType {
  String get key {
    switch (this) {
      case ReviewEntityType.destination:
        return 'destination';
      case ReviewEntityType.circuit:
        return 'circuit';
      case ReviewEntityType.activity:
        return 'activity';
    }
  }

  /// Firestore collection holding the parent entity (used to write back
  /// the aggregate rating/reviewsCount after a review is added/edited/removed).
  String get parentCollection {
    switch (this) {
      case ReviewEntityType.destination:
        return 'destinations';
      case ReviewEntityType.circuit:
        return 'circuits';
      case ReviewEntityType.activity:
        return 'activities';
    }
  }

  static ReviewEntityType fromKey(String key) {
    switch (key) {
      case 'circuit':
        return ReviewEntityType.circuit;
      case 'activity':
        return ReviewEntityType.activity;
      case 'destination':
      default:
        return ReviewEntityType.destination;
    }
  }
}

class Review {
  final String id; // Firestore doc id: '{entityType}_{entityId}_{userId}'
  final ReviewEntityType entityType;
  final String entityId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating; // 1.0 - 5.0
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.userId,
    this.userName = 'Anonymous',
    this.userAvatar = '',
    required this.rating,
    this.comment = '',
    required this.createdAt,
    this.updatedAt,
  });

  bool get wasEdited => updatedAt != null;

  factory Review.fromFirestore(Map<String, dynamic> data, String docId) {
    return Review(
      id: docId,
      entityType:
          ReviewEntityTypeX.fromKey(data['entityType']?.toString() ?? 'destination'),
      entityId: data['entityId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'Anonymous',
      userAvatar: data['userAvatar']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'entityType': entityType.key,
      'entityId': entityId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}
