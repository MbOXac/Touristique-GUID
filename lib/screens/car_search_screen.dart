import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/car_firestore_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';
import '../widgets/car_image.dart';
import 'car_detail_screen.dart';

class CarSearchScreen extends StatefulWidget {
  const CarSearchScreen({super.key});

  @override
  State<CarSearchScreen> createState() => _CarSearchScreenState();
}

class _CarSearchScreenState extends State<CarSearchScreen> {
  List<Car> _cars = [];
  List<Car> _filtered = [];
  List<String> _availableCities = [];
  String _selectedCity = '';
  String _selectedTransmission = 'All';
  String _selectedFuel = 'All';
  bool _isLoading = false;
  bool _isLoadingCities = true;

  final List<String> _transmissions = ['All', 'Automatic', 'Manual'];
  final List<String> _fuels = ['All', 'Petrol', 'Diesel', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _loadAvailableCities();
  }

  // Load all available cities from Firestore
  Future<void> _loadAvailableCities() async {
    setState(() => _isLoadingCities = true);
    final cities = await CarFirestoreService.getAllCities();
    setState(() {
      _availableCities = cities;
      _isLoadingCities = false;
    });
  }

  // Search cars by city
  Future<void> _searchCarsByCity(String city) async {
    if (city.isEmpty) {
      setState(() {
        _cars = [];
        _filtered = [];
        _selectedCity = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedCity = city;
    });

    final cars = await CarFirestoreService.searchCarsByCity(city);

    setState(() {
      _cars = cars;
      _filtered = cars;
      _isLoading = false;
    });
  }

  // Apply filters
  void _applyFilters() {
    setState(() {
      _filtered = _cars.where((car) {
        final matchTransmission = _selectedTransmission == 'All' ||
            car.transmission == _selectedTransmission;

        final matchFuel =
            _selectedFuel == 'All' || car.fuel == _selectedFuel;

        return matchTransmission && matchFuel;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/destination_1.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0xDD000000),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 60,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🚗 Car Rentals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find your perfect ride',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
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
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Search Bar with Autocomplete
                  Text(
                    'Search by City',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                    child: _isLoadingCities
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Loading cities...'),
                              ],
                            ),
                          )
                        : Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return _availableCities;
                              }
                              return _availableCities.where(
                                  (String option) {
                                return option.toLowerCase().contains(
                                    textEditingValue.text
                                        .toLowerCase());
                              });
                            },
                            onSelected: (String selection) {
                              _searchCarsByCity(selection);
                            },
                            fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController
                                  textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      _cars = [];
                                      _filtered = [];
                                      _selectedCity = '';
                                    });
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _searchCarsByCity(value);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter city name...',
                                  prefixIcon: Icon(
                                    Icons.location_on_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  suffixIcon: ValueListenableBuilder(
                                    valueListenable: textEditingController,
                                    builder: (context, value, child) {
                                      return value.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                  Icons.clear_rounded),
                                              onPressed: () {
                                                textEditingController
                                                    .clear();
                                                setState(() {
                                                  _cars = [];
                                                  _filtered = [];
                                                  _selectedCity = '';
                                                });
                                              },
                                            )
                                          : const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              );
                            },
                            optionsViewBuilder: (
                              BuildContext context,
                              AutocompleteOnSelected<String>
                                  onSelected,
                              Iterable<String> options,
                            ) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                      maxWidth: 350,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context,
                                              int index) {
                                        final String option =
                                            options.elementAt(index);
                                        return InkWell(
                                          onTap: () =>
                                              onSelected(option),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .location_city_rounded,
                                                  size: 16,
                                                  color: theme
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                const SizedBox(
                                                    width: 8),
                                                Text(
                                                  option,
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Transmission Filter
                  Text(
                    'Transmission',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _transmissions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final t = _transmissions[index];
                        final isSelected =
                            _selectedTransmission == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(
                                () => _selectedTransmission = t);
                            _applyFilters();
                          },
                          selectedColor: AppTheme.primaryOrange,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium
                                    ?.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Fuel Filter
                  Text(
                    'Fuel Type',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fuels.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final f = _fuels[index];
                        final isSelected = _selectedFuel == f;
                        return ChoiceChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedFuel = f);
                            _applyFilters();
                          },
                          selectedColor: AppTheme.goldAccent,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium
                                    ?.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Results count
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else if (_selectedCity.isNotEmpty)
                    Text(
                      '${_filtered.length} cars available in $_selectedCity',
                      style: TextStyle(
                        color: theme.textTheme.titleLarge?.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Enter a city to search for cars',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Car List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: _filtered.isEmpty &&
                    !_isLoading &&
                    _selectedCity.isNotEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 64,
                              color: theme.colorScheme.primary
                                  .withAlpha(100),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No cars found in $_selectedCity',
                              style: TextStyle(
                                color: theme
                                    .textTheme.titleLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different city or filter',
                              style: TextStyle(
                                color: theme
                                    .textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _isLoading
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 100),
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    : _filtered.isEmpty
                        ? const SliverToBoxAdapter(
                            child: SizedBox.shrink())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final car = _filtered[index];
                                return _CarCard(
                                  car: car,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CarDetailScreen(car: car),
                                    ),
                                  ),
                                );
                              },
                              childCount: _filtered.length,
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const _CarCard({
    required this.car,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 70 : 30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.cardLarge),
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'car_image_${car.id}',
                    child: CarImage(
                      imageUrl: car.image,
                      height: 180,
                      width: double.infinity,
                      cacheWidth: 600,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xAA000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        car.company,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.goldAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            car.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                      car.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Car Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Info
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withAlpha(10),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                car.company,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: 14,
                              color:
                                  theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                car.companyPhone,
                                style: TextStyle(
                                  color: theme
                                      .textTheme.bodySmall?.color,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email_rounded,
                              size: 14,
                              color:
                                  theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                car.companyEmail,
                                style: TextStyle(
                                  color: theme
                                      .textTheme.bodySmall?.color,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Car specs
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.people_rounded,
                        label: '${car.seats} seats',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.settings_rounded,
                        label: car.transmission,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.local_gas_station_rounded,
                        label: car.fuel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price & Button
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '\$${car.pricePerDay.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: ' / day',
                              style: TextStyle(
                                color: theme
                                    .textTheme.bodyMedium?.color,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('Book'),
                      ),
                    ],
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
