import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/tripadvisor_service.dart';
import '../theme/app_theme.dart';
import 'booking_form_screen.dart';

class AttractionDetailScreen extends StatefulWidget {
  final AttractionModel attraction;

  const AttractionDetailScreen({
    super.key,
    required this.attraction,
  });

  @override
  State<AttractionDetailScreen> createState() =>
      _AttractionDetailScreenState();
}

class _AttractionDetailScreenState
    extends State<AttractionDetailScreen> {
  List<String> _photos = [];
  bool _isLoadingPhotos = true;
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    // ✅ Show featured image immediately while loading
    if (widget.attraction.photoUrl.isNotEmpty) {
      setState(() {
        _photos = [widget.attraction.photoUrl];
        _isLoadingPhotos = false;
      });
    }

    // ✅ Then load real Wikipedia photos in background
    try {
      final photos =
          await TripAdvisorService.getAttractionPhotos(
        attractionName: widget.attraction.name,
        featuredImage: widget.attraction.photoUrl,
      );

      if (mounted) {
        setState(() {
          _photos = photos;
          _isLoadingPhotos = false;
        });
      }
    } catch (e) {
      print('Load photos error: $e');
      if (mounted) {
        setState(() => _isLoadingPhotos = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attraction = widget.attraction;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ✅ Book Now Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 60 : 20),
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
                name: attraction.name,
                imageUrl: attraction.photoUrl,
                type: BookingType.activity,
                pricePerPerson: attraction.price > 0
                    ? attraction.price
                    : 25.0,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF27AE60),
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
                'Book Activity 🎯',
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
          // ─── Photo Gallery SliverAppBar ───────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor:
                theme.appBarTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ Photos PageView
                  _photos.isEmpty
                      ? Container(
                          color: const Color(0xFF27AE60)
                              .withAlpha(30),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF27AE60)),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _photos.length,
                          onPageChanged: (index) {
                            setState(() =>
                                _currentPhotoIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              _photos[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child,
                                  loadingProgress) {
                                if (loadingProgress == null)
                                  return child;
                                return Container(
                                  color: const Color(0xFF27AE60)
                                      .withAlpha(20),
                                  child: const Center(
                                    child:
                                        CircularProgressIndicator(
                                      color: Color(0xFF27AE60),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) =>
                                  Container(
                                color: const Color(0xFF27AE60)
                                    .withAlpha(30),
                                child: const Icon(
                                    Icons.paragliding_rounded,
                                    size: 80,
                                    color: Color(0xFF27AE60)),
                              ),
                            );
                          },
                        ),

                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x55000000),
                          Color(0xCC000000)
                        ],
                      ),
                    ),
                  ),

                  // ✅ Back Button + Photo Counter
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black
                                      .withAlpha(120),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white
                                          .withAlpha(60)),
                                ),
                                child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 20),
                              ),
                            ),

                            // Photo counter
                            Row(
                              children: [
                                // Loading indicator
                                if (_isLoadingPhotos)
                                  Container(
                                    margin: const EdgeInsets
                                        .only(right: 8),
                                    width: 16,
                                    height: 16,
                                    child:
                                        const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                if (_photos.length > 1)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withAlpha(150),
                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                    ),
                                    child: Text(
                                      '${_currentPhotoIndex + 1}/${_photos.length} 📸',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ✅ Dots indicator
                  if (_photos.length > 1)
                    Positioned(
                      bottom: 70,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: List.generate(
                          _photos.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            width: _currentPhotoIndex == index
                                ? 20
                                : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == index
                                  ? const Color(0xFF27AE60)
                                  : Colors.white
                                      .withAlpha(150),
                              borderRadius:
                                  BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ✅ Name + Category on image
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            attraction.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          attraction.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: Color(0x88000000))
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Content ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ─── Stats ───────────────────────────
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (attraction.rating > 0)
                        _statCard(
                          icon: Icons.star_rounded,
                          label: 'Rating',
                          value: attraction.rating
                              .toStringAsFixed(1),
                          color: const Color(0xFFFFB800),
                          isDark: isDark,
                        ),
                      if (attraction.reviewCount > 0)
                        _statCard(
                          icon: Icons.reviews_rounded,
                          label: 'Reviews',
                          value: attraction.reviewCount
                              .toString(),
                          color: const Color(0xFF2980B9),
                          isDark: isDark,
                        ),
                      _statCard(
                        icon: Icons.payments_rounded,
                        label: 'Price',
                        value: attraction.price > 0
                            ? '\$${attraction.price.toStringAsFixed(0)}'
                            : 'Free',
                        color: const Color(0xFF27AE60),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Location ────────────────────────
                  if (attraction.location.isNotEmpty) ...[
                    _sectionTitle('📍 Location', theme),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius:
                            BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                                isDark ? 40 : 10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60)
                                  .withAlpha(30),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFF27AE60),
                                size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              attraction.location,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme
                                    .bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ─── About ───────────────────────────
                  _sectionTitle('📖 About', theme),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                              isDark ? 40 : 10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      attraction.description.isNotEmpty
                          ? attraction.description
                          : 'A wonderful attraction in ${attraction.location}. Experience this amazing place and create unforgettable memories!',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            theme.textTheme.bodyLarge?.color,
                        height: 1.65,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Photo Thumbnails ─────────────────
                  if (_photos.length > 1) ...[
                    _sectionTitle(
                        '📸 Photos (${_photos.length})',
                        theme),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final isSelected =
                              _currentPhotoIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(
                                    milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              setState(() =>
                                  _currentPhotoIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 200),
                              width: 90,
                              height: 90,
                              margin: const EdgeInsets.only(
                                  right: 10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF27AE60)
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                                  0xFF27AE60)
                                              .withAlpha(80),
                                          blurRadius: 8,
                                          offset:
                                              const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10),
                                child: Image.network(
                                  _photos[index],
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                    color: const Color(0xFF27AE60)
                                        .withAlpha(30),
                                    child: const Icon(
                                        Icons.image_rounded,
                                        color:
                                            Color(0xFF27AE60)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ─── Loading more photos indicator ────
                  if (_isLoadingPhotos)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60)
                            .withAlpha(15),
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF27AE60)
                                .withAlpha(50)),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Color(0xFF27AE60),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Loading more photos...',
                            style: TextStyle(
                              color: Color(0xFF27AE60),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF27AE60),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleLarge?.color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 25 : 15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}