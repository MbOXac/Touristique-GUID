import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingType { hotel, restaurant, tour, transport, activity, car }
enum BookingStatus { confirmed, pending, cancelled }

class Booking {
  final String id;
  final String userId;
  final BookingType type;
  final String name;
  final String imageUrl;
  final DateTime bookingDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final int guests;
  final double price;
  final BookingStatus status;
  final String details;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.imageUrl = '',
    required this.bookingDate,
    this.startDate,
    this.endDate,
    this.guests = 1,
    required this.price,
    required this.status,
    required this.details,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'name': name,
      'imageUrl': imageUrl,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'startDate': startDate != null
          ? Timestamp.fromDate(startDate!)
          : null,
      'endDate': endDate != null
          ? Timestamp.fromDate(endDate!)
          : null,
      'guests': guests,
      'price': price,
      'status': status.name,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Booking.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return Booking(
      id: docId,
      userId: data['userId'] ?? '',
      type: BookingType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BookingType.hotel,
      ),
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      guests: data['guests'] ?? 1,
      price: (data['price'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      details: data['details'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}