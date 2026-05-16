import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/preview_card.dart';
import '../widgets/horizontal_carousel.dart';
import 'trip_memories_screen.dart';
import 'bookings_screen.dart';

class TripTab extends StatelessWidget {
  const TripTab({super.key});

  @override
  Widget build(BuildContext context) {
    final memories = MockDataService.getTripMemories().take(3).toList();
    final bookings = MockDataService.getBookings().take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trip'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SectionHeader(
              title: 'My Trip Memories',
              onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
            ),
            HorizontalCarousel(
              height: 180,
              itemWidth: 160,
              items: memories.map((m) => PreviewCard(
                imagePath: m.photos.first,
                title: m.title,
                subtitle: m.location,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen())),
                badge: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Text(m.mood, style: const TextStyle(fontSize: 16)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            SectionHeader(
              title: 'My Bookings',
              onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: bookings.map((booking) {
                  final icon = _typeIcon(booking.type);
                  final statusColor = _statusColor(booking.status);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppTheme.sandBeige, borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, color: AppTheme.primaryOrange, size: 22),
                      ),
                      title: Text(booking.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.deepBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(booking.details, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${booking.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                            child: Text(_statusLabel(booking.status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(BookingType type) {
    switch (type) {
      case BookingType.hotel: return Icons.hotel;
      case BookingType.restaurant: return Icons.restaurant;
      case BookingType.tour: return Icons.explore;
      case BookingType.transport: return Icons.directions_car;
    }
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed: return AppTheme.oasisGreen;
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.cancelled: return Colors.red;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed: return 'Confirmed';
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }
}
