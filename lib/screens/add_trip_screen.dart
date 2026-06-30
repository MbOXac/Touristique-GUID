import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/trip_service.dart';
import '../theme/app_theme.dart';
import '../models/saved_trip.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hotelController = TextEditingController();
  final _budgetController = TextEditingController();
  final _tripService = TripService();
  final _picker = ImagePicker();

  final List<XFile> _images = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _mood = '✈️';
  String _selectedCountry = '';
  int _travelers = 1;
  double _budget = 0;
  bool _isSaving = false;
  
  final List<TripChecklist> _checklist = [];
  final _checklistController = TextEditingController();

  static const _moods = ['✈️', '🏜️', '🌅', '🏔️', '🏛️', '🐪', '🌴', '🍽️', '❤️'];
  
  static const _countries = [
    'Morocco',
    'Egypt',
    'Tunisia',
    'Algeria',
    'Libya',
    'Sudan',
    'Mauritania',
    'Mali',
    'Senegal',
    'Ivory Coast',
    'Ghana',
    'Nigeria',
    'Kenya',
    'Tanzania',
    'South Africa',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    _hotelController.dispose();
    _budgetController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(
      imageQuality: 45,
      maxWidth: 900,
    );

    if (picked.isEmpty || !mounted) return;

    final remainingSlots = TripService.maxPhotos - _images.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add up to 3 photos on the free Firestore version.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _images.addAll(picked.take(remainingSlots)));
  }

  Future<void> _takePhoto() async {
    if (kIsWeb) return;

    if (_images.length >= TripService.maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add up to 3 photos on the free Firestore version.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 45,
      maxWidth: 900,
    );

    if (photo == null || !mounted) return;
    setState(() => _images.add(photo));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = selected;
        if (_endDate != null && _endDate!.isBefore(selected)) {
          _endDate = selected;
        }
      } else {
        _endDate = selected;
      }
    });
  }

  void _addChecklistItem() {
    final task = _checklistController.text.trim();
    if (task.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task')),
      );
      return;
    }

    setState(() {
      _checklist.add(TripChecklist(task: task, done: false));
      _checklistController.clear();
    });
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    final start = _startDate;
    final end = _endDate ?? _startDate;

    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose trip dates.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a country.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Initialize user collection first
    //  await FirestoreInit.initializeUserCollection();

      await _tripService.createTrip(
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        country: _selectedCountry,
        description: _descriptionController.text.trim(),
        mood: _mood,
        startDate: start,
        endDate: end,
        images: _images,
        travelers: _travelers,
        budget: _budget,
        hotel: _hotelController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip saved successfully! 🎉'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save trip: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Save a Trip')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Text(
                'Create your trip',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Fill in your trip details and save to your Firestore account.',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 24),

              // Trip Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Trip title',
                  hintText: 'Example: Sahara weekend escape',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a trip title'
                    : null,
              ),
              const SizedBox(height: 14),

              // Destination
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Example: Merzouga, Errachidia',
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a destination'
                    : null,
              ),
              const SizedBox(height: 14),

              // Country Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCountry.isEmpty ? null : _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  prefixIcon: Icon(Icons.public_rounded),
                ),
                items: _countries
                    .map((country) => DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCountry = value ?? ''),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a country'
                    : null,
              ),
              const SizedBox(height: 14),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'Start date',
                      value: _startDate == null ? 'Choose' : _formatDate(_startDate!),
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateTile(
                      label: 'End date',
                      value: _endDate == null ? 'Choose' : _formatDate(_endDate!),
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Mood
              DropdownButtonFormField<String>(
                value: _mood,
                decoration: const InputDecoration(
                  labelText: 'Trip mood',
                  prefixIcon: Icon(Icons.emoji_emotions_rounded),
                ),
                items: _moods
                    .map((mood) => DropdownMenuItem(
                          value: mood,
                          child: Text(mood, style: const TextStyle(fontSize: 22)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _mood = value ?? _mood),
              ),
              const SizedBox(height: 14),

              // Travelers & Budget Row
              Row(
                children: [
                  // Travelers
                  Expanded(
                    child: _NumberField(
                      label: 'Travelers',
                      value: _travelers,
                      onChanged: (value) => setState(() => _travelers = value),
                      min: 1,
                      max: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Budget
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                        hintText: '0',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() => _budget = double.tryParse(value) ?? 0);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Hotel
              TextFormField(
                controller: _hotelController,
                decoration: const InputDecoration(
                  labelText: 'Hotel / Accommodation (optional)',
                  hintText: 'Example: Riad Atlas Dreams',
                  prefixIcon: Icon(Icons.hotel_rounded),
                ),
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Trip notes / plan',
                  hintText: 'Write your plan, places to visit, highlights...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Write a short trip note'
                    : null,
              ),
              const SizedBox(height: 20),

              // Checklist Section
              _ChecklistSection(
                checklist: _checklist,
                controller: _checklistController,
                onAdd: _addChecklistItem,
                onRemove: (index) => setState(() => _checklist.removeAt(index)),
                onToggle: (index) {
                  setState(() {
                    final item = _checklist[index];
                    _checklist[index] = TripChecklist(
                      task: item.task,
                      done: !item.done,
                    );
                  });
                },
              ),
              const SizedBox(height: 20),

              // Photo Picker
              _PhotoPicker(
                images: _images,
                onPickImages: _pickImages,
                onTakePhoto: _takePhoto,
                onRemove: (index) => setState(() => _images.removeAt(index)),
              ),
              const SizedBox(height: 26),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTrip,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(_isSaving ? 'Saving trip...' : 'Save Trip'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ WIDGETS ============

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;
  final int min;
  final int max;

  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: value > min ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove_rounded),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                  icon: const Icon(Icons.add_rounded),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppTheme.primaryOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: theme.textTheme.titleLarge?.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistSection extends StatelessWidget {
  final List<TripChecklist> checklist;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final void Function(int) onToggle;

  const _ChecklistSection({
    required this.checklist,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Checklist (Optional)',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add task...',
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: onAdd,
              child: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (checklist.isEmpty)
          Text(
            'No tasks yet',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Column(
            children: List.generate(
              checklist.length,
              (index) {
                final item = checklist[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: item.done,
                        onChanged: (_) => onToggle(index),
                      ),
                      title: Text(
                        item.task,
                        style: TextStyle(
                          decoration: item.done ? TextDecoration.lineThrough : null,
                          color: item.done
                              ? theme.textTheme.bodyMedium?.color
                              : theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        onPressed: () => onRemove(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPickImages;
  final VoidCallback onTakePhoto;
  final void Function(int index) onRemove;

  const _PhotoPicker({
    required this.images,
    required this.onPickImages,
    required this.onTakePhoto,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Trip photos',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              '${images.length} selected',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickImages,
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Gallery'),
              ),
            ),
            if (!kIsWeb) ...[
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTakePhoto,
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (images.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add up to 3 photos from phone gallery, camera, or file picker.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _PickedImageTile(
                image: images[index],
                onRemove: () => onRemove(index),
              ),
            ),
          ),
      ],
    );
  }
}

class _PickedImageTile extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _PickedImageTile({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 105,
                height: 105,
                color: Theme.of(context).cardColor,
                child: snapshot.hasData
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}