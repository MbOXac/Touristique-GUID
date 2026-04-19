import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Booking> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = MockDataService.getBookings();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _filteredBookings(String status) {
    switch (status) {
      case 'Confirmed': return _bookings.where((b) => b.status == BookingStatus.confirmed).toList();
      case 'Pending': return _bookings.where((b) => b.status == BookingStatus.pending).toList();
      default: return _bookings;
    }
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

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.primaryOrange,
          tabs: const [Tab(text: 'All'), Tab(text: 'Confirmed'), Tab(text: 'Pending')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['All', 'Confirmed', 'Pending'].map((status) {
          final bookings = _filteredBookings(status);
          if (bookings.isEmpty) {
            return const EmptyState(icon: Icons.calendar_today_outlined, title: 'No bookings', message: 'You have no bookings in this category.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: AppTheme.sandBeige, borderRadius: BorderRadius.circular(12)),
              child: Icon(_typeIcon(booking.type), color: AppTheme.primaryOrange, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(booking.details, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(_formatDate(booking.bookingDate), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${booking.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryOrange)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor(booking.status).withAlpha(30), borderRadius: BorderRadius.circular(10)),
                  child: Text(_statusLabel(booking.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor(booking.status))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
