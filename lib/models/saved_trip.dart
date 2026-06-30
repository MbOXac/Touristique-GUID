import 'package:cloud_firestore/cloud_firestore.dart';

class SavedTrip {
  final String id;
  final String userId;
  final String title;
  final String destination;
  final String country;
  final String description;
  final String mood;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // NEW FIELDS
  final String status; // "planned", "ongoing", "completed"
  final int travelers;
  final double budget;
  final double spent;
  final String hotel;
  final List<TripChecklist> checklist;

  const SavedTrip({
    required this.id,
    required this.userId,
    required this.title,
    required this.destination,
    required this.country,
    required this.description,
    required this.mood,
    required this.startDate,
    required this.endDate,
    required this.photoUrls,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'planned',
    this.travelers = 1,
    this.budget = 0,
    this.spent = 0,
    this.hotel = '',
    this.checklist = const [],
  });

  int get dayCount => endDate.difference(startDate).inDays + 1;
  
  // NEW: Calculate days remaining
  int get daysRemaining {
    if (status == 'completed') return 0;
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return startDate.difference(now).inDays;
    }
    return endDate.difference(now).inDays;
  }

  // NEW: Get trip progress percentage
  double get progressPercentage {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;
    
    final totalDays = dayCount.toDouble();
    final elapsedDays = now.difference(startDate).inDays.toDouble();
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  // NEW: Get budget remaining
  double get budgetRemaining => budget - spent;

  // NEW: Get budget percentage
  double get budgetPercentage {
    if (budget <= 0) return 0.0;
    return (spent / budget).clamp(0.0, 1.0);
  }

  factory SavedTrip.fromFirestore(Map<String, dynamic> data, String docId) {
    return SavedTrip(
      id: docId,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      destination: data['destination']?.toString() ?? '',
      country: data['country']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      mood: data['mood']?.toString() ?? '✈️',
      startDate: _readDate(data['startDate']),
      endDate: _readDate(data['endDate']),
      photoUrls: data['photoUrls'] is List
          ? List<String>.from(data['photoUrls'])
          : const [],
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
      status: data['status']?.toString() ?? 'planned',
      travelers: (data['travelers'] as num?)?.toInt() ?? 1,
      budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
      spent: (data['spent'] as num?)?.toDouble() ?? 0.0,
      hotel: data['hotel']?.toString() ?? '',
      checklist: data['checklist'] is List
          ? (data['checklist'] as List)
              .map((item) => TripChecklist.fromMap(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'destination': destination,
      'country': country,
      'description': description,
      'mood': mood,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'photoUrls': photoUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
      'travelers': travelers,
      'budget': budget,
      'spent': spent,
      'hotel': hotel,
      'checklist': checklist.map((item) => item.toMap()).toList(),
    };
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}

// NEW: Checklist item model
class TripChecklist {
  final String task;
  final bool done;

  const TripChecklist({
    required this.task,
    required this.done,
  });

  factory TripChecklist.fromMap(Map<String, dynamic> map) {
    return TripChecklist(
      task: map['task']?.toString() ?? '',
      done: map['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'done': done,
    };
  }
}