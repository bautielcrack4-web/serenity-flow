import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/core/l10n.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:serenity_flow/models/workout_model.dart';
import 'package:serenity_flow/screens/session/pre_session_screen.dart';
import 'package:serenity_flow/screens/workout/workout_detail_screen.dart';
import 'package:serenity_flow/services/user_profile_provider.dart';

/// 💪 Workouts Screen — Personalized based on onboarding exercise preference
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _selectedCategory = 'all';

  String get _preferredExercise => UserProfileProvider.instance.preferredExercise;

  /// Whether this user's preference maps to yoga routines
  bool get _isYogaUser => _preferredExercise == 'yoga';

  /// Filtered yoga routines based on selected category
  List<Routine> get _filteredRoutines {
    if (_selectedCategory == 'all') return routinesData;
    // Filter by difficulty
    if (_selectedCategory == 'easy') return routinesData.where((r) => r.difficulty == 1).toList();
    if (_selectedCategory == 'medium') return routinesData.where((r) => r.difficulty == 2).toList();
    if (_selectedCategory == 'hard') return routinesData.where((r) => r.difficulty == 3).toList();
    return routinesData;
  }

  /// Filtered workouts based on selected category
  List<Workout> get _filteredWorkouts {
    if (_selectedCategory == 'all') return _prioritizedWorkouts;
    return WorkoutLibrary.all.where((w) => w.category.toLowerCase() == _selectedCategory).toList();
  }

  /// Workouts prioritized by user preference
  List<Workout> get _prioritizedWorkouts {
    final all = List<Workout>.from(WorkoutLibrary.all);
    // Move preferred category to the top
    final Map<String, String> prefToCategory = {
      'hiit': 'HIIT',
      'gym': 'Fuerza',
      'dance': 'Cardio',
      'walking': 'Caminar',
    };
    final preferred = prefToCategory[_preferredExercise];
    if (preferred != null) {
      all.sort((a, b) {
        final aMatch = a.category == preferred ? 0 : 1;
        final bMatch = b.category == preferred ? 0 : 1;
        return aMatch.compareTo(bMatch);
      });
    }
    return all;
  }

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
              const Text('Workouts', style: TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 4),
              Text(
                _isYogaUser ? L10n.s.dashPlanBreathing : L10n.s.dashPlanHiit,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 24),

              // Featured card
              _isYogaUser ? _buildFeaturedRoutine() : _buildFeaturedWorkout(),
              const SizedBox(height: 24),

              // Categories
              _buildCategoryRow(),
              const SizedBox(height: 24),

              // Content list
              _isYogaUser ? _buildRoutineList() : _buildWorkoutList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── YOGA ROUTINES ────────────────────────────────────────────────

  Widget _buildFeaturedRoutine() {
    final featured = routinesData.first; // Gentle Wake Up
    return GestureDetector(
      onTap: () => _openRoutine(featured),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: featured.themeGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: featured.themeGradient.colors.first.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐ Recommended', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(featured.name, style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(featured.description, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 12),
                  Text('${featured.poseCount} poses · ${featured.computedDuration}',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Hero(
              tag: 'routine_icon_${featured.id}',
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(featured.icon, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineList() {
    final routines = _filteredRoutines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${routines.length} routines', style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
        const SizedBox(height: 16),
        ...routines.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RoutineListItem(routine: r, onTap: () => _openRoutine(r)),
        )),
      ],
    );
  }

  void _openRoutine(Routine routine) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => PreSessionScreen(routine: routine)));
  }

  // ── HIIT / GYM / DANCE / WALKING WORKOUTS ──────────────────────

  Widget _buildFeaturedWorkout() {
    final featured = _prioritizedWorkouts.first;
    return GestureDetector(
      onTap: () => _openWorkout(featured),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [featured.color, featured.color.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: featured.color.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(featured.emoji, style: const TextStyle(fontSize: 36)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                  child: Text('${featured.calories} cal', style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(featured.title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text('${featured.duration} · ${featured.level}', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 8),
            Text(featured.description, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white.withValues(alpha: 0.7), height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutList() {
    final workouts = _filteredWorkouts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${workouts.length} workouts', style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
        const SizedBox(height: 16),
        ...workouts.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _WorkoutListItem(workout: w, onTap: () => _openWorkout(w)),
        )),
      ],
    );
  }

  void _openWorkout(Workout workout) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)));
  }

  // ── SHARED UI ──────────────────────────────────────────────────

  Widget _buildCategoryRow() {
    final List<Map<String, String>> categories;

    if (_isYogaUser) {
      categories = [
        {'id': 'all', 'emoji': '✨', 'label': L10n.s.dashChecklist.split(' ').first},
        {'id': 'easy', 'emoji': '🌿', 'label': 'Easy'},
        {'id': 'medium', 'emoji': '🔥', 'label': 'Medium'},
        {'id': 'hard', 'emoji': '💪', 'label': 'Hard'},
      ];
    } else {
      // Build categories from workout library
      final cats = WorkoutLibrary.all.map((w) => w.category).toSet().toList();
      categories = [
        {'id': 'all', 'emoji': '✨', 'label': 'All'},
        ...cats.map((c) {
          final emoji = {'HIIT': '🔥', 'Yoga': '🧘', 'Caminar': '🚶', 'Cardio': '💃', 'Fuerza': '🏋️'}[c] ?? '⭐';
          return {'id': c.toLowerCase(), 'emoji': emoji, 'label': c};
        }),
      ];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat['id'] == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['id']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.coral : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: AppColors.gray.withValues(alpha: 0.15)),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Row(
                  children: [
                    Text(cat['emoji']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(cat['label']!, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.dark)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── YOGA ROUTINE LIST ITEM ───────────────────────────────────────

class _RoutineListItem extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  const _RoutineListItem({required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final difficultyStars = List.generate(3, (i) => Icon(
      i < routine.difficulty ? Icons.star_rounded : Icons.star_border_rounded,
      size: 14,
      color: i < routine.difficulty ? AppColors.coral : AppColors.gray.withValues(alpha: 0.3),
    ));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Hero(
              tag: 'routine_icon_${routine.id}',
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [routine.themeGradient.colors.first.withValues(alpha: 0.15), routine.themeGradient.colors.last.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(routine.icon, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routine.name, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${routine.poseCount} poses · ${routine.computedDuration}',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.5))),
                      const SizedBox(width: 8),
                      ...difficultyStars,
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_filled_rounded, color: routine.themeGradient.colors.first, size: 36),
          ],
        ),
      ),
    );
  }
}

// ── WORKOUT LIST ITEM ────────────────────────────────────────────

class _WorkoutListItem extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  const _WorkoutListItem({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: workout.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(workout.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                  const SizedBox(height: 4),
                  Text('${workout.duration} · ${workout.level} · ${workout.calories} cal',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Icon(Icons.play_circle_filled_rounded, color: workout.color, size: 36),
          ],
        ),
      ),
    );
  }
}
