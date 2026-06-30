import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/saved_trip.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int maxPhotos = 3;
  static const int maxTotalPhotoBytes = 650 * 1024;

  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to save trips.');
    }
    return user;
  }

  CollectionReference<Map<String, dynamic>> _tripsCollection() {
    return _firestore.collection('trips');
  }

  // Stream all trips for current user
  Stream<List<SavedTrip>> streamMyTrips() {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint('❌ ERROR: No authenticated user!');
      return Stream.value([]);
    }

    debugPrint('✅ Current user UID: ${user.uid}');

    return _tripsCollection()
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      debugPrint('📊 Snapshot received: ${snapshot.docs.length} documents');

      final trips = snapshot.docs
          .map((doc) => SavedTrip.fromFirestore(doc.data(), doc.id))
          .toList();

      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('✅ Successfully loaded ${trips.length} trips');
      return trips;
    });
  }

  // Stream trips by status
  Stream<List<SavedTrip>> streamTripsByStatus(String status) {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint('❌ ERROR: No authenticated user!');
      return Stream.value([]);
    }

    debugPrint('✅ Loading $status trips for user: ${user.uid}');

    return _tripsCollection()
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      debugPrint('📊 Snapshot received: ${snapshot.docs.length} documents');

      final filtered =
          snapshot.docs.where((doc) => doc['status'] == status).toList();

      final trips = filtered
          .map((doc) => SavedTrip.fromFirestore(doc.data(), doc.id))
          .toList();

      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('📊 $status trips: ${trips.length}');
      return trips;
    });
  }

  // Get single trip
  Future<SavedTrip?> getTrip(String tripId) async {
    try {
      final user = _currentUser;
      final doc = await _tripsCollection().doc(tripId).get();

      if (!doc.exists) {
        debugPrint('❌ Trip not found: $tripId');
        return null;
      }

      final data = doc.data();
      if (data == null || data['userId'] != user.uid) {
        debugPrint('❌ Unauthorized access to trip: $tripId');
        return null;
      }

      debugPrint('✅ Trip loaded: $tripId');
      return SavedTrip.fromFirestore(data, doc.id);
    } catch (e) {
      debugPrint('❌ Error getting trip: $e');
      return null;
    }
  }

  // Create new trip
  Future<String> createTrip({
    required String title,
    required String destination,
    required String country,
    required String description,
    required String mood,
    required DateTime startDate,
    required DateTime endDate,
    required List<XFile> images,
    int travelers = 1,
    double budget = 0,
    String hotel = '',
  }) async {
    final user = _currentUser;
    final docRef = _tripsCollection().doc();

    debugPrint('🚀 Creating trip: ${docRef.path}');

    final photoDataUrls = await _imagesToFirestoreDataUrls(images).timeout(
      const Duration(seconds: 35),
      onTimeout: () => throw Exception(
        'Image processing timed out. Try fewer or smaller photos.',
      ),
    );

    final now = DateTime.now();
    final trip = SavedTrip(
      id: docRef.id,
      userId: user.uid,
      title: title,
      destination: destination,
      country: country,
      description: description,
      mood: mood,
      startDate: startDate,
      endDate: endDate,
      photoUrls: photoDataUrls,
      createdAt: now,
      updatedAt: now,
      status: 'planned',
      travelers: travelers,
      budget: budget,
      hotel: hotel,
      checklist: const [],
    );

    final tripData = trip.toFirestore();
    debugPrint('📝 Trip data to save: $tripData');

    try {
      await docRef.set(tripData).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception(
          'Firestore save timed out. Check your internet connection.',
        ),
      );

      debugPrint('✅ Trip created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating trip: $e');
      rethrow;
    }
  }

  // Update trip
  Future<void> updateTrip(SavedTrip trip) async {
    try {
      final user = _currentUser;
      if (trip.userId != user.uid) {
        throw Exception('Unauthorized: Cannot update another user\'s trip');
      }

      await _tripsCollection().doc(trip.id).update(trip.toFirestore());
      debugPrint('✅ Trip updated: ${trip.id}');
    } catch (e) {
      debugPrint('❌ Error updating trip: $e');
      rethrow;
    }
  }

  // Update trip status
  Future<void> updateTripStatus(String tripId, String status) async {
    try {
      final user = _currentUser;

      final trip = await getTrip(tripId);
      if (trip == null || trip.userId != user.uid) {
        throw Exception('Unauthorized: Cannot update another user\'s trip');
      }

      await _tripsCollection().doc(tripId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Trip status updated to: $status');
    } catch (e) {
      debugPrint('❌ Error updating trip status: $e');
      rethrow;
    }
  }

  // Update trip budget spent
  Future<void> updateTripSpent(String tripId, double spent) async {
    try {
      final user = _currentUser;

      final trip = await getTrip(tripId);
      if (trip == null || trip.userId != user.uid) {
        throw Exception('Unauthorized: Cannot update another user\'s trip');
      }

      await _tripsCollection().doc(tripId).update({
        'spent': spent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Trip spent updated to: $spent');
    } catch (e) {
      debugPrint('❌ Error updating trip spent: $e');
      rethrow;
    }
  }

  // Delete trip
  Future<void> deleteTrip(SavedTrip trip) async {
    try {
      final user = _currentUser;
      if (trip.userId != user.uid) {
        throw Exception('Unauthorized: Cannot delete another user\'s trip');
      }

      await _tripsCollection().doc(trip.id).delete();
      debugPrint('✅ Trip deleted: ${trip.id}');
    } catch (e) {
      debugPrint('❌ Error deleting trip: $e');
      rethrow;
    }
  }

  // Image processing
  Future<List<String>> _imagesToFirestoreDataUrls(List<XFile> images) async {
    final selected = images.take(maxPhotos).toList();
    final dataUrls = <String>[];
    var totalBytes = 0;

    for (var i = 0; i < selected.length; i++) {
      final image = selected[i];
      final bytes = await image.readAsBytes().timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw Exception('Could not read image file: ${image.name}'),
      );

      totalBytes += bytes.length;
      if (totalBytes > maxTotalPhotoBytes) {
        throw Exception(
          'Photos are too large for Firestore free storage. Please choose fewer/smaller photos.',
        );
      }

      final mimeType = image.mimeType ?? _guessMimeType(image.name);
      final base64Photo = base64Encode(bytes);
      dataUrls.add('data:$mimeType;base64,$base64Photo');
    }

    return dataUrls;
  }

  String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}

// Extension
extension SavedTripExtension on SavedTrip {
  SavedTrip copyWith({
    String? id,
    String? userId,
    String? title,
    String? destination,
    String? country,
    String? description,
    String? mood,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    int? travelers,
    double? budget,
    double? spent,
    String? hotel,
    List<TripChecklist>? checklist,
  }) {
    return SavedTrip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      description: description ?? this.description,
      mood: mood ?? this.mood,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      travelers: travelers ?? this.travelers,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      hotel: hotel ?? this.hotel,
      checklist: checklist ?? this.checklist,
    );
  }
}