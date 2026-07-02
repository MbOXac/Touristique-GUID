import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/gallery_service.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final GalleryService _galleryService = GalleryService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes; // 🆕 For web preview
  String _selectedCategory = 'destination';
  bool _isUploading = false;

  final List<String> _categories = [
    'destination',
    'food',
    'culture',
    'adventure',
    'nature',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _galleryService.pickImage(source: source);
    if (image != null) {
      // 🆕 Read bytes for web preview
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _webImageBytes = bytes;
        });
      } else {
        setState(() => _selectedImage = image);
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final item = await _galleryService.uploadImage(
        image: _selectedImage!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        tags: tags,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );

      if (item != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
        Navigator.pop(context, item);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            _buildImagePicker(),
            const SizedBox(height: 24),

            // Title
            _buildTextField(
              controller: _titleController,
              label: 'Title *',
              hint: 'Give your image a catchy title',
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Tell the story behind this image',
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Category
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Location
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Where was this taken?',
              maxLines: 1,
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),

            // Tags
            _buildTextField(
              controller: _tagsController,
              label: 'Tags',
              hint: 'Separate with commas (e.g., beach, sunset, travel)',
              maxLines: 2,
              prefixIcon: Icons.local_offer,
            ),
            const SizedBox(height: 32),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadImage,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Upload Image',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _isUploading
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Take a photo'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text('Choose from gallery'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
            style: BorderStyle.solid,
          ),
          color: Colors.grey[100],
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImagePreview(), // 🆕 Cross-platform preview
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select an image',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG (Max 10MB)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // 🆕 Cross-platform image preview widget
  Widget _buildImagePreview() {
    if (kIsWeb) {
      // Web: Use Image.memory with bytes
      if (_webImageBytes != null) {
        return Image.memory(
          _webImageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
      return const Center(child: CircularProgressIndicator());
    } else {
      // Mobile: Use Image.file
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: _categories
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category.replaceFirst(
                          category[0],
                          category[0].toUpperCase(),
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ),
      ],
    );
  }
}