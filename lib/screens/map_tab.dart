import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../theme/app_theme.dart';

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  static const List<Destination> _destinations = [
    Destination(id: '1', name: 'Kasbah & Valleys', description: 'Ancient mud-brick kasbahs along Draa River', imageURLs: ['assets/images/destination_1.jpg'], rating: 4.8, distance: '120 km'),
    Destination(id: '2', name: 'Merzouga Desert', description: 'Iconic Erg Chebbi dunes and Sahara nights', imageURLs: ['assets/images/destination_2.jpg'], rating: 4.9, distance: '340 km'),
    Destination(id: '3', name: 'Todra Gorge', description: '300m limestone walls carved by Todra River', imageURLs: ['assets/images/destination_3.jpg'], rating: 4.7, distance: '175 km'),
    Destination(id: '4', name: 'Oasis & Palmeraies', description: 'Date-palm groves in Tinghir valley', imageURLs: ['assets/images/destination_4.jpg'], rating: 4.6, distance: '160 km'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFE8F4F8)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.deepBlue.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.map_rounded, size: 30, color: AppTheme.deepBlue),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Interactive Map',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.deepBlue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Full map integration coming soon',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ..._buildPins(),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Destinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepBlue)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                final dest = _destinations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(dest.imageURLs.first, width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    title: Text(dest.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepBlue, fontSize: 14)),
                    subtitle: Text(dest.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 16),
                        Text(dest.distance, style: const TextStyle(fontSize: 11, color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPins() {
    const positions = [
      Offset(0.3, 0.4),
      Offset(0.7, 0.6),
      Offset(0.5, 0.3),
      Offset(0.6, 0.7),
    ];
    return List.generate(_destinations.length, (index) {
      return Positioned(
        left: positions[index].dx * 300,
        top: positions[index].dy * 180,
        child: const Icon(Icons.location_pin, color: AppTheme.primaryOrange, size: 28),
      );
    });
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBBDEFB).withAlpha(128)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
