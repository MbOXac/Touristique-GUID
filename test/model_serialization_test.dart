import 'package:flutter_test/flutter_test.dart';
import 'package:touristique_guid/models/booking.dart';
import 'package:touristique_guid/models/favorite_place.dart';
import 'package:touristique_guid/models/trip_memory.dart';

void main() {
  test('FavoritePlace firestore roundtrip', () {
    final favorite = FavoritePlace(
      uid: 'u1',
      id: 'f1',
      name: 'Kasbah',
      category: 'monument',
      imagePath: 'assets/images/destination_1.jpg',
      rating: 4.7,
      address: 'Ouarzazate',
      isFavorited: true,
    );

    final map = favorite.toFirestore();
    final restored = FavoritePlace.fromFirestore(map, 'f1');
    expect(restored.uid, 'u1');
    expect(restored.name, 'Kasbah');
    expect(restored.rating, 4.7);
  });

  test('Booking firestore roundtrip', () {
    final booking = Booking(
      uid: 'u1',
      id: 'b1',
      type: BookingType.tour,
      name: 'Camel Tour',
      bookingDate: DateTime(2026, 1, 2),
      price: 120,
      status: BookingStatus.confirmed,
      details: '2 people',
    );

    final map = booking.toFirestore();
    final restored = Booking.fromFirestore(map, 'b1');
    expect(restored.uid, 'u1');
    expect(restored.type, BookingType.tour);
    expect(restored.status, BookingStatus.confirmed);
    expect(restored.price, 120);
  });

  test('TripMemory firestore roundtrip', () {
    final memory = TripMemory(
      uid: 'u1',
      id: 'm1',
      title: 'Sunrise',
      photos: const ['assets/images/destination_2.jpg'],
      date: DateTime(2026, 1, 3),
      description: 'Great moment',
      mood: '🌅',
      location: 'Merzouga',
    );

    final map = memory.toFirestore();
    final restored = TripMemory.fromFirestore(map, 'm1');
    expect(restored.uid, 'u1');
    expect(restored.title, 'Sunrise');
    expect(restored.photos.length, 1);
    expect(restored.location, 'Merzouga');
  });
}
