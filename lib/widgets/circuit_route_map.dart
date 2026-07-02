import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';

/// A reusable, lightweight map preview that draws a single circuit's route
/// as a polyline with numbered markers. Non-interactive by default — tapping
/// triggers [onTap] (e.g. to open the full-screen map tab).
class CircuitRouteMap extends StatelessWidget {
  final List<LatLng> routePoints;
  final double height;
  final bool interactive;
  final VoidCallback? onTap;

  const CircuitRouteMap({
    super.key,
    required this.routePoints,
    this.height = 200,
    this.interactive = false,
    this.onTap,
  });

  LatLng get _center {
    if (routePoints.isEmpty) return const LatLng(31.4368, -4.2331);
    double lat = 0, lng = 0;
    for (final p in routePoints) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / routePoints.length, lng / routePoints.length);
  }

  double get _fitZoom {
    if (routePoints.length < 2) return 9;
    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;
    for (final p in routePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final span = (maxLat - minLat).abs() > (maxLng - minLng).abs()
        ? (maxLat - minLat).abs()
        : (maxLng - minLng).abs();
    if (span > 4) return 5.5;
    if (span > 2) return 6.5;
    if (span > 1) return 7.5;
    if (span > 0.4) return 8.5;
    return 9.5;
  }

  @override
  Widget build(BuildContext context) {
    final disableGestures = !interactive;

    Widget map = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _center,
            initialZoom: _fitZoom,
            maxZoom: 18,
            minZoom: 3,
            interactionOptions: InteractionOptions(
              flags: disableGestures ? InteractiveFlag.none : InteractiveFlag.all,
            ),
            onTap: disableGestures && onTap != null
                ? (_, __) => onTap!()
                : null,
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
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: AppTheme.primaryOrange,
                    borderColor: Colors.white,
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
      ),
    );

    if (disableGestures && onTap != null) {
      // Overlay catches the tap because the map itself ignores gestures.
      map = Stack(
        children: [
          map,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_full_rounded,
                      color: Colors.white, size: 13),
                  SizedBox(width: 5),
                  Text(
                    'Open map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return map;
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    for (var i = 0; i < routePoints.length; i++) {
      final isStart = i == 0;
      final isEnd = i == routePoints.length - 1;
      final color = isStart
          ? AppTheme.oasisGreen
          : isEnd
              ? const Color(0xFFC0392B)
              : AppTheme.primaryOrange;

      markers.add(
        Marker(
          point: routePoints[i],
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }
}
