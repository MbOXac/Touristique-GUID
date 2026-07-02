import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/circuit.dart';

/// Seeds Firestore with sample circuits for Southeast Morocco.
/// Mirrors the pattern of [MockDataService] but writes to the
/// 'circuits' collection so the rest of the app can read real data.
class CircuitMockData {
  static const String _collectionName = 'circuits';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds the 4 sample circuits to Firestore.
  /// Safe to call multiple times — it clears existing seed docs first
  /// so you never end up with duplicates.
  static Future<void> seedCircuits() async {
    try {
      final collection = _firestore.collection(_collectionName);

      // Clear any previously seeded circuits to avoid duplicates.
      final existing = await collection.get();
      for (final doc in existing.docs) {
        await doc.reference.delete();
      }

      for (final circuit in _sampleCircuits()) {
        await collection.add(circuit.toFirestore());
      }

      debugPrint('Seeded ${_sampleCircuits().length} circuits successfully.');
    } catch (e) {
      debugPrint('Error seeding circuits: $e');
      rethrow;
    }
  }

  static List<Circuit> _sampleCircuits() {
    final now = DateTime.now();

    // ─── Real Southeast Morocco coordinates ──────────────────────
    const errachidia = LatLng(31.9314, -4.4244);
    const meskiSpring = LatLng(31.7517, -4.2856);
    const erfoud = LatLng(31.4368, -4.2331);
    const rissani = LatLng(31.2810, -4.2667);
    const merzouga = LatLng(31.0996, -4.0124);
    const ergChebbi = LatLng(31.1500, -3.9700);
    const khamlia = LatLng(31.0600, -4.0000);

    const ouarzazate = LatLng(30.9189, -6.8934);
    const aitBenhaddou = LatLng(31.0470, -7.1318);
    const skoura = LatLng(31.0606, -6.5536);
    const dadesValley = LatLng(31.3781, -5.9914);
    const todraGorge = LatLng(31.5853, -5.5969);
    const tinghir = LatLng(31.5147, -5.5326);
    const valleyOfRoses = LatLng(31.2167, -6.1000);

    const marrakech = LatLng(31.6295, -7.9811);
    const tichkaPass = LatLng(31.2961, -7.3736);
    const draaValley = LatLng(30.3333, -6.0500);
    const zagora = LatLng(30.3322, -5.8372);
    const midelt = LatLng(32.6852, -4.7350);
    const ifrane = LatLng(33.5228, -5.1106);
    const fes = LatLng(34.0331, -5.0003);

    const zizGorge = LatLng(31.8333, -4.3667);
    const zizValley = LatLng(31.6000, -4.2833);
    const aoufous = LatLng(31.6864, -4.2197);

    return [
      // ════════════════════════════════════════════════════════════
      // CIRCUIT 1 — 3-Day Sahara Desert Adventure
      // ════════════════════════════════════════════════════════════
      Circuit(
        id: '',
        title: '3-Day Sahara Desert Adventure',
        titleAr: 'مغامرة الصحراء الكبرى - 3 أيام',
        description:
            'Journey from Errachidia into the heart of the Sahara. Trek by '
            'camel over the golden dunes of Erg Chebbi, sleep under a blanket '
            'of stars in a Berber camp, and discover the music, fossils and '
            'souks of the deep south.',
        imageUrl:
            'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=1200',
        durationDays: 3,
        priceMAD: 2500,
        difficulty: 'medium',
        type: 'desert',
        rating: 4.8,
        reviewsCount: 214,
        destinationIds: const [],
        meetingPoint: 'Errachidia Bus Station, Av. Moulay Ali Cherif',
        maxGroupSize: 14,
        isAvailable: true,
        startLocation: errachidia,
        endLocation: merzouga,
        routePoints: const [
          errachidia,
          meskiSpring,
          erfoud,
          rissani,
          merzouga,
          ergChebbi,
        ],
        includedServices: const [
          'Transport (4x4)',
          'Desert camp (1 night)',
          'Hotel (1 night)',
          'Camel trek',
          'Local guide',
          'Breakfast & dinner',
        ],
        notIncluded: const [
          'Lunches',
          'Drinks',
          'Personal expenses',
          'Tips',
        ],
        gallery: const [
          'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=800',
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
          'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800',
        ],
        createdAt: now,
        itinerary: const [
          CircuitDay(
            dayNumber: 1,
            title: 'Errachidia → Meski → Erfoud',
            description:
                'Arrive in Errachidia, refresh at the Meski Spring oasis, then '
                'drive to Erfoud and visit a fossil workshop.',
            destinationId: '',
            imageUrl:
                'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
            accommodation: 'Riad in Erfoud',
            meals: 'Dinner',
            distanceKm: 95,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Arrive in Errachidia',
                  description: 'Meet your guide and load the 4x4.',
                  type: 'transport',
                  durationMinutes: 30),
              CircuitActivity(
                  time: '10:30',
                  title: 'Meski Spring (Source Bleue)',
                  description: 'Swim in the natural spring fringed by palms.',
                  type: 'visit',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '13:00',
                  title: 'Drive to Erfoud',
                  description: 'Scenic drive through the Ziz palm belt.',
                  type: 'transport',
                  durationMinutes: 75),
              CircuitActivity(
                  time: '16:00',
                  title: 'Fossil workshop',
                  description:
                      'See 350-million-year-old marine fossils being cut.',
                  type: 'experience',
                  durationMinutes: 60),
            ],
          ),
          CircuitDay(
            dayNumber: 2,
            title: 'Camel Trek into Erg Chebbi',
            description:
                'Trek by camel into the great dunes, try sandboarding, watch '
                'the sunset and enjoy a Berber music night at camp.',
            destinationId: '',
            imageUrl:
                'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=800',
            accommodation: 'Luxury desert camp, Erg Chebbi',
            meals: 'Breakfast, Dinner',
            distanceKm: 60,
            activities: [
              CircuitActivity(
                  time: '10:00',
                  title: 'Drive to Merzouga',
                  type: 'transport',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '16:00',
                  title: 'Camel trek into the dunes',
                  description: 'Ride camels deep into Erg Chebbi.',
                  type: 'experience',
                  durationMinutes: 120),
              CircuitActivity(
                  time: '18:00',
                  title: 'Sandboarding & sunset',
                  type: 'experience',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '20:30',
                  title: 'Berber music under the stars',
                  description: 'Drum circle and tagine dinner at camp.',
                  type: 'experience',
                  durationMinutes: 120),
            ],
          ),
          CircuitDay(
            dayNumber: 3,
            title: 'Sunrise · Khamlia · Rissani',
            description:
                'Catch sunrise over the dunes, hear Gnawa music in Khamlia, '
                'and explore the historic souk of Rissani before returning.',
            destinationId: '',
            imageUrl:
                'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800',
            accommodation: 'Return / end of tour',
            meals: 'Breakfast',
            distanceKm: 70,
            activities: [
              CircuitActivity(
                  time: '06:00',
                  title: 'Sunrise over Erg Chebbi',
                  type: 'experience',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '09:30',
                  title: 'Khamlia village — Gnawa music',
                  type: 'experience',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '11:30',
                  title: 'Rissani souk',
                  description: 'Wander the labyrinthine market.',
                  type: 'visit',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '14:00',
                  title: 'Return transfer',
                  type: 'transport',
                  durationMinutes: 90),
            ],
          ),
        ],
      ),

      // ════════════════════════════════════════════════════════════
      // CIRCUIT 2 — 5-Day Kasbah & Valley Trail
      // ════════════════════════════════════════════════════════════
      Circuit(
        id: '',
        title: '5-Day Kasbah & Valley Trail',
        titleAr: 'درب القصبات والوديان - 5 أيام',
        description:
            'A gentle cultural journey along the Valley of a Thousand Kasbahs. '
            'Walk through the UNESCO ksar of Ait Benhaddou, breathe the rose '
            'gardens of the Dades, and stand beneath the towering walls of '
            'Todra Gorge.',
        imageUrl:
            'https://images.unsplash.com/photo-1489493887464-892be6d1daae?w=1200',
        durationDays: 5,
        priceMAD: 4200,
        difficulty: 'easy',
        type: 'cultural',
        rating: 4.7,
        reviewsCount: 168,
        destinationIds: const [],
        meetingPoint: 'Ouarzazate Airport (OZZ) Arrivals Hall',
        maxGroupSize: 12,
        isAvailable: true,
        startLocation: ouarzazate,
        endLocation: tinghir,
        routePoints: const [
          ouarzazate,
          aitBenhaddou,
          skoura,
          valleyOfRoses,
          dadesValley,
          todraGorge,
          tinghir,
        ],
        includedServices: const [
          'Transport (minibus)',
          'Hotels (4 nights)',
          'Professional guide',
          'Breakfast & dinner',
          'Monument entries',
        ],
        notIncluded: const [
          'Lunches',
          'Drinks',
          'Tips',
          'Travel insurance',
        ],
        gallery: const [
          'https://images.unsplash.com/photo-1489493887464-892be6d1daae?w=800',
          'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800',
          'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',
        ],
        createdAt: now,
        itinerary: const [
          CircuitDay(
            dayNumber: 1,
            title: 'Ouarzazate — Gateway to the Desert',
            description:
                'Visit the Atlas Film Studios and the restored Kasbah '
                'Taourirt in the film capital of Morocco.',
            imageUrl:
                'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800',
            accommodation: 'Hotel in Ouarzazate',
            meals: 'Dinner',
            distanceKm: 10,
            activities: [
              CircuitActivity(
                  time: '14:00',
                  title: 'Atlas Film Studios',
                  type: 'visit',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '16:30',
                  title: 'Kasbah Taourirt',
                  type: 'visit',
                  durationMinutes: 75),
            ],
          ),
          CircuitDay(
            dayNumber: 2,
            title: 'Ait Benhaddou (UNESCO)',
            description:
                'Cross the river and walk up through the ancient ksar, a set '
                'for countless films.',
            imageUrl:
                'https://images.unsplash.com/photo-1489493887464-892be6d1daae?w=800',
            accommodation: 'Guesthouse near Ait Benhaddou',
            meals: 'Breakfast, Dinner',
            distanceKm: 32,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Drive to Ait Benhaddou',
                  type: 'transport',
                  durationMinutes: 45),
              CircuitActivity(
                  time: '10:00',
                  title: 'Walk through the ancient ksar',
                  type: 'hike',
                  durationMinutes: 150),
              CircuitActivity(
                  time: '13:00',
                  title: 'Lunch with a view',
                  type: 'meal',
                  durationMinutes: 60),
            ],
          ),
          CircuitDay(
            dayNumber: 3,
            title: 'Valley of Roses & Skoura',
            description:
                'Drive through the Valley of Roses, stroll the Skoura palm '
                'grove and tour the photogenic Kasbah Amridil.',
            imageUrl:
                'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',
            accommodation: 'Kasbah hotel in Skoura',
            meals: 'Breakfast, Dinner',
            distanceKm: 95,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Valley of Roses',
                  type: 'visit',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '12:00',
                  title: 'Skoura palm grove walk',
                  type: 'hike',
                  durationMinutes: 75),
              CircuitActivity(
                  time: '15:00',
                  title: 'Kasbah Amridil',
                  type: 'visit',
                  durationMinutes: 60),
            ],
          ),
          CircuitDay(
            dayNumber: 4,
            title: 'Dades Gorge',
            description:
                'Marvel at the "monkey fingers" rock formations and take in '
                'the famous switchback panoramic viewpoint.',
            imageUrl:
                'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800',
            accommodation: 'Hotel in Dades Valley',
            meals: 'Breakfast, Dinner',
            distanceKm: 110,
            activities: [
              CircuitActivity(
                  time: '09:30',
                  title: 'Monkey Fingers rock',
                  type: 'visit',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '11:30',
                  title: 'Dades switchbacks viewpoint',
                  type: 'visit',
                  durationMinutes: 45),
              CircuitActivity(
                  time: '16:00',
                  title: 'Sunset over the gorge',
                  type: 'free_time',
                  durationMinutes: 60),
            ],
          ),
          CircuitDay(
            dayNumber: 5,
            title: 'Todra Gorge & Tinghir',
            description:
                'Hike between the 300m canyon walls of Todra Gorge then '
                'explore the lush Tinghir oasis.',
            imageUrl:
                'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',
            accommodation: 'End of tour in Tinghir',
            meals: 'Breakfast',
            distanceKm: 70,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Hike Todra canyon walls',
                  type: 'hike',
                  durationMinutes: 120),
              CircuitActivity(
                  time: '12:30',
                  title: 'Tinghir oasis walk',
                  type: 'hike',
                  durationMinutes: 90),
            ],
          ),
        ],
      ),

      // ════════════════════════════════════════════════════════════
      // CIRCUIT 3 — 7-Day Grand South Morocco
      // ════════════════════════════════════════════════════════════
      Circuit(
        id: '',
        title: '7-Day Grand South Morocco',
        titleAr: 'الجنوب الكبير - 7 أيام',
        description:
            'The ultimate crossing of southern Morocco: over the High Atlas, '
            'down the Draa Valley to Zagora, across the Sahara at Merzouga, '
            'and up through the cedar forests of the Middle Atlas to Fes.',
        imageUrl:
            'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=1200',
        durationDays: 7,
        priceMAD: 6800,
        difficulty: 'hard',
        type: 'adventure',
        rating: 4.9,
        reviewsCount: 142,
        destinationIds: const [],
        meetingPoint: 'Marrakech, Jemaa el-Fnaa (north side)',
        maxGroupSize: 10,
        isAvailable: true,
        startLocation: marrakech,
        endLocation: fes,
        routePoints: const [
          marrakech,
          tichkaPass,
          ouarzazate,
          draaValley,
          zagora,
          merzouga,
          erfoud,
          midelt,
          ifrane,
          fes,
        ],
        includedServices: const [
          'Transport (4x4)',
          'Hotels (5 nights)',
          'Desert camp (1 night)',
          'Camel trek',
          'Expert guide',
          'Breakfast & dinner',
        ],
        notIncluded: const [
          'Lunches',
          'Drinks',
          'International flights',
          'Tips',
          'Insurance',
        ],
        gallery: const [
          'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=800',
          'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800',
          'https://images.unsplash.com/photo-1531219432768-9f540ce91ef8?w=800',
        ],
        createdAt: now,
        itinerary: const [
          CircuitDay(
            dayNumber: 1,
            title: 'Marrakech → Tichka → Ouarzazate',
            description:
                'Cross the High Atlas via the Tizi n\'Tichka pass, stopping '
                'at Ait Benhaddou before reaching Ouarzazate.',
            imageUrl:
                'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=800',
            accommodation: 'Hotel in Ouarzazate',
            meals: 'Dinner',
            distanceKm: 195,
            activities: [
              CircuitActivity(
                  time: '08:00',
                  title: 'Depart Marrakech',
                  type: 'transport',
                  durationMinutes: 120),
              CircuitActivity(
                  time: '11:00',
                  title: 'Tizi n\'Tichka pass (2260m)',
                  type: 'visit',
                  durationMinutes: 45),
              CircuitActivity(
                  time: '14:00',
                  title: 'Ait Benhaddou stop',
                  type: 'visit',
                  durationMinutes: 90),
            ],
          ),
          CircuitDay(
            dayNumber: 2,
            title: 'Ouarzazate → Draa Valley → Zagora',
            description:
                'Follow the palm-lined Draa Valley south to Zagora, the '
                'gateway to the Sahara.',
            imageUrl:
                'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800',
            accommodation: 'Riad in Zagora',
            meals: 'Breakfast, Dinner',
            distanceKm: 165,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Draa Valley palm groves',
                  type: 'visit',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '13:00',
                  title: 'Agdz kasbah stop',
                  type: 'visit',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '17:00',
                  title: '"Timbuktu 52 days" sign',
                  type: 'experience',
                  durationMinutes: 30),
            ],
          ),
          CircuitDay(
            dayNumber: 3,
            title: 'Zagora → Rissani → Merzouga',
            description:
                'Long desert drive east to Merzouga and the dunes of Erg '
                'Chebbi, with a stop at the Rissani souk.',
            imageUrl:
                'https://images.unsplash.com/photo-1531219432768-9f540ce91ef8?w=800',
            accommodation: 'Desert camp, Erg Chebbi',
            meals: 'Breakfast, Dinner',
            distanceKm: 360,
            activities: [
              CircuitActivity(
                  time: '08:00',
                  title: 'Drive towards Tafilalet',
                  type: 'transport',
                  durationMinutes: 240),
              CircuitActivity(
                  time: '14:00',
                  title: 'Rissani souk & lunch',
                  type: 'visit',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '17:00',
                  title: 'Camel trek to camp',
                  type: 'experience',
                  durationMinutes: 90),
            ],
          ),
          CircuitDay(
            dayNumber: 4,
            title: 'Sahara Day — Erg Chebbi',
            description:
                'A full day in the dunes: sunrise, a 4x4 desert circuit, the '
                'Gnawa village of Khamlia and a second night under the stars.',
            imageUrl:
                'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=800',
            accommodation: 'Desert camp, Erg Chebbi',
            meals: 'Breakfast, Dinner',
            distanceKm: 50,
            activities: [
              CircuitActivity(
                  time: '06:00',
                  title: 'Sunrise over the dunes',
                  type: 'experience',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '10:00',
                  title: '4x4 desert circuit & nomad visit',
                  type: 'experience',
                  durationMinutes: 180),
              CircuitActivity(
                  time: '16:00',
                  title: 'Khamlia Gnawa music',
                  type: 'experience',
                  durationMinutes: 60),
            ],
          ),
          CircuitDay(
            dayNumber: 5,
            title: 'Merzouga → Erfoud → Midelt',
            description:
                'Leave the desert, visit the Erfoud fossil workshops and the '
                'Ziz Valley, and climb to the mountain town of Midelt.',
            imageUrl:
                'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
            accommodation: 'Hotel in Midelt',
            meals: 'Breakfast, Dinner',
            distanceKm: 230,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Erfoud fossil workshop',
                  type: 'visit',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '11:00',
                  title: 'Ziz Valley panorama',
                  type: 'visit',
                  durationMinutes: 45),
              CircuitActivity(
                  time: '15:00',
                  title: 'Drive to Midelt',
                  type: 'transport',
                  durationMinutes: 150),
            ],
          ),
          CircuitDay(
            dayNumber: 6,
            title: 'Midelt → Ifrane (Cedar Forests)',
            description:
                'Climb through the Middle Atlas, meet the Barbary macaques of '
                'the Azrou cedar forest, and visit alpine Ifrane.',
            imageUrl:
                'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800',
            accommodation: 'Hotel in Ifrane',
            meals: 'Breakfast, Dinner',
            distanceKm: 130,
            activities: [
              CircuitActivity(
                  time: '10:00',
                  title: 'Azrou cedar forest & macaques',
                  type: 'visit',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '14:00',
                  title: 'Ifrane "little Switzerland"',
                  type: 'visit',
                  durationMinutes: 60),
            ],
          ),
          CircuitDay(
            dayNumber: 7,
            title: 'Ifrane → Fes',
            description:
                'Descend to Fes and end the journey at the gates of the '
                'world\'s largest living medieval medina.',
            imageUrl:
                'https://images.unsplash.com/photo-1531219432768-9f540ce91ef8?w=800',
            accommodation: 'End of tour in Fes',
            meals: 'Breakfast',
            distanceKm: 65,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Drive to Fes',
                  type: 'transport',
                  durationMinutes: 90),
              CircuitActivity(
                  time: '11:00',
                  title: 'Fes medina viewpoint',
                  type: 'visit',
                  durationMinutes: 60),
            ],
          ),
        ],
      ),

      // ════════════════════════════════════════════════════════════
      // CIRCUIT 4 — 2-Day Oasis Explorer
      // ════════════════════════════════════════════════════════════
      Circuit(
        id: '',
        title: '2-Day Oasis Explorer',
        titleAr: 'مستكشف الواحات - يومان',
        description:
            'A short, easy escape into the Ziz Valley — one of the longest '
            'palm oases on Earth. Marvel at the Ziz Gorge panorama, wander '
            'date-palm farms and shop the local souks of Erfoud.',
        imageUrl:
            'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=1200',
        durationDays: 2,
        priceMAD: 1200,
        difficulty: 'easy',
        type: 'oasis',
        rating: 4.6,
        reviewsCount: 89,
        destinationIds: const [],
        meetingPoint: 'Errachidia, Hotel Kenzi Azghor lobby',
        maxGroupSize: 12,
        isAvailable: true,
        startLocation: errachidia,
        endLocation: erfoud,
        routePoints: const [
          errachidia,
          zizGorge,
          zizValley,
          aoufous,
          erfoud,
        ],
        includedServices: const [
          'Transport (minibus)',
          'Hotel (1 night)',
          'Local guide',
          'Traditional lunch',
          'Breakfast',
        ],
        notIncluded: const [
          'Dinner',
          'Drinks',
          'Tips',
          'Personal expenses',
        ],
        gallery: const [
          'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',
          'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800',
        ],
        createdAt: now,
        itinerary: const [
          CircuitDay(
            dayNumber: 1,
            title: 'Ziz Gorge & Palm Groves',
            description:
                'Take in the Ziz Gorge panorama, walk among the palm groves '
                'and enjoy a traditional lunch with a local family.',
            imageUrl:
                'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',
            accommodation: 'Riad in the Ziz Valley',
            meals: 'Lunch',
            distanceKm: 55,
            activities: [
              CircuitActivity(
                  time: '09:30',
                  title: 'Ziz Gorge panorama',
                  type: 'visit',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '11:30',
                  title: 'Palm grove walk',
                  type: 'hike',
                  durationMinutes: 75),
              CircuitActivity(
                  time: '13:30',
                  title: 'Traditional lunch',
                  type: 'meal',
                  durationMinutes: 90),
            ],
          ),
          CircuitDay(
            dayNumber: 2,
            title: 'Erfoud Fossils & Date Farms',
            description:
                'Discover the marble-fossil workshops of Erfoud, tour the '
                'date-palm farms and browse the colourful local souk.',
            imageUrl:
                'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800',
            accommodation: 'End of tour in Erfoud',
            meals: 'Breakfast',
            distanceKm: 45,
            activities: [
              CircuitActivity(
                  time: '09:00',
                  title: 'Erfoud marble & fossils',
                  type: 'visit',
                  durationMinutes: 75),
              CircuitActivity(
                  time: '11:00',
                  title: 'Date palm farms',
                  type: 'visit',
                  durationMinutes: 60),
              CircuitActivity(
                  time: '12:30',
                  title: 'Local souk',
                  type: 'free_time',
                  durationMinutes: 60),
            ],
          ),
        ],
      ),
    ];
  }
}
