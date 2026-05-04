import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/destination.dart';

class DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'destinations';

  /// Fetch all destinations
  Future<List<Destination>> getAllDestinations() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();

      return querySnapshot.docs
          .map((doc) => Destination.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching destinations: $e');
      return [];
    }
  }

  /// Fetch a single destination by ID
  Future<Destination?> getDestinationById(String destinationId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(destinationId)
          .get();

      if (doc.exists) {
        return Destination.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching destination: $e');
      return null;
    }
  }

  /// Stream all destinations (real-time updates)
  Stream<List<Destination>> streamAllDestinations() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Destination.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Add a new destination
  Future<String> addDestination(Destination destination) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(destination.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding destination: $e');
      rethrow;
    }
  }

  /// Update a destination
  Future<void> updateDestination(
    String destinationId,
    Destination destination,
  ) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(destinationId)
          .update(destination.toFirestore());
    } catch (e) {
      debugPrint('Error updating destination: $e');
      rethrow;
    }
  }

  /// Delete a destination
  Future<void> deleteDestination(String destinationId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(destinationId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting destination: $e');
      rethrow;
    }
  }
}
