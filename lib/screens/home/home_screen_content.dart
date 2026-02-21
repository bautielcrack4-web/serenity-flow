import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:serenity_flow/screens/session/pre_session_screen.dart';
import 'package:serenity_flow/components/routine_card.dart';
import 'package:serenity_flow/components/mesh_gradient_background.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/services/revenue_cat_service.dart';
import 'package:serenity_flow/screens/monetization/paywall_screen.dart';
import 'package:serenity_flow/screens/home/create_routine_screen.dart';
import 'package:flutter/services.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  List<Routine> _customRoutines = [];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadCustomRoutines();
  }
  
  void _loadCustomRoutines() async {
    final routines = await SupabaseService().getCustomRoutines();
    if (mounted) {
      setState(() {
        _customRoutines = routines;
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ... (GREETING & RECOMMENDATION HELPERS KEEP THE SAME) ...
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

                // --- NEW: Custom Routines Section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("My Routines", style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.dark, size: 28),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateRoutineScreen()),
                        );
                        if (result == true) {
                          _loadCustomRoutines(); // Refresh list if saved
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_customRoutines.isEmpty)
                  _buildEmptyState()
                else
                  ..._customRoutines.map((routine) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RoutineCard(
                      routine: routine,
                      index: 0,
                      onTap: () => _handleRoutineStart(routine),
                      onLongPress: () => _confirmDeleteRoutine(routine),
                    ),
                  )),

                const SizedBox(height: 24),
                
                // Section Header
                Text("All Routines", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                
                // Routine Cards with Staggered Animation
                ...routinesData.asMap().entries.map((entry) {
                  final delay = entry.key * 0.08;
                  final start = (0.1 + delay).clamp(0.0, 0.9);
                  final end = (start + 0.3).clamp(0.0, 1.0);
                  
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(start, end, curve: Curves.easeOut),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(start, end, curve: Curves.easeOutQuart),
                        ),
                      ),
                      child: RoutineCard(
                        routine: entry.value,
                        index: entry.key,
                        onTap: () => _handleRoutineStart(entry.value),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SupabaseService().getProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        // Try to get name from metadata if not in profile, or default to empty
        final String? name = profile?['full_name'] as String?;
        final displayName = (name != null && name.isNotEmpty) ? ", $name" : "";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_getGreeting()}$displayName ☀️",
              style: AppTextStyles.headline.copyWith(color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            Text(
              "Ready for your practice today?",
              style: AppTextStyles.caption.copyWith(color: AppColors.dark.withValues(alpha: 0.6)),
            ),
          ],
        );
      }
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
            AppColors.coral.withValues(alpha: 0.15),
            AppColors.lavender.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.2),
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
                  color: Colors.white.withValues(alpha: 0.5),
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
                        color: AppColors.dark.withValues(alpha: 0.6),
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
    
    // Check RevenueCat local state first (fastest source of truth after purchase)
    bool isPro = RevenueCatService().isPro;
    
    final supabase = SupabaseService();
    
    // Fallback to DB if local says false (e.g. fresh install, restores)
    if (!isPro) {
       final profile = await supabase.getProfile();
       isPro = profile?['is_pro'] ?? false;
    }
    
    final int freeSessions = await supabase.getFreeSessionsCount();

    if (!isPro && freeSessions >= 3) {
      if (!mounted) return;
      
      // Show Paywall and wait for result
      final bool? purchased = await Navigator.push(
        context,
        MaterialPageRoute(
          // Don't pass onFinish, rely on default pop(true)
          builder: (context) => const PaywallScreen(showCloseButton: true), 
        ),
      );
      
      // If they bought it, start the routine immediately!
      if (purchased == true) {
         if (!mounted) return;
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreSessionScreen(routine: routine),
          ),
        );
      }
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

  Future<void> _confirmDeleteRoutine(Routine routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete Routine?", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark)),
        content: Text("Are you sure you want to delete '${routine.name}'? This action cannot be undone.", style: const TextStyle(color: AppColors.gray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseService().deleteCustomRoutine(routine.id);
      _loadCustomRoutines();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted '${routine.name}'"), backgroundColor: AppColors.dark),
        );
      }
    }
  }


  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.peachGradient.colors.first.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: const Icon(Icons.fitness_center, color: AppColors.dark),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Personal Flows", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Tap + to create your own routine", style: TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
