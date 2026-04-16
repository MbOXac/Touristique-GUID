import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../theme/app_theme.dart';
import '../widgets/destination_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<Destination> _destinations = [
    Destination(
      name: 'Kasbah & Valleys',
      description:
          'Explore centuries-old mud-brick kasbahs nestled among dramatic cliffs '
          'and verdant valleys along the Draa River.',
      imagePath: 'assets/images/destination_1.jpg',
      rating: 4.8,
      distance: '120 km',
    ),
    Destination(
      name: 'Merzouga Desert',
      description:
          'Ride camels across the iconic Erg Chebbi dunes and spend a night '
          'under a sky blazing with stars in the Sahara.',
      imagePath: 'assets/images/destination_2.jpg',
      rating: 4.9,
      distance: '340 km',
    ),
    Destination(
      name: 'Todra Gorge',
      description:
          'Walk through towering 300-metre limestone walls carved by the Todra '
          'River – a paradise for hikers and climbers.',
      imagePath: 'assets/images/destination_3.jpg',
      rating: 4.7,
      distance: '175 km',
    ),
    Destination(
      name: 'Oasis & Palmeraies',
      description:
          'Wander through sprawling date-palm groves irrigated by ancient '
          'khettara channels in the lush valleys of Tinghir.',
      imagePath: 'assets/images/destination_4.jpg',
      rating: 4.6,
      distance: '160 km',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DestinationCard(destination: _destinations[index]),
                ),
                childCount: _destinations.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.deepBlue,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Southeast Morocco',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Discover destinations',
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/welcome.jpg',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x44000000), Color(0xBB000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
