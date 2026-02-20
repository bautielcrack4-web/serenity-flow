import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/workout_model.dart';
import 'package:serenity_flow/screens/workout/workout_detail_screen.dart';

/// 💪 Workouts Screen — Browse workout categories and sessions
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _selectedCategory = 'Todos';
  static const _categories = ['Todos', 'HIIT', 'Yoga', 'Caminar', 'Cardio', 'Fuerza'];

  List<Workout> get _filteredWorkouts {
    if (_selectedCategory == 'Todos') return WorkoutLibrary.all;
    return WorkoutLibrary.all.where((w) => w.category == _selectedCategory).toList();
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
              Text('Elige tu entrenamiento de hoy', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.dark.withValues(alpha:0.5))),
              const SizedBox(height: 24),

              // Featured workout
              _FeaturedWorkoutCard(
                workout: WorkoutLibrary.hiitQuemagrasa,
                onTap: () => _openWorkout(WorkoutLibrary.hiitQuemagrasa),
              ),
              const SizedBox(height: 24),

              // Categories
              const Text('Categorías', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildCategoryRow(),
              const SizedBox(height: 24),

              // Workout list
              Text(
                _selectedCategory == 'Todos' ? 'Todos los workouts' : _selectedCategory,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark),
              ),
              const SizedBox(height: 16),
              ..._filteredWorkouts.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkoutListItem(workout: w, onTap: () => _openWorkout(w)),
              )),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _openWorkout(Workout workout) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)));
  }

  Widget _buildCategoryRow() {
    final categoryEmoji = {'Todos': '✨', 'HIIT': '🔥', 'Yoga': '🧘', 'Caminar': '🚶', 'Cardio': '💃', 'Fuerza': '🏋️'};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.coral : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: AppColors.gray.withValues(alpha:0.15)),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.coral.withValues(alpha:0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Row(
                  children: [
                    Text(categoryEmoji[cat]!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(cat, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.dark)),
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

class _FeaturedWorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  const _FeaturedWorkoutCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [workout.color, workout.color.withValues(alpha:0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: workout.color.withValues(alpha:0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(workout.emoji, style: const TextStyle(fontSize: 36)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.25), borderRadius: BorderRadius.circular(12)),
                  child: Text('${workout.calories} cal', style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(workout.title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text('${workout.duration} · ${workout.level}', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.white.withValues(alpha:0.8))),
            const SizedBox(height: 8),
            Text(workout.description, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white.withValues(alpha:0.7), height: 1.4)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: workout.color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Empezar 💪', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                color: workout.color.withValues(alpha:0.1),
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
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.dark.withValues(alpha:0.5))),
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
