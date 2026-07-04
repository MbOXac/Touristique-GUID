import 'package:flutter/material.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../widgets/car_image.dart';
import 'car_booking_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with car image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CarImage(
                    imageUrl: car.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    cacheWidth: 1200,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xDD000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
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
                        const SizedBox(height: 8),
                        Text(
                          car.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${car.rating} rating',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
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
          ),

          // Car Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price per day',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${car.pricePerDay.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.luggage_rounded,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${car.luggage} bags',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Specifications
                  Text(
                    'Specifications',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _SpecCard(
                        icon: Icons.people_rounded,
                        label: 'Seats',
                        value: '${car.seats} persons',
                        color: const Color(0xFF2980B9),
                      ),
                      _SpecCard(
                        icon: Icons.settings_rounded,
                        label: 'Transmission',
                        value: car.transmission,
                        color: const Color(0xFF27AE60),
                      ),
                      _SpecCard(
                        icon: Icons.local_gas_station_rounded,
                        label: 'Fuel Type',
                        value: car.fuel,
                        color: const Color(0xFFE74C3C),
                      ),
                      _SpecCard(
                        icon: Icons.business_rounded,
                        label: 'Company',
                        value: car.company,
                        color: AppTheme.primaryOrange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Included features
                  Text(
                    'What\'s included',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.shield_rounded,
                    label: 'Full insurance coverage',
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.local_gas_station_rounded,
                    label: 'Full tank of fuel',
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.support_agent_rounded,
                    label: '24/7 roadside assistance',
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.cleaning_services_rounded,
                    label: 'Vehicle cleaned before pickup',
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.gps_fixed_rounded,
                    label: 'GPS navigation included',
                    theme: theme,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Book Now Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CarBookingScreen(car: car),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Book Now 🚗',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SpecCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.oasisGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.oasisGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
  