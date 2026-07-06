import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/favorite_item.dart';

/// Unified favorites system.
/// Stores favorites at users/{uid}/favorites/{type}_{itemId} so a given
/// destination or trip can only ever be favorited once per user, and
/// checking/toggling is a single doc read/write instead of a query.
class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? _favoritesCollection() {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  String _docId(FavoriteType type, String itemId) => '${type.key}_$itemId';

  /// Stream all favorites for the current user, optionally filtered by type.
  Stream<List<FavoriteItem>> streamFavorites({FavoriteType? type}) {
    final collection = _favoritesCollection();
    if (collection == null) return Stream.value([]);

    Query<Map<String, dynamic>> query = collection;
    if (type != null) {
      query = query.where('type', isEqualTo: type.key);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => FavoriteItem.fromFirestore(doc.data(), doc.id))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    }).handleError((Object e) {
      debugPrint('Error streaming favorites: $e');
    });
  }

  /// Live favorited state for a single item — drives FavoriteButton.
  Stream<bool> isFavoritedStream(FavoriteType type, String itemId) {
    final collection = _favoritesCollection();
    if (collection == null) return Stream.value(false);

    return collection
        .doc(_docId(type, itemId))
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<bool> isFavorited(FavoriteType type, String itemId) async {
    final collection = _favoritesCollection();
    if (collection == null) return false;
    final doc = await collection.doc(_docId(type, itemId)).get();
    return doc.exists;
  }

  /// Adds or removes a favorite. Returns the new favorited state.
  Future<bool> toggleFavorite({
    required FavoriteType type,
    required String itemId,
    required String title,
    String subtitle = '',
    String imageUrl = '',
    double rating = 0.0,
  }) async {
    final collection = _favoritesCollection();
    if (collection == null) {
      throw Exception('You must be signed in to save favorites.');
    }

    final docRef = collection.doc(_docId(type, itemId));
    final existing = await docRef.get();

    if (existing.exists) {
      await docRef.delete();
      return false;
    }

    final favorite = FavoriteItem(
      id: docRef.id,
      userId: currentUserId!,
      itemId: itemId,
      type: type,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      rating: rating,
      createdAt: DateTime.now(),
    );

    await docRef.set(favorite.toFirestore());
    return true;
  }

  Future<void> removeFavorite(FavoriteType type, String itemId) async {
    final collection = _favoritesCollection();
    if (collection == null) return;
    await collection.doc(_docId(type, itemId)).delete();
  }

  /// Total favorites count, handy for profile stats.
  Stream<int> streamFavoritesCount() {
    return streamFavorites().map((items) => items.length);
  }
}
