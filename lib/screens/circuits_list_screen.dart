import 'package:flutter/material.dart';
import '../models/circuit.dart';
import '../services/circuit_service.dart' as circuit_service;
import '../services/circuit_mock_data.dart'; 
import '../theme/app_theme.dart';
import '../widgets/circuit_card.dart';
import '../widgets/empty_state.dart';
import 'circuit_map_screen.dart';

enum CircuitSort { popular, priceLowHigh, priceHighLow, duration }

class CircuitsListScreen extends StatefulWidget {
  const CircuitsListScreen({super.key});

  @override
  State<CircuitsListScreen> createState() => _CircuitsListScreenState();
}

class _CircuitsListScreenState extends State<CircuitsListScreen> {
  final circuit_service.CircuitService _circuitService = circuit_service.CircuitService();
  final TextEditingController _searchController = TextEditingController();

  List<Circuit> _allCircuits = [];
  bool _isLoading = true;
  bool _showSearch = false;
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedDuration = 'Any';
  CircuitSort _sort = CircuitSort.popular;

  final List<Map<String, dynamic>> _types = const [
    {'label': 'All', 'icon': Icons.apps_rounded},
    {'label': 'Desert', 'icon': Icons.wb_sunny_rounded},
    {'label': 'Cultural', 'icon': Icons.account_balance_rounded},
    {'label': 'Adventure', 'icon': Icons.terrain_rounded},
    {'label': 'Mountain', 'icon': Icons.landscape_rounded},
    {'label': 'Oasis', 'icon': Icons.park_rounded},
  ];

  final List<String> _durations = const ['Any', '1-2 Days', '3-5 Days', '6+ Days'];

  @override
  void initState() {
    super.initState();
    _loadCircuits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCircuits() async {
    setState(() => _isLoading = true);
    final circuits = await _circuitService.getAllCircuits();
    if (!mounted) return;
    setState(() {
      _allCircuits = circuits;
      _isLoading = false;
    });
  }

  Future<void> _seedCircuits() async {
    setState(() => _isLoading = true);
    try {
      await CircuitMockData.seedCircuits();
      await _loadCircuits();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample circuits loaded!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load circuits: $e')),
        );
      }
    }
  }

  List<Circuit> get _filtered {
    var list = List<Circuit>.from(_allCircuits);

    // Type
    if (_selectedType != 'All') {
      list = list
          .where((c) => c.type.toLowerCase() == _selectedType.toLowerCase())
          .toList();
    }

    // Duration
    if (_selectedDuration == '1-2 Days') {
      list = list.where((c) => c.durationDays <= 2).toList();
    } else if (_selectedDuration == '3-5 Days') {
      list = list
          .where((c) => c.durationDays >= 3 && c.durationDays <= 5)
          .toList();
    } else if (_selectedDuration == '6+ Days') {
      list = list.where((c) => c.durationDays >= 6).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.titleAr.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.type.toLowerCase().contains(q);
      }).toList();
    }

    // Sort
    switch (_sort) {
      case CircuitSort.popular:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case CircuitSort.priceLowHigh:
        list.sort((a, b) => a.priceMAD.compareTo(b.priceMAD));
        break;
      case CircuitSort.priceHighLow:
        list.sort((a, b) => b.priceMAD.compareTo(a.priceMAD));
        break;
      case CircuitSort.duration:
        list.sort((a, b) => a.durationDays.compareTo(b.durationDays));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Search circuits...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('Circuits'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CircuitMapScreen()),
          );
        },
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.map_rounded),
        label: const Text('Map'),
      ),
      body: Column(
        children: [
          // ─── Type filter chips ──────────────────────────────
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final t = _types[index];
                final label = t['label'] as String;
                final selected = _selectedType == label;
                return ChoiceChip(
                  avatar: Icon(
                    t['icon'] as IconData,
                    size: 16,
                    color: selected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedType = label),
                  selectedColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : theme.textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          // ─── Duration filter row ────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _durations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final d = _durations[index];
                final selected = _selectedDuration == d;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDuration = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.deepBlue
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppTheme.deepBlue
                            : theme.dividerColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ─── List ───────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? _buildShimmerList(theme)
                : RefreshIndicator(
                    color: AppTheme.primaryOrange,
                    onRefresh: _loadCircuits,
                    child: filtered.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
                              EmptyState(
                                icon: Icons.route_rounded,
                                title: _allCircuits.isEmpty
                                    ? 'No circuits yet'
                                    : 'No circuits found',
                                message: _allCircuits.isEmpty
                                    ? 'Load the sample Southeast Morocco circuits to get started.'
                                    : 'Try a different filter, duration or search term.',
                                ctaLabel:
                                    _allCircuits.isEmpty ? 'Load sample circuits' : null,
                                onCta: _allCircuits.isEmpty ? _seedCircuits : null,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) =>
                                CircuitCard(circuit: filtered[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Sort options sheet ─────────────────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        Widget tile(String label, CircuitSort value, IconData icon) {
          final selected = _sort == value;
          return ListTile(
            leading: Icon(icon,
                color: selected
                    ? AppTheme.primaryOrange
                    : theme.iconTheme.color),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected
                    ? AppTheme.primaryOrange
                    : theme.textTheme.titleLarge?.color,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_rounded,
                    color: AppTheme.primaryOrange)
                : null,
            onTap: () {
              setState(() => _sort = value);
              Navigator.pop(ctx);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(120),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort by',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              tile('Popular', CircuitSort.popular, Icons.local_fire_department_rounded),
              tile('Price: Low to High', CircuitSort.priceLowHigh,
                  Icons.arrow_upward_rounded),
              tile('Price: High to Low', CircuitSort.priceHighLow,
                  Icons.arrow_downward_rounded),
              tile('Duration', CircuitSort.duration, Icons.schedule_rounded),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ─── Loading shimmer ────────────────────────────────────────
  Widget _buildShimmerList(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark ? AppTheme.darkCard : Colors.grey.shade300;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _ShimmerBox(
        height: 110,
        color: base,
        highlight: isDark ? Colors.white10 : Colors.white,
      ),
    );
  }
}

/// Simple self-contained shimmer effect (no external package needed).
class _ShimmerBox extends StatefulWidget {
  final double height;
  final Color color;
  final Color highlight;

  const _ShimmerBox({
    required this.height,
    required this.color,
    required this.highlight,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ShaderMask(
            shaderCallback: (bounds) {
              final dx = bounds.width * (_controller.value * 2 - 1);
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  widget.color,
                  widget.highlight.withAlpha(120),
                  widget.color,
                ],
                stops: const [0.25, 0.5, 0.75],
                transform: _SlideGradient(dx),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}
