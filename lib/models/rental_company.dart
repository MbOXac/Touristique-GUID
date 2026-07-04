class RentalCompany {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double rating;
  final List<String> cities;

  const RentalCompany({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rating,
    required this.cities,
  });

  factory RentalCompany.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return RentalCompany(
      id: docId,
      name: data['name'] ?? 'Unknown Company',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      cities: List<String>.from(data['cities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'rating': rating,
      'cities': cities,
    };
  }
}