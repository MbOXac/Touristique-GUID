import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/review.dart';

/// Unified rating & review system for destinations, circuits, and activities.
/// Reviews live in a single top-level 'reviews' collection with doc id
/// '{entityType}_{entityId}_{userId}' so a user can only ever have one
/// review per item (writing again edits it in place). After every write or
/// delete, the parent entity's `rating` and `reviewsCount` fields are
/// recalculated from the live set of reviews, so screens that only read
/// the entity doc (e.g. list/card views) stay accurate without needing to
/// join against reviews themselves.
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionName = 'reviews';

  String? get currentUserId => _auth.currentUser?.uid;
  String get currentUserName => _auth.currentUser?.displayName ?? 'Anonymous';
  String get currentUserAvatar => _auth.currentUser?.photoURL ?? '';

  String _docId(ReviewEntityType type, String entityId, String userId) =>
      '${type.key}_${entityId}_$userId';

  /// Stream all reviews for an entity, newest first.
  Stream<List<Review>> streamReviews(ReviewEntityType type, String entityId) {
    return _firestore
        .collection(_collectionName)
        .where('entityType', isEqualTo: type.key)
        .where('entityId', isEqualTo: entityId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => Review.fromFirestore(doc.data(), doc.id))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    }).handleError((Object e) {
      debugPrint('Error streaming reviews: $e');
    });
  }

  /// Live stream of the current user's own review for this entity (null if
  /// they haven't reviewed it yet). Drives whether the CTA reads
  /// "Write a Review" or "Edit your Review".
  Stream<Review?> streamMyReview(ReviewEntityType type, String entityId) {
    final uid = currentUserId;
    if (uid == null) return Stream.value(null);

    return _firestore
        .collection(_collectionName)
        .doc(_docId(type, entityId, uid))
        .snapshots()
        .map((doc) => doc.exists ? Review.fromFirestore(doc.data()!, doc.id) : null)
        .handleError((Object e) {
      debugPrint('Error streaming my review: $e');
    });
  }

  /// Creates the current user's review, or overwrites their existing one.
  Future<void> submitReview({
    required ReviewEntityType type,
    required String entityId,
    required double rating,
    String comment = '',
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('You must be signed in to leave a review.');
    }

    final docRef =
        _firestore.collection(_collectionName).doc(_docId(type, entityId, uid));
    final existing = await docRef.get();

    final review = Review(
      id: docRef.id,
      entityType: type,
      entityId: entityId,
      userId: uid,
      userName: currentUserName,
      userAvatar: currentUserAvatar,
      rating: rating,
      comment: comment,
      createdAt: existing.exists
          ? Review.fromFirestore(existing.data()!, existing.id).createdAt
          : DateTime.now(),
      updatedAt: existing.exists ? DateTime.now() : null,
    );

    await docRef.set(review.toFirestore());
    await _recalculateAggregate(type, entityId);
  }

  /// Deletes the current user's review for this entity.
  Future<void> deleteMyReview(ReviewEntityType type, String entityId) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore
        .collection(_collectionName)
        .doc(_docId(type, entityId, uid))
        .delete();
    await _recalculateAggregate(type, entityId);
  }

  /// Recomputes average rating + review count from the live reviews and
  /// writes them back onto the parent entity document.
  Future<void> _recalculateAggregate(
      ReviewEntityType type, String entityId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('entityType', isEqualTo: type.key)
          .where('entityId', isEqualTo: entityId)
          .get();

      final count = snapshot.docs.length;
      final average = count == 0
          ? 0.0
          : snapshot.docs
                  .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0.0)
                  .reduce((a, b) => a + b) /
              count;

      await _firestore.collection(type.parentCollection).doc(entityId).set(
        {
          'rating': double.parse(average.toStringAsFixed(2)),
          'reviewsCount': count,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error recalculating rating aggregate: $e');
    }
  }

  /// Rating breakdown (star -> fraction of reviews with that star, rounded)
  /// used to draw the 5/4/3/2/1 progress bars.
  static Map<int, double> ratingBreakdown(List<Review> reviews) {
    if (reviews.isEmpty) {
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final star = r.rating.round().clamp(1, 5);
      counts[star] = (counts[star] ?? 0) + 1;
    }
    return counts.map((star, count) => MapEntry(star, count / reviews.length));
  }
}
