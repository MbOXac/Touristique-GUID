import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/activity.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'activities';

  /// Fetch all activities by location (your destination name)
  Future<List<Activity>> getActivitiesByLocation(String location) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('location', isEqualTo: location)
          .get();

      return querySnapshot.docs
          .map((doc) => Activity.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      return [];
    }
  }

  /// Fetch all activities
  Future<List<Activity>> getAllActivities() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();

      return querySnapshot.docs
          .map((doc) => Activity.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all activities: $e');
      return [];
    }
  }

  /// Fetch a single activity by ID
  Future<Activity?> getActivityById(String activityId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(activityId)
          .get();

      if (doc.exists) {
        return Activity.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching activity: $e');
      return null;
    }
  }

  /// Add a new activity
  Future<String> addActivity(Activity activity) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(activity.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding activity: $e');
      rethrow;
    }
  }

  /// Update an existing activity
  Future<void> updateActivity(String activityId, Activity activity) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(activityId)
          .update(activity.toFirestore());
    } catch (e) {
      debugPrint('Error updating activity: $e');
      rethrow;
    }
  }

  /// Delete an activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(activityId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      rethrow;
    }
  }

  /// Stream activities by location (real-time updates)
  Stream<List<Activity>> streamActivitiesByLocation(String location) {
    return _firestore
        .collection(_collectionName)
        .where('location', isEqualTo: location)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Activity.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream activities by region
  Stream<List<Activity>> streamActivitiesByRegion(String region) {
    return _firestore
        .collection(_collectionName)
        .where('region', isEqualTo: region)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Activity.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream activities by category
  Stream<List<Activity>> streamActivitiesByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Activity.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
