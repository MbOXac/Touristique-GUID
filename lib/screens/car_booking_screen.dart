import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/car.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';

class CarBookingScreen extends StatefulWidget {
  final Car car;

  const CarBookingScreen({super.key, required this.car});

  @override
  State<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _pickupDate;
  DateTime? _returnDate;
  int _driverAge = 30;
  bool _isSaving = false;

  int get _days {
    if (_pickupDate == null || _returnDate == null) return 0;
    return _returnDate!.difference(_pickupDate!).inDays;
  }

  double get _totalPrice => _days * widget.car.pricePerDay;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isPickup}) async {
    final now = DateTime.now();
    final initial = isPickup
        ? (_pickupDate ?? now)
        : (_returnDate ?? _pickupDate ?? now);

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isPickup) {
        _pickupDate = selected;
        if (_returnDate != null &&
            _returnDate!.isBefore(selected)) {
          _returnDate = selected.add(const Duration(days: 1));
        }
      } else {
        _returnDate = selected;
      }
    });
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickupDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select pickup and return dates.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Return date must be after pickup date.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to book a car.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final booking = Booking(
        id: '',
        userId: user.uid,
        type: BookingType.car,
        name: widget.car.name,
        imageUrl: widget.car.image,
        bookingDate: DateTime.now(),
        startDate: _pickupDate,
        endDate: _returnDate,
        guests: 1,
        price: _totalPrice,
        status: BookingStatus.pending,
        details:
            '${_days} days · ${widget.car.transmission} · ${widget.car.fuel} · Driver: ${_nameController.text.trim()}',
        createdAt: DateTime.now(),
      );

      await BookingService.createBooking(booking);

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final dialogTheme = Theme.of(context);
          return AlertDialog(
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
                  'Booking Confirmed!',
                  style: TextStyle(
                    color: dialogTheme.textTheme.titleLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your ${widget.car.name} rental has been confirmed. Have a great trip! 🚗',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dialogTheme.textTheme.bodyMedium?.color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl - 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Car'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Car Summary Card
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
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.car.image,
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.car.name,
                          style: TextStyle(
                            color: theme.textTheme.titleLarge?.color,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.car.company,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${widget.car.pricePerDay.toStringAsFixed(0)} / day',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Driver Information
            Text(
              'Driver Information',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter your phone number'
                  : null,
            ),
            const SizedBox(height: 12),

            // Driver Age
            Container(
              padding: const EdgeInsets.all(14),
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
                children: [
                  const Icon(Icons.cake_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver Age',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$_driverAge years',
                          style: TextStyle(
                            color: theme.textTheme.titleLarge?.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _driverAge > 20
                            ? () => setState(() => _driverAge--)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      IconButton(
                        onPressed: _driverAge < 65
                            ? () => setState(() => _driverAge++)
                            : null,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rental Dates
            Text(
              'Rental Dates',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'Pickup Date',
                    value: _pickupDate == null
                        ? 'Select'
                        : _formatDate(_pickupDate!),
                    icon: Icons.flight_land_rounded,
                    onTap: () => _pickDate(isPickup: true),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTile(
                    label: 'Return Date',
                    value: _returnDate == null
                        ? 'Select'
                        : _formatDate(_returnDate!),
                    icon: Icons.flight_takeoff_rounded,
                    onTap: () => _pickDate(isPickup: false),
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notes
            TextFormField(
              controller: _notesController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any special requests...',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Price Summary
            if (_days > 0)
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
                    _PriceRow(
                      label:
                          '\$${widget.car.pricePerDay.toStringAsFixed(0)} x $_days days',
                      value:
                          '\$${_totalPrice.toStringAsFixed(0)}',
                      theme: theme,
                    ),
                    const Divider(height: 20),
                    _PriceRow(
                      label: 'Total Price',
                      value: '\$${_totalPrice.toStringAsFixed(0)}',
                      theme: theme,
                      isTotal: true,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _confirmBooking,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  _isSaving ? 'Confirming...' : 'Confirm Booking 🚗',
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  const _DateTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryOrange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal
                ? theme.textTheme.titleLarge?.color
                : theme.textTheme.bodyMedium?.color,
            fontWeight:
                isTotal ? FontWeight.w900 : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? theme.colorScheme.primary
                : theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 20 : 14,
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}