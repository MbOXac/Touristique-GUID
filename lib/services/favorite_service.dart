import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_place.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'favorites';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<FavoritePlace>> streamFavorites() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoritePlace.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> upsertFavorite(FavoritePlace place) async {
    final uid = _uid;
    if (uid == null) return;
    final docRef = _firestore.collection(_collection).doc(place.id);
    final existing = await docRef.get();
    final payload = {
      ...place.copyWith(uid: uid).toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existing.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }
    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<void> setFavorited(FavoritePlace place, bool isFavorited) async {
    if (!isFavorited) {
      await removeFavorite(place.id);
      return;
    }
    await upsertFavorite(place.copyWith(isFavorited: true));
  }

  Future<void> removeFavorite(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection(_collection).doc(id).delete();
  }
}
