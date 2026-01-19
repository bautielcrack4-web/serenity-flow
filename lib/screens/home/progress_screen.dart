import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/components/gamification_widgets.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as api_ui;

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
  late AnimationController _firePulseController;
  late AnimationController _fireWobbleController;
  late AnimationController _todayPulseController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _wobbleAnimation;
  late Animation<double> _todayPulse;

  @override
  void initState() {
    super.initState();
    
    // Fire Streak Animations
    _firePulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _firePulseController, curve: Curves.easeInOut));

    _fireWobbleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _wobbleAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(CurvedAnimation(parent: _fireWobbleController, curve: Curves.easeInOutSine));

    // Today Pulse for Calendar
    _todayPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _todayPulse = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _todayPulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _firePulseController.dispose();
    _fireWobbleController.dispose();
    _todayPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: SupabaseService().getProfile(),
          builder: (context, profileSnapshot) {
            // Default values if loading or null
            final profile = profileSnapshot.data;
            final totalXP = profile?['total_xp'] as int? ?? 0;
            final streak = profile?['streak_days'] as int? ?? 0;

            return FutureBuilder<Map<String, int>>(
              future: SupabaseService().getStats(),
              builder: (context, statsSnapshot) {
                final stats = statsSnapshot.data ?? {'minutes': 0, 'sessions': 0};

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(AppSpacings.padding, 32, AppSpacings.padding, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.turquoise, AppColors.lavender],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          "Your Progress",
                          style: AppTextStyles.headline.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: AppSpacings.betweenSections),
                      
                      _buildDopamineCalendar(),
                      
                      const SizedBox(height: AppSpacings.betweenSections),
                      
                      // XP Progress Bar
                      XPProgressBar(totalXP: totalXP),
                      
                      const SizedBox(height: AppSpacings.betweenSections),
                      
                      _buildAnimatedFireStreak(streak),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                           Expanded(child: _buildDopamineStatCard("Minutes", "${stats['minutes']}", AppColors.coralStatusGradient, Icons.timer_outlined)),
                           const SizedBox(width: 16),
                           Expanded(child: _buildDopamineStatCard("Sessions", "${stats['sessions']}", AppColors.turquoiseStatusGradient, Icons.bolt_rounded)),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacings.betweenSections),
                      
                      Text("Weekly Activity", style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      _buildWeeklyChart(),
                      
                      const SizedBox(height: AppSpacings.betweenSections),
                      Text("Shiny Badges", style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      _buildBadgesGrid(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDopamineCalendar() {
    return FutureBuilder<List<DateTime>>(
      future: SupabaseService().getSessionDates(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];
        final totalDays = sessions.map((e) => "${e.year}-${e.month}-${e.day}").toSet().length;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppShadows.card,
            border: Border.all(color: AppColors.lavender.withOpacity(0.05), width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("January 2026", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.dark)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.turquoise.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text("$totalDays DAYS TOTAL", style: const TextStyle(color: AppColors.turquoise, fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Days Header
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                 children: ["M", "T", "W", "T", "F", "S", "S"].map((d) => SizedBox(width: 40, child: Text(d, textAlign: TextAlign.center, style: TextStyle(color: AppColors.gray.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 12)))).toList(),
              ),
              const SizedBox(height: 12),
              // Grid (Dynamic for Jan 2026)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(35, (index) {
                  int dayNumber = index - 2; // Jan 2026 starts on Thu (index 3 if starting at 1). L=0, M=1, M=2, J=3.
                  
                  if (dayNumber < 1 || dayNumber > 31) return const SizedBox(width: 40, height: 40);
                  
                  final currentDate = DateTime(2026, 1, dayNumber);
                  
                  // Check if any session was completed on this day
                  bool isCompleted = sessions.any((s) => 
                    s.year == currentDate.year && 
                    s.month == currentDate.month && 
                    s.day == currentDate.day
                  );
                  
                  final now = DateTime.now();
                  bool isToday = currentDate.year == now.year && 
                                 currentDate.month == now.month && 
                                 currentDate.day == now.day;
                  
                  return InkWell(
                    onTap: () {
                       HapticFeedback.lightImpact();
                    },
                    child: _buildCalendarDay(dayNumber, isCompleted, isToday),
                  );
                }),
              ),
        ],
      ),
    );
  });
  }

  Widget _buildCalendarDay(int day, bool isCompleted, bool isToday) {
    return RepaintBoundary(
      child: Container(
        width: 40, height: 40,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isToday)
              ScaleTransition(
                scale: _todayPulse,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                    ],
                  ),
                ),
              ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.turquoise : AppColors.lightGray.withOpacity(0.3),
                border: isCompleted ? null : Border.all(color: AppColors.gray.withOpacity(0.1), width: 1),
                gradient: isCompleted ? AppColors.turquoiseStatusGradient : null,
              ),
              alignment: Alignment.center,
              child: isCompleted 
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : Text("$day", style: TextStyle(color: isToday ? AppColors.dark : AppColors.gray.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return FutureBuilder<List<DateTime>>(
      future: SupabaseService().getSessionDates(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];
        
        // Calculate sessions per day of week for the last 7 days
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        
        // Count sessions for each day of the week (Mon=1, Sun=7)
        final Map<int, int> sessionsPerDay = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
        
        for (var session in sessions) {
          if (session.isAfter(weekAgo)) {
            final weekday = session.weekday; // 1=Mon, 7=Sun
            sessionsPerDay[weekday] = (sessionsPerDay[weekday] ?? 0) + 1;
          }
        }
        
        // Find max to normalize
        final maxSessions = sessionsPerDay.values.reduce((a, b) => a > b ? a : b);
        final normalizer = maxSessions > 0 ? maxSessions : 1;
        
        // Build bars
        final days = [
          ("Mon", 1, AppColors.coral),
          ("Tue", 2, AppColors.lavender),
          ("Wed", 3, AppColors.turquoise),
          ("Thu", 4, AppColors.coral),
          ("Fri", 5, AppColors.turquoise),
          ("Sat", 6, AppColors.lavender),
          ("Sun", 7, AppColors.coral),
        ];
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: AppShadows.card),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((day) {
              final count = sessionsPerDay[day.$2] ?? 0;
              final percent = count / normalizer;
              return _buildChartBar(day.$1, percent, day.$3);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildChartBar(String day, double percent, Color color) {
    return Column(
      children: [
        Container(
          width: 22, height: 120 * percent,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.8), color], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(8)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
          ),
        ),
        const SizedBox(height: 12),
        Text(day, style: TextStyle(color: AppColors.gray, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadgesGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBadge(Icons.emoji_events_rounded, Colors.amber, true, "Warrior"),
        _buildBadge(Icons.auto_awesome_rounded, const Color(0xFF7B61FF), true, "Flow"),
        _buildBadge(Icons.diamond_rounded, const Color(0xFF00D1FF), false, "Elite"),
      ],
    );
  }

  Widget _buildBadge(IconData icon, Color color, bool unlocked, String label) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: unlocked ? color.withOpacity(0.12) : Colors.black.withOpacity(0.03),
            shape: BoxShape.circle,
            border: Border.all(color: unlocked ? color.withOpacity(0.3) : Colors.transparent, width: 2),
            boxShadow: unlocked ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))] : [],
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: unlocked ? color : Colors.black.withOpacity(0.2), size: 42),
              if (!unlocked)
                Positioned(
                  bottom: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.lock_rounded, size: 14, color: Colors.grey.shade400),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(color: unlocked ? AppColors.dark : AppColors.gray, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildAnimatedFireStreak([int streak = 4]) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2D2D2D),
              const Color(0xFF1A1A1A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
            BoxShadow(color: AppColors.coral.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.coral.withOpacity(0.3), width: 1),
                      ),
                      child: const Text(
                        "ACTIVE STREAK",
                        style: TextStyle(
                          color: AppColors.coral,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "$streak Days",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Keep it up!",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.coral.withOpacity(0.3),
                      AppColors.coral.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.coral, AppColors.coral.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDopamineStatCard(String label, String value, LinearGradient gradient, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(32), boxShadow: AppShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 24),
          Text(value, style: AppTextStyles.number.copyWith(fontSize: 48, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
