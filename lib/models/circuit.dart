import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';

class Circuit {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String imageUrl;
  final int durationDays;
  final double priceMAD;
  final String difficulty; // easy / medium / hard
  final String type; // desert / cultural / adventure / mountain / oasis
  final double rating;
  final int reviewsCount;
  final List<String> destinationIds;
  final List<CircuitDay> itinerary;
  final List<LatLng> routePoints;
  final LatLng startLocation;
  final LatLng endLocation;
  final List<String> includedServices;
  final List<String> notIncluded;
  final List<String> gallery;
  final String meetingPoint;
  final int maxGroupSize;
  final bool isAvailable;
  final DateTime createdAt;

  const Circuit({
    required this.id,
    required this.title,
    this.titleAr = '',
    required this.description,
    this.imageUrl = '',
    required this.durationDays,
    required this.priceMAD,
    this.difficulty = 'easy',
    this.type = 'cultural',
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.destinationIds = const [],
    this.itinerary = const [],
    this.routePoints = const [],
    required this.startLocation,
    required this.endLocation,
    this.includedServices = const [],
    this.notIncluded = const [],
    this.gallery = const [],
    this.meetingPoint = '',
    this.maxGroupSize = 12,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory Circuit.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return Circuit(
      id: doc.id,
      title: data['title'] ?? '',
      titleAr: data['titleAr'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      durationDays: (data['durationDays'] ?? 1).toInt(),
      priceMAD: (data['priceMAD'] ?? 0).toDouble(),
      difficulty: data['difficulty'] ?? 'easy',
      type: data['type'] ?? 'cultural',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewsCount: (data['reviewsCount'] ?? 0).toInt(),
      destinationIds: List<String>.from(data['destinationIds'] ?? const []),
      itinerary: (data['itinerary'] as List<dynamic>? ?? const [])
          .map((e) => CircuitDay.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      routePoints: _parseLatLngList(data['routePoints']),
      startLocation: _parseLatLng(data['startLocation']) ??
          const LatLng(31.9314, -4.4244),
      endLocation: _parseLatLng(data['endLocation']) ??
          const LatLng(31.9314, -4.4244),
      includedServices:
          List<String>.from(data['includedServices'] ?? const []),
      notIncluded: List<String>.from(data['notIncluded'] ?? const []),
      gallery: List<String>.from(data['gallery'] ?? const []),
      meetingPoint: data['meetingPoint'] ?? '',
      maxGroupSize: (data['maxGroupSize'] ?? 12).toInt(),
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleAr': titleAr,
      'description': description,
      'imageUrl': imageUrl,
      'durationDays': durationDays,
      'priceMAD': priceMAD,
      'difficulty': difficulty,
      'type': type,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'destinationIds': destinationIds,
      'itinerary': itinerary.map((e) => e.toMap()).toList(),
      'routePoints': routePoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'startLocation': {
        'lat': startLocation.latitude,
        'lng': startLocation.longitude,
      },
      'endLocation': {
        'lat': endLocation.latitude,
        'lng': endLocation.longitude,
      },
      'includedServices': includedServices,
      'notIncluded': notIncluded,
      'gallery': gallery,
      'meetingPoint': meetingPoint,
      'maxGroupSize': maxGroupSize,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get formattedPrice => '${priceMAD.toStringAsFixed(0)} MAD';

  String get durationText =>
      '$durationDays ${durationDays == 1 ? 'Day' : 'Days'}';

  IconData get typeIcon {
    switch (type) {
      case 'desert':
        return Icons.wb_sunny_rounded;
      case 'cultural':
        return Icons.account_balance_rounded;
      case 'adventure':
        return Icons.terrain_rounded;
      case 'mountain':
        return Icons.landscape_rounded;
      case 'oasis':
        return Icons.park_rounded;
      default:
        return Icons.route_rounded;
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'easy':
        return AppTheme.oasisGreen;
      case 'medium':
        return AppTheme.goldAccent;
      case 'hard':
        return const Color(0xFFC0392B);
      default:
        return AppTheme.oasisGreen;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────
  static LatLng? _parseLatLng(dynamic value) {
    if (value is Map) {
      final lat = (value['lat'] ?? 0).toDouble();
      final lng = (value['lng'] ?? 0).toDouble();
      return LatLng(lat, lng);
    }
    return null;
  }

  static List<LatLng> _parseLatLngList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => LatLng(
                (e['lat'] ?? 0).toDouble(),
                (e['lng'] ?? 0).toDouble(),
              ))
          .toList();
    }
    return const [];
  }
}

class CircuitDay {
  final int dayNumber;
  final String title;
  final String description;
  final String destinationId;
  final String imageUrl;
  final List<CircuitActivity> activities;
  final String accommodation;
  final String meals;
  final double distanceKm;

  const CircuitDay({
    required this.dayNumber,
    required this.title,
    this.description = '',
    this.destinationId = '',
    this.imageUrl = '',
    this.activities = const [],
    this.accommodation = '',
    this.meals = '',
    this.distanceKm = 0.0,
  });

  factory CircuitDay.fromMap(Map<String, dynamic> data) {
    return CircuitDay(
      dayNumber: (data['dayNumber'] ?? 1).toInt(),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      destinationId: data['destinationId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      activities: (data['activities'] as List<dynamic>? ?? const [])
          .map((e) =>
              CircuitActivity.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      accommodation: data['accommodation'] ?? '',
      meals: data['meals'] ?? '',
      distanceKm: (data['distanceKm'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      'destinationId': destinationId,
      'imageUrl': imageUrl,
      'activities': activities.map((e) => e.toMap()).toList(),
      'accommodation': accommodation,
      'meals': meals,
      'distanceKm': distanceKm,
    };
  }

  String get distanceText =>
      distanceKm > 0 ? '${distanceKm.toStringAsFixed(0)} km' : 'On foot';
}

class CircuitActivity {
  final String time;
  final String title;
  final String description;
  final String type; // visit / hike / meal / transport / free_time / experience
  final int durationMinutes;

  const CircuitActivity({
    required this.time,
    required this.title,
    this.description = '',
    this.type = 'visit',
    this.durationMinutes = 0,
  });

  factory CircuitActivity.fromMap(Map<String, dynamic> data) {
    return CircuitActivity(
      time: data['time'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'visit',
      durationMinutes: (data['durationMinutes'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'title': title,
      'description': description,
      'type': type,
      'durationMinutes': durationMinutes,
    };
  }

  IconData get icon {
    switch (type) {
      case 'visit':
        return Icons.place_rounded;
      case 'hike':
        return Icons.hiking_rounded;
      case 'meal':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'free_time':
        return Icons.self_improvement_rounded;
      case 'experience':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.circle_rounded;
    }
  }
}
