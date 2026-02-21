import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serenity_flow/core/l10n.dart';

/// 🍽️ Nutrition Service — CRUD for user_meals & user_water
class NutritionService {
  static final NutritionService _instance = NutritionService._internal();
  factory NutritionService() => _instance;
  NutritionService._internal();

  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  String _dateStr(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // ── Meals ──────────────────────────────────────────────────────────

  /// Get all meals for a given date. Seeds defaults if none exist.
  Future<List<MealData>> getMealsForDate(DateTime date) async {
    if (_userId == null) return _defaultMeals();
    try {
      final rows = await _supabase
          .from('user_meals')
          .select()
          .eq('user_id', _userId!)
          .eq('date', _dateStr(date))
          .order('time');

      if (rows.isEmpty) {
        // Seed default meals for this date
        await seedDefaultMeals(date);
        return _defaultMeals();
      }

      return rows.map((r) => MealData(
        emoji: r['emoji'] ?? '🍽️',
        name: r['name'] ?? '',
        description: r['description'] ?? '',
        time: r['time'] ?? '',
        calories: r['calories'] ?? 0,
        mealType: r['meal_type'] ?? '',
        isCompleted: r['is_completed'] ?? false,
      )).toList();
    } catch (e) {
      debugPrint('NutritionService.getMealsForDate error: $e');
      return _defaultMeals();
    }
  }

  /// Toggle meal completion status
  Future<void> toggleMealCompleted(String mealType, DateTime date, bool completed) async {
    if (_userId == null) return;
    try {
      await _supabase
          .from('user_meals')
          .update({'is_completed': completed})
          .eq('user_id', _userId!)
          .eq('date', _dateStr(date))
          .eq('meal_type', mealType);
    } catch (e) {
      debugPrint('NutritionService.toggleMealCompleted error: $e');
    }
  }

  /// Seed default meals for a date
  Future<void> seedDefaultMeals(DateTime date) async {
    if (_userId == null) return;
    final defaults = _defaultMeals();
    try {
      final rows = defaults.map((m) => {
        'user_id': _userId!,
        'date': _dateStr(date),
        'meal_type': m.mealType,
        'emoji': m.emoji,
        'name': m.name,
        'description': m.description,
        'time': m.time,
        'calories': m.calories,
        'is_completed': false,
      }).toList();

      await _supabase.from('user_meals').upsert(rows, onConflict: 'user_id,date,meal_type');
    } catch (e) {
      debugPrint('NutritionService.seedDefaultMeals error: $e');
    }
  }

  // ── Water ──────────────────────────────────────────────────────────

  /// Get water glasses for a given date
  Future<int> getWaterGlasses(DateTime date) async {
    if (_userId == null) return 0;
    try {
      final rows = await _supabase
          .from('user_water')
          .select('glasses')
          .eq('user_id', _userId!)
          .eq('date', _dateStr(date));

      if (rows.isEmpty) return 0;
      return (rows.first['glasses'] as int?) ?? 0;
    } catch (e) {
      debugPrint('NutritionService.getWaterGlasses error: $e');
      return 0;
    }
  }

  /// Set water glasses for a given date
  Future<void> setWaterGlasses(int glasses, DateTime date) async {
    if (_userId == null) return;
    try {
      await _supabase.from('user_water').upsert({
        'user_id': _userId!,
        'date': _dateStr(date),
        'glasses': glasses,
      }, onConflict: 'user_id,date');
    } catch (e) {
      debugPrint('NutritionService.setWaterGlasses error: $e');
    }
  }

  // ── Defaults ───────────────────────────────────────────────────────

  List<MealData> _defaultMeals() {
    final s = L10n.s;
    return [
      MealData(emoji: '🥣', name: s.nutBreakfast, description: s.nutBreakfastDesc, time: '8:00', calories: 350, mealType: 'breakfast'),
      MealData(emoji: '🍎', name: s.nutMorningSnack, description: s.nutMorningSnackDesc, time: '10:30', calories: 180, mealType: 'morning_snack'),
      MealData(emoji: '🥗', name: s.nutLunch, description: s.nutLunchDesc, time: '13:00', calories: 480, mealType: 'lunch'),
      MealData(emoji: '🥜', name: s.nutAfternoonSnack, description: s.nutAfternoonSnackDesc, time: '16:00', calories: 200, mealType: 'afternoon_snack'),
      MealData(emoji: '🍗', name: s.nutDinner, description: s.nutDinnerDesc, time: '20:00', calories: 420, mealType: 'dinner'),
    ];
  }
}

/// Meal data model used across nutrition features
class MealData {
  final String emoji;
  final String name;
  final String description;
  final String time;
  final int calories;
  final String mealType;
  final bool isCompleted;

  const MealData({
    required this.emoji,
    required this.name,
    required this.description,
    required this.time,
    required this.calories,
    required this.mealType,
    this.isCompleted = false,
  });
}
