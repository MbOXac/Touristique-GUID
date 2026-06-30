import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HotelModel {
  final String hotelId;
  final String name;
  final String address;
  final double reviewScore;
  final String reviewScoreWord;
  final int reviewCount;
  final double pricePerNight;
  final String currency;
  final String photoUrl;
  final double lat;
  final double lng;

  HotelModel({
    required this.hotelId,
    required this.name,
    required this.address,
    required this.reviewScore,
    required this.reviewScoreWord,
    required this.reviewCount,
    required this.pricePerNight,
    required this.currency,
    required this.photoUrl,
    required this.lat,
    required this.lng,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    double price = 0.0;
    try {
      final priceData =
          json['priceBreakdown']?['grossPrice'];
      if (priceData != null) {
        price = (priceData['value'] ?? 0).toDouble();
      }
    } catch (_) {}

    String photo = '';
    try {
      final photos =
          json['property']?['photoUrls'];
      if (photos != null && photos.isNotEmpty) {
        photo = photos[0].toString();
      }
    } catch (_) {}

    String address = '';
    try {
      address = json['property']?['wishlistName'] ??
          json['property']?['countryCode'] ?? '';
    } catch (_) {}

    return HotelModel(
      hotelId: json['hotel_id']?.toString() ??
          json['property']?['id']?.toString() ?? '',
      name: json['property']?['name'] ??
          json['name'] ?? 'Unknown Hotel',
      address: address,
      reviewScore:
          (json['property']?['reviewScore'] ?? 0).toDouble(),
      reviewScoreWord:
          json['property']?['reviewScoreWord'] ?? '',
      reviewCount:
          (json['property']?['reviewCount'] ?? 0).toInt(),
      pricePerNight: price,
      currency:
          json['priceBreakdown']?['grossPrice']?['currency'] ??
              'USD',
      photoUrl: photo,
      lat: (json['property']?['latitude'] ?? 0).toDouble(),
      lng: (json['property']?['longitude'] ?? 0).toDouble(),
    );
  }
}

class HotelService {
  static const String _baseUrl =
      'booking-com15.p.rapidapi.com';

  static String get _apiKey =>
      dotenv.env['RAPIDAPI_KEY'] ?? '';

  static Map<String, String> get _headers => {
        'x-rapidapi-host': _baseUrl,
        'x-rapidapi-key': _apiKey,
        'Content-Type': 'application/json',
      };

  // ✅ STEP 1: Get destination ID
  static Future<String?> getDestinationId(
      String cityName) async {
    try {
      final uri = Uri.https(
          _baseUrl,
          '/api/v1/hotels/searchDestination',
          {'query': cityName});

      final response =
          await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data'] as List?;
        if (results != null && results.isNotEmpty) {
          for (var result in results) {
            if (result['search_type'] == 'city' ||
                result['dest_type'] == 'city') {
              return result['dest_id']?.toString();
            }
          }
          return results[0]['dest_id']?.toString();
        }
      }
    } catch (e) {
      print('Destination ID Error: $e');
    }
    return null;
  }

  // ✅ STEP 2: Search hotels
  static Future<List<HotelModel>> searchHotels({
    required String cityName,
    required String checkIn,
    required String checkOut,
    int adults = 1,
    int rooms = 1,
  }) async {
    try {
      final destId = await getDestinationId(cityName);
      if (destId == null) return [];

      final uri = Uri.https(
          _baseUrl,
          '/api/v1/hotels/searchHotels',
          {
            'dest_id': destId,
            'search_type': 'city',
            'arrival_date': checkIn,
            'departure_date': checkOut,
            'adults': adults.toString(),
            'room_qty': rooms.toString(),
            'units': 'metric',
            'temperature_unit': 'c',
            'languagecode': 'en-us',
            'currency_code': 'USD',
          });

      final response =
          await http.get(uri, headers: _headers);

      print('Hotel Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hotels =
            data['data']?['hotels'] as List?;
        if (hotels != null) {
          return hotels
              .map((h) => HotelModel.fromJson(h))
              .toList();
        }
      }
    } catch (e) {
      print('Search Hotels Error: $e');
    }
    return [];
  }

  // ✅ STEP 3: Get hotel photos
  static Future<List<String>> getHotelPhotos(
      String hotelId) async {
    try {
      final uri = Uri.https(
          _baseUrl,
          '/api/v1/hotels/getHotelPhotos',
          {'hotel_id': hotelId});

      final response =
          await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = data['data'] as List?;
        if (photos != null) {
          return photos
              .take(5)
              .map((p) =>
                  p['url_original']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      print('Hotel Photos Error: $e');
    }
    return [];
  }
}