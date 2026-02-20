/// Daily habit checklist — tracks daily progress for the weight loss journey.
class DailyChecklist {
  final String id;
  final String userId;
  final DateTime date;
  int waterGlasses;
  bool workoutDone;
  bool meditationDone;
  int mealsLogged;
  int? sleepQuality; // 1-5
  String? mood;       // 'great', 'good', 'okay', 'bad'

  DailyChecklist({
    required this.id,
    required this.userId,
    required this.date,
    this.waterGlasses = 0,
    this.workoutDone = false,
    this.meditationDone = false,
    this.mealsLogged = 0,
    this.sleepQuality,
    this.mood,
  });

  /// Completion percentage (0.0 - 1.0)
  double get completionRate {
    int total = 4; // water(8+), workout, meditation, meals(3+)
    int done = 0;
    if (waterGlasses >= 8) done++;
    if (workoutDone) done++;
    if (meditationDone) done++;
    if (mealsLogged >= 3) done++;
    return done / total;
  }

  /// Is every habit completed?
  bool get isComplete => completionRate >= 1.0;

  factory DailyChecklist.fromMap(Map<String, dynamic> map) {
    return DailyChecklist(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      waterGlasses: map['water_glasses'] ?? 0,
      workoutDone: map['workout_done'] ?? false,
      meditationDone: map['meditation_done'] ?? false,
      mealsLogged: map['meals_logged'] ?? 0,
      sleepQuality: map['sleep_quality'],
      mood: map['mood'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'water_glasses': waterGlasses,
      'workout_done': workoutDone,
      'meditation_done': meditationDone,
      'meals_logged': mealsLogged,
      'sleep_quality': sleepQuality,
      'mood': mood,
    };
  }

  /// Create an empty checklist for today
  factory DailyChecklist.empty(String userId) {
    return DailyChecklist(
      id: '',
      userId: userId,
      date: DateTime.now(),
    );
  }
}
