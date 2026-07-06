import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/booking.dart';
import '../services/photo_service.dart';
import '../services/trueway_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_radius.dart';
import 'booking_form_screen.dart';
import 'add_trip_screen.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ✅ Book Now Bottom Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 20),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTripScreen()),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add to trip', overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                ),
                icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                label: const Text('Book Now', overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(120),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(60)),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(60)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded,
                      color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Share: ${place.name}'),
                        backgroundColor: AppTheme.deepBlue,
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
                      color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryOrange),
                      ),
                    )
                  else
                    Image.network(
                      _photoUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 60,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppTheme.cardOverlayGradient),
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
                  // ─── Title + type tags ────────────────
                  Text(
                    place.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.titleLarge?.color,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (place.types.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: place.types.take(3).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.sandBeige.withAlpha(isDark ? 60 : 140),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: Text(
                            t.replaceAll('_', ' '),
                            style: const TextStyle(
                              color: AppTheme.earthBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

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
                                  backgroundColor: AppTheme.deepBlue,
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
                                  backgroundColor: AppTheme.deepBlue,
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
                            color: AppTheme.primaryOrange,
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
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 40 : 10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book_rounded,
                                  size: 18, color: theme.textTheme.titleLarge?.color),
                              const SizedBox(width: 8),
                              Text(
                                'About',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange,
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
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: theme.textTheme.titleLarge?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                      border: Border.all(color: theme.dividerColor),
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
                                  color: AppTheme.primaryOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(100),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryOrange : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? AppTheme.primaryOrange : theme.dividerColor,
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withAlpha(60),
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
                color: isPrimary ? Colors.white : theme.textTheme.titleLarge?.color,
                size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : theme.textTheme.titleLarge?.color,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange,
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
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLink ? AppTheme.deepBlue : theme.textTheme.bodyLarge?.color,
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