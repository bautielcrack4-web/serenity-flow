import 'dart:ui' show PlatformDispatcher;

/// 🌐 Yuna Localization — English / Spanish
/// Usage: L10n.s.someKey
/// Initialize once via L10n.init() before runApp()
class L10n {
  static late Strings _current;

  /// Call this ONCE before runApp()
  static void init() {
    final languageCode = PlatformDispatcher.instance.locale.languageCode;
    _current = languageCode == 'es' ? _EsStrings() : _EnStrings();
  }

  static Strings get s => _current;

  /// Current language code (e.g. 'es' or 'en')
  static String get locale => PlatformDispatcher.instance.locale.languageCode;
}

abstract class Strings {
  // ── SHARED ──────────────────────────────────────────────────────
  String get continueBtn;
  String get yearsUnit;
  String get cmUnit;
  String get kgUnit;
  String get glassesUnit;

  // ── PHASE 1 ──────────────────────────────────────────────────────
  String get p1WelcomeTitle;
  String get p1WelcomeSubtitle;

  String get p1GoalQuestion;
  String get p1GoalSubtitle;
  String get p1GoalLoseWeight;
  String get p1GoalTone;
  String get p1GoalFeelBetter;
  String get p1GoalEnergy;

  String get p1InfoTitle;
  String get p1InfoFact;

  String get p1MotivationQuestion;
  String get p1MotivationSubtitle;
  String get p1MotivEvent;
  String get p1MotivHealth;
  String get p1MotivConfidence;
  String get p1MotivClothes;
  String get p1MotivFreshStart;

  String get p1PrevQuestion;
  String get p1PrevSubtitle;
  String get p1PrevMany;
  String get p1PrevFew;
  String get p1PrevFirst;

  // ── PHASE 2 ──────────────────────────────────────────────────────
  String get p2AgeQuestion;
  String get p2AgeSubtitle;
  String get p2HeightQuestion;
  String get p2HeightSubtitle;
  String get p2CurrWeightQuestion;
  String get p2CurrWeightSubtitle;
  String get p2TargetWeightQuestion;
  String get p2TargetWeightSubtitle;

  String get p2MetabolismTitle;
  String get p2MetabolismFact;

  String get p2BodyTypeQuestion;
  String get p2BodyTypeSubtitle;
  String get p2BodyApple;
  String get p2BodyAppleDesc;
  String get p2BodyPear;
  String get p2BodyPearDesc;
  String get p2BodyHourglass;
  String get p2BodyHourglassDesc;
  String get p2BodyRectangle;
  String get p2BodyRectangleDesc;

  String get p2CycleQuestion;
  String get p2CycleSubtitle;
  String get p2CycleYes;
  String get p2CycleNo;
  String get p2CycleUnsure;
  String get p2CycleNA;

  // ── PHASE 3 ──────────────────────────────────────────────────────
  String get p3MealsQuestion;
  String get p3Meals12;
  String get p3Meals3;
  String get p3Meals45;
  String get p3MealsIrregular;

  String get p3WaterQuestion;

  String get p3WaterInfoTitle;
  String get p3WaterInfoFact;

  String get p3DietQuestion;
  String get p3DietSubtitle;
  String get p3DietVegetarian;
  String get p3DietVegan;
  String get p3DietGlutenFree;
  String get p3DietLactoseFree;
  String get p3DietNutFree;
  String get p3DietNone;

  String get p3SnackQuestion;
  String get p3SnackNever;
  String get p3SnackMorning;
  String get p3SnackAfternoon;
  String get p3SnackNight;
  String get p3SnackAllDay;

  String get p3EmotionalQuestion;
  String get p3EmotionalSubtitle;
  String get p3EmotionalAlways;
  String get p3EmotionalSometimes;
  String get p3EmotionalRarely;

  String get p3CookingQuestion;
  String get p3CookingLove;
  String get p3CookingNecessity;
  String get p3CookingNo;

  String get p3YunaInfoTitle;
  String get p3YunaInfoFact;

  // ── PHASE 4 ──────────────────────────────────────────────────────
  String get p4StressQuestion;
  String get p4StressVeryRelaxed;
  String get p4StressSome;
  String get p4StressModerate;
  String get p4StressPretty;
  String get p4StressVery;

  String get p4SleepQuestion;
  String get p4SleepLess5;
  String get p4Sleep56;
  String get p4Sleep78;
  String get p4SleepMore8;

  String get p4SleepInfoTitle;
  String get p4SleepInfoFact;

  String get p4ActivityQuestion;
  String get p4ActivitySedentary;
  String get p4ActivityLight;
  String get p4ActivityActive;
  String get p4ActivityVeryActive;

  String get p4ExerciseQuestion;
  String get p4ExerciseSubtitle;
  String get p4ExerciseYoga;
  String get p4ExerciseWalking;
  String get p4ExerciseHiit;
  String get p4ExerciseGym;
  String get p4ExerciseDance;
  String get p4ExerciseNone;

  String get p4MindfulnessQuestion;
  String get p4MindfulnessYes;
  String get p4MindfulnessSome;
  String get p4MindfulnessNever;

  String get p4BreathingTitle;
  String get p4BreathingSubtitle;
  String get p4BreathingInhale;
  String get p4BreathingExhale;

  // ── PHASE 5 ──────────────────────────────────────────────────────
  String get p5LoadingTitle;
  String get p5FactorMetabolism;
  String get p5FactorStress;
  String get p5FactorEating;
  String get p5FactorHormonal;
  String get p5FactorActivity;
  String get p5FactorSleep;
  String get p5FactorBodyType;
  String get p5FactorGoals;

  String get p5ProfileTitle;
  String get p5ProfileSubtitle;
  String get p5ProfileGoalLabel;
  String get p5ProfileGoalLoseWeight;
  String get p5ProfileGoalTone;
  String get p5ProfileGoalWellness;
  String get p5ProfileCurrentWeight;
  String get p5ProfileTargetWeight;
  String get p5ProfileHeight;
  String get p5ProfileStress;
  String get p5ProfileActivity;
  String get p5ViewPlanBtn;

  String get p5ProjectionTitle;
  String get p5Week2Milestone;
  String get p5Week2Desc;
  String get p5HalfwayMilestoneDesc;
  String get p5GoalMilestoneDesc;
  String get p5ViewFullPlanBtn;
  String get p5Today;
  String get p5WeekLabel;

  String get p5SocialProofTitle;
  String get p5SocialProofFact;

  String get p5PlanTitle;
  String get p5PlanAiBadge;
  String get p5PlanPhase1Title;
  String get p5PlanPhase1DescStress;
  String get p5PlanPhase1DescNormal;
  String get p5PlanPhase1Tag;
  String get p5PlanPhase2Title;
  String get p5PlanPhase2DescEmotional;
  String get p5PlanPhase2DescNormal;
  String get p5PlanPhase2Tag;
  String get p5PlanPhase3Title;
  String get p5PlanPhase3Tag;
  String get p5PlanPhase4Title;
  String get p5PlanPhase4Tag;

  String get p5FeaturesTitle;
  String get p5FeatureAiBadge;
  String get p5FeatureMeditationTitle;
  String get p5FeatureMeditationDescHigh;
  String get p5FeatureMeditationDescNormal;
  String get p5FeatureEmotionalTitle;
  String get p5FeatureEmotionalDesc;
  String get p5FeatureRecipesTitle;
  String get p5FeatureRecipesDescRestricted;
  String get p5FeatureRecipesDescNormal;
  String get p5FeatureTrackingTitle;
  String get p5FeatureTrackingDesc;
  String get p5FeatureWorkoutsBeginnerTitle;
  String get p5FeatureWorkoutsBeginnerDescSedentary;
  String get p5FeatureWorkoutsBeginnerDescLight;
  String get p5FeatureWorkoutsTitle;
  String get p5FeatureSleepTitle;
  String get p5ForYouTag;

  String get p5ComparisonTitle;
  String get p5ComparisonWithTitle;
  String get p5ComparisonWithoutTitle;
  String get p5WithoutRestrictive;
  String get p5WithoutEmotional;
  String get p5WithoutRebound;
  String get p5WithoutSlow;
  String get p5WithPlanWeeks;
  String get p5WithAntiStress;
  String get p5WithLastingResults;
  String get p5WithGoalKg;
  String get p5WantYunaBtn;

  String get p5ConfirmReady;
  String get p5ConfirmTitle;
  String get p5ConfirmBtn;
  String get p5ConfirmContinueBtn;
  String get p5BlueprintGoal;
  String get p5BlueprintDuration;
  String get p5BlueprintWeeks;
  String get p5BlueprintIncludes;
  String get p5BlueprintIncludesValue;
  String get p5BlueprintIntensity;
  String get p5BlueprintIntensityGradual;
  String get p5BlueprintIntensityModerate;
  String get p5BlueprintExtra;
  String get p5BlueprintAntiStress;

  String get p5NameTitle;
  String get p5NameSubtitle;
  String get p5NameHint;
  String get p5NameContinueBtn;

  String get p5PlanPhase3DescLowSleep;
  String get p5PlanPhase3DescNormal;
  String get p5PlanPhase4Desc;
  String get p5CreatedForYou;

  // ── PHASE 6 ──────────────────────────────────────────────────────
  String get p6TestimonialsTitle;
  String get p6TestimonialsSubtitle;
  String get p6Testimonial1Name;
  String get p6Testimonial1Text;
  String get p6Testimonial2Name;
  String get p6Testimonial2Text;
  String get p6Testimonial3Name;
  String get p6Testimonial3Text;

  String get p6CommitmentReady;
  String get p6CommitmentReadyNamed;
  String get p6CommitmentSubtitle;
  String get p6CommitmentBtn;

  String get p6UrgencyTitle;
  String get p6UrgencyFact;

  String get p6NotificationsTitle;
  String get p6NotificationsSubtitle;
  String get p6NotificationsBtn;
  String get p6NotificationsSkip;

  String get p6PlanReadyTitle;
  String get p6PlanReadyNamed;
  String get p6PlanGeneratedMin;
  String get p6ActiveUsersLabel;
  String get p6PlanSummary;
  String get p6ActivatePlanBtn;

  // ── PHASE 7 (PAYWALL) ─────────────────────────────────────────────
  String get p7FeatureAntiStress;
  String get p7FeatureEmotionalControl;
  String get p7FeatureAdaptedRecipes;
  String get p7FeatureYogaMeditation;
  String get p7FeatureSmartTracking;

  String get p7PlanReadyNamed;
  String get p7PlanReady;
  String get p7ActivateBtn;
  String get p7TrialInfo;
  String get p7RestoreBtn;
  String get p7TermsBtn;
  String get p7PrivacyBtn;

  String get p7PlanAnnual;
  String get p7PlanQuarterly;
  String get p7PlanMonthly;
  String get p7PerMonth;
  String get p7PerYear;
  String get p7PerQuarter;
  String get p7BestValue;
  String get p7Save72;

  String get p7GuaranteeTitle;
  String get p7GuaranteeSubtitle;
  String get p7GuaranteeFreeTrial;
  String get p7GuaranteeCancelOneTap;
  String get p7GuaranteeNoHiddenFees;

  String get p7AllInOneTitle;
  String get p7MeditationApp;
  String get p7Nutritionist;
  String get p7FitnessApp;
  String get p7PersonalCoach;
  String get p7YunaCompletePlan;
  String get p7PersonalizedWeeks;

  String get p7FinalReadyNamed;
  String get p7FinalReady;
  String get p7FinalSubtitle;
  String get p7ActivatePlanBtn;

  String get p7ExitWaitNamed;
  String get p7ExitWait;
  String get p7ExitDiscountMsg;
  String get p7ExitPriceComparison;
  String get p7ExitWantOffer;
  String get p7ExitDecline;

  // ── DASHBOARD ─────────────────────────────────────────────────────
  String get dashGoodMorning;
  String get dashGoodAfternoon;
  String get dashGoodEvening;
  String get dashTodayProgress;
  String get dashYourGoal;
  String get dashLostThisWeek;
  String get dashChecklist;
  String get dashWater;
  String get dashWorkout;
  String get dashMeditation;
  String get dashMeals;
  String get dashMealsUnit;
  String get dashTodayPlan;
  String get dashPlanHiit;
  String get dashPlanSalad;
  String get dashPlanLunch;
  String get dashPlanBreathing;
  String get dashPlanSleep;
  String get dashMotivationalQuote;

  // ── BOTTOM NAV ────────────────────────────────────────────────────
  String get navHome;
  String get navWorkouts;
  String get navMindfulness;
  String get navNutrition;
  String get navProgress;

  // ── NUTRITION ──────────────────────────────────────────────────────
  String get nutTitle;
  String get nutSubtitle;
  String get nutMacrosToday;
  String get nutCalLabel;
  String get nutProteins;
  String get nutCarbs;
  String get nutFats;
  String get nutWater;
  String get nutGlasses;
  String get nutMealsTitle;
  String get nutBreakfast;
  String get nutBreakfastDesc;
  String get nutMorningSnack;
  String get nutMorningSnackDesc;
  String get nutLunch;
  String get nutLunchDesc;
  String get nutAfternoonSnack;
  String get nutAfternoonSnackDesc;
  String get nutDinner;
  String get nutDinnerDesc;

  // ── MINDFULNESS ────────────────────────────────────────────────────
  String get mindTitle;
  String get mindSubtitle;
  String get mindQuickBreathing;
  String get mindQuickBreathingDesc;
  String get mindStartNow;
  String get mindCalm;
  String get mindMeditations;
  String get mindMorningMeditation;
  String get mindMorningMeditationDesc;
  String get mindInnerCalm;
  String get mindInnerCalmDesc;
  String get mindBodyScan;
  String get mindBodyScanDesc;
  String get mindGoalVisualization;
  String get mindGoalVisualizationDesc;
  String get mindSleepRoutines;
  String get mindBedtimeRoutine;
  String get mindBedtimeRoutineDesc;
  String get mindNatureSounds;
  String get mindNatureSoundsDesc;
  String get mindNightBodyScan;
  String get mindNightBodyScanDesc;
  String get mindEmotionalEating;
  String get mindPauseBeforeEating;
  String get mindPauseBeforeEatingDesc;
  String get mindEmotionDiary;
  String get mindEmotionDiaryDesc;
  String get mindSweetCraving;
  String get mindSweetCravingDesc;

  // ── PROFILE ────────────────────────────────────────────────────────
  String get profTitle;
  String get profActivePlan;
  String get profWeightProgress;
  String get profLast8Weeks;
  String get profTotalLost;
  String get profDayStreak;
  String get profWorkouts;
  String get profSessions;
  String get profAchievements;
  String get profAch7Days;
  String get profAchHydrated;
  String get profAch10Workouts;
  String get profAchZenMaster;
  String get profAch5kg;
  String get profAch30Days;
  String get profSettings;
  String get profEditProfile;
  String get profGoals;
  String get profNotifications;
  String get profSubscription;
  String get profHelp;
  String get profLogout;

  // ── SETTINGS ─────────────────────────────────────────────────────
  String get setTitle;
  String get setSession;
  String get setPoseDuration;
  String get setPreferences;
  String get setSound;
  String get setHaptics;
  String get setNotificationsSection;
  String get setReminders;
  String get setLegal;
  String get setPrivacyPolicy;
  String get setTermsOfService;
  String get setResetData;
  String get setDeleteAccount;
  String get setDeleteConfirmTitle;
  String get setDeleteConfirmMessage;
  String get setDeleteCancel;
  String get setDeleteConfirm;
  String get setProtectProgress;
  String get setProtectDesc;
  String get setUnlockPro;
  String get setUnlockProDesc;
  String get setAccountLinked;
  String get setSignInFailed;

  // ── QUESTIONNAIRE ────────────────────────────────────────────────
  String get questQ1;
  String get questQ2;
  String get questQ3;
  String get questQ4;
  String get questQ5;
  String get questQ6;
  String get questQ7;
  String get questQ8;
  // Q1 options
  String get questFlexibility;
  String get questStrength;
  String get questRelaxation;
  String get questMeditationOpt;
  // Q2 options
  String get questNever;
  String get questOccasionally;
  String get questRegularly;
  String get questDaily;
  // Q3 options
  String get questLowEnergy;
  String get questMediumEnergy;
  String get questHighEnergy;
  String get questLotsEnergy;
  // Q4 options
  String get questBack;
  String get questNeck;
  String get questKnees;
  String get questNone;
  // Q5 options
  String get questLowStress;
  String get questMediumStress;
  String get questHighStress;
  // Q6 options
  String get questTime5;
  String get questTime15;
  String get questTime30;
  // Q7 options
  String get questGuided;
  String get questSilent;
  String get questSoftMusic;
  // Q8
  String get questStartNow;

  // ── COMPLETION ───────────────────────────────────────────────────
  String get compSessionCompleted;
  String get compBodyMindBalance;
  String get compMinutes;
  String get compStreak;
  String get compDailyGoal;
  String get compShareVictory;
  String get compBackToHome;
  String get compStartPractice;
  String get compRateUs;
  String get compRateMessage;
  String get compLater;
  String get compRateNow;
  String get compShareSimulated;
}

// ═══════════════════════════════════════════════════════════════════
// ENGLISH
// ═══════════════════════════════════════════════════════════════════
class _EnStrings extends Strings {
  // SHARED
  @override String get continueBtn => 'Continue';
  @override String get yearsUnit => 'years';
  @override String get cmUnit => 'cm';
  @override String get kgUnit => 'kg';
  @override String get glassesUnit => 'glasses';

  // PHASE 1
  @override String get p1WelcomeTitle => 'Welcome to Yuna';
  @override String get p1WelcomeSubtitle => 'Yuna was designed for you.\nNot a diet. Your transformation.';

  @override String get p1GoalQuestion => 'What is your main goal?';
  @override String get p1GoalSubtitle => 'This helps us personalize your experience';
  @override String get p1GoalLoseWeight => 'Lose weight';
  @override String get p1GoalTone => 'Tone my body';
  @override String get p1GoalFeelBetter => 'Feel better about myself';
  @override String get p1GoalEnergy => 'Regain my energy';

  @override String get p1InfoTitle => 'Important stat';
  @override String get p1InfoFact => '78% of women who follow personalized plans achieve sustainable results vs only 23% with generic diets.';

  @override String get p1MotivationQuestion => 'What motivates you to make this change?';
  @override String get p1MotivationSubtitle => 'No wrong answer 💜';
  @override String get p1MotivEvent => 'A special event';
  @override String get p1MotivHealth => 'My health';
  @override String get p1MotivConfidence => 'Confidence in myself';
  @override String get p1MotivClothes => 'Fit into my favorite clothes';
  @override String get p1MotivFreshStart => 'A fresh start';

  @override String get p1PrevQuestion => 'Have you tried to lose weight before?';
  @override String get p1PrevSubtitle => 'We want to understand your experience';
  @override String get p1PrevMany => 'Many times, without lasting results';
  @override String get p1PrevFew => 'A few times';
  @override String get p1PrevFirst => 'This is my first time';

  // PHASE 2
  @override String get p2AgeQuestion => 'How old are you?';
  @override String get p2AgeSubtitle => 'Your age influences your metabolism';
  @override String get p2HeightQuestion => 'How tall are you?';
  @override String get p2HeightSubtitle => 'We need this to calculate your plan';
  @override String get p2CurrWeightQuestion => 'What is your current weight?';
  @override String get p2CurrWeightSubtitle => 'This is 100% private 🔒';
  @override String get p2TargetWeightQuestion => 'What is your target weight?';
  @override String get p2TargetWeightSubtitle => 'Experts recommend realistic, progressive goals';

  @override String get p2MetabolismTitle => 'Your metabolism is unique';
  @override String get p2MetabolismFact => "That's why Yuna analyzes 15+ factors to create a plan that works specifically FOR YOU. No two plans are the same.";

  @override String get p2BodyTypeQuestion => 'What is your body type?';
  @override String get p2BodyTypeSubtitle => 'This helps us personalize your exercises';
  @override String get p2BodyApple => 'Apple';
  @override String get p2BodyAppleDesc => 'More volume in the torso';
  @override String get p2BodyPear => 'Pear';
  @override String get p2BodyPearDesc => 'More volume in the hips';
  @override String get p2BodyHourglass => 'Hourglass';
  @override String get p2BodyHourglassDesc => 'Balanced proportions';
  @override String get p2BodyRectangle => 'Rectangle';
  @override String get p2BodyRectangleDesc => 'Uniform proportions';

  @override String get p2CycleQuestion => 'Is your menstrual cycle regular?';
  @override String get p2CycleSubtitle => 'This helps us adapt your plan to your hormones';
  @override String get p2CycleYes => 'Yes, it\'s fairly regular';
  @override String get p2CycleNo => 'No, it\'s irregular';
  @override String get p2CycleUnsure => 'I\'m not sure';
  @override String get p2CycleNA => 'Not applicable';

  // PHASE 3
  @override String get p3MealsQuestion => 'How many meals do you eat per day?';
  @override String get p3Meals12 => '1-2 meals';
  @override String get p3Meals3 => '3 meals';
  @override String get p3Meals45 => '4-5 meals';
  @override String get p3MealsIrregular => 'No fixed schedule';

  @override String get p3WaterQuestion => 'How many glasses of water do you drink daily?';

  @override String get p3WaterInfoTitle => 'Did you know?';
  @override String get p3WaterInfoFact => 'Drinking 500ml of water before each meal can increase weight loss by up to 44%. Water boosts metabolism and reduces appetite.';

  @override String get p3DietQuestion => 'Do you have any dietary restrictions?';
  @override String get p3DietSubtitle => 'You can choose more than one';
  @override String get p3DietVegetarian => 'Vegetarian';
  @override String get p3DietVegan => 'Vegan';
  @override String get p3DietGlutenFree => 'Gluten-free';
  @override String get p3DietLactoseFree => 'Lactose-free';
  @override String get p3DietNutFree => 'Nut-free';
  @override String get p3DietNone => 'No restrictions';

  @override String get p3SnackQuestion => 'When do you usually snack between meals?';
  @override String get p3SnackNever => 'Almost never';
  @override String get p3SnackMorning => 'Mid-morning';
  @override String get p3SnackAfternoon => 'Afternoon';
  @override String get p3SnackNight => 'At night';
  @override String get p3SnackAllDay => 'All day';

  @override String get p3EmotionalQuestion => 'Do you eat more when you\'re stressed or sad?';
  @override String get p3EmotionalSubtitle => 'Be honest, this is here to help you 💜';
  @override String get p3EmotionalAlways => 'Yes, it always happens to me';
  @override String get p3EmotionalSometimes => 'Sometimes';
  @override String get p3EmotionalRarely => 'Rarely';

  @override String get p3CookingQuestion => 'Do you enjoy cooking?';
  @override String get p3CookingLove => 'I love cooking';
  @override String get p3CookingNecessity => 'I do it out of necessity';
  @override String get p3CookingNo => 'I prefer delivery or quick meals';

  @override String get p3YunaInfoTitle => 'Yuna is different';
  @override String get p3YunaInfoFact => "Yuna combines smart nutrition with mindfulness. It's not about restriction — it's about awareness. We'll transform your relationship with food.";

  // PHASE 4
  @override String get p4StressQuestion => 'How would you describe your stress level?';
  @override String get p4StressVeryRelaxed => 'Very relaxed';
  @override String get p4StressSome => 'Some stress';
  @override String get p4StressModerate => 'Moderate stress';
  @override String get p4StressPretty => 'Pretty stressed';
  @override String get p4StressVery => 'Very stressed';

  @override String get p4SleepQuestion => 'How many hours do you sleep per night?';
  @override String get p4SleepLess5 => 'Less than 5 hours';
  @override String get p4Sleep56 => '5-6 hours';
  @override String get p4Sleep78 => '7-8 hours';
  @override String get p4SleepMore8 => 'More than 8 hours';

  @override String get p4SleepInfoTitle => 'Sleep & hunger';
  @override String get p4SleepInfoFact => 'Lack of sleep increases ghrelin (hunger hormone) by 28% and reduces leptin (satiety hormone). Yuna helps you sleep better to lose weight naturally.';

  @override String get p4ActivityQuestion => 'What is your activity level?';
  @override String get p4ActivitySedentary => 'Sedentary (little movement)';
  @override String get p4ActivityLight => 'Somewhat active (I walk regularly)';
  @override String get p4ActivityActive => 'Active (exercise 3-4 times/week)';
  @override String get p4ActivityVeryActive => 'Very active (daily exercise)';

  @override String get p4ExerciseQuestion => 'What type of exercise appeals to you most?';
  @override String get p4ExerciseSubtitle => 'We\'ll personalize your plan based on your preference';
  @override String get p4ExerciseYoga => 'Yoga & stretching';
  @override String get p4ExerciseWalking => 'Walking';
  @override String get p4ExerciseHiit => 'HIIT (high intensity)';
  @override String get p4ExerciseGym => 'Gym & weights';
  @override String get p4ExerciseDance => 'Dance & cardio';
  @override String get p4ExerciseNone => 'I don\'t like exercising';

  @override String get p4MindfulnessQuestion => 'Have you ever practiced meditation or conscious breathing?';
  @override String get p4MindfulnessYes => 'Yes, regularly';
  @override String get p4MindfulnessSome => 'A little, but not consistently';
  @override String get p4MindfulnessNever => 'Never tried it';

  @override String get p4BreathingTitle => 'Breathe with Yuna';
  @override String get p4BreathingSubtitle => 'Meditation reduces cortisol, which causes abdominal fat accumulation';
  @override String get p4BreathingInhale => 'Inhale';
  @override String get p4BreathingExhale => 'Exhale';

  // PHASE 5
  @override String get p5LoadingTitle => 'Analyzing your profile...';
  @override String get p5FactorMetabolism => 'Metabolism';
  @override String get p5FactorStress => 'Stress level';
  @override String get p5FactorEating => 'Eating habits';
  @override String get p5FactorHormonal => 'Hormonal cycle';
  @override String get p5FactorActivity => 'Activity level';
  @override String get p5FactorSleep => 'Sleep quality';
  @override String get p5FactorBodyType => 'Body type';
  @override String get p5FactorGoals => 'Personal goals';

  @override String get p5ProfileTitle => 'Your Yuna Profile';
  @override String get p5ProfileSubtitle => 'Created exclusively for you ✨';
  @override String get p5ProfileGoalLabel => 'Goal';
  @override String get p5ProfileGoalLoseWeight => 'Lose weight';
  @override String get p5ProfileGoalTone => 'Tone';
  @override String get p5ProfileGoalWellness => 'Wellness';
  @override String get p5ProfileCurrentWeight => 'Current weight';
  @override String get p5ProfileTargetWeight => 'Target weight';
  @override String get p5ProfileHeight => 'Height';
  @override String get p5ProfileStress => 'Stress';
  @override String get p5ProfileActivity => 'Activity';
  @override String get p5ViewPlanBtn => 'See my plan';

  @override String get p5ProjectionTitle => 'Your projection';
  @override String get p5Week2Milestone => 'Week 2';
  @override String get p5Week2Desc => 'First visible changes';
  @override String get p5HalfwayMilestoneDesc => 'Accelerating results';
  @override String get p5GoalMilestoneDesc => 'Goal reached';
  @override String get p5ViewFullPlanBtn => 'See my full plan';
  @override String get p5Today => 'Today';
  @override String get p5WeekLabel => 'Week';

  @override String get p5SocialProofTitle => 'Real results';
  @override String get p5SocialProofFact => '87% of women with a similar profile achieved their goal with Yuna within the estimated time.';

  @override String get p5PlanTitle => 'Your personalized plan';
  @override String get p5PlanAiBadge => 'AI analyzed your 8 factors';
  @override String get p5PlanPhase1Title => 'Week 1-2: Adaptation';
  @override String get p5PlanPhase1DescStress => 'Relaxation techniques to lower your stress';
  @override String get p5PlanPhase1DescNormal => 'Your body adjusts to the new plan gently';
  @override String get p5PlanPhase1Tag => 'Based on your profile';
  @override String get p5PlanPhase2Title => 'Week 3-6: Acceleration';
  @override String get p5PlanPhase2DescEmotional => 'Tools to manage emotional eating';
  @override String get p5PlanPhase2DescNormal => 'Visible results and more energy every day';
  @override String get p5PlanPhase2Tag => 'Personalized';
  @override String get p5PlanPhase3Title => 'Week 3+: Rest';
  @override String get p5PlanPhase3Tag => 'Adapted for you';
  @override String get p5PlanPhase4Title => 'Week 7+: Consolidation';
  @override String get p5PlanPhase4Tag => 'Your goal';

  @override String get p5FeaturesTitle => 'Your plan includes';
  @override String get p5FeatureAiBadge => 'AI-selected for you';
  @override String get p5FeatureMeditationTitle => 'Anti-stress meditations';
  @override String get p5FeatureMeditationDescHigh => 'Your stress is high — we include sessions to lower it';
  @override String get p5FeatureMeditationDescNormal => 'Relaxation sessions for your wellbeing';
  @override String get p5FeatureEmotionalTitle => 'Emotional hunger control';
  @override String get p5FeatureEmotionalDesc => 'You said you eat due to stress/emotions — we have techniques for that';
  @override String get p5FeatureRecipesTitle => 'Adapted recipes';
  @override String get p5FeatureRecipesDescRestricted => 'All recipes respect your dietary restrictions';
  @override String get p5FeatureRecipesDescNormal => 'Easy healthy dishes adapted to your cooking style';
  @override String get p5FeatureTrackingTitle => 'Smart tracking';
  @override String get p5FeatureTrackingDesc => 'Weight, water, habits and progress in one place';
  @override String get p5FeatureWorkoutsBeginnerTitle => 'Beginner workouts';
  @override String get p5FeatureWorkoutsBeginnerDescSedentary => 'We start slow because your level is sedentary';
  @override String get p5FeatureWorkoutsBeginnerDescLight => 'We start slow because your activity level is low';
  @override String get p5FeatureWorkoutsTitle => 'Personalized workouts';
  @override String get p5FeatureSleepTitle => 'Sleep routines';
  @override String get p5ForYouTag => 'For you';

  @override String get p5ComparisonTitle => 'With Yuna vs without a plan';
  @override String get p5ComparisonWithTitle => 'With Yuna ✨';
  @override String get p5ComparisonWithoutTitle => 'Without a plan';
  @override String get p5WithoutRestrictive => 'Restrictive diets';
  @override String get p5WithoutEmotional => 'No emotional support';
  @override String get p5WithoutRebound => 'Rebound effect';
  @override String get p5WithoutSlow => 'Slow and uncertain';
  @override String get p5WithPlanWeeks => '-week plan';
  @override String get p5WithAntiStress => 'Anti-stress included';
  @override String get p5WithLastingResults => 'Lasting results';
  @override String get p5WithGoalKg => 'kg goal';
  @override String get p5WantYunaBtn => 'I want Yuna';

  @override String get p5ConfirmReady => 'Your plan is ready';
  @override String get p5ConfirmTitle => 'This is your plan';
  @override String get p5ConfirmBtn => 'Yes, this is my plan ✨';
  @override String get p5ConfirmContinueBtn => 'Continue ✨';
  @override String get p5BlueprintGoal => 'Goal';
  @override String get p5BlueprintDuration => 'Duration';
  @override String get p5BlueprintWeeks => 'weeks';
  @override String get p5BlueprintIncludes => 'Includes';
  @override String get p5BlueprintIncludesValue => 'Meditation + Yoga + Nutrition';
  @override String get p5BlueprintIntensity => 'Intensity';
  @override String get p5BlueprintIntensityGradual => 'Gradual (adapted for you)';
  @override String get p5BlueprintIntensityModerate => 'Moderate';
  @override String get p5BlueprintExtra => 'Extra';
  @override String get p5BlueprintAntiStress => 'Personalized anti-stress';

  @override String get p5NameTitle => 'What would you like us to call you?';
  @override String get p5NameSubtitle => 'Your name makes your experience more personal 💜';
  @override String get p5NameHint => 'Your name';
  @override String get p5NameContinueBtn => 'Continue';

  @override String get p5PlanPhase3DescLowSleep => 'Sleep routines because you sleep';
  @override String get p5PlanPhase3DescNormal => 'Rest optimization to accelerate results';
  @override String get p5PlanPhase4Desc => 'Solid habits, stable weight at';
  @override String get p5CreatedForYou => 'Created exclusively for you ✨';

  // PHASE 6
  @override String get p6TestimonialsTitle => 'Real stories';
  @override String get p6TestimonialsSubtitle => 'Women who achieved their goal';
  @override String get p6Testimonial1Name => 'Emily, 28';
  @override String get p6Testimonial1Text => 'Lost 12 kg in 3 months. Meditation helped me stop stress eating.';
  @override String get p6Testimonial2Name => 'Sophia, 35';
  @override String get p6Testimonial2Text => 'I finally don\'t feel guilty eating. Yuna changed my relationship with food.';
  @override String get p6Testimonial3Name => 'Mia, 24';
  @override String get p6Testimonial3Text => 'Breathing routines changed my life. Lost 8kg without feeling hungry.';

  @override String get p6CommitmentReady => 'Are you ready?';
  @override String get p6CommitmentReadyNamed => 'Are you ready, {name}?';
  @override String get p6CommitmentSubtitle => 'Your transformation starts today.\nYuna will be with you every day.';
  @override String get p6CommitmentBtn => 'I\'m ready! 🎉';

  @override String get p6UrgencyTitle => 'The first 48 hours are key';
  @override String get p6UrgencyFact => 'Studies show that starting TODAY is 4x more likely to help you reach your goal. Your plan is ready to begin right now.';

  @override String get p6NotificationsTitle => 'Daily reminders';
  @override String get p6NotificationsSubtitle => 'Users with reminders enabled are 3x more successful at reaching their goals.';
  @override String get p6NotificationsBtn => 'Enable reminders';
  @override String get p6NotificationsSkip => 'No thanks';

  @override String get p6PlanReadyTitle => 'Your plan is ready';
  @override String get p6PlanReadyNamed => '{name}, your plan is ready';
  @override String get p6PlanGeneratedMin => 'Plan generated {min} min ago';
  @override String get p6ActiveUsersLabel => 'similar women started today';
  @override String get p6PlanSummary => '{weeks}-week plan optimized for you.\nIf you don\'t start now, results will be delayed.';
  @override String get p6ActivatePlanBtn => 'Activate my plan now';

  // PHASE 7
  @override String get p7FeatureAntiStress => 'Anti-stress';
  @override String get p7FeatureEmotionalControl => 'Emotional control';
  @override String get p7FeatureAdaptedRecipes => 'Adapted recipes';
  @override String get p7FeatureYogaMeditation => 'Yoga + Meditation';
  @override String get p7FeatureSmartTracking => 'Smart tracking';

  @override String get p7PlanReadyNamed => '{name}, your {weeks}-week plan is ready';
  @override String get p7PlanReady => 'Your {weeks}-week plan is ready';
  @override String get p7ActivateBtn => 'Activate my plan';
  @override String get p7TrialInfo => '7-day free trial · Cancel anytime';
  @override String get p7RestoreBtn => 'Restore purchase';
  @override String get p7TermsBtn => 'Terms';
  @override String get p7PrivacyBtn => 'Privacy';

  @override String get p7PlanAnnual => 'Annual Plan';
  @override String get p7PlanQuarterly => 'Quarterly Plan';
  @override String get p7PlanMonthly => 'Monthly Plan';
  @override String get p7PerMonth => '/month';
  @override String get p7PerYear => '/year';
  @override String get p7PerQuarter => '/quarter';
  @override String get p7BestValue => 'BEST VALUE 🔥';
  @override String get p7Save72 => 'Save 72%';

  @override String get p7GuaranteeTitle => 'Risk-free guarantee';
  @override String get p7GuaranteeSubtitle => '7 days free. Cancel anytime.\nNo commitment, no questions asked.';
  @override String get p7GuaranteeFreeTrial => '7-day free trial';
  @override String get p7GuaranteeCancelOneTap => '1-tap cancellation';
  @override String get p7GuaranteeNoHiddenFees => 'No hidden fees';

  @override String get p7AllInOneTitle => 'All-in-one for less';
  @override String get p7MeditationApp => 'Meditation app';
  @override String get p7Nutritionist => 'Nutritionist';
  @override String get p7FitnessApp => 'Fitness app';
  @override String get p7PersonalCoach => 'Personal coach';
  @override String get p7YunaCompletePlan => 'Yuna — Your complete plan';
  @override String get p7PersonalizedWeeks => '{weeks} personalized weeks for you';

  @override String get p7FinalReadyNamed => '{name}, your plan is ready!';
  @override String get p7FinalReady => 'Your plan is ready!';
  @override String get p7FinalSubtitle => 'Start your 7-day free trial\nand reach {target} kg with Yuna.';
  @override String get p7ActivatePlanBtn => 'Activate my plan 🎉';

  @override String get p7ExitWaitNamed => 'Wait, {name}!';
  @override String get p7ExitWait => 'Wait!';
  @override String get p7ExitDiscountMsg => 'Your {weeks}-week plan has an exclusive discount';
  @override String get p7ExitPriceComparison => '\$2.08/month instead of \$4.17';
  @override String get p7ExitWantOffer => 'I want this offer!';
  @override String get p7ExitDecline => 'No, thanks';

  // DASHBOARD
  @override String get dashGoodMorning => 'Good morning';
  @override String get dashGoodAfternoon => 'Good afternoon';
  @override String get dashGoodEvening => 'Good evening';
  @override String get dashTodayProgress => 'Your progress today ✨';
  @override String get dashYourGoal => 'Your goal';
  @override String get dashLostThisWeek => 'lost this week 🎉';
  @override String get dashChecklist => 'Daily checklist';
  @override String get dashWater => 'Drink water';
  @override String get dashWorkout => 'Today\'s workout';
  @override String get dashMeditation => 'Meditation';
  @override String get dashMeals => 'Log meals';
  @override String get dashMealsUnit => 'meals';
  @override String get dashTodayPlan => 'Today\'s plan';
  @override String get dashPlanHiit => 'Fat-Burn HIIT';
  @override String get dashPlanSalad => 'Power Salad';
  @override String get dashPlanLunch => 'Lunch';
  @override String get dashPlanBreathing => '4-7-8 Breathing';
  @override String get dashPlanSleep => 'Sleep Routine';
  @override String get dashMotivationalQuote => '"Progress, not perfection, is what matters."';

  // NAV
  @override String get navHome => 'Home';
  @override String get navWorkouts => 'Workouts';
  @override String get navMindfulness => 'Mindfulness';
  @override String get navNutrition => 'Nutrition';
  @override String get navProgress => 'Progress';

  // NUTRITION
  @override String get nutTitle => 'Nutrition';
  @override String get nutSubtitle => 'Your personalized meal plan';
  @override String get nutMacrosToday => 'Today\'s macros';
  @override String get nutCalLabel => 'cal';
  @override String get nutProteins => 'Protein';
  @override String get nutCarbs => 'Carbs';
  @override String get nutFats => 'Fats';
  @override String get nutWater => 'Water';
  @override String get nutGlasses => 'glasses';
  @override String get nutMealsTitle => 'Today\'s meals';
  @override String get nutBreakfast => 'Breakfast';
  @override String get nutBreakfastDesc => 'Oatmeal with fruits and chia seeds';
  @override String get nutMorningSnack => 'Morning snack';
  @override String get nutMorningSnackDesc => 'Apple with almond butter';
  @override String get nutLunch => 'Lunch';
  @override String get nutLunchDesc => 'Chicken salad with quinoa and avocado';
  @override String get nutAfternoonSnack => 'Afternoon snack';
  @override String get nutAfternoonSnackDesc => 'Greek yogurt with nuts';
  @override String get nutDinner => 'Dinner';
  @override String get nutDinnerDesc => 'Baked salmon with roasted vegetables';

  // MINDFULNESS
  @override String get mindTitle => 'Mind';
  @override String get mindSubtitle => 'Your space for inner peace';
  @override String get mindQuickBreathing => 'Quick Breathing';
  @override String get mindQuickBreathingDesc => 'Reduce cortisol and anxiety in 3 minutes';
  @override String get mindStartNow => 'Start now';
  @override String get mindCalm => 'Calm';
  @override String get mindMeditations => 'Meditations';
  @override String get mindMorningMeditation => 'Morning Meditation';
  @override String get mindMorningMeditationDesc => 'Start your day with clear intention';
  @override String get mindInnerCalm => 'Inner Calm';
  @override String get mindInnerCalmDesc => 'Deep relaxation for stressful moments';
  @override String get mindBodyScan => 'Body Scan';
  @override String get mindBodyScanDesc => 'Connect with your body in 5 minutes';
  @override String get mindGoalVisualization => 'Goal Visualization';
  @override String get mindGoalVisualizationDesc => 'Imagine your best version';
  @override String get mindSleepRoutines => 'Sleep Routines';
  @override String get mindBedtimeRoutine => 'Bedtime Routine';
  @override String get mindBedtimeRoutineDesc => 'Relax body and mind for deep sleep';
  @override String get mindNatureSounds => 'Nature Sounds';
  @override String get mindNatureSoundsDesc => 'Forest, rain and ocean waves';
  @override String get mindNightBodyScan => 'Night Body Scan';
  @override String get mindNightBodyScanDesc => 'Release the day\'s tension';
  @override String get mindEmotionalEating => 'Emotional Eating Management';
  @override String get mindPauseBeforeEating => 'Pause Before Eating';
  @override String get mindPauseBeforeEatingDesc => 'Are you really hungry or emotionally hungry?';
  @override String get mindEmotionDiary => 'Emotion Diary';
  @override String get mindEmotionDiaryDesc => 'Connect your emotions with your eating';
  @override String get mindSweetCraving => 'When You Crave Something Sweet';
  @override String get mindSweetCravingDesc => 'Manage cravings with awareness';

  // PROFILE
  @override String get profTitle => 'Profile';
  @override String get profActivePlan => 'Active plan';
  @override String get profWeightProgress => 'Weight Progress';
  @override String get profLast8Weeks => 'Last 8 weeks';
  @override String get profTotalLost => 'total lost';
  @override String get profDayStreak => 'Day streak';
  @override String get profWorkouts => 'Workouts';
  @override String get profSessions => 'Sessions';
  @override String get profAchievements => 'Achievements';
  @override String get profAch7Days => '7 day streak';
  @override String get profAchHydrated => 'Hydrated';
  @override String get profAch10Workouts => '10 workouts';
  @override String get profAchZenMaster => 'Zen master';
  @override String get profAch5kg => '-5 kg';
  @override String get profAch30Days => '30 days';
  @override String get profSettings => 'Settings';
  @override String get profEditProfile => 'Edit profile';
  @override String get profGoals => 'Goals';
  @override String get profNotifications => 'Notifications';
  @override String get profSubscription => 'Subscription';
  @override String get profHelp => 'Help';
  @override String get profLogout => 'Log out';

  // SETTINGS
  @override String get setTitle => 'Settings';
  @override String get setSession => 'SESSION';
  @override String get setPoseDuration => 'Pose Duration';
  @override String get setPreferences => 'PREFERENCES';
  @override String get setSound => 'Sound';
  @override String get setHaptics => 'Haptics';
  @override String get setNotificationsSection => 'NOTIFICATIONS';
  @override String get setReminders => 'Reminders';
  @override String get setLegal => 'LEGAL';
  @override String get setPrivacyPolicy => 'Privacy Policy';
  @override String get setTermsOfService => 'Terms of Service';
  @override String get setResetData => 'Reset Practice Data';
  @override String get setDeleteAccount => 'Delete Account';
  @override String get setDeleteConfirmTitle => 'Delete Account';
  @override String get setDeleteConfirmMessage => 'Are you sure? This action is irreversible and will delete all your progress.';
  @override String get setDeleteCancel => 'Cancel';
  @override String get setDeleteConfirm => 'Delete';
  @override String get setProtectProgress => 'Protect Your Progress';
  @override String get setProtectDesc => 'Sign in with Apple to save your routines & progress in the cloud';
  @override String get setUnlockPro => 'Unlock Pro Access';
  @override String get setUnlockProDesc => 'Get unlimited access to all advanced yoga routines & premium features';
  @override String get setAccountLinked => 'Account successfully linked! Progress saved. ✅';
  @override String get setSignInFailed => 'Sign in failed';

  // QUESTIONNAIRE
  @override String get questQ1 => 'What is your main goal?';
  @override String get questQ2 => 'How often do you practice yoga?';
  @override String get questQ3 => 'How is your energy today?';
  @override String get questQ4 => 'Any physical discomfort?';
  @override String get questQ5 => 'Current stress level?';
  @override String get questQ6 => 'How much time do you have?';
  @override String get questQ7 => 'Session preference?';
  @override String get questQ8 => 'Ready to start?';
  @override String get questFlexibility => 'Flexibility';
  @override String get questStrength => 'Strength';
  @override String get questRelaxation => 'Relaxation';
  @override String get questMeditationOpt => 'Meditation';
  @override String get questNever => 'Never';
  @override String get questOccasionally => 'Occasionally';
  @override String get questRegularly => 'Regularly';
  @override String get questDaily => 'Daily';
  @override String get questLowEnergy => 'Low';
  @override String get questMediumEnergy => 'Medium';
  @override String get questHighEnergy => 'High';
  @override String get questLotsEnergy => 'Lots of energy';
  @override String get questBack => 'Back';
  @override String get questNeck => 'Neck';
  @override String get questKnees => 'Knees';
  @override String get questNone => 'None';
  @override String get questLowStress => 'Low';
  @override String get questMediumStress => 'Medium';
  @override String get questHighStress => 'High';
  @override String get questTime5 => '5-10 min';
  @override String get questTime15 => '15-20 min';
  @override String get questTime30 => '30+ min';
  @override String get questGuided => 'Guided';
  @override String get questSilent => 'Silent';
  @override String get questSoftMusic => 'Soft Music';
  @override String get questStartNow => 'Start Now!';

  // COMPLETION
  @override String get compSessionCompleted => 'SESSION COMPLETED!';
  @override String get compBodyMindBalance => 'Body and mind in balance';
  @override String get compMinutes => 'Minutes';
  @override String get compStreak => 'Streak';
  @override String get compDailyGoal => 'Daily Goal';
  @override String get compShareVictory => 'SHARE VICTORY';
  @override String get compBackToHome => 'BACK TO HOME';
  @override String get compStartPractice => 'START PRACTICE';
  @override String get compRateUs => 'Rate Us';
  @override String get compRateMessage => 'Thank you! Being a 5-star app helps us reach more people. Would you help us out?';
  @override String get compLater => 'Later';
  @override String get compRateNow => 'Rate Now';
  @override String get compShareSimulated => 'Opening share menu... (Simulated)';
}

// ═══════════════════════════════════════════════════════════════════
// SPANISH
// ═══════════════════════════════════════════════════════════════════
class _EsStrings extends Strings {
  // SHARED
  @override String get continueBtn => 'Continuar';
  @override String get yearsUnit => 'años';
  @override String get cmUnit => 'cm';
  @override String get kgUnit => 'kg';
  @override String get glassesUnit => 'vasos';

  // PHASE 1
  @override String get p1WelcomeTitle => 'Bienvenida a Yuna';
  @override String get p1WelcomeSubtitle => 'Yuna fue diseñada para vos.\nNo es una dieta. Es tu transformación.';
  @override String get p1GoalQuestion => '¿Cuál es tu objetivo principal?';
  @override String get p1GoalSubtitle => 'Esto nos ayuda a personalizar tu experiencia';
  @override String get p1GoalLoseWeight => 'Perder peso';
  @override String get p1GoalTone => 'Tonificar mi cuerpo';
  @override String get p1GoalFeelBetter => 'Sentirme mejor conmigo misma';
  @override String get p1GoalEnergy => 'Recuperar mi energía';

  @override String get p1InfoTitle => 'Dato importante';
  @override String get p1InfoFact => 'El 78% de las mujeres que siguen planes personalizados logran resultados sostenibles, vs solo el 23% con dietas genéricas.';

  @override String get p1MotivationQuestion => '¿Qué te motiva a hacer este cambio?';
  @override String get p1MotivationSubtitle => 'No hay respuesta incorrecta 💜';
  @override String get p1MotivEvent => 'Un evento especial';
  @override String get p1MotivHealth => 'Mi salud';
  @override String get p1MotivConfidence => 'Confianza en mí misma';
  @override String get p1MotivClothes => 'Volver a usar mi ropa favorita';
  @override String get p1MotivFreshStart => 'Un nuevo comienzo';

  @override String get p1PrevQuestion => '¿Has intentado bajar de peso antes?';
  @override String get p1PrevSubtitle => 'Queremos entender tu experiencia';
  @override String get p1PrevMany => 'Muchas veces, sin éxito duradero';
  @override String get p1PrevFew => 'Algunas veces';
  @override String get p1PrevFirst => 'Es mi primera vez';

  // PHASE 2
  @override String get p2AgeQuestion => '¿Cuántos años tenés?';
  @override String get p2AgeSubtitle => 'Tu edad influye en tu metabolismo';
  @override String get p2HeightQuestion => '¿Cuánto medís?';
  @override String get p2HeightSubtitle => 'Necesitamos esto para calcular tu plan';
  @override String get p2CurrWeightQuestion => '¿Cuánto pesás actualmente?';
  @override String get p2CurrWeightSubtitle => 'Esto es 100% privado 🔒';
  @override String get p2TargetWeightQuestion => '¿Cuál es tu peso objetivo?';
  @override String get p2TargetWeightSubtitle => 'Los expertos recomiendan metas realistas y progresivas';

  @override String get p2MetabolismTitle => 'Tu metabolismo es único';
  @override String get p2MetabolismFact => 'Por eso Yuna analiza +15 factores para crear un plan que funcione específicamente para VOS. No hay dos planes iguales.';

  @override String get p2BodyTypeQuestion => '¿Cuál es tu tipo de cuerpo?';
  @override String get p2BodyTypeSubtitle => 'Esto nos ayuda a personalizar tus ejercicios';
  @override String get p2BodyApple => 'Manzana';
  @override String get p2BodyAppleDesc => 'Más volumen en el torso';
  @override String get p2BodyPear => 'Pera';
  @override String get p2BodyPearDesc => 'Más volumen en caderas';
  @override String get p2BodyHourglass => 'Reloj de arena';
  @override String get p2BodyHourglassDesc => 'Proporciones equilibradas';
  @override String get p2BodyRectangle => 'Rectángulo';
  @override String get p2BodyRectangleDesc => 'Proporciones uniformes';

  @override String get p2CycleQuestion => '¿Tu ciclo menstrual es regular?';
  @override String get p2CycleSubtitle => 'Esto nos ayuda a adaptar tu plan a tus hormonas';
  @override String get p2CycleYes => 'Sí, es bastante regular';
  @override String get p2CycleNo => 'No, es irregular';
  @override String get p2CycleUnsure => 'No estoy segura';
  @override String get p2CycleNA => 'No aplica';

  // PHASE 3
  @override String get p3MealsQuestion => '¿Cuántas comidas hacés al día?';
  @override String get p3Meals12 => '1-2 comidas';
  @override String get p3Meals3 => '3 comidas';
  @override String get p3Meals45 => '4-5 comidas';
  @override String get p3MealsIrregular => 'No tengo horario fijo';

  @override String get p3WaterQuestion => '¿Cuántos vasos de agua tomás al día?';

  @override String get p3WaterInfoTitle => '¿Sabías esto?';
  @override String get p3WaterInfoFact => 'Beber 500ml de agua antes de cada comida puede aumentar la pérdida de peso hasta un 44%. El agua acelera el metabolismo y reduce el apetito.';

  @override String get p3DietQuestion => '¿Tenés alguna restricción alimentaria?';
  @override String get p3DietSubtitle => 'Podés elegir más de una';
  @override String get p3DietVegetarian => 'Vegetariana';
  @override String get p3DietVegan => 'Vegana';
  @override String get p3DietGlutenFree => 'Sin gluten';
  @override String get p3DietLactoseFree => 'Sin lactosa';
  @override String get p3DietNutFree => 'Sin frutos secos';
  @override String get p3DietNone => 'Ninguna restricción';

  @override String get p3SnackQuestion => '¿Cuándo solés picar entre comidas?';
  @override String get p3SnackNever => 'Casi nunca';
  @override String get p3SnackMorning => 'A media mañana';
  @override String get p3SnackAfternoon => 'A la tarde';
  @override String get p3SnackNight => 'A la noche';
  @override String get p3SnackAllDay => 'Todo el día';

  @override String get p3EmotionalQuestion => '¿Comés más cuando estás estresada o triste?';
  @override String get p3EmotionalSubtitle => 'Sé honesta, esto es para ayudarte 💜';
  @override String get p3EmotionalAlways => 'Sí, siempre me pasa';
  @override String get p3EmotionalSometimes => 'A veces';
  @override String get p3EmotionalRarely => 'Casi nunca';

  @override String get p3CookingQuestion => '¿Te gusta cocinar?';
  @override String get p3CookingLove => 'Me encanta cocinar';
  @override String get p3CookingNecessity => 'Lo hago por necesidad';
  @override String get p3CookingNo => 'Prefiero delivery o cosas rápidas';

  @override String get p3YunaInfoTitle => 'Yuna es diferente';
  @override String get p3YunaInfoFact => 'Yuna combina nutrición inteligente con mindfulness. No se trata de restricción, sino de consciencia. Vamos a transformar tu relación con la comida.';

  // PHASE 4
  @override String get p4StressQuestion => '¿Cómo describirías tu nivel de estrés?';
  @override String get p4StressVeryRelaxed => 'Muy relajada';
  @override String get p4StressSome => 'Algo de estrés';
  @override String get p4StressModerate => 'Estrés moderado';
  @override String get p4StressPretty => 'Bastante estresada';
  @override String get p4StressVery => 'Muy estresada';

  @override String get p4SleepQuestion => '¿Cuántas horas dormís por noche?';
  @override String get p4SleepLess5 => 'Menos de 5 horas';
  @override String get p4Sleep56 => '5-6 horas';
  @override String get p4Sleep78 => '7-8 horas';
  @override String get p4SleepMore8 => 'Más de 8 horas';

  @override String get p4SleepInfoTitle => 'Sueño y hambre';
  @override String get p4SleepInfoFact => 'La falta de sueño aumenta la grelina (hormona del hambre) un 28% y reduce la leptina (hormona de saciedad). Yuna te ayuda a dormir mejor para perder peso de forma natural.';

  @override String get p4ActivityQuestion => '¿Cuál es tu nivel de actividad?';
  @override String get p4ActivitySedentary => 'Sedentaria (poco movimiento)';
  @override String get p4ActivityLight => 'Algo activa (camino regularmente)';
  @override String get p4ActivityActive => 'Activa (ejercicio 3-4 veces/semana)';
  @override String get p4ActivityVeryActive => 'Muy activa (ejercicio diario)';

  @override String get p4ExerciseQuestion => '¿Qué tipo de ejercicio te atrae más?';
  @override String get p4ExerciseSubtitle => 'Personalizaremos tu plan según tu preferencia';
  @override String get p4ExerciseYoga => 'Yoga y stretching';
  @override String get p4ExerciseWalking => 'Caminar';
  @override String get p4ExerciseHiit => 'HIIT (alta intensidad)';
  @override String get p4ExerciseGym => 'Gym y pesas';
  @override String get p4ExerciseDance => 'Baile y cardio';
  @override String get p4ExerciseNone => 'No me gusta ejercitarme';

  @override String get p4MindfulnessQuestion => '¿Practicaste meditación o respiración consciente alguna vez?';
  @override String get p4MindfulnessYes => 'Sí, regularmente';
  @override String get p4MindfulnessSome => 'Un poco, pero no soy constante';
  @override String get p4MindfulnessNever => 'Nunca probé';

  @override String get p4BreathingTitle => 'Respirá con Yuna';
  @override String get p4BreathingSubtitle => 'La meditación reduce el cortisol, que causa acumulación de grasa abdominal';
  @override String get p4BreathingInhale => 'Inhalá';
  @override String get p4BreathingExhale => 'Exhalá';

  // PHASE 5
  @override String get p5LoadingTitle => 'Analizando tu perfil...';
  @override String get p5FactorMetabolism => 'Metabolismo';
  @override String get p5FactorStress => 'Nivel de estrés';
  @override String get p5FactorEating => 'Hábitos alimenticios';
  @override String get p5FactorHormonal => 'Ciclo hormonal';
  @override String get p5FactorActivity => 'Nivel de actividad';
  @override String get p5FactorSleep => 'Calidad de sueño';
  @override String get p5FactorBodyType => 'Tipo de cuerpo';
  @override String get p5FactorGoals => 'Objetivos personales';

  @override String get p5ProfileTitle => 'Tu perfil Yuna';
  @override String get p5ProfileSubtitle => 'Creado exclusivamente para vos ✨';
  @override String get p5ProfileGoalLabel => 'Objetivo';
  @override String get p5ProfileGoalLoseWeight => 'Perder peso';
  @override String get p5ProfileGoalTone => 'Tonificar';
  @override String get p5ProfileGoalWellness => 'Bienestar';
  @override String get p5ProfileCurrentWeight => 'Peso actual';
  @override String get p5ProfileTargetWeight => 'Peso objetivo';
  @override String get p5ProfileHeight => 'Altura';
  @override String get p5ProfileStress => 'Estrés';
  @override String get p5ProfileActivity => 'Actividad';
  @override String get p5ViewPlanBtn => 'Ver mi plan';

  @override String get p5ProjectionTitle => 'Tu proyección';
  @override String get p5Week2Milestone => 'Semana 2';
  @override String get p5Week2Desc => 'Primeros cambios visibles';
  @override String get p5HalfwayMilestoneDesc => 'Aceleración de resultados';
  @override String get p5GoalMilestoneDesc => 'Meta alcanzada';
  @override String get p5ViewFullPlanBtn => 'Ver mi plan completo';
  @override String get p5Today => 'Hoy';
  @override String get p5WeekLabel => 'Sem';

  @override String get p5SocialProofTitle => 'Resultados reales';
  @override String get p5SocialProofFact => 'El 87% de las mujeres con un perfil similar al tuyo lograron su objetivo con Yuna en el tiempo estimado.';

  @override String get p5PlanTitle => 'Tu plan personalizado';
  @override String get p5PlanAiBadge => 'IA analizó tus 8 factores';
  @override String get p5PlanPhase1Title => 'Semana 1-2: Adaptación';
  @override String get p5PlanPhase1DescStress => 'Técnicas de relajación para bajar tu estrés';
  @override String get p5PlanPhase1DescNormal => 'Tu cuerpo se ajusta al nuevo plan suavemente';
  @override String get p5PlanPhase1Tag => 'Basado en tu perfil';
  @override String get p5PlanPhase2Title => 'Semana 3-6: Aceleración';
  @override String get p5PlanPhase2DescEmotional => 'Herramientas para manejar la alimentación emocional';
  @override String get p5PlanPhase2DescNormal => 'Resultados visibles y más energía cada día';
  @override String get p5PlanPhase2Tag => 'Personalizado';
  @override String get p5PlanPhase3Title => 'Semana 3+: Descanso';
  @override String get p5PlanPhase3Tag => 'Adaptado a vos';
  @override String get p5PlanPhase4Title => 'Semana 7+: Consolidación';
  @override String get p5PlanPhase4Tag => 'Tu meta';

  @override String get p5FeaturesTitle => 'Tu plan incluye';
  @override String get p5FeatureAiBadge => 'Seleccionado por IA para vos';
  @override String get p5FeatureMeditationTitle => 'Meditaciones anti-estrés';
  @override String get p5FeatureMeditationDescHigh => 'Tu estrés es alto — incluimos sesiones para bajarlo';
  @override String get p5FeatureMeditationDescNormal => 'Sesiones de relajación para tu bienestar';
  @override String get p5FeatureEmotionalTitle => 'Control de hambre emocional';
  @override String get p5FeatureEmotionalDesc => 'Dijiste que comés por estrés/emociones — tenemos técnicas para eso';
  @override String get p5FeatureRecipesTitle => 'Recetas adaptadas';
  @override String get p5FeatureRecipesDescRestricted => 'Todas las recetas respetan tus restricciones alimentarias';
  @override String get p5FeatureRecipesDescNormal => 'Platos fáciles adaptados a tu estilo de cocina';
  @override String get p5FeatureTrackingTitle => 'Tracking inteligente';
  @override String get p5FeatureTrackingDesc => 'Peso, agua, hábitos y progreso en un solo lugar';
  @override String get p5FeatureWorkoutsBeginnerTitle => 'Workouts para principiantes';
  @override String get p5FeatureWorkoutsBeginnerDescSedentary => 'Empezamos suave porque tu nivel es sedentario';
  @override String get p5FeatureWorkoutsBeginnerDescLight => 'Empezamos suave porque tu nivel de actividad es bajo';
  @override String get p5FeatureWorkoutsTitle => 'Workouts personalizados';
  @override String get p5FeatureSleepTitle => 'Rutinas de sueño';
  @override String get p5ForYouTag => 'Para vos';

  @override String get p5ComparisonTitle => 'Con Yuna vs sin plan';
  @override String get p5ComparisonWithTitle => 'Con Yuna ✨';
  @override String get p5ComparisonWithoutTitle => 'Sin plan';
  @override String get p5WithoutRestrictive => 'Dietas restrictivas';
  @override String get p5WithoutEmotional => 'Sin apoyo emocional';
  @override String get p5WithoutRebound => 'Efecto rebote';
  @override String get p5WithoutSlow => 'Lento e incierto';
  @override String get p5WithPlanWeeks => ' semanas';
  @override String get p5WithAntiStress => 'Anti-estrés incluido';
  @override String get p5WithLastingResults => 'Resultados duraderos';
  @override String get p5WithGoalKg => 'kg meta';
  @override String get p5WantYunaBtn => 'Quiero Yuna';

  @override String get p5ConfirmReady => 'Tu plan está listo';
  @override String get p5ConfirmTitle => 'Este es tu plan';
  @override String get p5ConfirmBtn => 'Sí, este es mi plan ✨';
  @override String get p5ConfirmContinueBtn => 'Continuar ✨';
  @override String get p5BlueprintGoal => 'Objetivo';
  @override String get p5BlueprintDuration => 'Duración';
  @override String get p5BlueprintWeeks => 'semanas';
  @override String get p5BlueprintIncludes => 'Incluye';
  @override String get p5BlueprintIncludesValue => 'Meditación + Yoga + Nutrición';
  @override String get p5BlueprintIntensity => 'Intensidad';
  @override String get p5BlueprintIntensityGradual => 'Gradual (adaptado a vos)';
  @override String get p5BlueprintIntensityModerate => 'Moderada';
  @override String get p5BlueprintExtra => 'Extra';
  @override String get p5BlueprintAntiStress => 'Anti-estrés personalizado';

  @override String get p5NameTitle => '¿Cómo te gustaría que te llamemos?';
  @override String get p5NameSubtitle => 'Tu nombre hace tu experiencia más personal 💜';
  @override String get p5NameHint => 'Tu nombre';
  @override String get p5NameContinueBtn => 'Continuar';

  @override String get p5PlanPhase3DescLowSleep => 'Rutinas de sueño porque dormís';
  @override String get p5PlanPhase3DescNormal => 'Optimización del descanso para acelerar resultados';
  @override String get p5PlanPhase4Desc => 'Hábitos sólidos, peso estable en';
  @override String get p5CreatedForYou => 'Creado exclusivamente para vos ✨';

  // PHASE 6
  @override String get p6TestimonialsTitle => 'Historias reales';
  @override String get p6TestimonialsSubtitle => 'Mujeres como vos que lograron su objetivo';
  @override String get p6Testimonial1Name => 'María, 28';
  @override String get p6Testimonial1Text => 'Perdí 12kg en 3 meses. La meditación me ayudó a dejar de comer por ansiedad.';
  @override String get p6Testimonial2Name => 'Valentina, 35';
  @override String get p6Testimonial2Text => 'Por fin no siento culpa al comer. Yuna cambió mi relación con la comida.';
  @override String get p6Testimonial3Name => 'Camila, 24';
  @override String get p6Testimonial3Text => 'Las rutinas de respiración me cambiaron la vida. Bajé 8kg sin pasar hambre.';

  @override String get p6CommitmentReady => '¿Estás lista?';
  @override String get p6CommitmentReadyNamed => '¿Estás lista, {name}?';
  @override String get p6CommitmentSubtitle => 'Tu transformación empieza hoy.\nYuna va a acompañarte cada día.';
  @override String get p6CommitmentBtn => '¡Estoy lista! 🎉';

  @override String get p6UrgencyTitle => 'Las primeras 48 horas son clave';
  @override String get p6UrgencyFact => 'Los estudios muestran que empezar HOY aumenta 4x la probabilidad de alcanzar tu objetivo. Tu plan está listo para comenzar ahora mismo.';

  @override String get p6NotificationsTitle => 'Recordatorios diarios';
  @override String get p6NotificationsSubtitle => 'Las usuarias con recordatorios activados tienen 3x más éxito en alcanzar su objetivo.';
  @override String get p6NotificationsBtn => 'Activar recordatorios';
  @override String get p6NotificationsSkip => 'No, gracias';

  @override String get p6PlanReadyTitle => 'Tu plan está listo';
  @override String get p6PlanReadyNamed => '{name}, tu plan está listo';
  @override String get p6PlanGeneratedMin => 'Plan generado hace {min} min';
  @override String get p6ActiveUsersLabel => 'mujeres similares empezaron hoy';
  @override String get p6PlanSummary => 'Plan de {weeks} semanas optimizado para vos.\nSi no empezás ahora, los resultados se retrasan.';
  @override String get p6ActivatePlanBtn => 'Activar mi plan ahora';

  // PHASE 7
  @override String get p7FeatureAntiStress => 'Anti-estrés';
  @override String get p7FeatureEmotionalControl => 'Control emocional';
  @override String get p7FeatureAdaptedRecipes => 'Recetas adaptadas';
  @override String get p7FeatureYogaMeditation => 'Yoga + Meditación';
  @override String get p7FeatureSmartTracking => 'Tracking inteligente';

  @override String get p7PlanReadyNamed => '{name}, tu plan de {weeks} semanas está listo';
  @override String get p7PlanReady => 'Tu plan de {weeks} semanas está listo';
  @override String get p7ActivateBtn => 'Activar mi plan';
  @override String get p7TrialInfo => '7 días de prueba gratis · Cancelá cuando quieras';
  @override String get p7RestoreBtn => 'Restaurar compra';
  @override String get p7TermsBtn => 'Términos';
  @override String get p7PrivacyBtn => 'Privacidad';

  @override String get p7PlanAnnual => 'Plan Anual';
  @override String get p7PlanQuarterly => 'Plan Trimestral';
  @override String get p7PlanMonthly => 'Plan Mensual';
  @override String get p7PerMonth => '/mes';
  @override String get p7PerYear => '/año';
  @override String get p7PerQuarter => '/trimestre';
  @override String get p7BestValue => 'MEJOR VALOR 🔥';
  @override String get p7Save72 => 'Ahorrás 72%';

  @override String get p7GuaranteeTitle => 'Garantía sin riesgo';
  @override String get p7GuaranteeSubtitle => '7 días gratis. Cancelá cuando quieras.\nSin compromiso, sin preguntas.';
  @override String get p7GuaranteeFreeTrial => 'Prueba gratis de 7 días';
  @override String get p7GuaranteeCancelOneTap => 'Cancelación en 1 tap';
  @override String get p7GuaranteeNoHiddenFees => 'Sin cargos ocultos';

  @override String get p7AllInOneTitle => 'Todo-en-uno por menos';
  @override String get p7MeditationApp => 'App de meditación';
  @override String get p7Nutritionist => 'Nutricionista';
  @override String get p7FitnessApp => 'App de fitness';
  @override String get p7PersonalCoach => 'Coach personal';
  @override String get p7YunaCompletePlan => 'Yuna — Tu plan completo';
  @override String get p7PersonalizedWeeks => '{weeks} semanas personalizadas para vos';

  @override String get p7FinalReadyNamed => '¡{name}, tu plan está listo!';
  @override String get p7FinalReady => '¡Tu plan está listo!';
  @override String get p7FinalSubtitle => 'Empezá tu prueba gratuita de 7 días\ny llegá a {target} kg con Yuna.';
  @override String get p7ActivatePlanBtn => 'Activar mi plan 🎉';

  @override String get p7ExitWaitNamed => '¡Esperá, {name}!';
  @override String get p7ExitWait => '¡Esperá!';
  @override String get p7ExitDiscountMsg => 'Tu plan de {weeks} semanas tiene un descuento exclusivo';
  @override String get p7ExitPriceComparison => '\$2.08/mes en vez de \$4.17';
  @override String get p7ExitWantOffer => '¡Quiero esta oferta!';
  @override String get p7ExitDecline => 'No, gracias';

  // DASHBOARD
  @override String get dashGoodMorning => 'Buenos días';
  @override String get dashGoodAfternoon => 'Buenas tardes';
  @override String get dashGoodEvening => 'Buenas noches';
  @override String get dashTodayProgress => 'Tu progreso hoy ✨';
  @override String get dashYourGoal => 'Tu objetivo';
  @override String get dashLostThisWeek => 'esta semana 🎉';
  @override String get dashChecklist => 'Checklist del día';
  @override String get dashWater => 'Tomar agua';
  @override String get dashWorkout => 'Workout del día';
  @override String get dashMeditation => 'Meditación';
  @override String get dashMeals => 'Registrar comidas';
  @override String get dashMealsUnit => 'comidas';
  @override String get dashTodayPlan => 'Plan de hoy';
  @override String get dashPlanHiit => 'HIIT Quemagrasa';
  @override String get dashPlanSalad => 'Ensalada power';
  @override String get dashPlanLunch => 'Almuerzo';
  @override String get dashPlanBreathing => 'Respiración 4-7-8';
  @override String get dashPlanSleep => 'Rutina de sueño';
  @override String get dashMotivationalQuote => '"El progreso, no la perfección, es lo que importa."';

  // NAV
  @override String get navHome => 'Inicio';
  @override String get navWorkouts => 'Workouts';
  @override String get navMindfulness => 'Mindfulness';
  @override String get navNutrition => 'Nutrición';
  @override String get navProgress => 'Progreso';

  // NUTRITION
  @override String get nutTitle => 'Nutrición';
  @override String get nutSubtitle => 'Tu plan alimenticio personalizado';
  @override String get nutMacrosToday => 'Macros de hoy';
  @override String get nutCalLabel => 'cal';
  @override String get nutProteins => 'Proteínas';
  @override String get nutCarbs => 'Carbos';
  @override String get nutFats => 'Grasas';
  @override String get nutWater => 'Agua';
  @override String get nutGlasses => 'vasos';
  @override String get nutMealsTitle => 'Comidas del día';
  @override String get nutBreakfast => 'Desayuno';
  @override String get nutBreakfastDesc => 'Avena con frutas y semillas de chía';
  @override String get nutMorningSnack => 'Snack mañana';
  @override String get nutMorningSnackDesc => 'Manzana con mantequilla de almendras';
  @override String get nutLunch => 'Almuerzo';
  @override String get nutLunchDesc => 'Ensalada de pollo con quinoa y aguacate';
  @override String get nutAfternoonSnack => 'Snack tarde';
  @override String get nutAfternoonSnackDesc => 'Yogur griego con nueces';
  @override String get nutDinner => 'Cena';
  @override String get nutDinnerDesc => 'Salmón al horno con verduras asadas';

  // MINDFULNESS
  @override String get mindTitle => 'Mind';
  @override String get mindSubtitle => 'Tu espacio de paz interior';
  @override String get mindQuickBreathing => 'Respiración rápida';
  @override String get mindQuickBreathingDesc => 'Reduce el cortisol y la ansiedad en 3 minutos';
  @override String get mindStartNow => 'Comenzar ahora';
  @override String get mindCalm => 'Calma';
  @override String get mindMeditations => 'Meditaciones';
  @override String get mindMorningMeditation => 'Meditación de la mañana';
  @override String get mindMorningMeditationDesc => 'Empieza tu día con intención clara';
  @override String get mindInnerCalm => 'Calma interior';
  @override String get mindInnerCalmDesc => 'Relajación profunda para momentos de estrés';
  @override String get mindBodyScan => 'Body scan';
  @override String get mindBodyScanDesc => 'Conecta con tu cuerpo en 5 minutos';
  @override String get mindGoalVisualization => 'Visualización de metas';
  @override String get mindGoalVisualizationDesc => 'Imagina tu mejor versión';
  @override String get mindSleepRoutines => 'Rutinas de sueño';
  @override String get mindBedtimeRoutine => 'Rutina antes de dormir';
  @override String get mindBedtimeRoutineDesc => 'Relaja cuerpo y mente para un sueño profundo';
  @override String get mindNatureSounds => 'Sonidos de la naturaleza';
  @override String get mindNatureSoundsDesc => 'Bosque, lluvia y olas del mar';
  @override String get mindNightBodyScan => 'Escaneo corporal nocturno';
  @override String get mindNightBodyScanDesc => 'Suelta tensiones del día';
  @override String get mindEmotionalEating => 'Manejo del hambre emocional';
  @override String get mindPauseBeforeEating => 'Pausa antes de comer';
  @override String get mindPauseBeforeEatingDesc => '¿Tenés hambre real o emocional?';
  @override String get mindEmotionDiary => 'Diario de emociones';
  @override String get mindEmotionDiaryDesc => 'Conecta tus emociones con la alimentación';
  @override String get mindSweetCraving => 'Cuando querés algo dulce';
  @override String get mindSweetCravingDesc => 'Maneja los antojos con consciencia';

  // PROFILE
  @override String get profTitle => 'Perfil';
  @override String get profActivePlan => 'Plan activo';
  @override String get profWeightProgress => 'Progreso de peso';
  @override String get profLast8Weeks => 'Últimas 8 semanas';
  @override String get profTotalLost => 'perdidos en total';
  @override String get profDayStreak => 'Día streak';
  @override String get profWorkouts => 'Workouts';
  @override String get profSessions => 'Sesiones';
  @override String get profAchievements => 'Logros';
  @override String get profAch7Days => '7 días seguidos';
  @override String get profAchHydrated => 'Hidratada';
  @override String get profAch10Workouts => '10 workouts';
  @override String get profAchZenMaster => 'Zen master';
  @override String get profAch5kg => '-5 kg';
  @override String get profAch30Days => '30 días';
  @override String get profSettings => 'Configuración';
  @override String get profEditProfile => 'Editar perfil';
  @override String get profGoals => 'Objetivos';
  @override String get profNotifications => 'Notificaciones';
  @override String get profSubscription => 'Suscripción';
  @override String get profHelp => 'Ayuda';
  @override String get profLogout => 'Cerrar sesión';

  // SETTINGS
  @override String get setTitle => 'Ajustes';
  @override String get setSession => 'SESIÓN';
  @override String get setPoseDuration => 'Duración de pose';
  @override String get setPreferences => 'PREFERENCIAS';
  @override String get setSound => 'Sonido';
  @override String get setHaptics => 'Vibración';
  @override String get setNotificationsSection => 'NOTIFICACIONES';
  @override String get setReminders => 'Recordatorios';
  @override String get setLegal => 'LEGAL';
  @override String get setPrivacyPolicy => 'Política de privacidad';
  @override String get setTermsOfService => 'Términos de servicio';
  @override String get setResetData => 'Restablecer datos';
  @override String get setDeleteAccount => 'Eliminar cuenta';
  @override String get setDeleteConfirmTitle => 'Eliminar cuenta';
  @override String get setDeleteConfirmMessage => '¿Estás segura? Esta acción es irreversible y eliminará todo tu progreso.';
  @override String get setDeleteCancel => 'Cancelar';
  @override String get setDeleteConfirm => 'Eliminar';
  @override String get setProtectProgress => 'Protegé tu progreso';
  @override String get setProtectDesc => 'Iniciá sesión con Apple para guardar tus rutinas y progreso en la nube';
  @override String get setUnlockPro => 'Desbloqueá Pro';
  @override String get setUnlockProDesc => 'Accedé a todas las rutinas avanzadas y funciones premium';
  @override String get setAccountLinked => '¡Cuenta vinculada! Progreso guardado. ✅';
  @override String get setSignInFailed => 'Error al iniciar sesión';

  // QUESTIONNAIRE
  @override String get questQ1 => '¿Cuál es tu objetivo principal?';
  @override String get questQ2 => '¿Con qué frecuencia practicás yoga?';
  @override String get questQ3 => '¿Cómo está tu energía hoy?';
  @override String get questQ4 => '¿Alguna molestia física?';
  @override String get questQ5 => '¿Nivel de estrés actual?';
  @override String get questQ6 => '¿Cuánto tiempo tenés?';
  @override String get questQ7 => '¿Preferencia de sesión?';
  @override String get questQ8 => '¿Lista para empezar?';
  @override String get questFlexibility => 'Flexibilidad';
  @override String get questStrength => 'Fuerza';
  @override String get questRelaxation => 'Relajación';
  @override String get questMeditationOpt => 'Meditación';
  @override String get questNever => 'Nunca';
  @override String get questOccasionally => 'Ocasionalmente';
  @override String get questRegularly => 'Regularmente';
  @override String get questDaily => 'Todos los días';
  @override String get questLowEnergy => 'Baja';
  @override String get questMediumEnergy => 'Media';
  @override String get questHighEnergy => 'Alta';
  @override String get questLotsEnergy => 'Mucha energía';
  @override String get questBack => 'Espalda';
  @override String get questNeck => 'Cuello';
  @override String get questKnees => 'Rodillas';
  @override String get questNone => 'Ninguna';
  @override String get questLowStress => 'Bajo';
  @override String get questMediumStress => 'Medio';
  @override String get questHighStress => 'Alto';
  @override String get questTime5 => '5-10 min';
  @override String get questTime15 => '15-20 min';
  @override String get questTime30 => '30+ min';
  @override String get questGuided => 'Guiada';
  @override String get questSilent => 'Silenciosa';
  @override String get questSoftMusic => 'Música suave';
  @override String get questStartNow => '¡Empezar ahora!';

  // COMPLETION
  @override String get compSessionCompleted => '¡SESIÓN COMPLETADA!';
  @override String get compBodyMindBalance => 'Cuerpo y mente en equilibrio';
  @override String get compMinutes => 'Minutos';
  @override String get compStreak => 'Racha';
  @override String get compDailyGoal => 'Meta diaria';
  @override String get compShareVictory => 'COMPARTIR LOGRO';
  @override String get compBackToHome => 'VOLVER AL INICIO';
  @override String get compStartPractice => 'INICIAR PRÁCTICA';
  @override String get compRateUs => 'Calificanos';
  @override String get compRateMessage => '¡Gracias! Ser una app de 5 estrellas nos ayuda a llegar a más personas. ¿Nos ayudás?';
  @override String get compLater => 'Después';
  @override String get compRateNow => 'Calificar ahora';
  @override String get compShareSimulated => 'Abriendo menú para compartir... (Simulado)';
}
