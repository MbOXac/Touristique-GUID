import '../models/favorite_place.dart';
import '../models/top_rated_place.dart';
import '../models/trip_memory.dart';

class MockDataService {


  static List<FavoritePlace> getFavoritePlaces() => [
        FavoritePlace(id: 'f1', name: 'Riad Merzouga', category: 'hotel', imagePath: 'assets/images/destination_2.jpg', rating: 4.8, address: 'Merzouga Village, Errachidia'),
        FavoritePlace(id: 'f2', name: 'Kasbah du Toubkal', category: 'monument', imagePath: 'assets/images/destination_1.jpg', rating: 4.9, address: 'Draa Valley, Ouarzazate'),
        FavoritePlace(id: 'f3', name: 'Café des Dunes', category: 'restaurant', imagePath: 'assets/images/destination_2.jpg', rating: 4.6, address: 'Hassilabied, Merzouga'),
        FavoritePlace(id: 'f4', name: 'Todra Gorge Trek', category: 'activity', imagePath: 'assets/images/destination_3.jpg', rating: 4.7, address: 'Tinghir Province'),
        FavoritePlace(id: 'f5', name: 'Oasis Gardens', category: 'activity', imagePath: 'assets/images/destination_4.jpg', rating: 4.5, address: 'Tinghir, Souss-Massa'),
        FavoritePlace(id: 'f6', name: 'Restaurant Tagine', category: 'restaurant', imagePath: 'assets/images/destination_1.jpg', rating: 4.4, address: 'Ouarzazate Medina'),
      ];

  static List<TopRatedPlace> getTopRatedPlaces() => const [
        TopRatedPlace(id: 't1', name: 'Erg Chebbi', rating: 4.9, reviewCount: 1240, category: 'Landmark', imagePath: 'assets/images/destination_2.jpg', description: 'Iconic golden dunes rising up to 150m, perfect for camel treks and stargazing.', distance: '340 km'),
        TopRatedPlace(id: 't2', name: 'Kasbah Aït Benhaddou', rating: 4.9, reviewCount: 980, category: 'Heritage', imagePath: 'assets/images/destination_1.jpg', description: 'UNESCO World Heritage Site and iconic backdrop for many Hollywood films.', distance: '120 km'),
        TopRatedPlace(id: 't3', name: 'Todra Gorge', rating: 4.7, reviewCount: 756, category: 'Nature', imagePath: 'assets/images/destination_3.jpg', description: '300m limestone canyon carved by the Todra River, paradise for climbers.', distance: '175 km'),
        TopRatedPlace(id: 't4', name: 'Tinghir Oasis', rating: 4.6, reviewCount: 543, category: 'Nature', imagePath: 'assets/images/destination_4.jpg', description: 'Lush palm groves irrigated by ancient khettara channels in the valley.', distance: '160 km'),
      ];

  static List<TripMemory> getTripMemories() => [
        TripMemory(id: 'm1', title: 'Sahara Sunrise', photos: ['assets/images/destination_2.jpg', 'assets/images/destination_2.jpg'], date: DateTime(2024, 3, 15), description: 'Woke up at 4am to catch the most incredible sunrise over the Erg Chebbi dunes. Worth every minute!', mood: '🌅', location: 'Merzouga, Errachidia'),
        TripMemory(id: 'm2', title: 'Todra Gorge Hike', photos: ['assets/images/destination_3.jpg', 'assets/images/destination_4.jpg'], date: DateTime(2024, 3, 12), description: 'Hiked through the stunning 300m limestone walls. Met amazing local climbers along the way.', mood: '🏔️', location: 'Tinghir Province'),
        TripMemory(id: 'm3', title: 'Kasbah Discovery', photos: ['assets/images/destination_1.jpg', 'assets/images/destination_1.jpg'], date: DateTime(2024, 3, 10), description: 'Explored ancient mud-brick kasbahs. The history and architecture is breathtaking.', mood: '🏛️', location: 'Draa Valley'),
      ];


}