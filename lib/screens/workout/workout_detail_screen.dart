import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/workout_model.dart';
import 'package:serenity_flow/screens/workout/workout_player_screen.dart';

/// Workout Detail — Preview exercises before starting
class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final activeExercises = workout.exercises.where((e) => !e.isRest).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero header
          SliverToBoxAdapter(child: _buildHero(context)),
          // Exercise list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('${activeExercises.length} ejercicios',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
                  const SizedBox(height: 16),
                  ...workout.exercises.asMap().entries.map((entry) {
                    final i = entry.key;
                    final exercise = entry.value;
                    return _ExercisePreviewTile(exercise: exercise, index: i, color: workout.color);
                  }),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating start button
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => WorkoutPlayerScreen(workout: workout),
              ));
            },
            backgroundColor: workout.color,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: const Text('Empezar Workout 💪',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 20, right: 20, bottom: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [workout.color, workout.color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: workout.color.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(workout.level, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Emoji + title
          Text(workout.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(workout.title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
          const SizedBox(height: 8),
          Text(workout.description, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.4)),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _StatPill(icon: Icons.timer_outlined, text: workout.duration),
              const SizedBox(width: 10),
              _StatPill(icon: Icons.local_fire_department_rounded, text: '${workout.calories} cal'),
              const SizedBox(width: 10),
              _StatPill(icon: Icons.format_list_numbered_rounded, text: '${workout.exercises.where((e) => !e.isRest).length} ejercicios'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class _ExercisePreviewTile extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final Color color;
  const _ExercisePreviewTile({required this.exercise, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: exercise.isRest ? AppColors.lightGray.withValues(alpha: 0.3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: exercise.isRest ? null : AppShadows.card,
        ),
        child: Row(
          children: [
            // Number / emoji
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: exercise.isRest ? Colors.transparent : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: exercise.isRest
                    ? Text(exercise.emoji, style: const TextStyle(fontSize: 18))
                    : Text(exercise.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: exercise.isRest ? 13 : 15,
                      fontWeight: exercise.isRest ? FontWeight.w500 : FontWeight.w700,
                      color: exercise.isRest ? AppColors.gray : AppColors.dark,
                    ),
                  ),
                  if (exercise.description != null && !exercise.isRest)
                    Text(exercise.description!, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Text(
              '${exercise.durationSeconds}s',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: exercise.isRest ? AppColors.gray : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
