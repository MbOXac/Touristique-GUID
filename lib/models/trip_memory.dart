class TripMemory {
  final String id;
  final String title;
  final List<String> photos;
  final DateTime date;
  final String description;
  final String mood; // emoji
  final String location;

  const TripMemory({
    required this.id,
    required this.title,
    required this.photos,
    required this.date,
    required this.description,
    required this.mood,
    required this.location,
  });
}
