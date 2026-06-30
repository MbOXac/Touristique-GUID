import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/booking.dart';
import '../services/photo_service.dart';
import '../services/trueway_service.dart';
import 'booking_form_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final TruewayPlace place;
  final VoidCallback? onDirectionsTap;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    this.onDirectionsTap,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final PhotoService _photoService = PhotoService();
  String? _photoUrl;
  String? _description;
  bool _isLoadingPhoto = true;
  bool _isLoadingDescription = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final photoFuture = _photoService.getBestPhoto(
      placeName: widget.place.name,
      category: widget.place.mainCategory,
    );
    final descFuture =
        _photoService.getWikipediaDescription(widget.place.name);

    final photo = await photoFuture;
    final desc = await descFuture;

    if (mounted) {
      setState(() {
        _photoUrl = photo;
        _description = desc;
        _isLoadingPhoto = false;
        _isLoadingDescription = false;
      });
    }
  }

  // ✅ Detect booking type from place types
  BookingType get _bookingType {
    final types = widget.place.types.map((t) => t.toLowerCase()).toList();
    if (types.any((t) => t.contains('hotel') ||
        t.contains('lodging') ||
        t.contains('accommodation'))) {
      return BookingType.hotel;
    } else if (types.any((t) => t.contains('restaurant') ||
        t.contains('food') ||
        t.contains('cafe'))) {
      return BookingType.restaurant;
    } else if (types.any((t) =>
        t.contains('tour') || t.contains('attraction'))) {
      return BookingType.tour;
    } else {
      return BookingType.activity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Book Now Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingFormScreen(
                name: place.name,
                imageUrl: _photoUrl ?? '',
                type: _bookingType,
                pricePerPerson: 30.0,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_add_rounded,
                  color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded,
                      color: Colors.black),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Share: ${place.name}'),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_isLoadingPhoto)
                    Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Colors.black),
                      ),
                    )
                  else
                    Image.network(
                      _photoUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 60,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black87,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: place.types.take(3).map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                t.replaceAll('_', ' '),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎯 ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          icon: Icons.directions_rounded,
                          label: 'Directions',
                          isPrimary: true,
                          onTap: () {
                            Navigator.pop(context);
                            if (widget.onDirectionsTap != null) {
                              widget.onDirectionsTap!();
                            }
                          },
                        ),
                      ),
                      if (place.phoneNumber != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionButton(
                            icon: Icons.phone_rounded,
                            label: 'Call',
                            onTap: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Call: ${place.phoneNumber}'),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (place.website != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionButton(
                            icon: Icons.language_rounded,
                            label: 'Web',
                            onTap: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Open: ${place.website}'),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  _infoCard(
                    icon: Icons.location_on_rounded,
                    title: 'Address',
                    value: place.address,
                  ),
                  if (place.phoneNumber != null)
                    _infoCard(
                      icon: Icons.phone_rounded,
                      title: 'Phone',
                      value: place.phoneNumber!,
                    ),
                  if (place.website != null)
                    _infoCard(
                      icon: Icons.language_rounded,
                      title: 'Website',
                      value: place.website!,
                      isLink: true,
                    ),
                  if (place.distance != null)
                    _infoCard(
                      icon: Icons.directions_walk_rounded,
                      title: 'Distance',
                      value: '${place.distanceText} from you',
                    ),

                  if (_isLoadingDescription)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  else if (_description != null &&
                      _description!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.menu_book_rounded,
                                  size: 18, color: Colors.black),
                              const SizedBox(width: 8),
                              const Text(
                                'About',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Wikipedia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _description!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  const Text(
                    'Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(place.lat, place.lng),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          userAgentPackageName:
                              'com.example.touristique_guid',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(place.lat, place.lng),
                              width: 50,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.place_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? Colors.black : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isPrimary ? Colors.white : Colors.black,
                size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLink ? Colors.blue[700] : Colors.black,
                    fontWeight: FontWeight.w500,
                    decoration: isLink
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}