import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/services/notification_service.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:serenity_flow/screens/onboarding/pages/phase1_hook.dart';
import 'package:serenity_flow/screens/onboarding/pages/phase2_body.dart';
import 'package:serenity_flow/screens/onboarding/pages/phase3_eating.dart';
import 'package:serenity_flow/screens/onboarding/pages/phase4_wellness.dart';
import 'package:serenity_flow/screens/onboarding/pages/phase5_plan.dart';
import 'package:serenity_flow/screens/onboarding/pages/phase6_commitment.dart';
import 'package:serenity_flow/screens/onboarding/pages/phase7_paywall.dart';

/// Main onboarding flow controller — manages the 45-screen quiz funnel
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final OnboardingData _data = OnboardingData();
  int _currentPage = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      // PHASE 1: Emotional Hook (pages 0-4)
      ...buildPhase1Pages(_data, _next, _answer),
      // PHASE 2: Body Profile (pages 5-11)
      ...buildPhase2Pages(_data, _next, _answer),
      // PHASE 3: Eating Habits (pages 12-19)
      ...buildPhase3Pages(_data, _next, _answer),
      // PHASE 4: Emotional Wellness (pages 20-26)
      ...buildPhase4Pages(_data, _next, _answer),
      // PHASE 5: Personalized Plan (pages 27-34)
      ...buildPhase5Pages(_data, _next, _answer),
      // PHASE 6: Commitment + Social Proof (pages 35-39)
      ...buildPhase6Pages(_data, _next, _answer),
      // PHASE 7: Paywall (pages 40-44)
      ...buildPhase7Pages(_data, _next, _answer, _completeOnboarding),
    ];
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _answer(String key, dynamic value) {
    _data.set(key, value);
    // Rebuild pages so they reflect the new answers
    setState(() => _buildPages());
    _next();
  }

  Future<void> _completeOnboarding() async {
    // Save to Supabase
    try {
      final supabase = SupabaseService();
      await supabase.saveOnboardingProfile(_data);
    } catch (e) {
      debugPrint('Onboarding save to Supabase failed: $e');
    }

    // Link email to RevenueCat subscriber
    final email = _data.email;
    if (email != null && email.isNotEmpty) {
      await RevenueCatService().setEmail(email);
    }

    // Schedule notifications if user accepted
    if (_data.notificationsAccepted) {
      await NotificationService().scheduleAll();
    }

    // Save locally as fallback
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Progress bar
            OnboardingProgressBar(
              currentPage: _currentPage,
              totalPages: _pages.length,
            ),
            const SizedBox(height: 8),
            // Back button (after first page)
            if (_currentPage > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  color: AppColors.dark.withValues(alpha: 0.5),
                ),
              ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
