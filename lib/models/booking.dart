enum BookingType { hotel, restaurant, tour, transport }
enum BookingStatus { confirmed, pending, cancelled }

class Booking {
  final String id;
  final BookingType type;
  final String name;
  final DateTime bookingDate;
  final double price;
  final BookingStatus status;
  final String details;

  const Booking({
    required this.id,
    required this.type,
    required this.name,
    required this.bookingDate,
    required this.price,
    required this.status,
    required this.details,
  });
}
