import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AttractionModel {
  final String id;
  final String name;
  final String description;
  final double rating;
  final int reviewCount;
  final String photoUrl;
  final String category;
  final String location;
  final double price;
  final String link;

  AttractionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.photoUrl,
    required this.category,
    required this.location,
    required this.price,
    this.link = '',
  });

  factory AttractionModel.fromJson(Map<String, dynamic> json) {
    String photo = '';
    try {
      photo = json['featured_image']?.toString() ?? '';
    } catch (_) {}

    double rating = 0.0;
    try {
      rating = double.tryParse(
              json['rating']?.toString() ?? '0') ??
          0.0;
    } catch (_) {}

    int reviews = 0;
    try {
      reviews = int.tryParse(
              json['num_reviews']?.toString() ?? '0') ??
          0;
    } catch (_) {}

    double price = 0.0;
    try {
      final priceStr = json['price']?.toString() ?? '';
      final cleaned =
          priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
      price = double.tryParse(cleaned) ?? 0.0;
    } catch (_) {}

    String category = 'Attraction';
    try {
      category =
          json['place_type']?.toString() ?? 'Attraction';
    } catch (_) {}

    String location = '';
    try {
      location = json['parent_location']?.toString() ??
          json['address']?.toString() ?? '';
    } catch (_) {}

    return AttractionModel(
      id: json['tripadvisor_entity_id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['parent_location']?.toString() ?? '',
      rating: rating,
      reviewCount: reviews,
      photoUrl: photo,
      category: category,
      location: location,
      price: price,
      link: json['link']?.toString() ?? '',
    );
  }
}

class TripAdvisorService {
  static const String _baseUrl =
      'tripadvisor-scraper.p.rapidapi.com';

  static String get _apiKey =>
      dotenv.env['RAPIDAPI_KEY'] ?? '';

  static Map<String, String> get _headers => {
        'x-rapidapi-host': _baseUrl,
        'x-rapidapi-key': _apiKey,
        'Content-Type': 'application/json',
      };

  // ✅ Search Attractions
  static Future<List<AttractionModel>> searchAttractions({
    required String query,
  }) async {
    try {
      final uri = Uri.https(
        _baseUrl,
        '/attractions/search',
        {'query': query},
      );

      final response =
          await http.get(uri, headers: _headers);
      print('✅ TripAdvisor Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List? items;
        if (data is List) {
          items = data;
        } else if (data['data'] is List) {
          items = data['data'];
        } else if (data['results'] is List) {
          items = data['results'];
        }

        if (items != null) {
          return items
              .map((item) => AttractionModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('TripAdvisor Error: $e');
    }
    return [];
  }

  // ✅ Get REAL Multiple Photos from Wikipedia Commons
  // FREE - No API key needed!
  static Future<List<String>> getAttractionPhotos({
    required String attractionName,
    required String featuredImage,
  }) async {
    List<String> photos = [];

    // ✅ Add TripAdvisor photo first
    if (featuredImage.isNotEmpty) {
      photos.add(featuredImage);
    }

    try {
      // ✅ Step 1: Search Wikipedia for the attraction
      final searchUri = Uri.https(
        'en.wikipedia.org',
        '/w/api.php',
        {
          'action': 'query',
          'list': 'search',
          'srsearch': attractionName,
          'format': 'json',
          'srlimit': '1',
        },
      );

      final searchResponse = await http.get(searchUri, headers: {
        'User-Agent': 'TouristiqueApp/1.0',
      });

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final results =
            searchData['query']?['search'] as List?;

        if (results != null && results.isNotEmpty) {
          final pageTitle =
              results[0]['title']?.toString() ?? '';

          if (pageTitle.isNotEmpty) {
            // ✅ Step 2: Get images from that Wikipedia page
            final imagesUri = Uri.https(
              'en.wikipedia.org',
              '/w/api.php',
              {
                'action': 'query',
                'titles': pageTitle,
                'prop': 'images',
                'format': 'json',
                'imlimit': '20',
              },
            );

            final imagesResponse =
                await http.get(imagesUri, headers: {
              'User-Agent': 'TouristiqueApp/1.0',
            });

            if (imagesResponse.statusCode == 200) {
              final imagesData =
                  json.decode(imagesResponse.body);
              final pages = imagesData['query']?['pages']
                  as Map<String, dynamic>?;

              if (pages != null) {
                final page = pages.values.first;
                final images =
                    page['images'] as List?;

                if (images != null) {
                  // ✅ Filter only real image files
                  final imageNames = images
                      .map((img) =>
                          img['title']?.toString() ?? '')
                      .where((title) =>
                          title.isNotEmpty &&
                          (title.toLowerCase().endsWith('.jpg') ||
                              title.toLowerCase().endsWith('.jpeg') ||
                              title.toLowerCase().endsWith('.png')) &&
                          !title.toLowerCase().contains('icon') &&
                          !title.toLowerCase().contains('logo') &&
                          !title.toLowerCase().contains('flag') &&
                          !title.toLowerCase().contains('map') &&
                          !title.toLowerCase().contains('symbol'))
                      .take(8)
                      .toList();

                  // ✅ Step 3: Get actual URLs for each image
                  for (String imageName in imageNames) {
                    if (photos.length >= 5) break;

                    try {
                      final urlUri = Uri.https(
                        'en.wikipedia.org',
                        '/w/api.php',
                        {
                          'action': 'query',
                          'titles': imageName,
                          'prop': 'imageinfo',
                          'iiprop': 'url',
                          'format': 'json',
                        },
                      );

                      final urlResponse = await http.get(
                          urlUri,
                          headers: {
                            'User-Agent': 'TouristiqueApp/1.0',
                          });

                      if (urlResponse.statusCode == 200) {
                        final urlData =
                            json.decode(urlResponse.body);
                        final urlPages =
                            urlData['query']?['pages']
                                as Map<String, dynamic>?;

                        if (urlPages != null) {
                          final urlPage =
                              urlPages.values.first;
                          final imageInfo =
                              urlPage['imageinfo'] as List?;

                          if (imageInfo != null &&
                              imageInfo.isNotEmpty) {
                            final url = imageInfo[0]['url']
                                ?.toString();
                            if (url != null &&
                                url.isNotEmpty &&
                                !photos.contains(url)) {
                              photos.add(url);
                            }
                          }
                        }
                      }
                    } catch (_) {}
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Wikipedia Photos Error: $e');
    }

    print('✅ Total photos found: ${photos.length}');
    return photos.take(5).toList();
  }
}