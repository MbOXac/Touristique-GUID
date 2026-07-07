import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/admin_service.dart';
import '../../services/destination_service.dart';
import '../../models/destination.dart';
import '../../theme/app_theme.dart';

/// Admin overview — Warm Desert Luxury style.
/// Hero banner + stat cards + live destination list on the right.
class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  final _adminService = AdminService();
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _adminService.getDashboardStats();
  }

  void _refresh() => setState(() {
        _statsFuture = _adminService.getDashboardStats();
      });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final adminName = user?.displayName ?? user?.email ?? 'Admin';

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: RefreshIndicator(
        color: AppTheme.primaryOrange,
        onRefresh: () async => _refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            // ── Shared left-column content ────────────
            Widget leftContent = SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top bar ──────────────────────
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.deepBlue,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Welcome back, $adminName',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Refresh button
                      _IconAction(
                        icon: Icons.refresh_rounded,
                        onTap: _refresh,
                        tooltip: 'Refresh stats',
                      ),
                      const SizedBox(width: 8),
                      // Admin badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFC1592E),
                              Color(0xFF8B3A1A)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                color: AppTheme.goldAccent, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Hero welcome banner ──────────
                  _HeroBanner(name: adminName),
                  const SizedBox(height: 28),

                  // ── Stat cards ───────────────────
                  const _SectionLabel('At a Glance'),
                  const SizedBox(height: 14),
                  FutureBuilder<Map<String, int>>(
                    future: _statsFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryOrange),
                          ),
                        );
                      }
                      final s = snap.data ?? {};
                      return _StatsRow(stats: s);
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Quick tips ───────────────────
                  const _SectionLabel('Quick Actions'),
                  const SizedBox(height: 14),
                  _QuickTip(
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.goldAccent,
                    title: 'Confirm pending bookings',
                    subtitle:
                        'Open Bookings tab → Pending to review and confirm.',
                  ),
                  const SizedBox(height: 10),
                  _QuickTip(
                    icon: Icons.add_location_alt_rounded,
                    color: AppTheme.primaryOrange,
                    title: 'Add new destinations',
                    subtitle:
                        'Destinations tab → + Add to create a new entry with photos.',
                  ),
                  const SizedBox(height: 10),
                  _QuickTip(
                    icon: Icons.manage_accounts_rounded,
                    color: AppTheme.deepBlue,
                    title: 'Manage admin roles',
                    subtitle:
                        'Set users/{uid}/role = "admin" in Firebase Console.',
                  ),
                  const SizedBox(height: 24),

                  // ── Destinations (mobile only) ────
                  if (!isWide) ...
                  [
                    const Divider(height: 1, color: AppTheme.lightBorder),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.lightBorder),
                        ),
                        child: const _DestinationsSidebar(shrinkWrap: true),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );

            if (isWide) {
              // ── Wide layout: side-by-side ─────────
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: leftContent),
                  // Right: destinations sidebar
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        left: BorderSide(
                          color: AppTheme.lightBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const _DestinationsSidebar(),
                  ),
                ],
              );
            } else {
              // ── Narrow layout: single column ──────
              return leftContent;
            }
          },
        ),
      ),
    );
  }
}

// ── Hero welcome banner ───────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC1592E),
            Color(0xFF8B3A1A),
            Color(0xFF1B2E45),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC1592E).withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative ornament — top right
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldAccent.withAlpha(20),
              ),
            ),
          ),
          // Gold star ornament
          Positioned(
            top: 18,
            right: 24,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.goldAccent.withAlpha(180),
              size: 36,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 60,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.goldAccent.withAlpha(100),
              size: 18,
            ),
          ),
          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.goldAccent.withAlpha(100)),
                  ),
                  child: const Text(
                    '🌍  Southeast Morocco Admin Panel',
                    style: TextStyle(
                      color: AppTheme.goldAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final Map<String, int> stats;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatDef('Destinations', stats['destinations'] ?? 0,
          Icons.place_rounded, AppTheme.primaryOrange),
      _StatDef('Bookings', stats['bookings'] ?? 0,
          Icons.book_online_rounded, AppTheme.deepBlue),
      _StatDef('Users', stats['users'] ?? 0,
          Icons.people_rounded, AppTheme.oasisGreen),
      _StatDef('Pending', stats['pendingBookings'] ?? 0,
          Icons.pending_actions_rounded, AppTheme.goldAccent),
      _StatDef('Cars', stats['cars'] ?? 0,
          Icons.directions_car_rounded, const Color(0xFF7B52AB)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 500) {
          // Wide: single row
          return Row(
            children: cards
                .map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _StatCard(def: c),
                      ),
                    ))
                .toList(),
          );
        } else {
          // Narrow: 2-column grid
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: cards.map((c) => _StatCard(def: c)).toList(),
          );
        }
      },
    );
  }
}

class _StatDef {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatDef(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.def});
  final _StatDef def;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored circle icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: def.color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(def.icon, color: def.color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            def.value.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppTheme.deepBlue,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            def.label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Right: destinations sidebar ───────────────────────────────────────────────

class _DestinationsSidebar extends StatelessWidget {
  const _DestinationsSidebar({this.shrinkWrap = false});

  /// When true the list uses shrinkWrap so it can be placed inside a
  /// scrollable Column (mobile inline mode).
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    Widget listArea = StreamBuilder<List<Destination>>(
      stream: DestinationService().streamAllDestinations(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryOrange));
        }
        final destinations = snap.data ?? [];
        if (destinations.isEmpty) {
          return const Center(
            child: Text('No destinations yet',
                style: TextStyle(
                    color: AppTheme.lightTextSecondary,
                    fontSize: 13)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          itemCount: destinations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) =>
              _DestinationMiniCard(dest: destinations[i]),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Destinations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepBlue,
                ),
              ),
              Text(
                'Live from Firestore',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.lightBorder),
        // On wide screens use Expanded so the list fills the sidebar;
        // on mobile (shrinkWrap) just let it size to its content.
        shrinkWrap ? listArea : Expanded(child: listArea),
      ],
    );
  }
}

class _DestinationMiniCard extends StatelessWidget {
  const _DestinationMiniCard({required this.dest});
  final Destination dest;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        dest.imageURLs.isNotEmpty ? dest.imageURLs.first : null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          if (imageUrl != null)
            SizedBox(
              height: 90,
              width: double.infinity,
              child: Image.network(imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _noPhoto()),
            )
          else
            _noPhoto(),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dest.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.deepBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppTheme.goldAccent, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      dest.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepBlue),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.location_on_rounded,
                        color: AppTheme.primaryOrange, size: 12),
                    Expanded(
                      child: Text(
                        dest.distance,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.lightTextSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noPhoto() => Container(
        height: 90,
        width: double.infinity,
        color: AppTheme.sandBeige,
        child: const Center(
          child: Icon(Icons.image_outlined,
              color: AppTheme.earthBrown, size: 28),
        ),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC1592E), Color(0xFFD9A441)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.deepBlue,
          ),
        ),
      ],
    );
  }
}

class _QuickTip extends StatelessWidget {
  const _QuickTip(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.deepBlue)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.lightTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction(
      {required this.icon, required this.onTap, required this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, color: AppTheme.deepBlue, size: 20),
        ),
      ),
    );
  }
}
