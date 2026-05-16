enum BookingType { hotel, restaurant, tour, transport }
enum BookingStatus { confirmed, pending, cancelled }

class Booking {
  final String uid;
  final String id;
  final BookingType type;
  final String name;
  final DateTime bookingDate;
  final double price;
  final BookingStatus status;
  final String details;

  const Booking({
    required this.uid,
    required this.id,
    required this.type,
    required this.name,
    required this.bookingDate,
    required this.price,
    required this.status,
    required this.details,
  });

  factory Booking.fromFirestore(Map<String, dynamic> data, String docId) {
    final typeString = (data['type'] ?? 'tour').toString();
    final statusString = (data['status'] ?? 'pending').toString();
    return Booking(
      uid: data['uid'] ?? '',
      id: docId,
      type: BookingType.values.firstWhere(
        (e) => e.name == typeString,
        orElse: () => BookingType.tour,
      ),
      name: data['name'] ?? '',
      bookingDate: DateTime.tryParse((data['bookingDate'] ?? '').toString()) ??
          DateTime.now(),
      price: (data['price'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => BookingStatus.pending,
      ),
      details: data['details'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'type': type.name,
      'name': name,
      'bookingDate': bookingDate.toIso8601String(),
      'price': price,
      'status': status.name,
      'details': details,
    };
  }

  Booking copyWith({
    String? uid,
    String? id,
    BookingType? type,
    String? name,
    DateTime? bookingDate,
    double? price,
    BookingStatus? status,
    String? details,
  }) {
    return Booking(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      bookingDate: bookingDate ?? this.bookingDate,
      price: price ?? this.price,
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }
}
