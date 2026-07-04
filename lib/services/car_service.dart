import '../models/car.dart';
import 'car_firestore_service.dart';

class CarService {
  // Get cars from Firestore by city
  static Future<List<Car>> searchCars({
    required String cityName,
    required String pickUpDate,
    required String dropOffDate,
  }) async {
    try {
      // First try Firestore
      final firestoreCars =
          await CarFirestoreService.searchCarsByCity(cityName);

      if (firestoreCars.isNotEmpty) {
        print('✅ Found ${firestoreCars.length} cars in Firestore');
        return firestoreCars;
      }

      // TODO: If Firestore empty, try API here
      print('⚠️ No cars in Firestore, will try API later');
      return [];
    } catch (e) {
      print('❌ Error in CarService: $e');
      return [];
    }
  }

  // Get all cities from Firestore
  static Future<List<String>> getAllCities() async {
    return await CarFirestoreService.getAllCities();
  }
}