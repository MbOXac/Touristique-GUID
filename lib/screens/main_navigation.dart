import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';
import 'map_tab.dart';
import 'ai_chat_tab.dart';
import 'trip_tab.dart';
import 'profile_tab.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  static const _tabLabels = ['Home', 'Map', 'AI Guide', 'Trips', 'Profile'];
  static const _outlinedIcons = [
    Icons.home_outlined,
    Icons.map_outlined,
    Icons.auto_awesome_outlined,
    Icons.luggage_outlined,
    Icons.person_outline_rounded,
  ];
  static const _filledIcons = [
    Icons.home_rounded,
    Icons.map_rounded,
    Icons.auto_awesome_rounded,
    Icons.luggage_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabChange(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  late final List<Widget> _tabs = [
    HomePage(onTabChange: _onTabChange),
    const MapTab(),
    const AiChatTab(),
    const TripTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkAppBar : AppTheme.cream,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(
                _tabLabels.length,
                (index) => Expanded(
                  child: _buildNavItem(index: index, isDark: isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required bool isDark}) {
    final isSelected = _currentIndex == index;
    final activeColor = AppTheme.primaryOrange;
    final inactiveColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _onTabChange(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: isSelected
                ? Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                  )
                : const AlwaysStoppedAnimation(1.0),
            child: Icon(
              isSelected ? _filledIcons[index] : _outlinedIcons[index],
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _tabLabels[index],
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
