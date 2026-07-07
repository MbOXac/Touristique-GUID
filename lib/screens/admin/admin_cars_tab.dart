import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/car_firestore_service.dart';
import '../../models/car.dart';
import '../../theme/app_theme.dart';
import 'package:uuid/uuid.dart';

/// Warm Desert style — Cars management tab.
class AdminCarsTab extends StatefulWidget {
  const AdminCarsTab({super.key});

  @override
  State<AdminCarsTab> createState() => _AdminCarsTabState();
}

class _AdminCarsTabState extends State<AdminCarsTab> {
  final _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cars',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.deepBlue)),
                    Text('Manage rental vehicles',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.lightTextSecondary)),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showAddCarSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Car'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _adminService.streamAllCars(),
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
                final cars = snap.data ?? [];
                if (cars.isEmpty) {
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
                          child: const Icon(
                              Icons.directions_car_outlined,
                              size: 44,
                              color: AppTheme.earthBrown),
                        ),
                        const SizedBox(height: 16),
                        const Text('No cars yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepBlue)),
                        const SizedBox(height: 8),
                        const Text('Add your first rental car.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.lightTextSecondary)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddCarSheet(context),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Car'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: cars.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _CarCard(
                    car: cars[i],
                    onDelete: () => _confirmDelete(ctx, cars[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext ctx, Map<String, dynamic> car) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Car'),
        content: Text(
            'Are you sure you want to delete "${car['name'] ?? 'this car'}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && ctx.mounted) {
      await _adminService.deleteCar(car['id'] as String);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('Car deleted.'),
          backgroundColor: AppTheme.primaryOrange,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _showAddCarSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddCarSheet(),
    );
  }
}

// ── Car card ──────────────────────────────────────────────────────────────────

class _CarCard extends StatelessWidget {
  const _CarCard({required this.car, required this.onDelete});

  final Map<String, dynamic> car;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageUrl = car['image'] as String? ?? '';

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
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 90,
              height: 100,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _carPlaceholder())
                  : _carPlaceholder(),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car['brand'] ?? ''} ${car['name'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.deepBlue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(Icons.location_on_rounded,
                          car['city'] as String? ?? '—',
                          AppTheme.primaryOrange),
                      _buildInfoChip(Icons.attach_money_rounded,
                          '\$${car['pricePerDay']}/day',
                          AppTheme.oasisGreen),
                      _buildInfoChip(Icons.people_rounded,
                          '${car['seats']} seats',
                          AppTheme.deepBlue),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${car['transmission'] ?? ''} · ${car['fuel'] ?? ''}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.lightTextSecondary),
                  ),
                ],
              ),
            ),
          ),

          // Delete
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _carPlaceholder() => Container(
        color: AppTheme.sandBeige,
        child: const Center(
          child: Icon(Icons.directions_car_outlined,
              color: AppTheme.earthBrown, size: 36),
        ),
      );
}

// ── Add car bottom sheet ──────────────────────────────────────────────────────

class _AddCarSheet extends StatefulWidget {
  const _AddCarSheet();

  @override
  State<_AddCarSheet> createState() => _AddCarSheetState();
}

class _AddCarSheetState extends State<_AddCarSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController(text: '4');
  final _luggageCtrl = TextEditingController(text: '2');
  final _cityCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _companyIdCtrl = TextEditingController();
  final _companyEmailCtrl = TextEditingController();
  final _companyPhoneCtrl = TextEditingController();
  String _transmission = 'Automatic';
  String _fuel = 'Petrol';
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _brandCtrl, _imageCtrl, _priceCtrl, _seatsCtrl,
      _luggageCtrl, _cityCtrl, _companyCtrl, _companyIdCtrl,
      _companyEmailCtrl, _companyPhoneCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final car = Car(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        brand: _brandCtrl.text.trim(),
        image: _imageCtrl.text.trim(),
        pricePerDay: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        seats: int.tryParse(_seatsCtrl.text.trim()) ?? 4,
        luggage: int.tryParse(_luggageCtrl.text.trim()) ?? 2,
        city: _cityCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        companyId: _companyIdCtrl.text.trim(),
        companyEmail: _companyEmailCtrl.text.trim(),
        companyPhone: _companyPhoneCtrl.text.trim(),
        transmission: _transmission,
        fuel: _fuel,
        rating: 0,
      );
      await CarFirestoreService.addCar(car);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Car added successfully!'),
          backgroundColor: AppTheme.oasisGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_car_rounded,
                        color: AppTheme.primaryOrange, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add New Car',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.deepBlue)),
                      Text('Fill in the vehicle details',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.lightTextSecondary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _field(_nameCtrl, 'Car Name',
                  Icons.directions_car_rounded, required: true),
              const SizedBox(height: 12),
              _field(_brandCtrl, 'Brand',
                  Icons.branding_watermark_rounded, required: true),
              const SizedBox(height: 12),
              _field(_imageCtrl, 'Image URL', Icons.image_rounded),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _field(_priceCtrl, 'Price/Day (\$)',
                        Icons.attach_money_rounded,
                        required: true,
                        inputType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_cityCtrl, 'City',
                        Icons.location_on_rounded, required: true)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _field(_seatsCtrl, 'Seats',
                        Icons.event_seat_rounded,
                        inputType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_luggageCtrl, 'Luggage',
                        Icons.luggage_rounded,
                        inputType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _transmission,
                    decoration: const InputDecoration(
                        labelText: 'Transmission',
                        prefixIcon:
                            Icon(Icons.settings_rounded, size: 20)),
                    items: ['Automatic', 'Manual']
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _transmission = v ?? 'Automatic'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fuel,
                    decoration: const InputDecoration(
                        labelText: 'Fuel',
                        prefixIcon: Icon(Icons.local_gas_station_rounded,
                            size: 20)),
                    items: ['Petrol', 'Diesel', 'Electric', 'Hybrid']
                        .map((f) =>
                            DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _fuel = v ?? 'Petrol'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _field(_companyCtrl, 'Rental Company',
                  Icons.business_rounded),
              const SizedBox(height: 12),
              _field(_companyEmailCtrl, 'Company Email',
                  Icons.email_outlined),
              const SizedBox(height: 12),
              _field(_companyPhoneCtrl, 'Company Phone',
                  Icons.phone_outlined,
                  inputType: TextInputType.phone),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saving…' : 'Add Car'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      validator: required
          ? (v) => (v == null || v.isEmpty) ? '$label is required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
