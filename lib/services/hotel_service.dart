import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────────────────────────────────────

class HotelModel {
  final String hotelId;
  final String name;
  final String city;
  final String address;
  final int stars;
  final double reviewScore;
  final String reviewScoreWord;
  final int reviewCount;
  final double pricePerNight;
  final String currency;
  final String photoUrl;
  final List<String> photos;
  final List<String> amenities;
  final String description;
  final List<String> tags;
  final double lat;
  final double lng;
  final String source; // 'local' | 'api'

  HotelModel({
    required this.hotelId,
    required this.name,
    this.city = '',
    required this.address,
    this.stars = 0,
    required this.reviewScore,
    required this.reviewScoreWord,
    required this.reviewCount,
    required this.pricePerNight,
    this.currency = 'USD',
    required this.photoUrl,
    this.photos = const [],
    this.amenities = const [],
    this.description = '',
    this.tags = const [],
    required this.lat,
    required this.lng,
    this.source = 'api',
  });

  // ── From Firestore ──────────────────────────────────────────────────────────
  factory HotelModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return HotelModel(
      hotelId: doc.id,
      name: d['name']?.toString() ?? 'Unknown',
      city: d['city']?.toString() ?? '',
      address: d['address']?.toString() ?? '',
      stars: (d['stars'] ?? 0).toInt(),
      reviewScore: (d['reviewScore'] ?? 0).toDouble(),
      reviewScoreWord: d['reviewScoreWord']?.toString() ?? '',
      reviewCount: (d['reviewCount'] ?? 0).toInt(),
      pricePerNight: (d['pricePerNight'] ?? 0).toDouble(),
      currency: d['currency']?.toString() ?? 'USD',
      photoUrl: d['photoUrl']?.toString() ?? '',
      photos: List<String>.from(d['photos'] ?? []),
      amenities: List<String>.from(d['amenities'] ?? []),
      description: d['description']?.toString() ?? '',
      tags: List<String>.from(d['tags'] ?? []),
      lat: (d['lat'] ?? 0).toDouble(),
      lng: (d['lng'] ?? 0).toDouble(),
      source: d['source']?.toString() ?? 'local',
    );
  }

  // ── From Airbnb API ─────────────────────────────────────────────────────────
  factory HotelModel.fromAirbnbJson(Map<String, dynamic> json) {
    double price = 0.0;
    try {
      price = (json['price']?['rate']?['amount'] ?? 0).toDouble();
    } catch (_) {}

    String photo = '';
    try {
      final pics = json['pictures'] as List?;
      if (pics != null && pics.isNotEmpty) {
        photo = pics[0]['picture']?.toString() ?? '';
      }
    } catch (_) {}
    if (photo.isEmpty) photo = json['picture']?.toString() ?? '';

    double rating = (json['avg_rating'] ?? 0).toDouble();
    String ratingWord = '';
    if (rating >= 4.8) ratingWord = 'Exceptionnel';
    else if (rating >= 4.5) ratingWord = 'Superbe';
    else if (rating >= 4.0) ratingWord = 'Très bien';
    else if (rating >= 3.5) ratingWord = 'Bien';
    else if (rating > 0) ratingWord = 'Correct';

    final city = json['city']?.toString() ?? '';
    final country = json['country']?.toString() ?? '';
    final address = [city, country].where((s) => s.isNotEmpty).join(', ');

    return HotelModel(
      hotelId: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Unknown',
      city: city,
      address: address,
      reviewScore: rating,
      reviewScoreWord: ratingWord,
      reviewCount: (json['reviewsCount'] ?? 0).toInt(),
      pricePerNight: price,
      currency: json['price']?['rate']?['currency']?.toString() ?? 'USD',
      photoUrl: photo,
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      source: 'api',
    );
  }

  // ── To Map (for Firestore write) ────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'name': name,
        'city': city,
        'address': address,
        'stars': stars,
        'reviewScore': reviewScore,
        'reviewScoreWord': reviewScoreWord,
        'reviewCount': reviewCount,
        'pricePerNight': pricePerNight,
        'currency': currency,
        'photoUrl': photoUrl,
        'photos': photos,
        'amenities': amenities,
        'description': description,
        'tags': tags,
        'lat': lat,
        'lng': lng,
        'source': source,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
//  SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class HotelService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'hotels';

  // Airbnb API (fallback)
  static const String _apiHost = 'airbnb13.p.rapidapi.com';
  static String get _apiKey => dotenv.env['RAPIDAPI_KEY'] ?? '';

  // ─────────────────────────────────────────────────────────────────────────
  //  MÉTHODE PRINCIPALE : cherche d'abord Firestore, puis API en fallback
  // ─────────────────────────────────────────────────────────────────────────

  static Future<List<HotelModel>> searchHotels({
    required String cityName,
    required String checkIn,
    required String checkOut,
    int adults = 1,
    int rooms = 1,
    double? minPrice,
    double? maxPrice,
    int? minStars,
    double? minRating,
  }) async {
    // ── ÉTAPE 1 : Chercher dans Firestore ─────────────────────────────────────
    final localResults = await searchFirestore(
      cityName: cityName,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minStars: minStars,
      minRating: minRating,
    );

    if (localResults.isNotEmpty) {
      print('[HotelService] ✅ ${localResults.length} hôtels depuis Firestore');
      return localResults;
    }

    // ── ÉTAPE 2 : Fallback → API Airbnb si Firestore ne contient rien ─────────
    print('[HotelService] Firestore vide pour "$cityName" → fallback API');
    return await _searchFromApi(
      cityName: cityName,
      checkIn: checkIn,
      checkOut: checkOut,
      adults: adults,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FILTRE FIRESTORE
  // ─────────────────────────────────────────────────────────────────────────

  static Future<List<HotelModel>> searchFirestore({
    required String cityName,
    double? minPrice,
    double? maxPrice,
    int? minStars,
    double? minRating,
  }) async {
    try {
      // Recherche par ville (insensible à la casse via tags)
      final searchTerm = cityName.trim().toLowerCase();

      // Requête de base sur la collection hotels
      Query query = _db.collection(_collection);

      // Filtre prix min
      if (minPrice != null) {
        query = query.where('pricePerNight', isGreaterThanOrEqualTo: minPrice);
      }

      // Filtre prix max
      if (maxPrice != null) {
        query = query.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }

      // Filtre étoiles minimum
      if (minStars != null) {
        query = query.where('stars', isGreaterThanOrEqualTo: minStars);
      }

      // Filtre note minimum
      if (minRating != null) {
        query = query.where('reviewScore', isGreaterThanOrEqualTo: minRating);
      }

      // Trier par note
      query = query.orderBy('reviewScore', descending: true);

      final snap = await query.limit(50).get();

      // Filtrer localement sur le nom de ville (Firestore n'a pas de LIKE)
      final results = snap.docs
          .map((doc) => HotelModel.fromFirestore(doc))
          .where((hotel) {
            final hotelCity = hotel.city.toLowerCase();
            final hotelTags = hotel.tags.join(' ').toLowerCase();
            final hotelName = hotel.name.toLowerCase();
            return hotelCity.contains(searchTerm) ||
                hotelTags.contains(searchTerm) ||
                hotelName.contains(searchTerm) ||
                searchTerm.contains(hotelCity);
          })
          .toList();

      return results;
    } catch (e) {
      print('[HotelService] Firestore error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FALLBACK : API Airbnb
  // ─────────────────────────────────────────────────────────────────────────

  static Future<List<HotelModel>> _searchFromApi({
    required String cityName,
    required String checkIn,
    required String checkOut,
    int adults = 1,
  }) async {
    if (_apiKey.isEmpty) {
      print('[HotelService] Pas de clé API configurée.');
      return [];
    }

    try {
      final uri = Uri.https(
        _apiHost,
        '/search-location',
        {
          'location': cityName,
          'checkin': checkIn,
          'checkout': checkOut,
          'adults': adults.toString(),
          'children': '0',
          'infants': '0',
          'pets': '0',
          'page': '1',
          'currency': 'USD',
        },
      );

      final response = await http.get(uri, headers: {
        'x-rapidapi-host': _apiHost,
        'x-rapidapi-key': _apiKey,
      }).timeout(const Duration(seconds: 10));

      print('[HotelService] API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List? results;
        if (data['results'] is List) results = data['results'] as List;
        else if (data['data'] is List) results = data['data'] as List;
        else if (data is List) results = data;

        if (results != null && results.isNotEmpty) {
          return results
              .map((item) => HotelModel.fromAirbnbJson(
                    item as Map<String, dynamic>))
              .toList();
        }
      } else if (response.statusCode == 429) {
        throw Exception('Quota API dépassé. Vérifiez votre abonnement RapidAPI.');
      }
    } catch (e) {
      print('[HotelService] API Error: $e');
      rethrow;
    }
    return [];
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  UTILITAIRES FIRESTORE
  // ─────────────────────────────────────────────────────────────────────────

  /// Récupère TOUS les hôtels d'une ville depuis Firestore
  static Future<List<HotelModel>> getHotelsByCity(String city) async {
    return searchFirestore(cityName: city);
  }

  /// Récupère les hôtels mieux notés (top rated)
  static Future<List<HotelModel>> getTopRated({int limit = 10}) async {
    try {
      final snap = await _db
          .collection(_collection)
          .orderBy('reviewScore', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => HotelModel.fromFirestore(d)).toList();
    } catch (e) {
      print('[HotelService] getTopRated error: $e');
      return [];
    }
  }

  /// Récupère les hôtels les moins chers en premier
  static Future<List<HotelModel>> getCheapest({int limit = 10}) async {
    try {
      final snap = await _db
          .collection(_collection)
          .orderBy('pricePerNight', descending: false)
          .limit(limit)
          .get();
      return snap.docs.map((d) => HotelModel.fromFirestore(d)).toList();
    } catch (e) {
      print('[HotelService] getCheapest error: $e');
      return [];
    }
  }

  /// Récupère les hôtels par nombre d'étoiles
  static Future<List<HotelModel>> getByStars(int stars) async {
    try {
      final snap = await _db
          .collection(_collection)
          .where('stars', isEqualTo: stars)
          .orderBy('reviewScore', descending: true)
          .get();
      return snap.docs.map((d) => HotelModel.fromFirestore(d)).toList();
    } catch (e) {
      print('[HotelService] getByStars error: $e');
      return [];
    }
  }

  /// Récupère les photos d'un hôtel depuis Firestore (ou API en fallback)
  static Future<List<String>> getHotelPhotos(String hotelId) async {
    try {
      final doc = await _db.collection(_collection).doc(hotelId).get();
      if (doc.exists) {
        final photos = List<String>.from(doc.data()?['photos'] ?? []);
        if (photos.isNotEmpty) return photos;
      }
    } catch (e) {
      print('[HotelService] getHotelPhotos Firestore error: $e');
    }

    // Fallback: API Airbnb
    if (_apiKey.isNotEmpty) {
      try {
        final uri = Uri.https(_apiHost, '/listing-details', {'id': hotelId});
        final response = await http.get(uri, headers: {
          'x-rapidapi-host': _apiHost,
          'x-rapidapi-key': _apiKey,
        });
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final pics = data['data']?['images'] as List? ??
              data['pictures'] as List? ?? [];
          return pics
              .take(8)
              .map((p) => (p['picture'] ?? p['url'] ?? '').toString())
              .where((url) => url.startsWith('http'))
              .toList();
        }
      } catch (e) {
        print('[HotelService] getHotelPhotos API error: $e');
      }
    }
    return [];
  }
}