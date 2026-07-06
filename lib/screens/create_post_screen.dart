import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionCtrl = TextEditingController();
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x != null) {
      setState(() => _image = File(x.path));
    }
  }

  void _shareMock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('UI ready ✅ Backend upload comes next')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.sandBeige.withAlpha(110),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: _image == null
                    ? Center(
                        child: Text(
                          'Tap to pick image',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareMock,
                icon: const Icon(Icons.send),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}