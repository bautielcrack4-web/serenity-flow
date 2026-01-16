import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serenity_flow/models/gamification_model.dart';
import 'package:serenity_flow/models/routine_model.dart';

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
      print('Error signing in anonymously: $e');
      // Continue without auth - app will work in offline mode
    }
  }

  String? get userId => _supabase.auth.currentUser?.id;

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
      print('Error getting profile: $e');
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
      print('Error updating streak: $e');
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
      print('Error getting sessions: $e');
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
      print ('Error getting stats: $e');
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

  // --- Free Tier Logic ---

  Future<int> getFreeSessionsCount() async {
    if (userId == null) return 0;
    try {
      final profile = await getProfile();
      return profile?['free_sessions_count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> incrementFreeSessionsCount() async {
    if (userId == null) return;
    final currentCount = await getFreeSessionsCount();
    await _supabase.from('profiles').update({
      'free_sessions_count': currentCount + 1,
    }).eq('id', userId!);
  }
}
