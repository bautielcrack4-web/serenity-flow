/// Accumulates all quiz responses during the 45-screen onboarding flow.
/// Gets saved to Supabase as JSON and used to populate UserProfile + generate plan.
class OnboardingData {
  final Map<String, dynamic> _responses = {};

  OnboardingData();

  // Phase 1: Emotional Hook
  String? get goalType => _responses['goal_type'];
  String? get motivation => _responses['motivation'];
  String? get previousAttempts => _responses['previous_attempts'];

  // Phase 2: Body Profile
  int? get age => _responses['age'];
  double? get height => _responses['height'];
  double? get currentWeight => _responses['current_weight'];
  double? get targetWeight => _responses['target_weight'];
  String? get bodyType => _responses['body_type'];
  bool? get cycleRegular => _responses['cycle_regular'];

  // Phase 3: Eating Habits
  String? get mealsPerDay => _responses['meals_per_day'];
  int? get waterGlasses => _responses['water_glasses'];
  List<String> get dietaryRestrictions =>
      List<String>.from(_responses['dietary_restrictions'] ?? []);
  String? get snackingTime => _responses['snacking_time'];
  String? get emotionalEating => _responses['emotional_eating'];
  String? get cookingPreference => _responses['cooking_preference'];

  // Phase 4: Wellness
  int? get stressLevel => _responses['stress_level'];
  String? get sleepHours => _responses['sleep_hours'];
  String? get activityLevel => _responses['activity_level'];
  String? get preferredExercise => _responses['preferred_exercise'];
  String? get mindfulnessExperience => _responses['mindfulness_experience'];

  // Phase 5+: Plan & Commitment
  String? get displayName => _responses['display_name'];
  String? get email => _responses['email'];
  bool get notificationsAccepted => _responses['notifications_accepted'] ?? false;

  /// Set a response value
  void set(String key, dynamic value) {
    _responses[key] = value;
  }

  /// Get a response value
  dynamic get(String key) => _responses[key];

  /// Check if a key has been answered
  bool hasAnswer(String key) => _responses.containsKey(key);

  /// Get all responses as JSON for saving to Supabase
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_responses);

  /// Total questions answered (for progress tracking)
  int get answeredCount => _responses.length;

  /// Convert to UserProfile fields map for Supabase update
  Map<String, dynamic> toProfileMap() {
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
      'onboarding_completed': true,
      'plan_generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Load from saved JSON
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    final data = OnboardingData();
    json.forEach((key, value) => data.set(key, value));
    return data;
  }
}
