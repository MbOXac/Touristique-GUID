class Car {
  final String id;
  final String name;
  final String brand;
  final String image;
  final double pricePerDay;
  final int seats;
  final String transmission;
  final String fuel;
  final String company;
  final String companyId; // 🆕
  final String companyEmail; // 🆕
  final String companyPhone; // 🆕
  final double rating;
  final int luggage;
  final String city; // 🆕

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuel,
    required this.company,
    required this.companyId,
    required this.companyEmail,
    required this.companyPhone,
    required this.rating,
    required this.luggage,
    required this.city,
  });

  factory Car.fromFirestore(Map<String, dynamic> data, String docId) {
    return Car(
      id: docId,
      name: data['name'] ?? 'Unknown Car',
      brand: data['brand'] ?? '',
      image: data['image'] ?? 'https://via.placeholder.com/400x300',
      pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
      seats: (data['seats'] ?? 4).toInt(),
      transmission: data['transmission'] ?? 'Automatic',
      fuel: data['fuel'] ?? 'Petrol',
      company: data['company'] ?? 'Unknown',
      companyId: data['companyId'] ?? '',
      companyEmail: data['companyEmail'] ?? '',
      companyPhone: data['companyPhone'] ?? '',
      rating: (data['rating'] ?? 4.0).toDouble(),
      luggage: (data['luggage'] ?? 2).toInt(),
      city: data['city'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'image': image,
      'pricePerDay': pricePerDay,
      'seats': seats,
      'transmission': transmission,
      'fuel': fuel,
      'company': company,
      'companyId': companyId,
      'companyEmail': companyEmail,
      'companyPhone': companyPhone,
      'rating': rating,
      'luggage': luggage,
      'city': city,
    };
  }
}