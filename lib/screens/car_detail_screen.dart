import 'package:flutter/material.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../widgets/car_image.dart';
import '../widgets/rating_badge.dart';
import 'car_booking_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  // Text drawn directly over the hero photo — hardcoded white
                  // is intentional here (photo overlay), per the design system.
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
                            borderRadius:
                                BorderRadius.circular(AppRadius.chip),
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
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          car.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Gold star + gold bold rating, matching RatingBadge.
                        RatingBadge(rating: car.rating),
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
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price + luggage capacity — rounded shadow card matching
                  // the app's CircuitCard/DestinationCard visual system.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '\$${car.pricePerDay.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.primaryOrange,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent.withAlpha(30),
                            borderRadius:
                                BorderRadius.circular(AppRadius.badge),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.luggage_rounded,
                                color: AppTheme.goldAccent,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${car.luggage} bags',
                                style: const TextStyle(
                                  color: AppTheme.goldAccent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Specifications
                  Text(
                    'Specifications',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
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
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 2.5,
                      children: [
                        _SpecCard(
                          icon: Icons.people_rounded,
                          label: 'Seats',
                          value: '${car.seats} persons',
                          color: AppTheme.deepBlue,
                        ),
                        _SpecCard(
                          icon: Icons.settings_rounded,
                          label: 'Transmission',
                          value: car.transmission,
                          color: AppTheme.oasisGreen,
                        ),
                        _SpecCard(
                          icon: Icons.local_gas_station_rounded,
                          label: 'Fuel Type',
                          value: car.fuel,
                          color: AppTheme.earthBrown,
                        ),
                        _SpecCard(
                          icon: Icons.business_rounded,
                          label: 'Company',
                          value: car.company,
                          color: AppTheme.primaryOrange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Included features
                  Text(
                    'What\'s included',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
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
                    child: Column(
                      children: [
                        _FeatureRow(
                          icon: Icons.shield_rounded,
                          label: 'Full insurance coverage',
                          theme: theme,
                        ),
                        const Divider(height: 1, indent: 48),
                        _FeatureRow(
                          icon: Icons.local_gas_station_rounded,
                          label: 'Full tank of fuel',
                          theme: theme,
                        ),
                        const Divider(height: 1, indent: 48),
                        _FeatureRow(
                          icon: Icons.support_agent_rounded,
                          label: '24/7 roadside assistance',
                          theme: theme,
                        ),
                        const Divider(height: 1, indent: 48),
                        _FeatureRow(
                          icon: Icons.cleaning_services_rounded,
                          label: 'Vehicle cleaned before pickup',
                          theme: theme,
                        ),
                        const Divider(height: 1, indent: 48),
                        _FeatureRow(
                          icon: Icons.gps_fixed_rounded,
                          label: 'GPS navigation included',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Book Now Button — plain ElevatedButton renders as the app's
      // terracotta filled pill via ElevatedButtonTheme.
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarBookingScreen(car: car),
              ),
            ),
            child: const Text('Book Now 🚗'),
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.oasisGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.badge - 2),
            ),
            child: Icon(
              icon,
              color: AppTheme.oasisGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
