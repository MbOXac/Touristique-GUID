import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_memory.dart';

class TripMemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'memories';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<TripMemory>> streamMemories() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripMemory.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createMemory(TripMemory memory) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection(_collection).add({
      ...memory.copyWith(uid: uid).toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
