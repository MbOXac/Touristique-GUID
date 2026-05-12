import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/destination.dart';
import '../theme/app_theme.dart';
import 'destination_detail_screen.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  // Your current local list (later you can replace with Firestore StreamBuilder)
  static const List<Destination> _destinations = [
    Destination(
      id: '1',
      name: 'Kasbah & Valleys',
      description: 'Ancient mud-brick kasbahs along Draa River',
      imageURLs: ['assets/images/destination_1.jpg'],
      rating: 4.8,
      distance: '120 km',
      lat: 30.3722,
      lng: -8.9641,
      tags: 'Historical, Scenic',
    ),
    Destination(
      id: '2',
      name: 'Merzouga Desert',
      description: 'Iconic Erg Chebbi dunes and Sahara nights',
      imageURLs: ['assets/images/destination_2.jpg'],
      rating: 4.9,
      distance: '340 km',
      lat: 31.0990,
      lng: -4.0127,
      tags: 'Desert, Scenic',
    ),
    Destination(
      id: '3',
      name: 'Todra Gorge',
      description: '300m limestone walls carved by Todra River',
      imageURLs: ['assets/images/destination_3.jpg'],
      rating: 4.7,
      distance: '175 km',
      lat: 31.5716,
      lng: -5.5669,
      tags: 'Gorge, Hiking',
    ),
    Destination(
      id: '4',
      name: 'Oasis & Palmeraies',
      description: 'Date-palm groves in Tinghir valley',
      imageURLs: ['assets/images/destination_4.jpg'],
      rating: 4.6,
      distance: '160 km',
      lat: 31.5124,
      lng: -5.5322,
      tags: 'Oasis, Agriculture',
    ),
  ];

  GoogleMapController? _controller;
  String? _selectedDestinationId;

  Set<Marker> _buildMarkers() {
    return _destinations.map((d) {
      return Marker(
        markerId: MarkerId(d.id),
        position: LatLng(d.lat, d.lng),
        infoWindow: InfoWindow(
          title: d.name,
          snippet: d.tags,
          onTap: () => _openDestination(d),
        ),
        onTap: () {
          setState(() => _selectedDestinationId = d.id);
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
    await _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(d.lat, d.lng),
          zoom: 11.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = _destinations.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // REAL MAP (replaces the fake grid/pins UI)
          SizedBox(
            height: 260,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(initial.lat, initial.lng),
                zoom: 6.5, // Morocco-level view
              ),
              markers: _buildMarkers(),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (c) => _controller = c,
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Destinations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepBlue,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                final dest = _destinations[index];
                final selected = dest.id == _selectedDestinationId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: selected ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: selected
                        ? const BorderSide(color: AppTheme.primaryOrange, width: 1.2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    onTap: () => _focusOn(dest), // tap list item -> move camera
                    onLongPress: () => _openDestination(dest), // long press -> open details
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        dest.imageURLs.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      dest.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepBlue,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      dest.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 16),
                        Text(
                          dest.distance,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}