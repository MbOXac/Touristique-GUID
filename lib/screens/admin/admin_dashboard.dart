import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../theme/app_theme.dart';
import 'admin_overview_tab.dart';
import 'admin_destinations_tab.dart';
import 'admin_bookings_tab.dart';
import 'admin_users_tab.dart';
import 'admin_cars_tab.dart';

/// Admin shell — responsive:
///  • Wide screens (≥ 600 px) → terracotta sidebar + content
///  • Narrow screens (< 600 px) → bottom navigation bar
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded,      Icons.dashboard_outlined,      'Overview'),
    _NavItem(Icons.place_rounded,          Icons.place_outlined,          'Destinations'),
    _NavItem(Icons.book_online_rounded,    Icons.book_online_outlined,    'Bookings'),
    _NavItem(Icons.people_rounded,         Icons.people_outline_rounded,  'Users'),
    _NavItem(Icons.directions_car_rounded, Icons.directions_car_outlined, 'Cars'),
  ];

  late final List<Widget> _tabs = [
    const AdminOverviewTab(),
    const AdminDestinationsTab(),
    const AdminBookingsTab(),
    const AdminUsersTab(),
    const AdminCarsTab(),
  ];

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of the admin panel?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // Clear Google session if applicable
      try {
        const webClientId =
            '202821805924-7038jg7f4183lei3ad7rtg2pf8an71bi.apps.googleusercontent.com';
        final googleSignIn = kIsWeb
            ? GoogleSignIn(clientId: webClientId)
            : GoogleSignIn();
        await googleSignIn.signOut();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      // AuthGate reacts to the auth stream and shows LoginPage automatically
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      // ── Mobile: bottom nav bar ──────────────────────────────────────────
      bottomNavigationBar: isWide
          ? null
          : _MobileBottomBar(
              selectedIndex: _selectedIndex,
              navItems: _navItems,
              onItemTap: (i) => setState(() => _selectedIndex = i),
            ),
      body: isWide
          // ── Wide: sidebar layout ──────────────────────────────────────
          ? Row(
              children: [
                _AdminSidebar(
                  selectedIndex: _selectedIndex,
                  navItems: _navItems,
                  onItemTap: (i) => setState(() => _selectedIndex = i),
                  onSignOut: _signOut,
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _tabs,
                  ),
                ),
              ],
            )
          // ── Narrow: full-width content + top app bar ──────────────────
          : Column(
              children: [
                _MobileAppBar(onSignOut: _signOut),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _tabs,
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Mobile top app bar ────────────────────────────────────────────────────────

class _MobileAppBar extends StatelessWidget {
  const _MobileAppBar({required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC1592E), Color(0xFF8B3A1A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: AppTheme.goldAccent, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Touristique GUID',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  Text('Control Panel',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6)),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white70, size: 22),
                tooltip: 'Sign Out',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile bottom navigation bar ─────────────────────────────────────────────

class _MobileBottomBar extends StatelessWidget {
  const _MobileBottomBar({
    required this.selectedIndex,
    required this.navItems,
    required this.onItemTap,
  });

  final int selectedIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8B3A1A),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(navItems.length, (i) {
              final isSelected = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onItemTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isSelected
                              ? AppTheme.goldAccent
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? navItems[i].filledIcon
                              : navItems[i].outlinedIcon,
                          color: isSelected
                              ? AppTheme.goldAccent
                              : Colors.white.withAlpha(160),
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          navItems[i].label,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.goldAccent
                                : Colors.white.withAlpha(160),
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Sidebar (wide screens only) ───────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.onItemTap,
    required this.onSignOut,
  });

  final int selectedIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onItemTap;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC1592E), Color(0xFF8B3A1A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Logo / header ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: AppTheme.goldAccent, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Touristique',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3)),
                          Text('GUID',
                              style: TextStyle(
                                  color: AppTheme.goldAccent,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withAlpha(60), width: 1),
                    ),
                    child: const Text('Control Panel',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                  ),
                ],
              ),
            ),

            // Ornamental divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          height: 1,
                          color: Colors.white.withAlpha(40))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.auto_awesome_rounded,
                        color: AppTheme.goldAccent.withAlpha(180), size: 10),
                  ),
                  Expanded(
                      child: Container(
                          height: 1,
                          color: Colors.white.withAlpha(40))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Nav items ─────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: navItems.length,
                itemBuilder: (ctx, i) {
                  final isSelected = selectedIndex == i;
                  return _SidebarNavItem(
                    item: navItems[i],
                    isSelected: isSelected,
                    onTap: () => onItemTap(i),
                  );
                },
              ),
            ),

            // ── Sign out ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: GestureDetector(
                onTap: onSignOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withAlpha(40), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 10),
                      Text('Sign Out',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sidebar nav item ──────────────────────────────────────────────────────────

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? item.filledIcon : item.outlinedIcon,
                color: isSelected
                    ? AppTheme.primaryOrange
                    : Colors.white.withAlpha(200),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.primaryOrange
                      : Colors.white.withAlpha(200),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData filledIcon;
  final IconData outlinedIcon;
  final String label;
  const _NavItem(this.filledIcon, this.outlinedIcon, this.label);
}
