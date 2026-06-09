import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PhotoService {
  final Random _random = Random();

  // ════════════════════════════════════════════════
  // 🚫 NO DUPLICATE PHOTOS TRACKER
  // ════════════════════════════════════════════════
  final Set<String> _usedPhotoUrls = {};

  void clearUsedPhotos() {
    _usedPhotoUrls.clear();
    print('🔄 Photo tracker cleared');
  }

  bool _registerPhoto(String? url) {
    if (url == null || url.isEmpty) return false;
    if (_usedPhotoUrls.contains(url)) {
      print('⚠️ Duplicate skipped');
      return false;
    }
    _usedPhotoUrls.add(url);
    return true;
  }

  // ════════════════════════════════════════════════
  // 🏆 MASTER METHOD
  // Order: Foursquare → Wikipedia → Wikimedia → Pexels
  // ════════════════════════════════════════════════
  Future<String?> getBestPhoto({
    required String placeName,
    required String category,
    double? lat,
    double? lng,
  }) async {
    print('\n🔍 Finding photo for: "$placeName" [$category]');

    // 1️⃣ FOURSQUARE — Real exact place photos
    if (lat != null && lng != null) {
      final foursquarePhoto = await _tryFoursquarePhoto(
        placeName: placeName,
        category: category,
        lat: lat,
        lng: lng,
      );
      if (foursquarePhoto != null) {
        print('✅ SOURCE: Foursquare');
        return foursquarePhoto;
      }
    }

    // 2️⃣ WIKIPEDIA — Famous landmarks
    final wikiPhoto = await _tryWikipediaPhoto(placeName);
    if (wikiPhoto != null) {
      print('✅ SOURCE: Wikipedia');
      return wikiPhoto;
    }

    // 3️⃣ WIKIMEDIA — Broader search
    final wikimediaPhoto = await _tryWikimediaPhoto(placeName, category);
    if (wikimediaPhoto != null) {
      print('✅ SOURCE: Wikimedia');
      return wikimediaPhoto;
    }

    // 4️⃣ PEXELS — Last resort
    final pexelsPhoto = await _tryPexelsPhoto(category);
    if (pexelsPhoto != null) {
      print('✅ SOURCE: Pexels');
      return pexelsPhoto;
    }

    print('❌ No photo found for: $placeName');
    return null;
  }

  // ════════════════════════════════════════════════
  // 🔄 LIST OF CORS PROXIES (fallback)
  // ════════════════════════════════════════════════
  static const List<String> _corsProxies = [
    'https://corsproxy.io/?',
    'https://api.allorigins.win/raw?url=',
    'https://api.codetabs.com/v1/proxy?quest=',
    'https://cors.eu.org/',
  ];

  int _currentProxyIndex = 0;

  String _getProxiedUrl(String targetUrl) {
    final proxy = _corsProxies[_currentProxyIndex];
    return '$proxy${Uri.encodeComponent(targetUrl)}';
  }

  void _rotateProxy() {
    _currentProxyIndex = (_currentProxyIndex + 1) % _corsProxies.length;
    print('   🔄 Switched to proxy: ${_corsProxies[_currentProxyIndex]}');
  }

    // ════════════════════════════════════════════════
  // 1️⃣ FOURSQUARE — Local proxy (unlimited!)
  // ════════════════════════════════════════════════
  Future<String?> _tryFoursquarePhoto({
    required String placeName,
    required String category,
    required double lat,
    required double lng,
  }) async {
    try {
      final apiKey = dotenv.env['FOURSQUARE_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ No Foursquare API key');
        return null;
      }

      final query = Uri.encodeComponent(placeName);

      // 🆕 Local proxy URL (unlimited, no CORS!)
      final searchUrl = Uri.parse(
        'http://localhost:8010/proxy/places/search'
        '?query=$query'
        '&ll=$lat,$lng'
        '&radius=500'
        '&limit=5',
      );

      print('   🔎 Foursquare searching: "$placeName"');

      final searchResponse = await http.get(
        searchUrl,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
          'X-Places-Api-Version': '2025-06-17',
        },
      ).timeout(const Duration(seconds: 10));

      print('   Foursquare status: ${searchResponse.statusCode}');

      if (searchResponse.statusCode == 401) {
        print('   ❌ AUTH ERROR: ${searchResponse.body}');
        return null;
      }

      if (searchResponse.statusCode != 200) {
        print('   ❌ Error: ${searchResponse.body}');
        return null;
      }

      final searchData = json.decode(searchResponse.body);
      final results = searchData['results'] as List? ?? [];

      if (results.isEmpty) {
        print('   No Foursquare results');
        return null;
      }

      print('   Found ${results.length} place(s)');

      for (final place in results) {
        final fsqId = place['fsq_place_id'] as String? ??
            place['fsq_id'] as String? ??
            '';
        if (fsqId.isEmpty) continue;

        final photoUrl = await _getFoursquarePhoto(fsqId, apiKey);
        if (photoUrl != null && _registerPhoto(photoUrl)) {
          print('   ✅ Foursquare photo found!');
          return photoUrl;
        }
      }
      return null;
    } catch (e) {
      print('   Foursquare error: $e');
      return null;
    }
  }

  Future<String?> _getFoursquarePhoto(String fsqId, String apiKey) async {
    try {
      // 🆕 Local proxy URL for photos
      final photoUrl = Uri.parse(
        'http://localhost:8010/proxy/places/$fsqId/photos?limit=5',
      );

      final photoResponse = await http.get(
        photoUrl,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
          'X-Places-Api-Version': '2025-06-17',
        },
      ).timeout(const Duration(seconds: 8));

      print('   Photos status: ${photoResponse.statusCode}');

      if (photoResponse.statusCode != 200) {
        return null;
      }

      final photos = json.decode(photoResponse.body) as List? ?? [];

      if (photos.isEmpty) {
        print('   No photos for this place');
        return null;
      }

      print('   Found ${photos.length} photo(s)');

      final shuffled = List.from(photos)..shuffle(_random);

      for (final photo in shuffled) {
        final prefix = photo['prefix'] as String? ?? '';
        final suffix = photo['suffix'] as String? ?? '';
        if (prefix.isEmpty || suffix.isEmpty) continue;

        final url = '${prefix}800x600$suffix';
        if (!_usedPhotoUrls.contains(url)) return url;
      }
      return null;
    } catch (e) {
      print('   Photo fetch exception: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════
  // 🔄 TRY REQUEST WITH ALL PROXIES (fallback)
  // ════════════════════════════════════════════════
  Future<http.Response?> _tryRequestWithProxies(
    String targetUrl,
    String apiKey,
  ) async {
    for (int i = 0; i < _corsProxies.length; i++) {
      try {
        final proxy = _corsProxies[(_currentProxyIndex + i) % _corsProxies.length];
        final proxyUrl = '$proxy${Uri.encodeComponent(targetUrl)}';

        print('   🌐 Trying proxy ${i + 1}/${_corsProxies.length}');

        final response = await http.get(
          Uri.parse(proxyUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Accept': 'application/json',
            'X-Places-Api-Version': '2025-06-17',
          },
        ).timeout(const Duration(seconds: 10));

        // Success!
        if (response.statusCode == 200) {
          _currentProxyIndex = (_currentProxyIndex + i) % _corsProxies.length;
          return response;
        }

        // Rate limited - try next proxy
        if (response.statusCode == 429) {
          print('   ⚠️ Proxy ${i + 1} rate limited, trying next...');
          continue;
        }

        // Other error - return it
        return response;
      } catch (e) {
        print('   ⚠️ Proxy ${i + 1} failed: ${e.toString().substring(0, 50)}');
        continue;
      }
    }
    return null;
  }

  // ════════════════════════════════════════════════
  // 2️⃣ WIKIPEDIA — Famous places
  // ════════════════════════════════════════════════
  Future<String?> _tryWikipediaPhoto(String placeName) async {
    final strategies = [
      placeName,
      '$placeName Morocco',
      '$placeName Maroc',
      _simplifyName(placeName),
      '${_simplifyName(placeName)} Morocco',
    ];

    for (final term in strategies) {
      if (term.trim().isEmpty) continue;
      print('   🔎 Wikipedia: "$term"');

      final url = await _fetchWikipediaPhoto(term.trim());
      if (url != null && _registerPhoto(url)) return url;
    }
    return null;
  }

  Future<String?> _fetchWikipediaPhoto(String term) async {
    try {
      final url = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/'
        '${Uri.encodeComponent(term)}',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'TouristiqueApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final type = data['type'] as String? ?? '';
      if (type == 'disambiguation') return null;

      final original = data['originalimage'];
      if (original != null) {
        final src = original['source'] as String?;
        final width = original['width'] as int? ?? 0;
        if (src != null && width > 300) return src;
      }

      final thumbnail = data['thumbnail'];
      if (thumbnail != null) {
        final src = thumbnail['source'] as String?;
        if (src != null && src.isNotEmpty) return src;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // ════════════════════════════════════════════════
  // 3️⃣ WIKIMEDIA COMMONS
  // ════════════════════════════════════════════════
  Future<String?> _tryWikimediaPhoto(
      String placeName, String category) async {
    final queries = _buildHumanSearchQueries(placeName, category);
    print('   📋 Trying ${queries.length} Wikimedia queries...');

    for (final query in queries) {
      print('   🔎 Wikimedia: "$query"');
      final urls = await _wikimediaSearchMultiple(query);

      for (final url in urls) {
        if (_registerPhoto(url)) {
          print('   ✅ Wikimedia photo found!');
          return url;
        }
      }
    }
    return null;
  }

  Future<List<String>> _wikimediaSearchMultiple(String query) async {
    final List<String> foundUrls = [];
    try {
      final searchUrl = Uri.parse(
        'https://commons.wikimedia.org/w/api.php'
        '?action=query'
        '&list=search'
        '&srsearch=${Uri.encodeComponent(query)}'
        '&srnamespace=6'
        '&srlimit=15'
        '&srqiprofile=classic_noboostlinks'
        '&format=json'
        '&origin=*',
      );

      final searchResponse = await http.get(
        searchUrl,
        headers: {
          'User-Agent': 'TouristiqueApp/1.0 (tourism guide Morocco)',
        },
      ).timeout(const Duration(seconds: 7));

      if (searchResponse.statusCode != 200) return foundUrls;

      final searchData = json.decode(searchResponse.body);
      final results = searchData['query']?['search'] as List? ?? [];
      if (results.isEmpty) return foundUrls;

      // Filter only real image files
      final imageResults = results.where((r) {
        final title = (r['title'] as String? ?? '').toLowerCase();
        return (title.endsWith('.jpg') ||
                title.endsWith('.jpeg') ||
                title.endsWith('.png') ||
                title.endsWith('.webp')) &&
            !title.contains('logo') &&
            !title.contains('icon') &&
            !title.contains('flag') &&
            !title.contains('map') &&
            !title.contains('diagram') &&
            !title.contains('chart') &&
            !title.contains('symbol') &&
            !title.contains('coat_of_arms') &&
            !title.contains('emblem') &&
            !title.contains('stamp') &&
            !title.contains('banner');
      }).toList();

      for (final result in imageResults.take(8)) {
        final title = result['title'] as String;
        final imageUrl = await _getWikimediaImageUrl(title);
        if (imageUrl != null && imageUrl.isNotEmpty) {
          foundUrls.add(imageUrl);
        }
      }
    } catch (e) {
      print('Wikimedia error: $e');
    }
    return foundUrls;
  }

  Future<String?> _getWikimediaImageUrl(String title) async {
    try {
      final infoUrl = Uri.parse(
        'https://commons.wikimedia.org/w/api.php'
        '?action=query'
        '&titles=${Uri.encodeComponent(title)}'
        '&prop=imageinfo'
        '&iiprop=url|thumburl|mediatype|mime|size'
        '&iiurlwidth=800'
        '&format=json'
        '&origin=*',
      );

      final infoResponse = await http.get(
        infoUrl,
        headers: {
          'User-Agent': 'TouristiqueApp/1.0 (tourism guide Morocco)',
        },
      ).timeout(const Duration(seconds: 5));

      if (infoResponse.statusCode != 200) return null;

      final infoData = json.decode(infoResponse.body);
      final pages = infoData['query']?['pages'] as Map? ?? {};

      for (final page in pages.values) {
        final imageinfo = page['imageinfo'] as List? ?? [];
        if (imageinfo.isEmpty) continue;

        final info = imageinfo.first;
        final mediaType = info['mediatype'] as String? ?? '';
        final mime = info['mime'] as String? ?? '';

        if (mediaType == 'DRAWING' ||
            mediaType == 'AUDIO' ||
            mediaType == 'VIDEO' ||
            mime.contains('svg') ||
            mime.contains('gif') ||
            mime.contains('audio') ||
            mime.contains('video')) continue;

        final width = info['width'] as int? ?? 0;
        final height = info['height'] as int? ?? 0;
        if (width < 300 || height < 200) continue;

        final thumbUrl = info['thumburl'] as String?;
        if (thumbUrl != null && thumbUrl.isNotEmpty) return thumbUrl;

        final directUrl = info['url'] as String?;
        if (directUrl != null &&
            directUrl.isNotEmpty &&
            !directUrl.toLowerCase().endsWith('.svg')) {
          return directUrl;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ════════════════════════════════════════════════
  // 4️⃣ PEXELS — Last resort
  // ════════════════════════════════════════════════
  Future<String?> _tryPexelsPhoto(String category) async {
    try {
      final apiKey = dotenv.env['PEXELS_API_KEY'] ?? '';
      if (apiKey.isEmpty) return null;

      final searchTerm = _getCategorySearchTerm(category);

      final url = Uri.parse(
        'https://api.pexels.com/v1/search'
        '?query=${Uri.encodeComponent(searchTerm)}'
        '&per_page=30'
        '&orientation=landscape',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': apiKey},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = data['photos'] as List? ?? [];
        if (photos.isEmpty) return null;

        final shuffled = List.from(photos)..shuffle(_random);

        for (final photo in shuffled) {
          final src = photo['src'] as Map;
          final photoUrl = src['large2x'] as String? ??
              src['large'] as String? ??
              src['original'] as String?;

          if (photoUrl != null && _registerPhoto(photoUrl)) {
            return photoUrl;
          }
        }
      }
      return null;
    } catch (e) {
      print('Pexels error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════
  // 📚 WIKIPEDIA DESCRIPTION
  // ════════════════════════════════════════════════
  Future<String?> getWikipediaDescription(String placeName) async {
    try {
      final strategies = [
        placeName,
        '$placeName Morocco',
        _simplifyName(placeName),
      ];

      for (final term in strategies) {
        if (term.trim().isEmpty) continue;

        final url = Uri.parse(
          'https://en.wikipedia.org/api/rest_v1/page/summary/'
          '${Uri.encodeComponent(term.trim())}',
        );

        final response = await http.get(
          url,
          headers: {'User-Agent': 'TouristiqueApp/1.0'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final type = data['type'] as String? ?? '';
          if (type == 'disambiguation') continue;
          final extract = data['extract'] as String?;
          if (extract != null && extract.length > 50) return extract;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ════════════════════════════════════════════════
  // 🧠 HUMAN SEARCH QUERIES
  // ════════════════════════════════════════════════
  List<String> _buildHumanSearchQueries(
      String placeName, String category) {
    final cat = category.toLowerCase().replaceAll('_', ' ');
    final city = _extractCity(placeName);
    final cleanName = _cleanPlaceName(placeName);
    final simpleName = _simplifyName(placeName);

    final List<String> queries = [];

    if (cat.contains('hotel') || cat.contains('lodging') ||
        cat.contains('riad')) {
      queries.addAll([
        '$cleanName $city',
        '$cleanName Morocco',
        '$simpleName $city',
        'Riad $city Morocco',
        '$city riad traditional courtyard',
        'moroccan riad interior',
      ]);
    } else if (cat.contains('restaurant') || cat.contains('food')) {
      queries.addAll([
        '$cleanName $city',
        '$cleanName restaurant Morocco',
        '$city restaurant moroccan food',
        'moroccan restaurant tagine',
      ]);
    } else if (cat.contains('cafe') || cat.contains('café')) {
      queries.addAll([
        '$cleanName $city',
        '$city cafe moroccan mint tea',
        'moroccan cafe traditional',
        'Morocco cafe rooftop',
      ]);
    } else if (cat.contains('mosque') || cat.contains('masjid')) {
      queries.addAll([
        '$cleanName mosque',
        '$cleanName $city',
        '$city mosque minaret',
        'Morocco mosque islamic architecture',
      ]);
    } else if (cat.contains('museum')) {
      queries.addAll([
        '$cleanName museum',
        '$cleanName $city',
        '$city museum Morocco',
      ]);
    } else if (cat.contains('tourist') || cat.contains('attraction')) {
      queries.addAll([
        '$cleanName',
        '$cleanName $city',
        '$cleanName Morocco landmark',
        '$city historic landmark Morocco',
      ]);
    } else if (cat.contains('market') || cat.contains('souk')) {
      queries.addAll([
        '$cleanName $city',
        '$city souk market Morocco',
        'moroccan souk spices colorful',
      ]);
    } else if (cat.contains('hospital') || cat.contains('clinic')) {
      queries.addAll([
        '$cleanName $city',
        '$city hospital Morocco',
      ]);
    } else if (cat.contains('pharmacy')) {
      queries.addAll([
        'pharmacy Morocco $city',
        'pharmacie Maroc',
      ]);
    } else if (cat.contains('bank')) {
      queries.addAll([
        '$cleanName bank $city',
        '$city bank Morocco',
      ]);
    } else if (cat.contains('shopping') || cat.contains('mall')) {
      queries.addAll([
        '$cleanName $city',
        '$city shopping mall Morocco',
      ]);
    } else if (cat.contains('desert')) {
      queries.addAll([
        'Sahara desert Morocco dunes',
        'Merzouga sand dunes',
        'Erg Chebbi Morocco',
      ]);
    } else if (cat.contains('mountain')) {
      queries.addAll([
        'Atlas Mountains Morocco',
        'High Atlas Morocco landscape',
      ]);
    } else if (cat.contains('beach') || cat.contains('plage')) {
      queries.addAll([
        '$city beach Morocco',
        'Morocco Atlantic beach waves',
      ]);
    } else if (cat.contains('palace') || cat.contains('palais')) {
      queries.addAll([
        '$cleanName palace Morocco',
        '$city palace Morocco historic',
      ]);
    } else if (cat.contains('medina') || cat.contains('kasbah')) {
      queries.addAll([
        '$city medina old city Morocco',
        'Morocco medina ancient kasbah',
      ]);
    } else {
      queries.addAll([
        '$cleanName $city',
        '$cleanName Morocco',
        '$city Morocco landmark',
      ]);
    }

    return queries
        .where((q) => q.trim().length > 3)
        .toSet()
        .toList();
  }

  // ════════════════════════════════════════════════
  // 🔧 HELPERS
  // ════════════════════════════════════════════════
  String _cleanPlaceName(String name) {
    return name
        .replaceAll(
          RegExp(r'\b(SARL|SAS|Ltd|LLC|&|et|and)\b',
              caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _simplifyName(String name) {
    return name
        .replaceAll(
          RegExp(
            r'\b(Al|El|Al-|El-|Riad|Hotel|Cafe|Café|Dar|Restaurant|'
            r'Maison|Villa|Auberge|Complexe|Centre|Le|La|Les|Du|De|'
            r'Chez|Bar|Snack|Fast|Food|Mini|Super|Mosque|Mosquée|'
            r'Hammam|Spa|Garden|Jardin|Marché)\b',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _extractCity(String placeName) {
    const cities = [
      'Marrakech', 'Casablanca', 'Fes', 'Fez', 'Rabat',
      'Tangier', 'Tanger', 'Agadir', 'Meknes', 'Meknès',
      'Ouarzazate', 'Chefchaouen', 'Essaouira', 'Merzouga',
      'Erfoud', 'Zagora', 'Dakhla', 'Tetouan', 'Tétouan',
      'Safi', 'El Jadida', 'Beni Mellal', 'Ifrane', 'Azrou',
      'Errachidia', 'Tiznit', 'Taroudant', 'Midelt', 'Nador',
      'Oujda', 'Kenitra', 'Salé', 'Sale', 'Mohammedia',
      'Settat', 'Khouribga', 'Laayoune', 'Taza', 'Guelmim',
      'Tan Tan', 'Ait Benhaddou',
    ];

    final lower = placeName.toLowerCase();
    for (final city in cities) {
      if (lower.contains(city.toLowerCase())) return city;
    }
    return 'Morocco';
  }

  String _getCategorySearchTerm(String category) {
    final cat = category.toLowerCase().replaceAll('_', ' ');
    if (cat.contains('hotel') || cat.contains('lodging')) {
      return 'riad moroccan hotel luxury interior';
    } else if (cat.contains('restaurant')) {
      return 'moroccan restaurant tagine food';
    } else if (cat.contains('cafe')) {
      return 'moroccan cafe mint tea traditional';
    } else if (cat.contains('mosque')) {
      return 'mosque morocco minaret islamic';
    } else if (cat.contains('hospital')) {
      return 'hospital medical building';
    } else if (cat.contains('pharmacy')) {
      return 'pharmacy medicine store';
    } else if (cat.contains('gas')) {
      return 'gas station fuel pump';
    } else if (cat.contains('atm')) {
      return 'atm cash machine bank';
    } else if (cat.contains('bank')) {
      return 'bank building finance';
    } else if (cat.contains('parking')) {
      return 'parking garage lot';
    } else if (cat.contains('museum')) {
      return 'museum art gallery morocco';
    } else if (cat.contains('shopping')) {
      return 'shopping mall modern stores';
    } else if (cat.contains('tourist') || cat.contains('attraction')) {
      return 'morocco ancient landmark medina';
    } else if (cat.contains('desert')) {
      return 'sahara desert dunes camel morocco';
    } else if (cat.contains('mountain')) {
      return 'atlas mountains morocco landscape';
    } else if (cat.contains('market') || cat.contains('souk')) {
      return 'moroccan souk market spices colorful';
    } else if (cat.contains('beach')) {
      return 'morocco beach ocean waves';
    } else if (cat.contains('riad')) {
      return 'moroccan riad courtyard tiles fountain';
    } else if (cat.contains('palace')) {
      return 'moroccan palace historic royal';
    } else if (cat.contains('medina')) {
      return 'medina morocco old city streets';
    } else {
      return 'morocco landmark architecture travel';
    }
  }

    Future<void> testFoursquareKey() async {
    print('\n═══════════════════════════════════════');
    print('🔑 FOURSQUARE KEY TEST (Local Proxy)');
    print('═══════════════════════════════════════');

    final apiKey = dotenv.env['FOURSQUARE_API_KEY'] ?? '';
    print('Key length: ${apiKey.length}');
    print('Key first 4: ${apiKey.length > 4 ? apiKey.substring(0, 4) : "EMPTY"}');

    if (apiKey.isEmpty) {
      print('❌ KEY IS EMPTY!');
      return;
    }

    final url = Uri.parse(
      'http://localhost:8010/proxy/places/search'
      '?ll=31.6295,-7.9811&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
          'X-Places-Api-Version': '2025-06-17',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ SUCCESS! API working via local proxy!');
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        print('Found ${results.length} test result(s)');
        if (results.isNotEmpty) {
          print('First place: ${results.first['name']}');
        }
      } else {
        print('❌ Failed: ${response.body.substring(0, 200)}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      print('💡 Is the proxy running? Open new terminal and run:');
      print('   npx local-cors-proxy --proxyUrl https://places-api.foursquare.com --port 8010');
    }
    print('═══════════════════════════════════════\n');
  }

}