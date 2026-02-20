import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serenity_flow/models/gamification_model.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:serenity_flow/models/onboarding_data.dart';
import 'package:serenity_flow/core/design_system.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _supabase = Supabase.instance.client;

  // --- Auth ---

  Future<void> signInAnonymously() async {
    try {
      if (_supabase.auth.currentUser == null) {
        await _supabase.auth.signInAnonymously();
      }
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      // Continue without auth - app will work in offline mode
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String name) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  String? get userId => _supabase.auth.currentUser?.id;

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> deleteAccount() async {
    // Note: In a real production app, you might want to call a cloud function 
    // to handle full data cleanup (storage, multiple tables). 
    // For this MVP, we sign out which effectively "removes" access. 
    // A true deletion usually requires an Edge Function to delete the auth user.
    // We will simulate it by clearing session and signing out for MVP compliance.
    await signOut();
  }

  // --- Onboarding Data ---

  /// Save all onboarding responses to the profiles table
  Future<bool> saveOnboardingProfile(OnboardingData data) async {
    if (userId == null) return false;
    try {
      final profileData = data.toProfileMap();
      // Add extra fields not in toProfileMap
      profileData['selected_plan'] = data.get('selected_plan');
      profileData['notifications_accepted'] = data.notificationsAccepted;
      profileData['motivation'] = data.motivation;
      profileData['previous_attempts'] = data.previousAttempts;
      profileData['meals_per_day'] = data.mealsPerDay;
      profileData['water_glasses'] = data.waterGlasses;
      profileData['cooking_preference'] = data.cookingPreference;
      profileData['mindfulness_experience'] = data.mindfulnessExperience;

      await _supabase.from('profiles').update(profileData).eq('id', userId!);
      debugPrint('✅ Onboarding profile saved to Supabase');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving onboarding profile: $e');
      return false;
    }
  }

  // --- Profiles (XP, Level, Streak) ---

  Future<Map<String, dynamic>?> getProfile() async {
    if (userId == null) return null;
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId!)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  Future<void> updateXP(int xpEarned) async {
    if (userId == null) return;
    
    // Get current profile
    final profile = await getProfile();
    if (profile == null) return;

    final currentXP = profile['total_xp'] as int? ?? 0;
    final newXP = currentXP + xpEarned;
    final newLevel = LevelSystem.calculateLevel(newXP);

    await _supabase.from('profiles').update({
      'total_xp': newXP,
      'level': newLevel,
      'last_session_at': DateTime.now().toIso8601String(),
    }).eq('id', userId!);
  }

  Future<void> updateStreak() async {
    if (userId == null) return;
    
    try {
      final profile = await getProfile();
      if (profile == null) return;

      final int currentStreak = profile['streak_days'] as int? ?? 0;
      final String? lastSessionStr = profile['last_session_at'] as String?;
      
      int newStreak = currentStreak;
      final now = DateTime.now();
      
      if (lastSessionStr != null) {
        final lastSession = DateTime.parse(lastSessionStr);
        final difference = now.difference(lastSession).inDays;
        
        // Check if it's the same day (ignore)
        final isSameDay = now.year == lastSession.year && 
                          now.month == lastSession.month && 
                          now.day == lastSession.day;
                          
        if (isSameDay) {
          // Already practiced today, keep streak same
          return; 
        } else if (difference == 1 || (difference == 0 && !isSameDay)) { 
          // Consecutive day (yesterday or just across midnight header)
          // Note: difference inDays truncates, so we might want more robust "calendar day" check
          // Better logic: Check if lastSession was yesterday
          
          final yesterday = now.subtract(const Duration(days: 1));
          final isYesterday = yesterday.year == lastSession.year && 
                              yesterday.month == lastSession.month && 
                              yesterday.day == lastSession.day;

          if (isYesterday || difference <= 1) { //Allow grace period of < 24h gap across days
             newStreak++;
          } else {
             newStreak = 1; // Broken streak
          }
        } else {
          newStreak = 1; // Broken streak (> 1 day gap)
        }
      } else {
        newStreak = 1; // First session ever
      }
    
      await _supabase.from('profiles').update({
        'streak_days': newStreak,
        'last_session_at': now.toIso8601String(),
      }).eq('id', userId!);
      
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  // --- Sessions (History & Calendar) ---

  Future<void> saveSession(Routine routine, int durationSeconds) async {
    if (userId == null) return;

    await _supabase.from('sessions').insert({
      'user_id': userId,
      'routine_id': routine.id,
      'duration_seconds': durationSeconds,
      'xp_earned': LevelSystem.xpPerSession, // Base XP
      'completed_at': DateTime.now().toIso8601String(),
    });

    // Update streak logic (checks dates)
    await updateStreak();

    await updateXP(LevelSystem.xpPerSession);

    // Increment free sessions if user is not pro
    final profile = await getProfile();
    final bool isPro = profile?['is_pro'] ?? false;
    if (!isPro) {
      await incrementFreeSessionsCount();
    }
  }

  Future<List<DateTime>> getSessionDates() async {
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('sessions')
          .select('completed_at')
          .eq('user_id', userId!)
          .order('completed_at', ascending: false);
      
      return (response as List).map((e) => DateTime.parse(e['completed_at'])).toList();
    } catch (e) {
      debugPrint('Error getting sessions: $e');
      return [];
    }
  }
  
  // --- Stats for Progress Screen ---
  
  Future<Map<String, int>> getStats() async {
    if (userId == null) return {'minutes': 0, 'sessions': 0};
    
    try {
      final response = await _supabase
          .from('sessions')
          .select('duration_seconds');
          
      final List data = response as List;
      final int sessions = data.length;
      final int totalSeconds = data.fold(0, (sum, item) => sum + (item['duration_seconds'] as int));
      
      return {
        'minutes': (totalSeconds / 60).round(),
        'sessions': sessions,
      };
    } catch (e) {
      debugPrint ('Error getting stats: $e');
      return {'minutes': 0, 'sessions': 0};
    }
  }

  // --- Achievements ---

  Future<List<String>> getUnlockedAchievements() async {
    if (userId == null) return [];
    try {
      final response = await _supabase
          .from('achievements')
          .select('achievement_id')
          .eq('user_id', userId!);
      
      return (response as List).map((e) => e['achievement_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (userId == null) return;
    
    // Check if already unlocked
    final existing = await _supabase
        .from('achievements')
        .select()
        .eq('user_id', userId!)
        .eq('achievement_id', achievementId)
        .maybeSingle();
        
    if (existing != null) return; // Already unlocked

    await _supabase.from('achievements').insert({
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProStatus(bool isPro) async {
    if (userId == null) return;
    await _supabase.from('profiles').update({
      'is_pro': isPro,
    }).eq('id', userId!);
  }

  // --- Custom Routines ---

  Future<List<Routine>> getCustomRoutines() async {
    if (userId == null) return [];
    try {
      final response = await _supabase
          .from('user_routines')
          .select()
          .eq('user_id', userId!)
          .order('created_at', ascending: false);

      return (response as List).map((data) {
        final List<dynamic> posesJson = data['poses'] ?? [];
        final poses = posesJson.map((p) => Pose.fromMap(p)).toList();

        return Routine(
          id: data['id'],
          name: data['name'],
          description: data['description'] ?? 'Custom Routine',
          duration: data['duration'] ?? '0 min',
          poseCount: poses.length,
          difficulty: data['difficulty'] ?? 1,
          icon: data['icon'] ?? 'assets/images/poses/pose_montana.png',
          themeGradient: AppColors.organicGradient, // Default theme for custom
          poses: poses,
          isCustom: true,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching custom routines: $e');
      return [];
    }
  }

  Future<bool> saveCustomRoutine(String name, List<Pose> poses) async {
    if (userId == null) return false;

    // 1. Check Limits for Free Users
    final profile = await getProfile();
    final bool isPro = profile?['is_pro'] ?? false;

    if (!isPro) {
      final currentRoutines = await getCustomRoutines();
      if (currentRoutines.length >= 3) {
        return false; // Limit reached
      }
    }

    // 2. Calculate Metadata
    final durationSeconds = poses.fold(0, (sum, p) => sum + p.duration);
    final durationMin = (durationSeconds / 60).ceil();

    // 3. Save to DB
    try {
      await _supabase.from('user_routines').insert({
        'user_id': userId,
        'name': name,
        'description': 'My personal flow',
        'duration': '$durationMin min',
        'difficulty': 1, // Default
        'icon': poses.isNotEmpty ? poses.first.image : 'assets/images/poses/pose_montana.png',
        'poses': poses.map((p) => p.toMap()).toList(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving custom routine: $e');
      return false;
    }
  }

  Future<void> deleteCustomRoutine(String routineId) async {
    try {
      await _supabase
          .from('user_routines')
          .delete()
          .eq('id', routineId)
          .eq('user_id', userId!); // Extra safety
    } catch (e) {
      debugPrint('Error deleting routine: $e');
    }
  }

  // --- Free Tier Logic ---
  
  static const String _localFreeCountKey = 'free_sessions_count';

  Future<int> getFreeSessionsCount() async {
    // 1. Check Local Fallback (Guest mode or offline)
    final prefs = await SharedPreferences.getInstance();
    final localCount = prefs.getInt(_localFreeCountKey) ?? 0;

    // 2. If Auth is available, sync and use DB
    if (userId != null) {
      try {
        final profile = await getProfile();
        final dbCount = profile?['free_sessions_count'] as int? ?? 0;
        
        // Use the higher value to prevent exploits
        final finalCount = dbCount > localCount ? dbCount : localCount;
        
        // Keep synced
        if (dbCount != finalCount) {
           await _supabase.from('profiles').update({
            'free_sessions_count': finalCount,
          }).eq('id', userId!);
        }
        if (localCount != finalCount) {
          await prefs.setInt(_localFreeCountKey, finalCount);
        }
        
        return finalCount;
      } catch (e) {
        return localCount;
      }
    }
    
    return localCount;
  }

  Future<void> incrementFreeSessionsCount() async {
    // 1. Update Local
    final prefs = await SharedPreferences.getInstance();
    final currentLocal = prefs.getInt(_localFreeCountKey) ?? 0;
    final newCount = currentLocal + 1;
    await prefs.setInt(_localFreeCountKey, newCount);

    // 2. Update DB if logged in
    if (userId != null) {
      try {
        await _supabase.from('profiles').update({
          'free_sessions_count': newCount,
        }).eq('id', userId!);
      } catch (e) {
        debugPrint('Error syncing free count to DB: $e');
      }
    }
  }
}
