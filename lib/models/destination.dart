import 'package:flutter/foundation.dart';

class Destination {
  final String id;
  final String name;
  final String description;
  final List<String> imageURLs;
  final double rating;
  final int reviewsCount;
  final String distance;
  final double lat;
  final double lng;
  final String tags;

  const Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageURLs,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.distance = '0 km',
    required this.lat,
    required this.lng,
    required this.tags,
  });

  String get imagePath => imageURLs.isNotEmpty ? imageURLs[0] : '';

  factory Destination.fromFirestore(Map<String, dynamic> data, String docId) {
    debugPrint('DEBUG: Destination data: $data');
    debugPrint('DEBUG: imageURL field: ${data['imageURL']}');
    debugPrint('DEBUG: imageURL type: ${data['imageURL'].runtimeType}');
    
    List<String> urls = [];
    
    // Try to get imageURL - it might be an array
    if (data['imageURL'] != null) {
      if (data['imageURL'] is List) {
        urls = List<String>.from(data['imageURL']);
      } else if (data['imageURL'] is String) {
        urls = [data['imageURL']];
      }
    }
    
    debugPrint('DEBUG: Parsed URLs: $urls');

    return Destination(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageURLs: urls,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewsCount: (data['reviewsCount'] ?? 0).toInt(),
      distance: data['distance'] ?? '0 km',
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      tags: data['tags'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageURL': imageURLs,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'distance': distance,
      'lat': lat,
      'lng': lng,
      'tags': tags,
    };
  }
}