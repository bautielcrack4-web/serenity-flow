import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:serenity_flow/screens/session/pre_session_screen.dart';
import 'package:serenity_flow/components/routine_card.dart';
import 'package:serenity_flow/components/mesh_gradient_background.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/screens/monetization/paywall_screen.dart';
import 'package:flutter/services.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }

  String _getRecommendation() {
    final hour = DateTime.now().hour;
    if (hour < 10) return "Gentle Wake Up";
    if (hour < 14) return "Tension Relief";
    if (hour < 20) return "Tension Relief";
    return "Deep Sleep";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: MeshGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacings.padding, 32, AppSpacings.padding, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personalized Greeting
                _buildGreeting(),
                const SizedBox(height: 32),
                
                // Intelligent Recommendation
                _buildRecommendationCard(),
                const SizedBox(height: 32),
                
                // Section Header
                Text("All Routines", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                
                // Routine Cards with Staggered Animation
                ...routinesData.asMap().entries.map((entry) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(
                          0.2 + (entry.key * 0.15),
                          0.8 + (entry.key * 0.05),
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(
                            0.2 + (entry.key * 0.15),
                            0.8 + (entry.key * 0.05),
                            curve: Curves.easeOutQuart,
                          ),
                        ),
                      ),
                      child: RoutineCard(
                        routine: entry.value,
                        index: entry.key,
                        onTap: () => _handleRoutineStart(entry.value),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_getGreeting()}, Maria ☀️",
          style: AppTextStyles.headline.copyWith(color: AppColors.dark),
        ),
        const SizedBox(height: 8),
        Text(
          "Ready for your practice today?",
          style: AppTextStyles.caption.copyWith(color: AppColors.dark.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    final recommendedName = _getRecommendation();
    final recommended = routinesData.firstWhere((r) => r.name == recommendedName);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.coral.withOpacity(0.15),
            AppColors.lavender.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.coral.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.coral.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "SUGGESTED FOR YOU",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.coral,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(recommended.icon, fit: BoxFit.contain),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommended.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommended.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.dark.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _handleRoutineStart(recommended),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                "START NOW",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRoutineStart(Routine routine) async {
    HapticFeedback.mediumImpact();
    
    final supabase = SupabaseService();
    final profile = await supabase.getProfile();
    final bool isPro = profile?['is_pro'] ?? false;
    final int freeSessions = profile?['free_sessions_count'] ?? 0;

    if (!isPro && freeSessions >= 3) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaywallScreen(
            onFinish: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreSessionScreen(routine: routine),
        ),
      );
    }
  }
}
