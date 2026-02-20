import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/screens/home/dashboard_screen.dart';
import 'package:serenity_flow/screens/home/workouts_screen.dart';
import 'package:serenity_flow/screens/home/nutrition_screen.dart';
import 'package:serenity_flow/screens/home/mindfulness_screen.dart';
import 'package:serenity_flow/screens/home/profile_screen.dart';

/// 5-Tab Navigation — Home, Workouts, Nutrition, Mind, Profile
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    WorkoutsScreen(),
    NutritionScreen(),
    MindfulnessScreen(),
    ProfileScreen(),
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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
            ],
          ),
          child: Stack(
            children: [
              // Animated indicator line
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment(_lerpIndicatorAlign(_currentIndex), -1.0),
                child: Container(
                  width: 36, height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                    boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.fitness_center_rounded, 'Workouts'),
                  _buildNavItem(2, Icons.restaurant_rounded, 'Nutrition'),
                  _buildNavItem(3, Icons.self_improvement_rounded, 'Mind'),
                  _buildNavItem(4, Icons.person_rounded, 'Profile'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _lerpIndicatorAlign(int index) {
    // Map 0-4 to -0.8 → 0.8
    return -0.8 + (index * 0.4);
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.coral.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.coral : AppColors.gray.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: isSelected ? AppColors.coral : AppColors.gray.withValues(alpha: 0.4),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
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
