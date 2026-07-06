import 'package:flutter/material.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../models/booking.dart';
import '../services/tripadvisor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_badge.dart';
import 'booking_form_screen.dart';
import 'attraction_detail_screen.dart';

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
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                  decoration: const InputDecoration(
                    hintText: 'Enter location (e.g. Marrakech...)',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                  onSubmitted: (_) => _searchAttractions(),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _searchAttractions,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Search Activities'),
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
                color: AppTheme.goldAccent.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.paragliding_rounded,
                  size: 40, color: AppTheme.goldAccent),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Search Activities',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: AppSpacing.sm),
            Text('Enter a location to find activities',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppTheme.primaryOrange),
            const SizedBox(height: AppSpacing.lg),
            Text('Searching activities...',
                style: theme.textTheme.bodyMedium),
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
              const SizedBox(height: AppSpacing.lg),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _searchAttractions,
                child: const Text('Try Again'),
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
            Icon(Icons.search_off_rounded,
                size: 60, color: theme.textTheme.bodyMedium?.color),
            const SizedBox(height: AppSpacing.lg),
            Text('No activities found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: AppSpacing.sm),
            Text('Try a different location',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: _attractions.length,
      itemBuilder: (context, index) => _buildAttractionCard(
          _attractions[index], theme, isDark),
    );
  }

  Widget _buildAttractionCard(AttractionModel attraction,
      ThemeData theme, bool isDark) {
    final placeholderBg =
        isDark ? AppTheme.darkCard : Colors.grey.shade200;
    final placeholderIconColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade400;

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
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 70 : 30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Image ──────────────────────────────────
              attraction.photoUrl.isNotEmpty
                  ? Image.network(
                      attraction.photoUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: placeholderBg,
                        child: Icon(Icons.paragliding_rounded,
                            size: 60,
                            color: placeholderIconColor),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: placeholderBg,
                      child: Icon(Icons.paragliding_rounded,
                          size: 60, color: placeholderIconColor),
                    ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withAlpha(30),
                        borderRadius:
                            BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        attraction.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.earthBrown,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Name
                    Text(
                      attraction.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location
                    if (attraction.location.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 14,
                              color: theme.textTheme.bodyMedium?.color),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              attraction.location,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.sm),

                    // ✅ "Tap for details" hint
                    Row(
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 13,
                          color: AppTheme.primaryOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to see details & photos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

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
                              color: AppTheme.goldAccent
                                  .withAlpha(30),
                              borderRadius:
                                  BorderRadius.circular(
                                      AppRadius.badge),
                            ),
                            child: RatingBadge(
                              rating: attraction.rating,
                              reviewCount: attraction.reviewCount > 0
                                  ? attraction.reviewCount
                                  : null,
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
                                    TextSpan(
                                      text: '/person',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textTheme
                                              .bodyMedium?.color),
                                    ),
                                  ],
                                ),
                              )
                            : const Text(
                                'Free Entry',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.oasisGreen,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

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
                        child: const Text('Book Activity'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}