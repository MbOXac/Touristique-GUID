import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryUploadSheet extends StatelessWidget {
  final Function(ImageSource) onSourceSelected;

  const GalleryUploadSheet({
    super.key,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOption(
                  context,
                  icon: Icons.camera_alt,
                  title: 'Take a Photo',
                  subtitle: 'Use your camera',
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  context,
                  icon: Icons.image,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from your device',
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}