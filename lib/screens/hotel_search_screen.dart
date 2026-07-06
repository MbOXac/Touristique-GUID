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
  State<HotelSearchScreen> createState() =>
      _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final TextEditingController _cityController =
      TextEditingController();
  List<HotelModel> _hotels = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  DateTime _checkIn =
      DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut =
      DateTime.now().add(const Duration(days: 3));
  int _adults = 2;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> _pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked;
        if (_checkOut.isBefore(_checkIn)) {
          _checkOut =
              _checkIn.add(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _pickCheckOut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate:
          DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _checkOut = picked);
  }

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
      );
      setState(() {
        _hotels = hotels;
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
        title: const Text('Search Hotels'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── Search Form ───────────────────────────────
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
                // City
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    hintText:
                        '🏙️ Enter city (e.g. Paris, Dubai...)',
                    prefixIcon: Icon(
                        Icons.location_city_rounded,
                        color: AppTheme.primaryOrange),
                  ),
                  onSubmitted: (_) => _searchHotels(),
                ),
                const SizedBox(height: AppSpacing.md),

                // Dates + Adults Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickCheckIn,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.primaryOrange
                                    .withAlpha(150)),
                            borderRadius:
                                BorderRadius.circular(12),
                            color: AppTheme.primaryOrange
                                .withAlpha(15),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Check In',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: theme.textTheme
                                          .bodySmall?.color)),
                              const SizedBox(height: 2),
                              Text(
                                _formatDisplayDate(_checkIn),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppTheme.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primaryOrange,
                        size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickCheckOut,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.primaryOrange
                                    .withAlpha(150)),
                            borderRadius:
                                BorderRadius.circular(12),
                            color: AppTheme.primaryOrange
                                .withAlpha(15),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Check Out',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: theme.textTheme
                                          .bodySmall?.color)),
                              const SizedBox(height: 2),
                              Text(
                                _formatDisplayDate(_checkOut),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppTheme.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.primaryOrange
                                .withAlpha(150)),
                        borderRadius:
                            BorderRadius.circular(12),
                        color: AppTheme.primaryOrange
                            .withAlpha(15),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_adults > 1)
                                setState(() => _adults--);
                            },
                            child: const Icon(Icons.remove,
                                size: 16,
                                color: AppTheme.primaryOrange),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8),
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
                              if (_adults < 10)
                                setState(() => _adults++);
                            },
                            child: const Icon(Icons.add,
                                size: 16,
                                color: AppTheme.primaryOrange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _searchHotels,
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
                color: AppTheme.primaryOrange.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hotel_rounded,
                  size: 40,
                  color: AppTheme.primaryOrange),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Search for Hotels',
                style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.sm),
            Text('Enter a city and pick your dates',
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color)),
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
            Text('Searching hotels...',
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color)),
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
                onPressed: _searchHotels,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 60,
                color: theme.textTheme.bodyMedium?.color),
            const SizedBox(height: AppSpacing.lg),
            Text('No hotels found',
                style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Text('Try a different city or dates',
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _hotels.length,
      itemBuilder: (context, index) =>
          _buildHotelCard(_hotels[index], theme, isDark),
    );
  }

  Widget _buildHotelCard(
      HotelModel hotel, ThemeData theme, bool isDark) {
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
            hotel.photoUrl.isNotEmpty
                ? Image.network(
                    hotel.photoUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color:
                          AppTheme.primaryOrange.withAlpha(30),
                      child: const Icon(Icons.hotel_rounded,
                          size: 60,
                          color: AppTheme.primaryOrange),
                    ),
                  )
                : Container(
                    height: 180,
                    color:
                        AppTheme.primaryOrange.withAlpha(30),
                    child: const Icon(Icons.hotel_rounded,
                        size: 60,
                        color: AppTheme.primaryOrange),
                  ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  if (hotel.address.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 14,
                            color:
                                theme.textTheme.bodyMedium?.color),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            hotel.address,
                            style: TextStyle(
                                fontSize: 12,
                                color: theme
                                    .textTheme.bodyMedium?.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      if (hotel.reviewScore > 0)
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
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14,
                                  color: AppTheme.goldAccent),
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
                                      color:
                                          AppTheme.goldAccent),
                                ),
                            ],
                          ),
                        ),
                      if (hotel.pricePerNight > 0)
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '\$${hotel.pricePerNight.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                              TextSpan(
                                text: '/night',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme
                                        .bodyMedium?.color),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
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
}