import 'dart:convert';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════
// 📍 NOMINATIM PLACE MODEL
// ════════════════════════════════════════════════
class NominatimPlace {
  final String id;
  final String name;
  final String displayName;
  final double lat;
  final double lng;
  final String type;
  final String category;
  final bool isFromDatabase;

  NominatimPlace({
    required this.id,
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lng,
    required this.type,
    required this.category,
    this.isFromDatabase = false,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      id: json['place_id'].toString(),
      name: json['name'] ??
          json['display_name'].toString().split(',').first,
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lon'].toString()),
      type: json['type'] ?? '',
      category: json['class'] ?? '',
    );
  }
}

// ════════════════════════════════════════════════
// 🛣️ ROUTE MODELS
// ════════════════════════════════════════════════
class LatLngPoint {
  final double lat;
  final double lng;
  LatLngPoint({required this.lat, required this.lng});
}

class RouteInfo {
  final List<LatLngPoint> points;
  final double distanceMeters;
  final double durationSeconds;

  RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get distanceText {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toInt()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get durationText {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMin = minutes % 60;
    return '${hours}h ${remainingMin}min';
  }
}

// ════════════════════════════════════════════════
// 🌍 NOMINATIM SERVICE
// ════════════════════════════════════════════════
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _osrmUrl = 'https://router.project-osrm.org';

  // 🔍 Search anything worldwide
  Future<List<NominatimPlace>> search({
    required String query,
    double? lat,
    double? lng,
    int limit = 15,
  }) async {
    try {
      String url = '$_baseUrl/search?q=${Uri.encodeComponent(query)}'
          '&format=json'
          '&limit=$limit'
          '&addressdetails=1'
          '&extratags=1';

      if (lat != null && lng != null) {
        url += '&viewbox=${lng - 2},${lat + 2},${lng + 2},${lat - 2}';
        url += '&bounded=0';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TouristiqueGuid-PFE-App/1.0',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data
            .map((item) => NominatimPlace.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 💡 Autocomplete suggestions
  Future<List<NominatimPlace>> autocomplete({
    required String query,
    int limit = 5,
  }) async {
    try {
      final url = '$_baseUrl/search?q=${Uri.encodeComponent(query)}'
          '&format=json'
          '&limit=$limit'
          '&addressdetails=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TouristiqueGuid-PFE-App/1.0',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data
            .map((item) => NominatimPlace.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 🛣️ Get route between two points (OSRM - FREE)
  Future<List<LatLngPoint>> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final url = '$_osrmUrl/route/v1/driving/'
          '$fromLng,$fromLat;$toLng,$toLat'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords =
            data['routes'][0]['geometry']['coordinates'] as List;

        return coords
            .map((c) => LatLngPoint(
                  lat: (c[1] as num).toDouble(),
                  lng: (c[0] as num).toDouble(),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 📏 Get route info (distance + duration + points)
  Future<RouteInfo?> getRouteInfo({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final url = '$_osrmUrl/route/v1/driving/'
          '$fromLng,$fromLat;$toLng,$toLat'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final coords = route['geometry']['coordinates'] as List;

        return RouteInfo(
          points: coords
              .map((c) => LatLngPoint(
                    lat: (c[1] as num).toDouble(),
                    lng: (c[0] as num).toDouble(),
                  ))
              .toList(),
          distanceMeters: (route['distance'] as num).toDouble(),
          durationSeconds: (route['duration'] as num).toDouble(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}