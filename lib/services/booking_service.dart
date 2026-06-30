import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class BookingService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId => _auth.currentUser?.uid ?? '';

  static CollectionReference get _bookingsRef => _firestore
      .collection('bookings')
      .doc(_userId)
      .collection('userBookings');

  // ✅ CREATE
  static Future<void> createBooking(Booking booking) async {
    try {
      final docRef = _bookingsRef.doc();
      final newBooking = Booking(
        id: docRef.id,
        userId: _userId,
        type: booking.type,
        name: booking.name,
        imageUrl: booking.imageUrl,
        bookingDate: booking.bookingDate,
        startDate: booking.startDate,
        endDate: booking.endDate,
        guests: booking.guests,
        price: booking.price,
        status: BookingStatus.pending,
        details: booking.details,
        createdAt: DateTime.now(),
      );
      await docRef.set(newBooking.toMap());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // ✅ READ ALL
  static Stream<List<Booking>> getUserBookings() {
    return _bookingsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // ✅ READ BY STATUS
  static Stream<List<Booking>> getBookingsByStatus(
      BookingStatus status) {
    return _bookingsRef
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // ✅ CANCEL
  static Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingsRef
          .doc(bookingId)
          .update({'status': BookingStatus.cancelled.name});
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // ✅ DELETE
  static Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  // ✅ CONFIRM
  static Future<void> confirmBooking(String bookingId) async {
    try {
      await _bookingsRef
          .doc(bookingId)
          .update({'status': BookingStatus.confirmed.name});
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }
}