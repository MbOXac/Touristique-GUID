import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  late final CloudinaryPublic _cloudinary;
  late final String _cloudName;

  void initialize() {
    _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    _cloudinary = CloudinaryPublic(
      _cloudName,
      uploadPreset,
      cache: false,
    );
  }

  // =====================
  // 📤 UPLOAD IMAGE (Works with XFile on Web & Mobile)
  // =====================
  Future<CloudinaryResponse?> uploadImage(
    XFile imageFile, { // 🆕 Changed from File to XFile
    String? folder,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path, // Works on both platforms
          folder: folder ?? 'touristique_gallery',
          resourceType: CloudinaryResourceType.Image,
          context: context,
        ),
      );

      return response;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  // =====================
  // 🖼️ GET OPTIMIZED URL
  // =====================
  String getOptimizedUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    String transformation = 'q_$quality,f_$format';

    if (width != null) transformation += ',w_$width';
    if (height != null) transformation += ',h_$height';

    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformation/$publicId';
  }

  // =====================
  // 📐 GET THUMBNAIL URL
  // =====================
  String getThumbnailUrl(String publicId, {int size = 400}) {
    return getOptimizedUrl(
      publicId,
      width: size,
      height: size,
      quality: 'auto:low',
    );
  }
}