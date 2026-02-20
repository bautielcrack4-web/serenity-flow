/// Global constants for Yuna Weight Loss app
class AppConstants {
  // Onboarding
  static const int totalOnboardingPages = 45;
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Pricing
  static const String monthlyPlanId = 'yuna_monthly';
  static const String quarterlyPlanId = 'yuna_quarterly';
  static const String annualPlanId = 'yuna_annual';
  static const double monthlyPrice = 14.99;
  static const double quarterlyPrice = 24.99;
  static const double annualPrice = 49.99;

  // Daily goals
  static const int dailyWaterGoal = 8; // glasses
  static const int dailyMealsGoal = 3;

  // Weight loss recommendations
  static const double healthyWeeklyLossMin = 0.5; // kg
  static const double healthyWeeklyLossMax = 1.0; // kg
  static const double healthyWeeklyLossAvg = 0.75; // kg

  // Gamification
  static const int xpPerWorkout = 15;
  static const int xpPerMeditation = 10;
  static const int xpPerDayComplete = 25;
  static const int xpPerWeightLog = 5;
  static const int xpPerStreak = 10;

  // Body types
  static const List<String> bodyTypes = ['apple', 'pear', 'hourglass', 'rectangle'];

  // Activity levels
  static const Map<String, String> activityLevels = {
    'sedentary': 'Sedentaria',
    'light': 'Algo activa',
    'active': 'Activa',
    'very_active': 'Muy activa',
  };

  // Goal types
  static const Map<String, String> goalTypes = {
    'lose_weight': 'Perder peso',
    'tone': 'Tonificar',
    'feel_better': 'Sentirme mejor',
    'energy': 'Recuperar energía',
  };
}
