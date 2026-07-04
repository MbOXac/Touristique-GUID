import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// CarImageService patches real Wikimedia Commons image URLs into every
/// car document based on the car's `name` field.
///
/// Instead of using `Special:FilePath` (which redirects and breaks CORS on
/// Flutter Web), we compute the MD5 hash of the filename and build a direct
/// `upload.wikimedia.org` URL.
///
/// Call `await CarImageService.initializeCarImages();` from main.dart once.
class CarImageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Map of exact car `name` values used in sample_data_service.dart →
  /// Wikimedia Commons filename.
  static final Map<String, String> _filenames = {
    // SUVs / 4x4
    'Dacia Duster': '2023_Dacia_Duster_1X7A6302.jpg',
    'Renault Duster': '2023_Dacia_Duster_1X7A6302.jpg',
    'Toyota Land Cruiser': 'TOYOTA_LAND_CRUISER_200_China_(10).jpg',
    'Toyota Prado': 'TOYOTA_LAND_CRUISER_200_China_(10).jpg',
    'Toyota Hilux': 'Toyota_Hilux_Policia_Nacional_Dominicana.jpg',
    'Toyota RAV4': 'Toyota_RAV4_front_20071007.jpg',
    'Mitsubishi Pajero':
        '2002-2006_Mitsubishi_Pajero_(NP)_Exceed_wagon_01.jpg',
    'Mitsubishi L200': '2002_Mitsubishi_L200_4Life_4WD_2.5_Front.jpg',
    'Ford Ranger': 'Ford_Ranger_Raptor_(P703)_DSC_7063.jpg',
    'Jeep Wrangler': '2020_Jeep_Wrangler_Unlimited_Rubicon_front.jpg',
    'Nissan Qashqai': 'Nissan_Qashqai_2015_in_Punta_del_Este.JPG',
    'Nissan X-Trail': 'Nissan_X-Trail_T31_0151.JPG',
    'Kia Sportage': 'Kia_Sportage_III_front_20100918.jpg',
    'Hyundai Tucson': 'Hyundai_Tucson_(NX4)_IMG_3678.jpg',

    // Economy / compact
    'Renault Clio': '2019_Renault_Clio_RS_Line_TCE_Automatic_1.3.jpg',
    'Peugeot 208': 'Peugeot_208_II.jpg',
    'Peugeot 308': 'Peugeot_308_.JPG',
    'Peugeot 3008': 'Peugeot_3008_20090706_front.JPG',
    'Toyota Yaris': 'Toyota_Yaris_II_Facelift_20090517_front.JPG',
    'Toyota Corolla': 'Toyota_Corolla_2016_Model.jpg',
    'Dacia Logan': 'Dacia_Logan_III.jpg',
    'Dacia Sandero': 'Dacia_Sandero_Stepway_III_IMG_3693.jpg',
    'Dacia Sandero Stepway': 'Dacia_Sandero_Stepway_III_IMG_3693.jpg',
    'Hyundai i10': '2022_Hyundai_i10_SE_Connect_MPi_1.0_Front.jpg',
    'Kia Picanto': 'Kia_Picanto_20090906_front.JPG',
    'Citroen C3': '2009_Citroen_C3_Gold_by_Pinko.JPG',
    'Ford Focus': 'Ford_Focus_(42).JPG',
    'Volkswagen Golf': 'Volkswagen_Golf_GLD_1979.jpg',

    // Vans / premium
    'Mercedes Vito': 'MERCEDES-BENZ_VITO_(W447)_China_(5).jpg',
    'Ford Transit Custom': '2014_Ford_Transit_Custom_290_2.2.jpg',
    'BMW X5': 'BMW_X5_xDrive50i_F15.JPG',
  };

  /// Builds a direct Wikimedia Commons image URL from a filename.
  ///
  /// Wikimedia stores files under folders based on the MD5 hash of the
  /// filename. The direct URL format is:
  /// `https://upload.wikimedia.org/wikipedia/commons/{h1}/{h2}/{filename}`
  static String directCommonsUrl(String filename) {
    final digest = md5.convert(utf8.encode(filename)).toString();
    final h1 = digest[0];
    final h2 = digest.substring(0, 2);
    return 'https://upload.wikimedia.org/wikipedia/commons/$h1/$h2/$filename';
  }

  /// Call this from main.dart once, after Firebase is initialized.
  /// It updates every car's `image` field to a direct Wikimedia photo URL
  /// when one exists in [_filenames] and the current image is a placeholder.
  static Future<void> initializeCarImages() async {
    try {
      final snapshot = await _firestore.collection('cars').get();
      print('🖼️ Found ${snapshot.docs.length} cars to check for images');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '';
        final currentImage = (data['image'] as String? ?? '').trim();

        final filename = _filenames[name];
        if (filename == null) {
          print('⚠️ No image mapping for "$name"');
          continue;
        }

        final realUrl = directCommonsUrl(filename);

        // Only update if the current image is missing or a placeholder.
        final isPlaceholder = currentImage.isEmpty ||
            currentImage.contains('placehold.co') ||
            currentImage.contains('via.placeholder') ||
            currentImage.contains('commons.wikimedia.org/wiki/Special:FilePath');

        if (isPlaceholder) {
          await doc.reference.update({'image': realUrl});
          print('✅ Updated image for ${doc.id}: $name');
        } else {
          print('⏩ Skipped ${doc.id}: already has custom image');
        }
      }
      print('🖼️ Car image update complete');
    } catch (e) {
      print('❌ Error updating car images: $e');
    }
  }

  /// Returns the direct image URL for a given car name without writing to
  /// Firestore. Useful if you prefer to resolve images at runtime instead.
  static String? imageUrlFor(String carName) {
    final filename = _filenames[carName];
    return filename == null ? null : directCommonsUrl(filename);
  }
}
