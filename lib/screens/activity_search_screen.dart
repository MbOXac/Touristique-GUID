import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/tripadvisor_service.dart';
import '../theme/app_theme.dart';
import 'booking_form_screen.dart';
import 'attraction_detail_screen.dart'; // ✅ ADD THIS

class ActivitySearchScreen extends StatefulWidget {
  const ActivitySearchScreen({super.key});

  @override
  State<ActivitySearchScreen> createState() =>
      _ActivitySearchScreenState();
}

class _ActivitySearchScreenState
    extends State<ActivitySearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  List<AttractionModel> _attractions = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  Future<void> _searchAttractions() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _attractions = [];
    });

    try {
      final attractions =
          await TripAdvisorService.searchAttractions(
        query: _searchController.text.trim(),
      );
      setState(() {
        _attractions = attractions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Activities'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── Search Bar ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withAlpha(isDark ? 40 : 15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        '📍 Enter location (e.g. Marrakech...)',
                    prefixIcon: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF27AE60)),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: Colors.grey.withAlpha(80)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF27AE60), width: 2),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.darkBackground
                        : Colors.grey.shade50,
                  ),
                  onSubmitted: (_) => _searchAttractions(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _searchAttractions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF27AE60),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            '🔍 Search Activities',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildResults(theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme, bool isDark) {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.paragliding_rounded,
                  size: 40, color: Color(0xFF27AE60)),
            ),
            const SizedBox(height: 16),
            const Text('Search Activities',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Enter a location to find activities',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                color: Color(0xFF27AE60)),
            SizedBox(height: 16),
            Text('Searching activities...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 50, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchAttractions,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange),
                child: const Text('Try Again',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_attractions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No activities found',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Try a different location',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attractions.length,
      itemBuilder: (context, index) => _buildAttractionCard(
          _attractions[index], theme, isDark),
    );
  }

  Widget _buildAttractionCard(AttractionModel attraction,
      ThemeData theme, bool isDark) {
    return GestureDetector(
      // ✅ TAP → OPENS DETAIL SCREEN
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttractionDetailScreen(
            attraction: attraction,
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image ──────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              child: attraction.photoUrl.isNotEmpty
                  ? Image.network(
                      attraction.photoUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: const Color(0xFF27AE60)
                            .withAlpha(30),
                        child: const Icon(
                            Icons.paragliding_rounded,
                            size: 60,
                            color: Color(0xFF27AE60)),
                      ),
                    )
                  : Container(
                      height: 180,
                      color:
                          const Color(0xFF27AE60).withAlpha(30),
                      child: const Icon(
                          Icons.paragliding_rounded,
                          size: 60,
                          color: Color(0xFF27AE60)),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60)
                          .withAlpha(30),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      attraction.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    attraction.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Location
                  if (attraction.location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attraction.location,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),

                  // ✅ "Tap for details" hint
                  Row(
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        size: 13,
                        color: Color(0xFF27AE60),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to see details & photos',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Rating + Price Row
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      if (attraction.rating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.oasisGreen
                                .withAlpha(30),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14,
                                  color: AppTheme.oasisGreen),
                              const SizedBox(width: 4),
                              Text(
                                attraction.rating
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        AppTheme.oasisGreen),
                              ),
                              if (attraction.reviewCount > 0)
                                Text(
                                  ' (${attraction.reviewCount})',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppTheme.oasisGreen),
                                ),
                            ],
                          ),
                        ),
                      attraction.price > 0
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '\$${attraction.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w800,
                                      color: AppTheme
                                          .primaryOrange,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '/person',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : const Text(
                              'Free Entry',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF27AE60),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(
                            name: attraction.name,
                            imageUrl: attraction.photoUrl,
                            type: BookingType.activity,
                            pricePerPerson:
                                attraction.price > 0
                                    ? attraction.price
                                    : 25.0,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF27AE60),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Activity 🎯',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
}