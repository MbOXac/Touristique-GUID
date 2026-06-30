import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _typeIcon(BookingType type) {
    switch (type) {
      case BookingType.hotel: return Icons.hotel;
      case BookingType.restaurant: return Icons.restaurant;
      case BookingType.tour: return Icons.explore;
      case BookingType.transport: return Icons.directions_car;
      case BookingType.activity: return Icons.hiking;
      case BookingType.car: return Icons.car_rental;
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
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ✅ Cancel booking with confirmation dialog
  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel "${booking.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await BookingService.cancelBooking(booking.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ Delete booking with confirmation dialog
  void _deleteBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Booking'),
        content: Text('Delete "${booking.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await BookingService.deleteBooking(booking.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to see bookings')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.primaryOrange,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      // ✅ StreamBuilder listens to Firestore in real-time
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(BookingService.getUserBookings()),
          _buildBookingList(
              BookingService.getBookingsByStatus(BookingStatus.confirmed)),
          _buildBookingList(
              BookingService.getBookingsByStatus(BookingStatus.pending)),
        ],
      ),
    );
  }

  // ✅ StreamBuilder Widget
  Widget _buildBookingList(Stream<List<Booking>> stream) {
    return StreamBuilder<List<Booking>>(
      stream: stream,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Empty
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'No bookings',
            message: 'You have no bookings in this category.',
          );
        }

        // ✅ Show bookings from Firestore
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) =>
              _buildBookingCard(bookings[index]),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkBackground
                    : AppTheme.sandBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon(booking.type),
                  color: AppTheme.primaryOrange, size: 26),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    booking.details,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(booking.bookingDate),
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Price + Status + Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${booking.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryOrange),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(booking.status)),
                  ),
                ),
                const SizedBox(height: 6),

                // ✅ Action buttons
                if (booking.status == BookingStatus.pending)
                  GestureDetector(
                    onTap: () => _cancelBooking(booking),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ),
                if (booking.status == BookingStatus.cancelled)
                  GestureDetector(
                    onTap: () => _deleteBooking(booking),
                    child: const Text('Delete',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}