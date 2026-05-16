import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'bookings';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Booking>> streamBookings() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> createBooking(Booking booking) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection(_collection).add({
      ...booking.copyWith(uid: uid).toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBooking(Booking booking) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection(_collection).doc(booking.id).set({
      ...booking.copyWith(uid: uid).toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
