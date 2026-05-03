class Activity {
  final String id;
  final String name;
  final String description;
  final String category;
  final String duration;
  final String location;
  final String price; // Changed to String to match Firestore "100 DH"
  final String region;

  const Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.duration,
    required this.location,
    required this.price,
    required this.region,
  });

  // Convert Firestore document to Activity object
  factory Activity.fromFirestore(Map<String, dynamic> data, String docId) {
    return Activity(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'nature',
      duration: data['duration'] ?? '',
      location: data['location'] ?? '',
      price: data['price'] ?? '0 DH',
      region: data['region'] ?? '',
    );
  }

  // Convert Activity to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'duration': duration,
      'location': location,
      'price': price,
      'region': region,
    };
  }
}