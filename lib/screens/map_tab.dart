import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/destination.dart';
import '../services/destination_service.dart';
import 'destination_detail_screen.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final DestinationService _destinationService = DestinationService();
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _controller;
  String? _selectedDestinationId;
  List<Destination> _searchResults = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<Destination> destinations) {
    return destinations.map((d) {
      return Marker(
        markerId: MarkerId(d.id),
        position: LatLng(d.lat, d.lng),
        infoWindow: InfoWindow(
          title: d.name,
          snippet: d.tags,
          onTap: () => _openDestination(d),
        ),
        onTap: () async {
          await _focusOn(d);
          if (!mounted) return;
          _openDestination(d);
        },
      );
    }).toSet();
  }

  void _openDestination(Destination d) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(destination: d),
      ),
    );
  }

  Future<void> _focusOn(Destination d) async {
    setState(() => _selectedDestinationId = d.id);
    final c = _controller;
    if (c == null) return;
    await c.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(d.lat, d.lng), 16.0),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    _destinationService.getAllDestinations().then((allDestinations) {
      final results = allDestinations
          .where((d) => d.name.toLowerCase().contains(query.toLowerCase().trim()))
          .toList();

      setState(() {
        _searchResults = results;
        _hasSearched = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: theme.appBarTheme.backgroundColor?.withAlpha(230),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<List<Destination>>(
        stream: _destinationService.streamAllDestinations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            );
          }

          final allDestinations = snapshot.data ?? [];
          final markersForMap = _hasSearched ? _searchResults : allDestinations;

          final initialLat = allDestinations.isNotEmpty ? allDestinations.first.lat : 31.7917;
          final initialLng = allDestinations.isNotEmpty ? allDestinations.first.lng : -7.0926;

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(initialLat, initialLng),
                  zoom: 6.5,
                ),
                markers: _buildMarkers(markersForMap),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (c) => _controller = c,
              ),
              Column(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
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
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _performSearch,
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: 'Search by destination name...',
                            hintStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () => _performSearch(_searchController.text),
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.search_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_hasSearched)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 12,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _searchResults.isEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 32,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No exact match',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try searching for: "${_searchController.text}"',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final dest = _searchResults[index];
                                    final selected = dest.id == _selectedDestinationId;

                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => _focusOn(dest),
                                        onLongPress: () => _openDestination(dest),
                                        child: Container(
                                          width: 160,
                                          margin: const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selected
                                                  ? theme.colorScheme.primary
                                                  : theme.dividerColor,
                                              width: selected ? 2 : 1,
                                            ),
                                            boxShadow: selected
                                                ? [
                                                    BoxShadow(
                                                      color: theme.colorScheme.primary.withAlpha(77),
                                                      blurRadius: 8,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  dest.imageURLs.isNotEmpty
                                                      ? dest.imageURLs.first
                                                      : 'assets/images/placeholder.jpg',
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [Colors.transparent, Colors.black45],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment.topRight,
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                            decoration: BoxDecoration(
                                                              color: theme.colorScheme.primary,
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Text(
                                                              '${dest.rating}⭐',
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            dest.name,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.location_on, color: Colors.white70, size: 12),
                                                              const SizedBox(width: 2),
                                                              Expanded(
                                                                child: Text(
                                                                  dest.distance,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}