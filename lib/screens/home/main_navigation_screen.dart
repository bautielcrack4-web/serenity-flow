import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/screens/home/home_screen_content.dart';
import 'package:serenity_flow/screens/home/progress_screen.dart';
import 'package:serenity_flow/screens/home/settings_screen.dart';
import 'package:flutter/services.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(),
    const ProgressScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageTransitionSwitcher(
        currentIndex: _currentIndex,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildPremiumNavBar(),
    );
  }

  Widget _buildPremiumNavBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Stack(
        children: [
          // Indicator Line
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment(_lerpIndicatorAlign(_currentIndex), -1.0),
            child: Container(
              width: 48, height: 4,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                boxShadow: [BoxShadow(color: AppColors.coral.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))],
              ),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.spa_outlined, "Home"),
              _buildNavItem(1, Icons.bar_chart_rounded, "Progress"),
              _buildNavItem(2, Icons.settings_rounded, "Settings"),
            ],
          ),
        ],
      ),
    );
  }

  double _lerpIndicatorAlign(int index) {
    if (index == 0) return -0.66;
    if (index == 1) return 0.0;
    return 0.66;
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.coral : AppColors.gray.withOpacity(0.5),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.coral : AppColors.gray.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageTransitionSwitcher extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const PageTransitionSwitcher({super.key, required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey<int>(currentIndex),
        child: child,
      ),
    );
  }
}
