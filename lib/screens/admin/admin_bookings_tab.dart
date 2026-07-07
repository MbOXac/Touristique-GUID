import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

/// Warm Desert style — All bookings management tab.
class AdminBookingsTab extends StatefulWidget {
  const AdminBookingsTab({super.key});

  @override
  State<AdminBookingsTab> createState() => _AdminBookingsTabState();
}

class _AdminBookingsTabState extends State<AdminBookingsTab>
    with SingleTickerProviderStateMixin {
  final _adminService = AdminService();
  late final TabController _tabController;

  static const _statuses = [
    null,
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.cancelled,
  ];
  static const _tabLabels = ['All', 'Pending', 'Confirmed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: Column(
        children: [
          // ── Warm header ──────────────────────────────
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: MediaQuery.of(context).size.width < 600
                      ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                      : const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bookings',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.deepBlue)),
                          Text('All reservations across all users',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.lightTextSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Tab bar
                TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  labelColor: AppTheme.primaryOrange,
                  unselectedLabelColor: AppTheme.lightTextSecondary,
                  indicatorColor: AppTheme.primaryOrange,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
                ),
              ],
            ),
          ),

          // ── Tab content ──────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (i) {
                final status = _statuses[i];
                final stream = status == null
                    ? _adminService.streamAllBookings()
                    : _adminService.streamBookingsByStatus(status);
                return _BookingList(
                    stream: stream, adminService: _adminService);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Booking list ──────────────────────────────────────────────────────────────

class _BookingList extends StatelessWidget {
  const _BookingList(
      {required this.stream, required this.adminService});

  final Stream<List<Booking>> stream;
  final AdminService adminService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booking>>(
      stream: stream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryOrange));
        }
        if (snap.hasError) {
          return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        final bookings = snap.data ?? [];
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.sandBeige,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.book_online_outlined,
                      size: 44, color: AppTheme.earthBrown),
                ),
                const SizedBox(height: 16),
                const Text('No bookings here',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepBlue)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => _BookingCard(
              booking: bookings[i], adminService: adminService),
        );
      },
    );
  }
}

// ── Booking card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  const _BookingCard(
      {required this.booking, required this.adminService});

  final Booking booking;
  final AdminService adminService;

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppTheme.oasisGreen;
      case BookingStatus.pending:
        return AppTheme.goldAccent;
      case BookingStatus.cancelled:
        return Colors.redAccent;
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.pending:
        return Icons.pending_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String get _typeLabel =>
      booking.type.name[0].toUpperCase() + booking.type.name.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Color bar top ───────────────────────────
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type + status row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.sandBeige,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_typeLabel,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.earthBrown)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _statusColor.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon,
                              color: _statusColor, size: 12),
                          const SizedBox(width: 4),
                          Text(booking.status.name.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _statusColor,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Name
                Text(booking.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.deepBlue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),

                // Details chips
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _buildChip(Icons.person_outline_rounded,
                        booking.userId.length > 10
                            ? '${booking.userId.substring(0, 10)}…'
                            : booking.userId),
                    _buildChip(Icons.calendar_today_outlined,
                        _formatDate(booking.bookingDate)),
                    _buildChip(Icons.group_outlined,
                        '${booking.guests} guest${booking.guests == 1 ? '' : 's'}'),
                    _buildChip(Icons.attach_money_rounded,
                        '\$${booking.price.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.lightBorder),
                const SizedBox(height: 12),

                // Action buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (booking.status != BookingStatus.confirmed)
                      _WarmActionBtn(
                        label: 'Confirm',
                        icon: Icons.check_rounded,
                        color: AppTheme.oasisGreen,
                        onTap: () => _updateStatus(
                            context, BookingStatus.confirmed),
                      ),
                    if (booking.status != BookingStatus.cancelled)
                      _WarmActionBtn(
                        label: 'Cancel',
                        icon: Icons.close_rounded,
                        color: AppTheme.primaryOrange,
                        onTap: () => _updateStatus(
                            context, BookingStatus.cancelled),
                      ),
                    GestureDetector(
                      onTap: () => _deleteBooking(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, BookingStatus status) async {
    await adminService.updateBookingStatus(booking, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(status == BookingStatus.confirmed
            ? 'Booking confirmed ✓'
            : 'Booking cancelled.'),
        backgroundColor: status == BookingStatus.confirmed
            ? AppTheme.oasisGreen
            : AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _deleteBooking(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Booking'),
        content: const Text(
            'This will permanently remove the booking from all records.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await adminService.deleteBooking(booking);
    }
  }

  Widget _buildChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.lightTextSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.lightTextSecondary)),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Warm action button ────────────────────────────────────────────────────────

class _WarmActionBtn extends StatelessWidget {
  const _WarmActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
