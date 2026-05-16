class TripMemory {
  final String uid;
  final String id;
  final String title;
  final List<String> photos;
  final DateTime date;
  final String description;
  final String mood; // emoji
  final String location;

  const TripMemory({
    required this.uid,
    required this.id,
    required this.title,
    required this.photos,
    required this.date,
    required this.description,
    required this.mood,
    required this.location,
  });

  factory TripMemory.fromFirestore(Map<String, dynamic> data, String docId) {
    return TripMemory(
      uid: data['uid'] ?? '',
      id: docId,
      title: data['title'] ?? '',
      photos: data['photos'] is List ? List<String>.from(data['photos']) : [],
      date:
          DateTime.tryParse((data['date'] ?? '').toString()) ?? DateTime.now(),
      description: data['description'] ?? '',
      mood: data['mood'] ?? '😊',
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'title': title,
      'photos': photos,
      'date': date.toIso8601String(),
      'description': description,
      'mood': mood,
      'location': location,
    };
  }

  TripMemory copyWith({
    String? uid,
    String? id,
    String? title,
    List<String>? photos,
    DateTime? date,
    String? description,
    String? mood,
    String? location,
  }) {
    return TripMemory(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      title: title ?? this.title,
      photos: photos ?? this.photos,
      date: date ?? this.date,
      description: description ?? this.description,
      mood: mood ?? this.mood,
      location: location ?? this.location,
    );
  }
}
