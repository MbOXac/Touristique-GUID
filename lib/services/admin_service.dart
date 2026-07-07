import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';

/// Admin-only Firestore operations.
/// All methods guard themselves with an admin role check.
/// Regular user-facing services (BookingService, DestinationService, …)
/// are left completely untouched.
class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────
  //  ROLE CHECK
  // ─────────────────────────────────────────────

  /// Returns true when the currently signed-in user has role == "admin"
  /// stored inside their `users/{uid}` document.
  Future<bool> isCurrentUserAdmin() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['role'] == 'admin';
    } catch (e) {
      debugPrint('AdminService.isCurrentUserAdmin error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  DASHBOARD STATS
  // ─────────────────────────────────────────────

  /// Aggregated stats for the admin overview: total counts.
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _db.collection('destinations').count().get(),
        _db.collection('allBookings').count().get(),
        _db.collection('users').count().get(),
        _db
            .collection('allBookings')
            .where('status', isEqualTo: 'pending')
            .count()
            .get(),
        _db.collection('cars').count().get(),
      ]);
      return {
        'destinations': results[0].count ?? 0,
        'bookings': results[1].count ?? 0,
        'users': results[2].count ?? 0,
        'pendingBookings': results[3].count ?? 0,
        'cars': results[4].count ?? 0,
      };
    } catch (e) {
      debugPrint('AdminService.getDashboardStats error: $e');
      return {
        'destinations': 0,
        'bookings': 0,
        'users': 0,
        'pendingBookings': 0,
        'cars': 0,
      };
    }
  }

  // ─────────────────────────────────────────────
  //  ALL BOOKINGS  (flat mirror collection)
  // ─────────────────────────────────────────────

  /// Real-time stream of every booking across all users, newest first.
  /// Reads from the flat `allBookings` collection (written by BookingService).
  Stream<List<Booking>> streamAllBookings() {
    return _db
        .collection('allBookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Booking.fromFirestore(d.data(), d.id))
            .toList())
        .handleError((Object e) {
      debugPrint('AdminService.streamAllBookings error: $e');
    });
  }

  /// Stream filtered by status.
  Stream<List<Booking>> streamBookingsByStatus(BookingStatus status) {
    return _db
        .collection('allBookings')
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Booking.fromFirestore(d.data(), d.id))
            .toList())
        .handleError((Object e) {
      debugPrint('AdminService.streamBookingsByStatus error: $e');
    });
  }

  /// Update booking status in BOTH collections:
  ///  • allBookings/{bookingId}
  ///  • bookings/{userId}/userBookings/{bookingId}
  Future<void> updateBookingStatus(
      Booking booking, BookingStatus newStatus) async {
    try {
      final batch = _db.batch();

      // Mirror collection
      batch.update(
        _db.collection('allBookings').doc(booking.id),
        {'status': newStatus.name},
      );

      // Original per-user sub-collection
      if (booking.userId.isNotEmpty) {
        batch.update(
          _db
              .collection('bookings')
              .doc(booking.userId)
              .collection('userBookings')
              .doc(booking.id),
          {'status': newStatus.name},
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('AdminService.updateBookingStatus error: $e');
      rethrow;
    }
  }

  /// Delete a booking from both collections.
  Future<void> deleteBooking(Booking booking) async {
    try {
      final batch = _db.batch();
      batch.delete(_db.collection('allBookings').doc(booking.id));
      if (booking.userId.isNotEmpty) {
        batch.delete(
          _db
              .collection('bookings')
              .doc(booking.userId)
              .collection('userBookings')
              .doc(booking.id),
        );
      }
      await batch.commit();
    } catch (e) {
      debugPrint('AdminService.deleteBooking error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  //  USERS
  // ─────────────────────────────────────────────

  /// Real-time stream of all user documents.
  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList())
        .handleError((Object e) {
      debugPrint('AdminService.streamAllUsers error: $e');
    });
  }

  /// Stream users ordered by name (fallback when no createdAt field).
  Stream<List<Map<String, dynamic>>> streamAllUsersByName() {
    return _db
        .collection('users')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
          list.sort((a, b) =>
              (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
          return list;
        })
        .handleError((Object e) {
      debugPrint('AdminService.streamAllUsersByName error: $e');
    });
  }

  /// Remove a user's Firestore document.
  /// Note: this does NOT delete the Firebase Auth account.
  Future<void> deleteUserDocument(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint('AdminService.deleteUserDocument error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  //  CARS
  // ─────────────────────────────────────────────

  /// Real-time stream of all cars.
  Stream<List<Map<String, dynamic>>> streamAllCars() {
    return _db
        .collection('cars')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList())
        .handleError((Object e) {
      debugPrint('AdminService.streamAllCars error: $e');
    });
  }

  /// Delete a car document.
  Future<void> deleteCar(String carId) async {
    try {
      await _db.collection('cars').doc(carId).delete();
    } catch (e) {
      debugPrint('AdminService.deleteCar error: $e');
      rethrow;
    }
  }
}
