import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/circuit.dart';

class CircuitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'circuits';

  /// Fetch all circuits
  Future<List<Circuit>> getAllCircuits() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();

      return querySnapshot.docs
          .map((doc) => Circuit.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching circuits: $e');
      // Fallback without ordering (in case createdAt is missing on some docs)
      try {
        final fallback =
            await _firestore.collection(_collectionName).get();
        return fallback.docs
            .map((doc) => Circuit.fromFirestore(doc))
            .toList();
      } catch (e2) {
        debugPrint('Error fetching circuits (fallback): $e2');
        return [];
      }
    }
  }

  /// Stream all circuits (real-time updates)
  Stream<List<Circuit>> streamAllCircuits() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Circuit.fromFirestore(doc))
            .toList());
  }

  /// Fetch a single circuit by ID
  Future<Circuit?> getCircuitById(String id) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return Circuit.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching circuit: $e');
      return null;
    }
  }

  /// Fetch circuits filtered by type (desert / cultural / adventure / mountain / oasis)
  Future<List<Circuit>> getCircuitsByType(String type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('type', isEqualTo: type)
          .get();

      return querySnapshot.docs
          .map((doc) => Circuit.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching circuits by type: $e');
      return [];
    }
  }

  /// Fetch circuits within a duration range (inclusive)
  Future<List<Circuit>> getCircuitsByDuration(
      int minDays, int maxDays) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('durationDays', isGreaterThanOrEqualTo: minDays)
          .where('durationDays', isLessThanOrEqualTo: maxDays)
          .get();

      return querySnapshot.docs
          .map((doc) => Circuit.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching circuits by duration: $e');
      return [];
    }
  }

  /// Fetch circuits within a price range (inclusive)
  Future<List<Circuit>> getCircuitsByPriceRange(
      double min, double max) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('priceMAD', isGreaterThanOrEqualTo: min)
          .where('priceMAD', isLessThanOrEqualTo: max)
          .get();

      return querySnapshot.docs
          .map((doc) => Circuit.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching circuits by price range: $e');
      return [];
    }
  }

  /// Search circuits by title / description / type (client-side contains)
  Future<List<Circuit>> searchCircuits(String query) async {
    try {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return getAllCircuits();

      final all = await getAllCircuits();
      return all.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.titleAr.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.type.toLowerCase().contains(q) ||
            c.meetingPoint.toLowerCase().contains(q);
      }).toList();
    } catch (e) {
      debugPrint('Error searching circuits: $e');
      return [];
    }
  }

  /// Fetch the most popular circuits (highest rating first)
  Future<List<Circuit>> getPopularCircuits({int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Circuit.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching popular circuits: $e');
      // Fallback: sort client-side
      try {
        final all = await getAllCircuits();
        all.sort((a, b) => b.rating.compareTo(a.rating));
        return all.take(limit).toList();
      } catch (e2) {
        debugPrint('Error fetching popular circuits (fallback): $e2');
        return [];
      }
    }
  }

  /// Add a new circuit
  Future<String> addCircuit(Circuit circuit) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(circuit.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding circuit: $e');
      rethrow;
    }
  }

  // ─── Favorites (users/{userId}/favorite_circuits) ──────────────
  CollectionReference _favoritesRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorite_circuits');

  /// Toggle a circuit in the user's favorites
  Future<void> toggleFavoriteCircuit(
      String circuitId, String userId) async {
    if (userId.isEmpty) return;
    try {
      final docRef = _favoritesRef(userId).doc(circuitId);
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'circuitId': circuitId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      debugPrint('Error toggling favorite circuit: $e');
      rethrow;
    }
  }

  /// Whether a circuit is in the user's favorites
  Future<bool> isCircuitFavorited(String circuitId, String userId) async {
    if (userId.isEmpty) return false;
    try {
      final doc = await _favoritesRef(userId).doc(circuitId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking favorite circuit: $e');
      return false;
    }
  }

  /// Fetch all of a user's favorite circuits (resolved to full Circuit objects)
  Future<List<Circuit>> getFavoriteCircuits(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final snapshot = await _favoritesRef(userId).get();
      final ids = snapshot.docs.map((doc) => doc.id).toList();
      if (ids.isEmpty) return [];

      final circuits = <Circuit>[];
      for (final id in ids) {
        final circuit = await getCircuitById(id);
        if (circuit != null) circuits.add(circuit);
      }
      return circuits;
    } catch (e) {
      debugPrint('Error fetching favorite circuits: $e');
      return [];
    }
  }
}
