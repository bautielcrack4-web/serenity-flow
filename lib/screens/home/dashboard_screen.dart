import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/services/user_profile_provider.dart';

/// 🏠 Dashboard — Main home tab showing daily summary
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Daily checklist state
  bool _waterDone = false;
  bool _workoutDone = false;
  bool _meditationDone = false;
  bool _mealsDone = false;
  int _waterGlasses = 0;

  int get _completedTasks => [_waterDone, _workoutDone, _meditationDone, _mealsDone].where((e) => e).length;
  double get _dayProgress => _completedTasks / 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildWeightSummaryCard(),
              const SizedBox(height: 20),
              _buildDailyChecklist(),
              const SizedBox(height: 20),
              _buildTodaysPlan(),
              const SizedBox(height: 20),
              _buildMotivationalCard(),
              const SizedBox(height: 100), // Bottom nav padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final s = L10n.s;
    final up = UserProfileProvider.instance;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = s.dashGoodMorning;
    } else if (hour < 18) {
      greeting = s.dashGoodAfternoon;
    } else {
      greeting = s.dashGoodEvening;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, ${up.displayName}', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(L10n.s.dashTodayProgress, style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
            ],
          ),
        ),
        // Streak badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.coralStatusGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text('${up.currentStreak}', style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightSummaryCard() {
    final up = UserProfileProvider.instance;
    final current = up.currentWeight;
    final target = up.targetWeight;
    final progress = up.progressPercent;
    final progressPct = (progress * 100).round();

    // Format weight or show '—' if not set
    String fmtW(double? w) => w != null ? w.toStringAsFixed(1) : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          // Weight progress circle
          SizedBox(
            width: 80, height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.coral.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(AppColors.coral),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text('$progressPct%', style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.coral)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L10n.s.dashYourGoal, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.dark),
                    children: [
                      TextSpan(text: fmtW(current)),
                      const TextSpan(text: ' kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray)),
                      const TextSpan(text: '  →  '),
                      TextSpan(text: fmtW(target)),
                      const TextSpan(text: ' kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (up.weightToLose != null && up.weightToLose! > 0)
                  Text('${up.weightToLose!.toStringAsFixed(1)} kg ${L10n.s.dashLostThisWeek} 💪', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChecklist() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(L10n.s.dashChecklist, style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark)),
              ),
              Text('$_completedTasks/4', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.coral)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _dayProgress,
              backgroundColor: AppColors.coral.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.coral),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckItem('💧', L10n.s.dashWater, '$_waterGlasses/8 ${L10n.s.glassesUnit}', _waterDone, () {
            setState(() {
              _waterGlasses = (_waterGlasses + 1).clamp(0, 8);
              _waterDone = _waterGlasses >= 8;
            });
          }),
          _buildCheckItem('💪', L10n.s.dashWorkout, '20 min HIIT', _workoutDone, () {
            setState(() => _workoutDone = !_workoutDone);
          }),
          _buildCheckItem('🧘', L10n.s.dashMeditation, '5 min', _meditationDone, () {
            setState(() => _meditationDone = !_meditationDone);
          }),
          _buildCheckItem('🍽️', L10n.s.dashMeals, '3 ${L10n.s.dashMealsUnit}', _mealsDone, () {
            setState(() => _mealsDone = !_mealsDone);
          }),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String emoji, String title, String subtitle, bool done, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: done ? AppColors.coral.withValues(alpha: 0.08) : AppColors.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: done ? Border.all(color: AppColors.coral.withValues(alpha: 0.2)) : null,
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w600, color: done ? AppColors.coral : AppColors.dark, decoration: done ? TextDecoration.lineThrough : null)),
                    Text(subtitle, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.gray.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              Icon(done ? Icons.check_circle_rounded : Icons.circle_outlined, color: done ? AppColors.coral : AppColors.gray.withValues(alpha: 0.3), size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.s.dashTodayPlan, style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPlanCard('🔥', L10n.s.dashPlanHiit, '20 min', AppColors.coral)),
            const SizedBox(width: 12),
            Expanded(child: _buildPlanCard('🥗', L10n.s.dashPlanSalad, L10n.s.dashPlanLunch, AppColors.turquoise)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPlanCard('🧘', L10n.s.dashPlanBreathing, '5 min', AppColors.lavender)),
            const SizedBox(width: 12),
            Expanded(child: _buildPlanCard('🌙', L10n.s.dashPlanSleep, '10 min', const Color(0xFF5C6BC0))),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard(String emoji, String title, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark)),
          const SizedBox(height: 2),
          Text(time, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0EC), Color(0xFFFFE0D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('💪', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(L10n.s.dashMotivationalQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark, fontStyle: FontStyle.italic, height: 1.4)),
          const SizedBox(height: 8),
          const Text('— Yuna', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.coral, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
