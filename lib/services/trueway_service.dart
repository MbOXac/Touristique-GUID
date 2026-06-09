import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ════════════════════════════════════════════════
// 📍 TRUEWAY PLACE MODEL
// ════════════════════════════════════════════════
class TruewayPlace {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? website;
  final double lat;
  final double lng;
  final List<String> types;
  final int? distance;

  TruewayPlace({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.website,
    required this.lat,
    required this.lng,
    required this.types,
    this.distance,
  });

  factory TruewayPlace.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return TruewayPlace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      address: json['address']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      website: json['website']?.toString(),
      lat: (location['lat'] ?? 0).toDouble(),
      lng: (location['lng'] ?? 0).toDouble(),
      types: (json['types'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      distance: json['distance'] is int
          ? json['distance']
          : (json['distance'] as num?)?.toInt(),
    );
  }

  String get mainCategory {
    if (types.isEmpty) return 'Place';
    return types.first.replaceAll('_', ' ');
  }

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1000) return '${distance}m';
    return '${(distance! / 1000).toStringAsFixed(1)}km';
  }
}

// ════════════════════════════════════════════════
// 🌍 TRUEWAY SERVICE
// ════════════════════════════════════════════════
class TruewayService {
  String get _apiKey => dotenv.env['TRUEWAY_API_KEY'] ?? '';
  static const String _apiHost = 'trueway-places.p.rapidapi.com';

  Map<String, String> get _headers => {
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': _apiHost,
      };

  // 🏨 Find places by category
  Future<List<TruewayPlace>> findPlacesNearby({
    required double lat,
    required double lng,
    String? type,
    int radius = 5000,
    String language = 'en',
  }) async {
    try {
      final params = <String, String>{
        'location': '$lat,$lng',
        'radius': radius.toString(),
        'language': language,
        if (type != null) 'type': type,
      };

      final uri = Uri.https(_apiHost, '/FindPlacesNearby', params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        return results
            .map((item) => TruewayPlace.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 🔍 Find places by text
  Future<List<TruewayPlace>> findPlaceByText({
    required String text,
    double? lat,
    double? lng,
    int radius = 10000,
    String language = 'en',
  }) async {
    try {
      final params = <String, String>{
        'text': text,
        'radius': radius.toString(),
        'language': language,
        if (lat != null && lng != null) 'location': '$lat,$lng',
      };

      final uri = Uri.https(_apiHost, '/FindPlaceByText', params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        return results
            .map((item) => TruewayPlace.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

// ════════════════════════════════════════════════
// 🏷️ TRUEWAY CATEGORY TYPES
// ════════════════════════════════════════════════
class TruewayTypes {
  static const String hotel = 'lodging';
  static const String restaurant = 'restaurant';
  static const String cafe = 'cafe';
  static const String bar = 'bar';
  static const String hospital = 'hospital';
  static const String pharmacy = 'pharmacy';
  static const String gasStation = 'gas_station';
  static const String atm = 'atm';
  static const String bank = 'bank';
  static const String parking = 'parking';
  static const String mosque = 'mosque';
  static const String museum = 'museum';
  static const String park = 'park';
  static const String shopping = 'shopping_mall';
  static const String supermarket = 'supermarket';
  static const String touristAttraction = 'tourist_attraction';
}