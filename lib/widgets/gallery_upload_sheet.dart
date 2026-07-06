import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

/// Bottom-sheet action menu for picking an image source. Meant to be shown
/// via `showModalBottomSheet(backgroundColor: Colors.transparent, builder: ...)`
/// so the rounded top corners below render cleanly.
class GalleryUploadSheet extends StatelessWidget {
  final Function(ImageSource) onSourceSelected;

  const GalleryUploadSheet({
    super.key,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Wrap(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Image',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
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
                        backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF1ECE3),
                        foregroundColor: theme.textTheme.bodyLarge?.color,
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryOrange),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.titleLarge?.color),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor),
      ),
    );
  }
}