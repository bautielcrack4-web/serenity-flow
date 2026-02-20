/// Complete user profile for the weight loss journey
class UserProfile {
  final String id;
  String? displayName;
  String? goalType;       // 'lose_weight', 'tone', 'feel_better', 'energy'
  double? targetWeight;
  double? currentWeight;
  double? height;
  int? age;
  String? bodyType;       // 'apple', 'pear', 'hourglass', 'rectangle'
  String? activityLevel;  // 'sedentary', 'light', 'active', 'very_active'
  bool? cycleRegular;
  int? stressLevel;       // 1-10
  String? sleepHours;     // '<5', '5-6', '7-8', '8+'
  String? emotionalEating; // 'always', 'sometimes', 'rarely'
  List<String> dietaryRestrictions; // ['vegetarian', 'gluten_free', etc.]
  String? preferredExercise; // 'yoga', 'walking', 'hiit', 'gym', 'none'
  bool onboardingCompleted;
  DateTime? planGeneratedAt;
  DateTime? targetDate;
  int totalXP;
  int currentStreak;
  bool isPro;

  UserProfile({
    required this.id,
    this.displayName,
    this.goalType,
    this.targetWeight,
    this.currentWeight,
    this.height,
    this.age,
    this.bodyType,
    this.activityLevel,
    this.cycleRegular,
    this.stressLevel,
    this.sleepHours,
    this.emotionalEating,
    this.dietaryRestrictions = const [],
    this.preferredExercise,
    this.onboardingCompleted = false,
    this.planGeneratedAt,
    this.targetDate,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.isPro = false,
  });

  /// BMI calculation
  double? get bmi {
    if (currentWeight != null && height != null && height! > 0) {
      final heightInMeters = height! / 100;
      return currentWeight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  /// Weight to lose
  double? get weightToLose {
    if (currentWeight != null && targetWeight != null) {
      return currentWeight! - targetWeight!;
    }
    return null;
  }

  /// Estimated weeks to goal (0.5-1kg per week)
  int? get estimatedWeeksToGoal {
    final toLose = weightToLose;
    if (toLose != null && toLose > 0) {
      return (toLose / 0.75).ceil(); // ~0.75kg/week average
    }
    return null;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      displayName: map['display_name'],
      goalType: map['goal_type'],
      targetWeight: (map['target_weight'] as num?)?.toDouble(),
      currentWeight: (map['current_weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      age: map['age'],
      bodyType: map['body_type'],
      activityLevel: map['activity_level'],
      cycleRegular: map['cycle_regular'],
      stressLevel: map['stress_level'],
      sleepHours: map['sleep_hours'],
      emotionalEating: map['emotional_eating'],
      dietaryRestrictions: map['dietary_restrictions'] != null
          ? List<String>.from(map['dietary_restrictions'])
          : [],
      preferredExercise: map['preferred_exercise'],
      onboardingCompleted: map['onboarding_completed'] ?? false,
      planGeneratedAt: map['plan_generated_at'] != null
          ? DateTime.parse(map['plan_generated_at'])
          : null,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'])
          : null,
      totalXP: map['total_xp'] ?? 0,
      currentStreak: map['current_streak'] ?? 0,
      isPro: map['is_pro'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'goal_type': goalType,
      'target_weight': targetWeight,
      'current_weight': currentWeight,
      'height': height,
      'age': age,
      'body_type': bodyType,
      'activity_level': activityLevel,
      'cycle_regular': cycleRegular,
      'stress_level': stressLevel,
      'sleep_hours': sleepHours,
      'emotional_eating': emotionalEating,
      'dietary_restrictions': dietaryRestrictions,
      'preferred_exercise': preferredExercise,
      'onboarding_completed': onboardingCompleted,
      'plan_generated_at': planGeneratedAt?.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
    };
  }
}
