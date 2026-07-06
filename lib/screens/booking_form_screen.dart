import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';

class BookingFormScreen extends StatefulWidget {
  final String name;
  final String imageUrl;
  final BookingType type;
  final double pricePerPerson;

  /// When true, this is a circuit booking: the price is per person for the
  /// whole tour (total = pricePerPerson * people), the end date is optional,
  /// and prices are shown in MAD.
  final bool isCircuit;

  /// Optional fixed number of days for circuit bookings (used for the summary).
  final int? circuitDurationDays;

  const BookingFormScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.pricePerPerson,
    this.isCircuit = false,
    this.circuitDurationDays,
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
    if (widget.isCircuit) {
      return widget.circuitDurationDays ?? 1;
    }
    if (_startDate == null || _endDate == null) return 1;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice {
    if (widget.isCircuit) {
      // Circuit price is per person for the whole tour.
      return widget.pricePerPerson * _guests;
    }
    return widget.pricePerPerson * _guests * _numberOfDays;
  }

  String _money(double value) {
    final amount = value.toStringAsFixed(0);
    return widget.isCircuit ? '$amount MAD' : '\$$amount';
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
    if (widget.isCircuit) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a start date!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_startDate == null || _endDate == null) {
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
          builder: (ctx) {
            final dialogTheme = Theme.of(ctx);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sheet),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.oasisGreen.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.oasisGreen,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Booking Confirmed! 🎉',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      color: dialogTheme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${widget.name} has been booked!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: dialogTheme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    'Total: ${_money(_totalPrice)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl - 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('View My Bookings'),
                    ),
                  ),
                ],
              ),
            );
          },
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
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                          color: AppTheme.primaryOrange.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_rounded,
                            color: AppTheme.goldAccent),
                        const SizedBox(width: AppSpacing.sm + 2),
                        Text(
                          widget.isCircuit
                              ? '${widget.pricePerPerson.toStringAsFixed(0)} MAD per person'
                              : '\$${widget.pricePerPerson.toStringAsFixed(0)} per person/day',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ─── Dates ─────────────────────────────
                  Text(
                    '📅 Select Dates',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickStartDate,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md + 2),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(
                                color: _startDate != null
                                    ? AppTheme.primaryOrange
                                    : (isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder),
                                width: _startDate != null ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 70 : 30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
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
                                    color: theme.textTheme.bodySmall?.color,
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
                                        : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!widget.isCircuit) const SizedBox(width: AppSpacing.md),
                      if (!widget.isCircuit)
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickEndDate,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md + 2),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(
                                color: _endDate != null
                                    ? AppTheme.primaryOrange
                                    : (isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder),
                                width: _endDate != null ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 70 : 30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
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
                                    color: theme.textTheme.bodySmall?.color,
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
                                        : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ─── Guests ────────────────────────────
                  Text(
                    '👥 Number of Guests',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
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
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_guests Guest${_guests > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: theme.textTheme.bodyLarge?.color,
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
                                      : (isDark
                                          ? AppTheme.darkBorder
                                          : AppTheme.lightBorder),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Text(
                              '$_guests',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
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
                  const SizedBox(height: AppSpacing.xl),

                  // ─── Summary ───────────────────────────
                  if (_startDate != null &&
                      (widget.isCircuit || _endDate != null)) ...[
                    Text(
                      '🧾 Booking Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
                      child: Column(
                        children: [
                          _summaryRow(
                              '📍 Place', widget.name),
                          _divider(),
                          _summaryRow(
                              widget.isCircuit ? '📅 Start' : '📅 Check In',
                              _formatDate(_startDate)),
                          if (!widget.isCircuit) ...[
                            _divider(),
                            _summaryRow('📅 Check Out',
                                _formatDate(_endDate)),
                          ],
                          _divider(),
                          _summaryRow(
                              '🌙 Duration',
                              '$_numberOfDays day${_numberOfDays > 1 ? 's' : ''}'),
                          _divider(),
                          _summaryRow(
                              widget.isCircuit ? '👥 People' : '👥 Guests',
                              '$_guests guest${_guests > 1 ? 's' : ''}'),
                          _divider(),
                          _summaryRow(
                              widget.isCircuit
                                  ? '💰 Price/person'
                                  : '💰 Price/person/day',
                              _money(widget.pricePerPerson)),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withAlpha(20),
                              borderRadius: BorderRadius.circular(AppRadius.badge),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  'TOTAL PRICE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: theme.textTheme.titleLarge?.color,
                                  ),
                                ),
                                Text(
                                  _money(_totalPrice),
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
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // ─── Confirm Button ─────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _confirmBooking,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Confirm Booking 🎉'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg + 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Theme.of(context).dividerTheme.color, height: 1);
  }
}