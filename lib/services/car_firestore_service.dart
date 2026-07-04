import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/rental_company.dart';

class CarFirestoreService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ✅ Search cars by city
  static Future<List<Car>> searchCarsByCity(String city) async {
    try {
      print('🔍 Searching cars in: $city');

      final snapshot = await _firestore
          .collection('cars')
          .where('city', isEqualTo: city)
          .get();

      final cars = snapshot.docs
          .map((doc) => Car.fromFirestore(doc.data(), doc.id))
          .toList();

      print('✅ Found ${cars.length} cars in $city');
      return cars;
    } catch (e) {
      print('❌ Error searching cars: $e');
      return [];
    }
  }

  // ✅ Get all cities with cars
  static Future<List<String>> getAllCities() async {
    try {
      final snapshot = await _firestore.collection('cars').get();

      final cities = snapshot.docs
          .map((doc) => doc['city'] as String)
          .toSet()
          .toList();

      cities.sort();
      print('✅ Found cities: $cities');
      return cities;
    } catch (e) {
      print('❌ Error getting cities: $e');
      return [];
    }
  }

  // ✅ Get company details
  static Future<RentalCompany?> getCompanyDetails(
      String companyId) async {
    try {
      final doc =
          await _firestore.collection('rental_companies').doc(companyId).get();

      if (doc.exists) {
        return RentalCompany.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      print('❌ Error getting company: $e');
    }
    return null;
  }

  // ✅ Add car to Firestore (for testing)
  static Future<void> addCar(Car car) async {
    try {
      await _firestore.collection('cars').doc(car.id).set(car.toMap());
      print('✅ Car added: ${car.name}');
    } catch (e) {
      print('❌ Error adding car: $e');
    }
  }

  // ✅ Add rental company (for testing)
  static Future<void> addRentalCompany(RentalCompany company) async {
    try {
      await _firestore
          .collection('rental_companies')
          .doc(company.id)
          .set(company.toMap());
      print('✅ Company added: ${company.name}');
    } catch (e) {
      print('❌ Error adding company: $e');
    }
  }
}