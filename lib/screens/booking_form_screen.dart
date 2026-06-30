import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';

class BookingFormScreen extends StatefulWidget {
  final String name;
  final String imageUrl;
  final BookingType type;
  final double pricePerPerson;

  const BookingFormScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.pricePerPerson,
  });

  @override
  State<BookingFormScreen> createState() =>
      _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _guests = 1;
  bool _isLoading = false;

  int get _numberOfDays {
    if (_startDate == null || _endDate == null) return 1;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice {
    return widget.pricePerPerson * _guests * _numberOfDays;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null &&
            _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select start date first!')),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _startDate!.add(const Duration(days: 1)),
      firstDate:
          _startDate!.add(const Duration(days: 1)),
      lastDate:
          DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _confirmBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select start and end dates!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final booking = Booking(
        id: '',
        userId: '',
        type: widget.type,
        name: widget.name,
        imageUrl: widget.imageUrl,
        bookingDate: DateTime.now(),
        startDate: _startDate,
        endDate: _endDate,
        guests: _guests,
        price: _totalPrice,
        status: BookingStatus.pending,
        details:
            '$_numberOfDays days · $_guests guest${_guests > 1 ? 's' : ''}',
        createdAt: DateTime.now(),
      );

      await BookingService.createBooking(booking);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.oasisGreen.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.oasisGreen,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Booking Confirmed! 🎉',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.name} has been booked!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: \$${_totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                    child: const Text(
                      'View My Bookings',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Now'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Image ────────────────────────────
            Stack(
              children: [
                widget.imageUrl.startsWith('http')
                    ? Image.network(
                        widget.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(
                          height: 200,
                          color: AppTheme.primaryOrange
                              .withAlpha(30),
                          child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppTheme.primaryOrange),
                        ),
                      )
                    : widget.imageUrl.isNotEmpty
                        ? Image.asset(
                            widget.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(
                              height: 200,
                              color: AppTheme.primaryOrange
                                  .withAlpha(30),
                              child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color:
                                      AppTheme.primaryOrange),
                            ),
                          )
                        : Container(
                            height: 200,
                            color: AppTheme.primaryOrange
                                .withAlpha(30),
                            child: const Center(
                              child: Icon(
                                  Icons.hotel_rounded,
                                  size: 60,
                                  color:
                                      AppTheme.primaryOrange),
                            ),
                          ),
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC000000)
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Price Card ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange
                          .withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primaryOrange
                              .withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_rounded,
                            color: AppTheme.primaryOrange),
                        const SizedBox(width: 10),
                        Text(
                          '\$${widget.pricePerPerson.toStringAsFixed(0)} per person/day',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Dates ─────────────────────────────
                  const Text(
                    '📅 Select Dates',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickStartDate,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: _startDate != null
                                    ? AppTheme.primaryOrange
                                    : Colors.grey
                                        .withAlpha(80),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha(
                                          isDark ? 40 : 10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check In',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(_startDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _startDate != null
                                        ? AppTheme.primaryOrange
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickEndDate,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: _endDate != null
                                    ? AppTheme.primaryOrange
                                    : Colors.grey
                                        .withAlpha(80),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha(
                                          isDark ? 40 : 10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check Out',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(_endDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _endDate != null
                                        ? AppTheme.primaryOrange
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Guests ────────────────────────────
                  const Text(
                    '👥 Number of Guests',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius:
                          BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                              isDark ? 40 : 10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_guests Guest${_guests > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_guests > 1) {
                                  setState(() => _guests--);
                                }
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _guests > 1
                                      ? AppTheme.primaryOrange
                                      : Colors.grey
                                          .withAlpha(80),
                                  borderRadius:
                                      BorderRadius.circular(
                                          10),
                                ),
                                child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '$_guests',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                if (_guests < 20) {
                                  setState(() => _guests++);
                                }
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange,
                                  borderRadius:
                                      BorderRadius.circular(
                                          10),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white,
                                    size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Summary ───────────────────────────
                  if (_startDate != null &&
                      _endDate != null) ...[
                    const Text(
                      '🧾 Booking Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius:
                            BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                                isDark ? 40 : 10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _summaryRow(
                              '📍 Place', widget.name),
                          _divider(),
                          _summaryRow('📅 Check In',
                              _formatDate(_startDate)),
                          _divider(),
                          _summaryRow('📅 Check Out',
                              _formatDate(_endDate)),
                          _divider(),
                          _summaryRow(
                              '🌙 Duration',
                              '$_numberOfDays day${_numberOfDays > 1 ? 's' : ''}'),
                          _divider(),
                          _summaryRow(
                              '👥 Guests',
                              '$_guests guest${_guests > 1 ? 's' : ''}'),
                          _divider(),
                          _summaryRow(
                              '💰 Price/person/day',
                              '\$${widget.pricePerPerson.toStringAsFixed(0)}'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange
                                  .withAlpha(20),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL PRICE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$${_totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color:
                                        AppTheme.primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ─── Confirm Button ─────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primaryOrange,
                        disabledBackgroundColor:
                            AppTheme.primaryOrange
                                .withAlpha(100),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Confirm Booking 🎉',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.withAlpha(40), height: 1);
  }
}