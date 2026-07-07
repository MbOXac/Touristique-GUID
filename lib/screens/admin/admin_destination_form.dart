import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/destination.dart';
import '../../services/destination_service.dart';
import '../../services/cloudinary_service.dart';
import '../../theme/app_theme.dart';

/// Create / edit form for a destination.
/// Re-uses the existing [DestinationService] and [CloudinaryService].
class AdminDestinationForm extends StatefulWidget {
  /// Pass an existing [Destination] to edit, or null to create.
  final Destination? existing;

  const AdminDestinationForm({super.key, this.existing});

  @override
  State<AdminDestinationForm> createState() => _AdminDestinationFormState();
}

class _AdminDestinationFormState extends State<AdminDestinationForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = DestinationService();
  final _cloudinary = CloudinaryService();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _distanceCtrl;
  late final TextEditingController _tagsCtrl;

  // Existing images (URLs) + new local XFiles to upload
  List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _descCtrl = TextEditingController(text: d?.description ?? '');
    _latCtrl = TextEditingController(text: d?.lat != null ? d!.lat.toString() : '');
    _lngCtrl = TextEditingController(text: d?.lng != null ? d!.lng.toString() : '');
    _distanceCtrl = TextEditingController(text: d?.distance ?? '');
    _tagsCtrl = TextEditingController(text: d?.tags ?? '');
    _existingImageUrls = List.from(d?.imageURLs ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _distanceCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Image picking
  // ─────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _newImages.addAll(picked));
    }
  }

  void _removeExistingImage(int index) =>
      setState(() => _existingImageUrls.removeAt(index));

  void _removeNewImage(int index) =>
      setState(() => _newImages.removeAt(index));

  // ─────────────────────────────────────────────
  //  Save
  // ─────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Upload any new images to Cloudinary
      final uploadedUrls = <String>[];
      for (final xfile in _newImages) {
        final response = await _cloudinary.uploadImage(xfile);
        if (response != null) uploadedUrls.add(response.secureUrl);
      }

      final allUrls = [..._existingImageUrls, ...uploadedUrls];

      final destination = Destination(
        id: widget.existing?.id ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageURLs: allUrls,
        lat: double.tryParse(_latCtrl.text.trim()) ?? 0,
        lng: double.tryParse(_lngCtrl.text.trim()) ?? 0,
        distance: _distanceCtrl.text.trim(),
        tags: _tagsCtrl.text.trim(),
        rating: widget.existing?.rating ?? 0,
        reviewsCount: widget.existing?.reviewsCount ?? 0,
      );

      if (_isEditing) {
        await _service.updateDestination(widget.existing!.id, destination);
      } else {
        await _service.addDestination(destination);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Destination updated successfully!'
                : 'Destination added successfully!'),
            backgroundColor: AppTheme.oasisGreen,
          ),
        );
        Navigator.pop(context);
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Destination' : 'Add Destination'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Images section ───────────────────────────
            Text('Images',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Existing images
                  ..._existingImageUrls.asMap().entries.map((e) =>
                      _ImageThumb.network(
                          url: e.value,
                          onRemove: () => _removeExistingImage(e.key))),
                  // New local images
                  ..._newImages.asMap().entries.map((e) =>
                      _ImageThumb.xfile(
                          xfile: e.value,
                          onRemove: () => _removeNewImage(e.key))),
                  // Add button
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : AppTheme.sandBeige,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              color: AppTheme.primaryOrange, size: 32),
                          SizedBox(height: 4),
                          Text('Add',
                              style: TextStyle(
                                  color: AppTheme.primaryOrange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Fields ──────────────────────────────────
            _field(
              controller: _nameCtrl,
              label: 'Name',
              icon: Icons.place_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            _field(
              controller: _descCtrl,
              label: 'Description',
              icon: Icons.description_rounded,
              maxLines: 4,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Description is required' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: _latCtrl,
                    label: 'Latitude',
                    icon: Icons.my_location_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    controller: _lngCtrl,
                    label: 'Longitude',
                    icon: Icons.my_location_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _field(
              controller: _distanceCtrl,
              label: 'Distance (e.g. 12 km)',
              icon: Icons.straighten_rounded,
            ),
            const SizedBox(height: 14),
            _field(
              controller: _tagsCtrl,
              label: 'Tags (comma separated)',
              icon: Icons.tag_rounded,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(_isEditing ? 'Update Destination' : 'Add Destination'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

// ── Image thumbnail helper ────────────────────────────────────────────────────

class _ImageThumb extends StatelessWidget {
  const _ImageThumb.network({required this.url, required this.onRemove})
      : xfile = null;
  const _ImageThumb.xfile({required this.xfile, required this.onRemove})
      : url = null;

  final String? url;
  final XFile? xfile;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final image = xfile != null
        ? Image.network(xfile!.path, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
        : Image.network(url!, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: image,
        ),
        Positioned(
          top: 0,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
