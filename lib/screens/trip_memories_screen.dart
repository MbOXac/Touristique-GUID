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
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Memory – Coming soon!'), behavior: SnackBarBehavior.floating),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Memory'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 88,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title: Text(
                'My Memories',
                style: TextStyle(
                  color: theme.textTheme.headlineLarge?.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(color: theme.scaffoldBackgroundColor),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final memory = _memories[index];
                  return _buildMemoryCard(memory, index == _memories.length - 1);
                },
                childCount: _memories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(TripMemory memory, bool isLast) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                child: Center(child: Text(memory.mood, style: const TextStyle(fontSize: 20))),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark ? AppTheme.darkBorder : AppTheme.sandBeige,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            memory.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(memory.date),
                          style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: AppTheme.primaryOrange),
                        const SizedBox(width: 3),
                        Text(
                          memory.location,
                          style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                        ),
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
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(memory.photos[index], width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      memory.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
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