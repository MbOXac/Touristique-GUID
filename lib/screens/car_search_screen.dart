import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/car_service.dart';
import '../theme/app_theme.dart';
import 'car_detail_screen.dart';

class CarSearchScreen extends StatefulWidget {
  const CarSearchScreen({super.key});

  @override
  State<CarSearchScreen> createState() => _CarSearchScreenState();
}

class _CarSearchScreenState extends State<CarSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Car> _cars = [];
  List<Car> _filtered = [];
  String _selectedTransmission = 'All';
  String _selectedFuel = 'All';

  final List<String> _transmissions = ['All', 'Automatic', 'Manual'];
  final List<String> _fuels = ['All', 'Petrol', 'Diesel', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _cars = CarService.getCars();
    _filtered = _cars;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filtered = _cars.where((car) {
        final matchSearch = car.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()) ||
            car.brand
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchTransmission = _selectedTransmission == 'All' ||
            car.transmission == _selectedTransmission;

        final matchFuel =
            _selectedFuel == 'All' || car.fuel == _selectedFuel;

        return matchSearch && matchTransmission && matchFuel;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilters(),
                      decoration: InputDecoration(
                        hintText: 'Search cars...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFilters();
                                },
                              )
                            : null,
                      ),
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
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _transmissions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final t = _transmissions[index];
                        final isSelected = _selectedTransmission == t;
                        return GestureDetector(
                          onTap: () {
                            setState(
                                () => _selectedTransmission = t);
                            _applyFilters();
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor,
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme
                                        .textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
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
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fuels.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final f = _fuels[index];
                        final isSelected = _selectedFuel == f;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedFuel = f);
                            _applyFilters();
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.oasisGreen
                                  : theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.oasisGreen
                                    : theme.dividerColor,
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme
                                        .textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Results count
                  Text(
                    '${_filtered.length} cars available',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Car List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: _filtered.isEmpty
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
                              'No cars found',
                              style: TextStyle(
                                color: theme
                                    .textTheme.titleLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search or filter',
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    car.image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                            color: Colors.amber,
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
                          backgroundColor:
                              theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
        borderRadius: BorderRadius.circular(20),
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