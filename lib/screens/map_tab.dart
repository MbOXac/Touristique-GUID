import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/destination.dart';
import '../services/destination_service.dart';
import '../services/nominatim_service.dart';
import '../services/trueway_service.dart';
import '../services/photo_service.dart';
import '../theme/app_theme.dart';
import 'destination_detail_screen.dart';
import 'place_detail_screen.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  // ─── Controllers ───────────────────────────────
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // ─── Services ──────────────────────────────────
  final DestinationService _destinationService = DestinationService();
  final NominatimService _nominatim = NominatimService();
  final TruewayService _trueway = TruewayService();
  final PhotoService _photoService = PhotoService();

  // ─── State ─────────────────────────────────────
  String? _selectedDestinationId;
  List<Destination> _allDestinations = [];
  List<TruewayPlace> _truewayResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  Destination? _selectedDestination;
  TruewayPlace? _selectedTruewayPlace;
  bool _showBottomSheet = false;
  double _currentLat = 31.0800;
  double _currentLng = -4.0100;
  String _selectedCategory = 'All';

  // ─── Photo Cache ────────────────────────────────
  final Map<String, String?> _photoCache = {};

  // ─── Map Style ─────────────────────────────────
  String _currentMapStyle = 'streets';
  bool _showLayerMenu = false;

  // ─── Route state ───────────────────────────────
  List<LatLng> _routePoints = [];
  RouteInfo? _routeInfo;
  LatLng? _routeDestination;

  // ─── Categories ────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps_rounded, 'type': null},
    {'label': 'Hotel', 'icon': Icons.hotel_rounded, 'type': TruewayTypes.hotel},
    {'label': 'Restaurant', 'icon': Icons.restaurant_rounded, 'type': TruewayTypes.restaurant},
    {'label': 'Cafe', 'icon': Icons.local_cafe_rounded, 'type': TruewayTypes.cafe},
    {'label': 'Tourist', 'icon': Icons.landscape_rounded, 'type': TruewayTypes.touristAttraction},
    {'label': 'Museum', 'icon': Icons.museum_rounded, 'type': TruewayTypes.museum},
    {'label': 'Mosque', 'icon': Icons.mosque_rounded, 'type': TruewayTypes.mosque},
    {'label': 'Hospital', 'icon': Icons.local_hospital_rounded, 'type': TruewayTypes.hospital},
    {'label': 'Pharmacy', 'icon': Icons.local_pharmacy_rounded, 'type': TruewayTypes.pharmacy},
    {'label': 'Gas', 'icon': Icons.local_gas_station_rounded, 'type': TruewayTypes.gasStation},
    {'label': 'ATM', 'icon': Icons.atm_rounded, 'type': TruewayTypes.atm},
    {'label': 'Bank', 'icon': Icons.account_balance_rounded, 'type': TruewayTypes.bank},
    {'label': 'Parking', 'icon': Icons.local_parking_rounded, 'type': TruewayTypes.parking},
    {'label': 'Shopping', 'icon': Icons.shopping_bag_rounded, 'type': TruewayTypes.shopping},
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _photoService.testFoursquareKey();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────
  // 🖼️ PHOTO LOADER — Cached + No duplicates
  // ─────────────────────────────────────────────────
  Future<String?> _getPhoto(
    String name,
    String category, {
    double? lat,
    double? lng,
  }) async {
    final key = '${name}_$category';
    if (_photoCache.containsKey(key)) return _photoCache[key];

    final photo = await _photoService.getBestPhoto(
      placeName: name,
      category: category,
      lat: lat,
      lng: lng,
    );
    if (mounted) {
      setState(() => _photoCache[key] = photo);
    }
    return photo;
  }

  // ─────────────────────────────────────────────────
  // 🎨 MAP TILE URL
  // ─────────────────────────────────────────────────
  String _getTileUrl() {
    switch (_currentMapStyle) {
      case 'satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'hybrid':
        return 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
      case 'terrain':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
      case 'dark':
        return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
      case 'streets':
      default:
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
    }
  }

  List<String> _getSubdomains() {
    if (_currentMapStyle == 'dark') return ['a', 'b', 'c', 'd'];
    return [];
  }

  // ─────────────────────────────────────────────────
  // 🔥 LOAD FIRESTORE
  // ─────────────────────────────────────────────────
  Future<void> _loadDestinations() async {
    _destinationService.streamAllDestinations().listen((destinations) {
      if (mounted) {
        setState(() {
          _allDestinations = destinations
              .where((d) => d.lat != 0.0 && d.lng != 0.0)
              .toList();
        });
      }
    });
  }

  // ─────────────────────────────────────────────────
  // 🔍 SEARCH BY TEXT
  // ─────────────────────────────────────────────────
  Future<void> _performTextSearch(String query) async {
    if (query.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    // 🆕 Reset photos on new search
    _photoService.clearUsedPhotos();

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _showBottomSheet = false;
      _selectedCategory = 'All';
      _photoCache.clear();
    });

    final results = await _trueway.findPlaceByText(
      text: query,
      lat: _currentLat,
      lng: _currentLng,
      radius: 10000,
    );

    if (mounted) {
      setState(() {
        _truewayResults = results;
        _isSearching = false;
      });

      // 🆕 Pre-load photos
      _preloadPhotos(results);

      if (results.isNotEmpty) {
        _mapController.move(
          LatLng(results.first.lat, results.first.lng),
          14,
        );
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 🏷️ SEARCH BY CATEGORY
  // ─────────────────────────────────────────────────
  Future<void> _searchByCategory(String label, String? type) async {
    setState(() => _selectedCategory = label);

    if (type == null) {
      _searchController.clear();
      // 🆕 Reset photos
      _photoService.clearUsedPhotos();
      setState(() {
        _truewayResults = [];
        _hasSearched = false;
        _showBottomSheet = false;
        _photoCache.clear();
      });
      return;
    }

    // 🆕 Reset photos on new category search
    _photoService.clearUsedPhotos();

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _showBottomSheet = false;
      _searchController.text = label;
      _photoCache.clear();
    });

    final results = await _trueway.findPlacesNearby(
      lat: _currentLat,
      lng: _currentLng,
      type: type,
      radius: 5000,
    );

    if (mounted) {
      setState(() {
        _truewayResults = results;
        _isSearching = false;
      });

      // 🆕 Pre-load photos
      _preloadPhotos(results);

      if (results.isNotEmpty) {
        _mapController.move(
          LatLng(results.first.lat, results.first.lng),
          14,
        );
      }
    }
  }

  Future<void> _preloadPhotos(List<TruewayPlace> places) async {
    // 🆕 Only preload TOP 5 places (not 10)
    for (final place in places.take(5)) {
      final key = '${place.name}_${place.mainCategory}';
      if (_photoCache.containsKey(key)) continue;

      try {
        final photo = await _photoService.getBestPhoto(
          placeName: place.name,
          category: place.mainCategory,
          lat: place.lat,
          lng: place.lng,
        );

        if (mounted) {
          setState(() => _photoCache[key] = photo);
        }

        // 🆕 Wait 2 seconds between places (avoid rate limits)
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        print('Preload error: $e');
      }
    }
  }
  // ─────────────────────────────────────────────────
  // 📍 NAVIGATION
  // ─────────────────────────────────────────────────
  void _openDestinationDetail(Destination d) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(destination: d),
      ),
    );
  }

  void _openTruewayPlaceDetail(TruewayPlace place) {
    setState(() => _showBottomSheet = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(
          place: place,
          onDirectionsTap: () => _showDirections(place.lat, place.lng),
        ),
      ),
    );
  }

  void _focusOnTruewayPlace(TruewayPlace place) {
    _mapController.move(LatLng(place.lat, place.lng), 16);
  }

  // ─────────────────────────────────────────────────
  // 🛣️ DIRECTIONS
  // ─────────────────────────────────────────────────
  Future<void> _showDirections(double toLat, double toLng) async {
    setState(() => _showBottomSheet = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Calculating route...'),
          ],
        ),
        backgroundColor: Colors.black,
        duration: Duration(seconds: 30),
      ),
    );

    final routeInfo = await _nominatim.getRouteInfo(
      fromLat: _currentLat,
      fromLng: _currentLng,
      toLat: toLat,
      toLng: toLng,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (routeInfo == null || routeInfo.points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not calculate route'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _routePoints =
          routeInfo.points.map((p) => LatLng(p.lat, p.lng)).toList();
      _routeInfo = routeInfo;
      _routeDestination = LatLng(toLat, toLng);
    });

    _fitRouteOnMap();
  }

  void _fitRouteOnMap() {
    if (_routePoints.isEmpty) return;

    double minLat = _routePoints.first.latitude;
    double maxLat = _routePoints.first.latitude;
    double minLng = _routePoints.first.longitude;
    double maxLng = _routePoints.first.longitude;

    for (final point in _routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.all(80),
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _routeInfo = null;
      _routeDestination = null;
    });
  }

  // ─────────────────────────────────────────────────
  // 📍 MARKERS
  // ─────────────────────────────────────────────────
  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];

    for (final dest in _allDestinations) {
      final isSelected = dest.id == _selectedDestinationId;
      markers.add(
        Marker(
          point: LatLng(dest.lat, dest.lng),
          width: isSelected ? 50 : 42,
          height: isSelected ? 50 : 42,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDestination = dest;
                _selectedTruewayPlace = null;
                _showBottomSheet = true;
                _selectedDestinationId = dest.id;
              });
              _mapController.move(LatLng(dest.lat, dest.lng), 16);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.amber : Colors.white,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.place_rounded,
                color: isSelected ? Colors.amber : Colors.white,
                size: isSelected ? 28 : 22,
              ),
            ),
          ),
        ),
      );
    }

    for (final place in _truewayResults) {
      markers.add(
        Marker(
          point: LatLng(place.lat, place.lng),
          width: 42,
          height: 42,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTruewayPlace = place;
                _selectedDestination = null;
                _showBottomSheet = true;
              });
              _mapController.move(LatLng(place.lat, place.lng), 16);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.place_rounded,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    if (_routePoints.isNotEmpty) {
      markers.add(
        Marker(
          point: LatLng(_currentLat, _currentLng),
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      );

      if (_routeDestination != null) {
        markers.add(
          Marker(
            point: _routeDestination!,
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  // ─────────────────────────────────────────────────
  // 🎨 BUILD UI
  // ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 🗺️ MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_currentLat, _currentLng),
              initialZoom: 10,
              maxZoom: 20,
              minZoom: 3,
              onTap: (_, __) {
                setState(() {
                  _showBottomSheet = false;
                  _showLayerMenu = false;
                  _selectedDestination = null;
                  _selectedTruewayPlace = null;
                  _selectedDestinationId = null;
                });
                FocusScope.of(context).unfocus();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(),
                subdomains: _getSubdomains(),
                userAgentPackageName: 'com.example.touristique_guid',
                maxZoom: 20,
                maxNativeZoom: 19,
                retinaMode: true,
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 6,
                      color: Colors.black,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // 🛣️ ROUTE INFO BAR
          if (_routeInfo != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _routeInfo!.durationText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _routeInfo!.distanceText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _clearRoute,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🔍 SEARCH BAR + CATEGORIES
          if (_routeInfo == null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _performTextSearch,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search hotels, restaurants, places...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.search_rounded,
                                color: Colors.black,
                              ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _photoService.clearUsedPhotos();
                                  setState(() {
                                    _truewayResults = [];
                                    _hasSearched = false;
                                    _showBottomSheet = false;
                                    _selectedCategory = 'All';
                                    _photoCache.clear();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected =
                            _selectedCategory == cat['label'];
                        // These pills float directly over the map tiles (no
                        // solid app-bar backdrop behind them like
                        // CategoryChips has), so the unselected state stays
                        // a near-opaque card color rather than a truly
                        // translucent one — otherwise labels lose contrast
                        // against busy map imagery.
                        final unselectedBg = isDark
                            ? AppTheme.darkCard.withAlpha(235)
                            : Colors.white.withAlpha(235);
                        final unselectedLabel =
                            isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _searchByCategory(
                              cat['label'],
                              cat['type'],
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppTheme.orangeGradient
                                    : null,
                                color: isSelected ? null : unselectedBg,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AppTheme.primaryOrange.withAlpha(90)
                                        : Colors.black.withOpacity(0.12),
                                    blurRadius: isSelected ? 10 : 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cat['icon'] as IconData,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : unselectedLabel,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    cat['label'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : unselectedLabel,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // 📋 SEARCH RESULTS PANEL
          if (_hasSearched && !_showBottomSheet && _routeInfo == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Row(
                        children: [
                          Text(
                            _truewayResults.isEmpty
                                ? 'No results found'
                                : '${_truewayResults.length} real places found',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                            ),
                            onPressed: () {
                              _photoService.clearUsedPhotos();
                              setState(() {
                                _hasSearched = false;
                                _truewayResults = [];
                                _searchController.clear();
                                _selectedCategory = 'All';
                                _photoCache.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: _truewayResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 36,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(
                                  16, 4, 16, 16),
                              itemCount: _truewayResults.length,
                              itemBuilder: (context, index) {
                                return _buildTruewayCard(
                                    _truewayResults[index]);
                              },
                            ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    ),
                  ],
                ),
              ),
            ),

          // 📍 BOTTOM SHEETS
          if (_showBottomSheet &&
              _selectedDestination != null &&
              _routeInfo == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildDestinationBottomSheet(_selectedDestination!),
            ),

          if (_showBottomSheet &&
              _selectedTruewayPlace != null &&
              _routeInfo == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildTruewayBottomSheet(_selectedTruewayPlace!),
            ),

          // 🎮 CONTROLS
          Positioned(
            bottom: _showBottomSheet ? 300 : (_hasSearched ? 230 : 30),
            right: 16,
            child: Column(
              children: [
                _mapControlButton(
                  icon: Icons.layers_rounded,
                  active: _showLayerMenu || _currentMapStyle != 'streets',
                  onTap: () {
                    setState(() => _showLayerMenu = !_showLayerMenu);
                  },
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.my_location_rounded,
                  onTap: () => _mapController.move(
                    LatLng(_currentLat, _currentLng),
                    14,
                  ),
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.add_rounded,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                ),
              ],
            ),
          ),

          // 🎨 LAYER SWITCHER MENU — compact pill-button segmented control
          if (_showLayerMenu)
            Positioned(
              bottom: _showBottomSheet ? 300 : (_hasSearched ? 230 : 80),
              right: 70,
              child: Container(
                width: 168,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: isDark
                      ? Border.all(color: AppTheme.darkBorder)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Text(
                        'Map Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _layerOption('Streets', 'streets', Icons.map_rounded),
                        _layerOption('Satellite', 'satellite',
                            Icons.satellite_alt_rounded),
                        _layerOption(
                            'Hybrid', 'hybrid', Icons.layers_rounded),
                        _layerOption(
                            'Terrain', 'terrain', Icons.terrain_rounded),
                        _layerOption('Dark', 'dark', Icons.dark_mode_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // 🎨 LAYER OPTION — compact terracotta-highlighted pill
  // ─────────────────────────────────────────────────
  Widget _layerOption(String label, String style, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _currentMapStyle == style;
    final unselectedBg = isDark
        ? Colors.white.withAlpha(18)
        : AppTheme.sandBeige.withAlpha(120);
    final unselectedLabel =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMapStyle = style;
          _showLayerMenu = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : unselectedBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: isSelected ? Colors.white : unselectedLabel),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : unselectedLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // 🃏 TRUEWAY CARD — With photo
  // ─────────────────────────────────────────────────
  Widget _buildTruewayCard(TruewayPlace place) {
    final photoKey = '${place.name}_${place.mainCategory}';
    final cachedPhoto = _photoCache[photoKey];

    return GestureDetector(
      onTap: () {
        _focusOnTruewayPlace(place);
        setState(() {
          _selectedTruewayPlace = place;
          _selectedDestination = null;
          _showBottomSheet = true;
          _hasSearched = false;
        });
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🖼️ PHOTO
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: cachedPhoto != null
                  ? Image.network(
                      cachedPhoto,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildCardPlaceholder(place),
                    )
                  : _buildCardPlaceholder(place),
            ),

            // 📝 INFO
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (place.distance != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            place.distanceText,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    place.mainCategory,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder(TruewayPlace place) {
    return Container(
      height: 90,
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(place.mainCategory),
            size: 28,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          if (!_photoCache.containsKey(
              '${place.name}_${place.mainCategory}'))
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // 📍 DESTINATION BOTTOM SHEET
  // ─────────────────────────────────────────────────
  Widget _buildDestinationBottomSheet(Destination dest) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? AppTheme.darkSurface : AppTheme.softBackground;
    final titleColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final secondaryColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBorder : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  dest.imagePath,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 75,
                    height: 75,
                    color: isDark ? AppTheme.darkCard : Colors.grey[200],
                    child:
                        const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dest.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: titleColor)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppTheme.goldAccent),
                        const SizedBox(width: 4),
                        Text('${dest.rating}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.goldAccent)),
                        const SizedBox(width: 10),
                        Icon(Icons.directions_walk_rounded,
                            size: 14, color: secondaryColor),
                        const SizedBox(width: 4),
                        Text(dest.distance,
                            style: TextStyle(
                                color: secondaryColor, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: secondaryColor),
                onPressed: () => setState(() {
                  _showBottomSheet = false;
                  _selectedDestinationId = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          const SizedBox(height: 8),
          Text(dest.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: secondaryColor, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDirections(dest.lat, dest.lng),
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openDestinationDetail(dest),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.goldAccent,
                    side: const BorderSide(
                        color: AppTheme.goldAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // 📍 TRUEWAY BOTTOM SHEET — With photo
  // ─────────────────────────────────────────────────
  Widget _buildTruewayBottomSheet(TruewayPlace place) {
    final photoKey = '${place.name}_${place.mainCategory}';
    final cachedPhoto = _photoCache[photoKey];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? AppTheme.darkSurface : AppTheme.softBackground;
    final secondaryColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final primaryTextColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ PHOTO HEADER
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
                child: cachedPhoto != null
                    ? Image.network(
                        cachedPhoto,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildBottomSheetPlaceholder(place),
                      )
                    : FutureBuilder<String?>(
                        future: _getPhoto(
                          place.name,
                          place.mainCategory,
                          lat: place.lat,
                          lng: place.lng,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildBottomSheetPlaceholder(
                                place, isLoading: true);
                          }
                          if (snapshot.hasData &&
                              snapshot.data != null) {
                            return Image.network(
                              snapshot.data!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildBottomSheetPlaceholder(place),
                            );
                          }
                          return _buildBottomSheetPlaceholder(place);
                        },
                      ),
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showBottomSheet = false),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Place name on photo
              Positioned(
                bottom: 12,
                left: 16,
                right: 50,
                child: Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // 📝 DETAILS
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tags — terracotta pill chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: place.types.take(3).map((t) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.terracotta,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.replaceAll('_', ' '),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Divider(
                    color:
                        isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                const SizedBox(height: 8),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 18, color: secondaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.address,
                        style: TextStyle(
                            color: secondaryColor,
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),

                // Phone
                if (place.phoneNumber != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded,
                          size: 18, color: secondaryColor),
                      const SizedBox(width: 8),
                      Text(
                        place.phoneNumber!,
                        style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],

                // Distance
                if (place.distance != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.directions_walk_rounded,
                          size: 18, color: secondaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '${place.distanceText} away',
                        style: TextStyle(
                            color: secondaryColor, fontSize: 13),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showDirections(place.lat, place.lng),
                        icon: const Icon(Icons.directions_rounded,
                            size: 18),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _openTruewayPlaceDetail(place),
                        icon: const Icon(Icons.info_outline_rounded,
                            size: 18),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.goldAccent,
                          side: const BorderSide(
                              color: AppTheme.goldAccent, width: 1.5),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // 🖼️ PLACEHOLDERS
  // ─────────────────────────────────────────────────
  Widget _buildBottomSheetPlaceholder(
    TruewayPlace place, {
    bool isLoading = false,
  }) {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(place.mainCategory),
            size: 48,
            color: Colors.grey[400],
          ),
          if (isLoading) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // 🎯 CATEGORY → ICON
  // ─────────────────────────────────────────────────
  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('hotel') || cat.contains('lodging')) {
      return Icons.hotel_rounded;
    }
    if (cat.contains('restaurant') || cat.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (cat.contains('cafe') || cat.contains('café')) {
      return Icons.local_cafe_rounded;
    }
    if (cat.contains('mosque') || cat.contains('masjid')) {
      return Icons.mosque_rounded;
    }
    if (cat.contains('hospital') || cat.contains('clinic')) {
      return Icons.local_hospital_rounded;
    }
    if (cat.contains('pharmacy')) return Icons.local_pharmacy_rounded;
    if (cat.contains('gas') || cat.contains('fuel')) {
      return Icons.local_gas_station_rounded;
    }
    if (cat.contains('atm')) return Icons.atm_rounded;
    if (cat.contains('bank')) return Icons.account_balance_rounded;
    if (cat.contains('parking')) return Icons.local_parking_rounded;
    if (cat.contains('museum')) return Icons.museum_rounded;
    if (cat.contains('shopping') || cat.contains('mall')) {
      return Icons.shopping_bag_rounded;
    }
    if (cat.contains('tourist') || cat.contains('attraction')) {
      return Icons.landscape_rounded;
    }
    if (cat.contains('beach') || cat.contains('plage')) {
      return Icons.beach_access_rounded;
    }
    if (cat.contains('mountain')) return Icons.terrain_rounded;
    if (cat.contains('desert')) return Icons.wb_sunny_rounded;
    if (cat.contains('market') || cat.contains('souk')) {
      return Icons.store_rounded;
    }
    return Icons.place_rounded;
  }

  // ─────────────────────────────────────────────────
  // 🎮 MAP CONTROL BUTTON
  // ─────────────────────────────────────────────────
  Widget _mapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryOrange : bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: active
              ? Colors.white
              : (isDark ? AppTheme.darkTextPrimary : Colors.black),
          size: 20,
        ),
      ),
    );
  }
}