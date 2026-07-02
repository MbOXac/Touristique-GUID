import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/gallery_item.dart';
import '../models/gallery_collection.dart';
import 'cloudinary_service.dart';

class GalleryService {
  static final GalleryService _instance = GalleryService._internal();
  factory GalleryService() => _instance;
  GalleryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinary = CloudinaryService();

  // Collections
  CollectionReference get _galleryCollection => _firestore.collection('gallery');
  CollectionReference get _collectionsCollection => _firestore.collection('collections');

  String? get currentUserId => _auth.currentUser?.uid;
  String get currentUserName => _auth.currentUser?.displayName ?? 'Anonymous';
  String get currentUserAvatar => _auth.currentUser?.photoURL ?? '';

  // =====================
  // 📸 UPLOAD IMAGE
  // =====================
  // In gallery_service.dart - Update the uploadImage method

Future<GalleryItem?> uploadImage({
  required XFile image,
  required String title,
  String description = '',
  required String category,
  List<String> tags = const [],
  String? location,
}) async {
  try {
    if (currentUserId == null) throw 'User not logged in';

    final id = const Uuid().v4();

    // Upload to Cloudinary (works with XFile path on both platforms)
    final cloudinaryResponse = await _cloudinary.uploadImage(
      image, // 🆕 Pass XFile instead of File
      folder: 'touristique_gallery/$currentUserId',
      context: {
        'title': title,
        'category': category,
        'uploadedBy': currentUserId,
      },
    );

    if (cloudinaryResponse == null) {
      throw 'Failed to upload image';
    }

    // Get URLs
    final imageUrl = cloudinaryResponse.secureUrl;
    final publicId = cloudinaryResponse.publicId;
    final thumbnailUrl = _cloudinary.getThumbnailUrl(publicId);

    // Create gallery item
    final item = GalleryItem(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      category: category,
      uploadedBy: currentUserId!,
      uploaderName: currentUserName,
      uploaderAvatar: currentUserAvatar,
      tags: tags,
      location: location,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    await _galleryCollection.doc(id).set({
      ...item.toFirestore(),
      'publicId': publicId,
    });

    return item;
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}

  // =====================
  // 📷 PICK IMAGE
  // =====================
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return await _picker.pickImage(source: source, imageQuality: 80);
  }

  // =====================
  // 📖 GET ALL IMAGES
  // =====================
  Stream<List<GalleryItem>> getAllImages({String? category}) {
    Query query = _galleryCollection.orderBy('createdAt', descending: true);
    
    if (category != null && category != 'all') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => GalleryItem.fromFirestore(doc)).toList();
    });
  }

  // =====================
  // 🔥 GET TRENDING IMAGES
  // =====================
  Stream<List<GalleryItem>> getTrendingImages({int limit = 20}) {
    return _galleryCollection
        .orderBy('likes', descending: true)
        .orderBy('views', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GalleryItem.fromFirestore(doc)).toList();
    });
  }

  // =====================
  // 🆕 GET RECENT IMAGES
  // =====================
  Stream<List<GalleryItem>> getRecentImages({int limit = 20}) {
    return _galleryCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GalleryItem.fromFirestore(doc)).toList();
    });
  }

  // =====================
  // 👤 GET USER IMAGES
  // =====================
  Stream<List<GalleryItem>> getUserImages(String userId) {
    return _galleryCollection
        .where('uploadedBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GalleryItem.fromFirestore(doc)).toList();
    });
  }

  // =====================
  // ❤️ TOGGLE LIKE
  // =====================
  Future<void> toggleLike(String imageId) async {
    if (currentUserId == null) return;

    final docRef = _galleryCollection.doc(imageId);
    final doc = await docRef.get();
    
    if (!doc.exists) return;

    final item = GalleryItem.fromFirestore(doc);
    final isLiked = item.isLikedBy(currentUserId!);

    if (isLiked) {
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([currentUserId]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([currentUserId]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  // =====================
  // 💾 TOGGLE SAVE
  // =====================
  Future<void> toggleSave(String imageId) async {
    if (currentUserId == null) return;

    final docRef = _galleryCollection.doc(imageId);
    final doc = await docRef.get();
    
    if (!doc.exists) return;

    final item = GalleryItem.fromFirestore(doc);
    final isSaved = item.isSavedBy(currentUserId!);

    if (isSaved) {
      await docRef.update({
        'savedBy': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      await docRef.update({
        'savedBy': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  // =====================
  // 📊 INCREMENT VIEWS
  // =====================
  Future<void> incrementViews(String imageId) async {
    await _galleryCollection.doc(imageId).update({
      'views': FieldValue.increment(1),
    });
  }

  // =====================
  // 💬 GET SAVED IMAGES
  // =====================
  Stream<List<GalleryItem>> getSavedImages() {
    if (currentUserId == null) return Stream.value([]);

    return _galleryCollection
        .where('savedBy', arrayContains: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GalleryItem.fromFirestore(doc)).toList();
    });
  }

  // =====================
  // 🔍 SEARCH IMAGES
  // =====================
  Stream<List<GalleryItem>> searchImages(String query) {
    return _galleryCollection
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GalleryItem.fromFirestore(doc))
          .where((item) =>
              item.title.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase()) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  // =====================
  // 🏷️ GET BY TAG
  // =====================
  Stream<List<GalleryItem>> getImagesByTag(String tag) {
    return _galleryCollection
        .where('tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GalleryItem.fromFirestore(doc)).toList();
    });
  }

  // =====================
  // 🗑️ DELETE IMAGE
  // =====================
  Future<bool> deleteImage(String imageId) async {
    try {
      final doc = await _galleryCollection.doc(imageId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final uploadedBy = data['uploadedBy'];
      
      // Only allow deletion if user owns the image
      if (uploadedBy != currentUserId) return false;

      // Delete from Firestore
      await _galleryCollection.doc(imageId).delete();

      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  // =====================
  // 📂 COLLECTIONS
  // =====================
  Future<GalleryCollection?> createCollection({
    required String name,
    String description = '',
  }) async {
    if (currentUserId == null) return null;

    try {
      final id = const Uuid().v4();
      final collection = GalleryCollection(
        id: id,
        name: name,
        description: description,
        userId: currentUserId!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _collectionsCollection.doc(id).set(collection.toFirestore());
      return collection;
    } catch (e) {
      print('Create collection error: $e');
      return null;
    }
  }

  Stream<List<GalleryCollection>> getUserCollections() {
    if (currentUserId == null) return Stream.value([]);

    return _collectionsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GalleryCollection.fromFirestore(doc)).toList();
    });
  }

  Future<void> addToCollection(String collectionId, String imageId) async {
    await _collectionsCollection.doc(collectionId).update({
      'imageIds': FieldValue.arrayUnion([imageId]),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> removeFromCollection(String collectionId, String imageId) async {
    await _collectionsCollection.doc(collectionId).update({
      'imageIds': FieldValue.arrayRemove([imageId]),
      'updatedAt': Timestamp.now(),
    });
  }
}