import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(child: Text('Tap to pick image'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
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