// lib/screens/hotel_search_screen.dart
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/hotel_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';
import 'booking_form_screen.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  // ── Controllers & State ────────────────────────────────────────────────────
  final TextEditingController _cityController =
      TextEditingController(text: 'Errachidia');

  List<HotelModel> _hotels = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  String _sortBy = 'rating'; // 'rating' | 'price_asc' | 'price_desc'

  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 3));
  int _adults = 2;

  // ── Advanced Filters ───────────────────────────────────────────────────────
  double? _minPrice;
  double? _maxPrice;
  int? _minStars;
  double? _minRating;
  bool _showFilters = false;

  // Local slider values (before applying)
  RangeValues _priceRange = const RangeValues(0, 500);
  double _maxPriceSlider = 500;
  int _starsFilter = 0;       // 0 = any
  double _ratingFilter = 0.0; // 0 = any

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _formatDisplayDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  int get _nightCount => _checkOut.difference(_checkIn).inDays;

  // ── Date Pickers ───────────────────────────────────────────────────────────
  Future<void> _pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked;
        if (_checkOut.isBefore(_checkIn.add(const Duration(days: 1)))) {
          _checkOut = _checkIn.add(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _pickCheckOut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _checkOut = picked);
  }

  // ── Sorting ────────────────────────────────────────────────────────────────
  List<HotelModel> _applySorting(List<HotelModel> hotels) {
    final sorted = List<HotelModel>.from(hotels);
    switch (_sortBy) {
      case 'price_asc':
        sorted.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
        break;
      case 'price_desc':
        sorted.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
        break;
      default: // 'rating'
        sorted.sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
    }
    return sorted;
  }

  // ── Apply / Reset Filters ──────────────────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _minPrice = _priceRange.start > 0 ? _priceRange.start : null;
      _maxPrice =
          _priceRange.end < _maxPriceSlider ? _priceRange.end : null;
      _minStars = _starsFilter > 0 ? _starsFilter : null;
      _minRating = _ratingFilter > 0 ? _ratingFilter : null;
      _showFilters = false;
    });
    _searchHotels();
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(0, _maxPriceSlider);
      _starsFilter = 0;
      _ratingFilter = 0.0;
      _minPrice = null;
      _maxPrice = null;
      _minStars = null;
      _minRating = null;
    });
  }

  bool get _hasActiveFilters =>
      _minPrice != null ||
      _maxPrice != null ||
      _minStars != null ||
      _minRating != null;

  // ── Search ─────────────────────────────────────────────────────────────────
  Future<void> _searchHotels() async {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a city name!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _hotels = [];
    });

    try {
      final hotels = await HotelService.searchHotels(
        cityName: _cityController.text.trim(),
        checkIn: _formatDate(_checkIn),
        checkOut: _formatDate(_checkOut),
        adults: _adults,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minStars: _minStars,
        minRating: _minRating,
      );
      setState(() {
        _hotels = _applySorting(hotels);
        _isLoading = false;
      });
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('quota')) {
        errorMsg =
            '⚠️ API quota exceeded.\nLocal Firestore data is being used.';
      } else if (errorMsg.contains('SocketException') ||
          errorMsg.contains('network')) {
        errorMsg = '📡 No internet connection.\nPlease check your network.';
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hotels'),
        centerTitle: true,
        actions: [
          // Filter toggle button with badge
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  _showFilters
                      ? Icons.filter_list_off_rounded
                      : Icons.filter_list_rounded,
                  color: _hasActiveFilters
                      ? AppTheme.primaryOrange
                      : null,
                ),
                tooltip: 'Filters',
                onPressed: () =>
                    setState(() => _showFilters = !_showFilters),
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Form ──────────────────────────────────────────────────
          _buildSearchForm(theme, isDark),

          // ── Filter Panel (collapsible) ───────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildFilterPanel(theme, isDark),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),

          // ── Sort Bar (only when results exist) ───────────────────────────
          if (_hotels.isNotEmpty) _buildSortBar(theme),

          // ── Results ──────────────────────────────────────────────────────
          Expanded(child: _buildResults(theme, isDark)),
        ],
      ),
    );
  }

  // ── Search Form Widget ─────────────────────────────────────────────────────
  Widget _buildSearchForm(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // City input
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              hintText: '🏙️ Enter city (e.g. Merzouga, Erfoud...)',
              prefixIcon: Icon(
                Icons.location_city_rounded,
                color: AppTheme.primaryOrange,
              ),
            ),
            onSubmitted: (_) => _searchHotels(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Dates + Adults row
          Row(
            children: [
              // Check In
              Expanded(
                child: GestureDetector(
                  onTap: _pickCheckIn,
                  child: _dateBox(
                    label: 'Check In',
                    value: _formatDisplayDate(_checkIn),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppTheme.primaryOrange, size: 20),
              const SizedBox(width: 8),
              // Check Out
              Expanded(
                child: GestureDetector(
                  onTap: _pickCheckOut,
                  child: _dateBox(
                    label: 'Check Out',
                    value: _formatDisplayDate(_checkOut),
                    subtitle: '$_nightCount night${_nightCount > 1 ? 's' : ''}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Adults counter
              _adultsCounter(),
            ],
          ),
          const SizedBox(height: 12),

          // Search button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _searchHotels,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('🔍 Search Hotels'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox({
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppTheme.primaryOrange.withAlpha(150)),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.primaryOrange.withAlpha(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryOrange,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.primaryOrange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _adultsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppTheme.primaryOrange.withAlpha(150)),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.primaryOrange.withAlpha(15),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_adults > 1) setState(() => _adults--);
            },
            child: const Icon(Icons.remove,
                size: 16, color: AppTheme.primaryOrange),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$_adults 👤',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_adults < 10) setState(() => _adults++);
            },
            child: const Icon(Icons.add,
                size: 16, color: AppTheme.primaryOrange),
          ),
        ],
      ),
    );
  }

  // ── Filter Panel ───────────────────────────────────────────────────────────
  Widget _buildFilterPanel(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: 4),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: AppTheme.primaryOrange.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      color: AppTheme.primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Advanced Filters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text(
                  'Reset',
                  style: TextStyle(color: AppTheme.primaryOrange),
                ),
              ),
            ],
          ),
          const Divider(),

          // ── Price Range ──────────────────────────────────────────────────
          _filterSectionTitle('💰 Price per Night'),
          Row(
            children: [
              Text(
                '\$${_priceRange.start.toInt()}',
                style: const TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: _maxPriceSlider,
                  divisions: 50,
                  activeColor: AppTheme.primaryOrange,
                  inactiveColor: AppTheme.primaryOrange.withAlpha(40),
                  labels: RangeLabels(
                    '\$${_priceRange.start.toInt()}',
                    _priceRange.end >= _maxPriceSlider
                        ? 'Any'
                        : '\$${_priceRange.end.toInt()}',
                  ),
                  onChanged: (values) =>
                      setState(() => _priceRange = values),
                ),
              ),
              Text(
                _priceRange.end >= _maxPriceSlider
                    ? 'Any'
                    : '\$${_priceRange.end.toInt()}',
                style: const TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Stars ────────────────────────────────────────────────────────
          _filterSectionTitle('⭐ Minimum Stars'),
          Row(
            children: [
              // "Any" chip
              _starChip(0, 'Any'),
              const SizedBox(width: 6),
              for (int s = 1; s <= 5; s++) ...[
                _starChip(s, '$s★'),
                if (s < 5) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Rating ───────────────────────────────────────────────────────
          _filterSectionTitle('🏅 Minimum Rating'),
          Wrap(
            spacing: 6,
            children: [
              _ratingChip(0.0, 'Any'),
              _ratingChip(7.0, '7+'),
              _ratingChip(8.0, '8+'),
              _ratingChip(8.5, '8.5+'),
              _ratingChip(9.0, '9+'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Apply Button ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Apply Filters & Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _starChip(int value, String label) {
    final selected = _starsFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _starsFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryOrange
              : AppTheme.primaryOrange.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primaryOrange
                : AppTheme.primaryOrange.withAlpha(80),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _ratingChip(double value, String label) {
    final selected = _ratingFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _ratingFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.goldAccent
              : AppTheme.goldAccent.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.goldAccent
                : AppTheme.goldAccent.withAlpha(80),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.goldAccent,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── Sort Bar ───────────────────────────────────────────────────────────────
  Widget _buildSortBar(ThemeData theme) {
    return Container(
      height: 44,
      color: theme.cardColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: 6),
        children: [
          _sortChip(
            label: '⭐ Top Rated',
            value: 'rating',
            icon: Icons.star_rounded,
          ),
          const SizedBox(width: 8),
          _sortChip(
            label: '💲 Price ↑',
            value: 'price_asc',
            icon: Icons.arrow_upward_rounded,
          ),
          const SizedBox(width: 8),
          _sortChip(
            label: '💲 Price ↓',
            value: 'price_desc',
            icon: Icons.arrow_downward_rounded,
          ),
          // Active filter summary
          if (_hasActiveFilters) ...[
            const SizedBox(width: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  _resetFilters();
                  _searchHotels();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.red.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.close_rounded,
                          size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Clear filters',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sortChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final selected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
          _hotels = _applySorting(_hotels);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryOrange
              : AppTheme.primaryOrange.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primaryOrange
                : AppTheme.primaryOrange.withAlpha(60),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  selected ? Colors.white : AppTheme.primaryOrange,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RESULTS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildResults(ThemeData theme, bool isDark) {
    // ── Empty state (not yet searched) ────────────────────────────────────
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hotel_rounded,
                size: 40,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Search for Hotels',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter a city and pick your dates',
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try: Merzouga · Erfoud · Tinghir · Zagora',
              style: TextStyle(
                color: AppTheme.primaryOrange.withAlpha(180),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // ── Loading ───────────────────────────────────────────────────────────
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppTheme.primaryOrange),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Searching hotels...',
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      );
    }

    // ── Error ─────────────────────────────────────────────────────────────
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
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _searchHotels,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // ── No results ────────────────────────────────────────────────────────
    if (_hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: theme.textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No hotels found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a different city or adjust your filters',
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () {
                  _resetFilters();
                  _searchHotels();
                },
                icon: const Icon(Icons.filter_list_off_rounded),
                label: const Text('Remove Filters'),
              ),
            ],
          ],
        ),
      );
    }

    // ── Results list ──────────────────────────────────────────────────────
    return Column(
      children: [
        // Results count header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 8,
          ),
          child: Row(
            children: [
              Text(
                '${_hotels.length} hotel${_hotels.length > 1 ? 's' : ''} found',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Filtered',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            itemCount: _hotels.length,
            itemBuilder: (context, index) =>
                _buildHotelCard(_hotels[index], theme, isDark),
          ),
        ),
      ],
    );
  }

  // ── Hotel Card ─────────────────────────────────────────────────────────────
  Widget _buildHotelCard(
      HotelModel hotel, ThemeData theme, bool isDark) {
    final nights = _nightCount;
    final totalPrice = hotel.pricePerNight * nights;

    return Container(
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
            // ── Photo ──────────────────────────────────────────────────
            Stack(
              children: [
                hotel.photoUrl.isNotEmpty
                    ? Image.network(
                        hotel.photoUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _hotelPhotoPlaceholder(),
                      )
                    : _hotelPhotoPlaceholder(),

                // Source badge (Firestore vs API)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hotel.source == 'local'
                          ? Colors.green.withAlpha(220)
                          : Colors.blue.withAlpha(220),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hotel.source == 'local'
                          ? '📍 Local'
                          : '🌐 API',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Stars badge
                if (hotel.stars > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '★' * hotel.stars,
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info ───────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.all(AppSpacing.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    hotel.name,
                    style:
                        theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),

                  // Location
                  if (hotel.address.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color:
                              theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            hotel.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme
                                  .textTheme.bodyMedium?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  // Amenities chips
                  if (hotel.amenities.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 26,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: hotel.amenities
                            .take(5)
                            .length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 6),
                        itemBuilder: (_, i) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange
                                .withAlpha(15),
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryOrange
                                  .withAlpha(60),
                            ),
                          ),
                          child: Text(
                            hotel.amenities[i],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm + 2),

                  // Rating + Price row
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating badge
                      if (hotel.reviewScore > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent
                                .withAlpha(30),
                            borderRadius: BorderRadius.circular(
                                AppRadius.badge),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppTheme.goldAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hotel.reviewScore
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.goldAccent,
                                ),
                              ),
                              if (hotel.reviewScoreWord
                                  .isNotEmpty)
                                Text(
                                  ' · ${hotel.reviewScoreWord}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.goldAccent,
                                  ),
                                ),
                              if (hotel.reviewCount > 0)
                                Text(
                                  ' (${hotel.reviewCount})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.goldAccent
                                        .withAlpha(180),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Price column
                      if (hotel.pricePerNight > 0)
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '\$${hotel.pricePerNight.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w800,
                                      color:
                                          AppTheme.primaryOrange,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/night',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme
                                          .bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (nights > 1)
                              Text(
                                'Total: \$${totalPrice.toStringAsFixed(0)} · $nights nights',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textTheme
                                      .bodySmall?.color,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Book button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(
                            name: hotel.name,
                            imageUrl: hotel.photoUrl,
                            type: BookingType.hotel,
                            pricePerPerson:
                                hotel.pricePerNight > 0
                                    ? hotel.pricePerNight
                                    : 50.0,
                          ),
                        ),
                      ),
                      child: const Text('Book Now 🏨'),
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

  Widget _hotelPhotoPlaceholder() {
    return Container(
      height: 180,
      color: AppTheme.primaryOrange.withAlpha(30),
      child: const Center(
        child: Icon(
          Icons.hotel_rounded,
          size: 60,
          color: AppTheme.primaryOrange,
        ),
      ),
    );
  }
}