import 'package:flutter/material.dart';
import '../models/trip_memory.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

class TripMemoriesScreen extends StatefulWidget {
  const TripMemoriesScreen({super.key});

  @override
  State<TripMemoriesScreen> createState() => _TripMemoriesScreenState();
}

class _TripMemoriesScreenState extends State<TripMemoriesScreen> {
  late List<TripMemory> _memories;

  @override
  void initState() {
    super.initState();
    _memories = MockDataService.getTripMemories();
    _memories.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memories'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Memory – Coming soon!'), behavior: SnackBarBehavior.floating),
        ),
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Memory', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _memories.length,
        itemBuilder: (context, index) {
          final memory = _memories[index];
          return _buildMemoryCard(memory, index == _memories.length - 1);
        },
      ),
    );
  }

  Widget _buildMemoryCard(TripMemory memory, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                child: Center(child: Text(memory.mood, style: const TextStyle(fontSize: 20))),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppTheme.sandBeige, margin: const EdgeInsets.symmetric(vertical: 4))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(memory.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.deepBlue))),
                        Text(_formatDate(memory.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: AppTheme.primaryOrange),
                        const SizedBox(width: 3),
                        Text(memory.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: memory.photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(memory.photos[index], width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(memory.description, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
