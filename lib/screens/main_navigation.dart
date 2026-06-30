import 'dart:ui';
import 'package:flutter/material.dart';
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
    late final AnimationController _bottomBarController;
     late final Animation<Offset> _bottomBarAnimation;
     bool _isBottomBarVisible = true; 

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationController.forward();
    _bottomBarController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 250),
);

_bottomBarAnimation = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(0, 2),
).animate(
  CurvedAnimation(
    parent: _bottomBarController,
    curve: Curves.easeInOut,
  ),
);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bottomBarController.dispose();
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
  void hideBottomBar() {
  if (_isBottomBarVisible) {
    _isBottomBarVisible = false;
    _bottomBarController.forward();
  }
}

void showBottomBar() {
  if (!_isBottomBarVisible) {
    _isBottomBarVisible = true;
    _bottomBarController.reverse();
  }
}

  late final List<Widget> _tabs = [
    HomePage(
      onTabChange: _onTabChange,
      onScrollDown: hideBottomBar,
      onScrollUp: showBottomBar,
    ),
    const MapTab(),
    const AiChatTab(),
    TripTab(
      onScrollDown: hideBottomBar,
      onScrollUp: showBottomBar,
    ),
    ProfileTab(
      onScrollDown: hideBottomBar,
      onScrollUp: showBottomBar,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
         bottomNavigationBar: SlideTransition(
         position: _bottomBarAnimation,
         child: Padding(
         padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      outlinedIcon: Icons.home_outlined,
                      filledIcon: Icons.home_rounded,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      index: 1,
                      outlinedIcon: Icons.map_outlined,
                      filledIcon: Icons.map_rounded,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      index: 2,
                      outlinedIcon: Icons.chat_bubble_outline_rounded,
                      filledIcon: Icons.chat_bubble_rounded,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      index: 3,
                      outlinedIcon: Icons.luggage_outlined,
                      filledIcon: Icons.luggage_rounded,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      index: 4,
                      outlinedIcon: Icons.person_outline_rounded,
                      filledIcon: Icons.person_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
         ),
    );
    
  }

  Widget _buildNavItem({
    required int index,
    required IconData outlinedIcon,
    required IconData filledIcon,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return GestureDetector(
      onTap: () => _onTabChange(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: ScaleTransition(
            scale: isSelected
                ? Tween<double>(begin: 0.75, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                  )
                : const AlwaysStoppedAnimation(1.0),
            child: Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: isSelected ? 28 : 25,
            ),
          ),
        ),
      ),
    );
  }
}