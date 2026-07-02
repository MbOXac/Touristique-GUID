import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/circuit.dart';
import '../services/circuit_service.dart';
import '../theme/app_theme.dart';
import 'circuit_detail_screen.dart';

class CircuitMapScreen extends StatefulWidget {
  const CircuitMapScreen({super.key});

  @override
  State<CircuitMapScreen> createState() => _CircuitMapScreenState();
}

class _CircuitMapScreenState extends State<CircuitMapScreen> {
  final CircuitService _circuitService = CircuitService();
  final MapController _mapController = MapController();

  List<Circuit> _circuits = [];
  bool _isLoading = true;
  String _selectedType = 'All';
  Circuit? _selectedCircuit;
  LatLng? _userLocation;

  // Color per circuit type
  static const Map<String, Color> _typeColors = {
    'desert': AppTheme.goldAccent,
    'cultural': AppTheme.deepBlue,
    'adventure': Color(0xFFC0392B),
    'mountain': AppTheme.earthBrown,
    'oasis': AppTheme.oasisGreen,
  };

  final List<String> _typeFilters = const [
    'All',
    'Desert',
    'Cultural',
    'Adventure',
    'Mountain',
    'Oasis',
  ];

  @override
  void initState() {
    super.initState();
    _loadCircuits();
  }

  Future<void> _loadCircuits() async {
    final circuits = await _circuitService.getAllCircuits();
    if (!mounted) return;
    setState(() {
      _circuits = circuits;
      _isLoading = false;
    });
  }

  List<Circuit> get _visibleCircuits {
    if (_selectedType == 'All') return _circuits;
    return _circuits
        .where((c) => c.type.toLowerCase() == _selectedType.toLowerCase())
        .toList();
  }

  Color _colorFor(Circuit c) =>
      _typeColors[c.type] ?? AppTheme.primaryOrange;

  List<LatLng> _pointsFor(Circuit c) => c.routePoints.isNotEmpty
      ? c.routePoints
      : [c.startLocation, c.endLocation];

  Future<void> _goToMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_userLocation!, 11);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ─── Map ─────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(31.4368, -4.5000),
              initialZoom: 6.5,
              maxZoom: 18,
              minZoom: 3,
              onTap: (_, __) => setState(() => _selectedCircuit = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.touristique_guid',
                maxZoom: 20,
                maxNativeZoom: 19,
                retinaMode: true,
              ),
              PolylineLayer(polylines: _buildPolylines()),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // ─── Top bar ─────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _circleButton(Icons.arrow_back_rounded,
                    () => Navigator.pop(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.route_rounded,
                            color: AppTheme.primaryOrange, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Circuits Map',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_visibleCircuits.length} routes',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Type filter ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 62,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _typeFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final t = _typeFilters[index];
                  final selected = _selectedType == t;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedType = t;
                      _selectedCircuit = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryOrange
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ─── Legend ──────────────────────────────────────────
          Positioned(
            left: 12,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _typeColors.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: e.value,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _capitalize(e.key),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── My location button ──────────────────────────────
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton.small(
              heroTag: 'circuit-map-loc',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // ─── Selected circuit card ───────────────────────────
          if (_selectedCircuit != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: _buildSelectedCard(theme, _selectedCircuit!),
            ),

          // ─── Loading ─────────────────────────────────────────
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryOrange),
            ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: theme.cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: theme.iconTheme.color, size: 20),
      ),
    );
  }

  List<Polyline> _buildPolylines() {
    return _visibleCircuits.map((c) {
      final selected = _selectedCircuit?.id == c.id;
      return Polyline(
        points: _pointsFor(c),
        strokeWidth: selected ? 7 : 4,
        color: _colorFor(c).withAlpha(selected ? 255 : 200),
        borderColor: Colors.white,
        borderStrokeWidth: 1.5,
      );
    }).toList();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    for (final c in _visibleCircuits) {
      final points = _pointsFor(c);
      if (points.isEmpty) continue;
      // Start marker doubles as the tappable label for the whole route.
      markers.add(
        Marker(
          point: points.first,
          width: 34,
          height: 34,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedCircuit = c);
              _mapController.move(points.first, 8);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _colorFor(c),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(90),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(c.typeIcon, color: Colors.white, size: 16),
            ),
          ),
        ),
      );
    }

    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.blue.withAlpha(120), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.my_location_rounded,
                color: Colors.white, size: 18),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildSelectedCard(ThemeData theme, Circuit circuit) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: circuit.imageUrl.isNotEmpty
                  ? Image.network(
                      circuit.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _colorFor(circuit).withAlpha(40),
                        child: Icon(circuit.typeIcon,
                            color: _colorFor(circuit)),
                      ),
                    )
                  : Container(
                      color: _colorFor(circuit).withAlpha(40),
                      child:
                          Icon(circuit.typeIcon, color: _colorFor(circuit)),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      circuit.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${circuit.durationText} · ${circuit.formattedPrice}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CircuitDetailScreen(circuit: circuit),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: theme.textTheme.bodyMedium?.color),
              onPressed: () => setState(() => _selectedCircuit = null),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
