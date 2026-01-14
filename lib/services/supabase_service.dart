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

  Future<void> incrementStreak() async {
    if (userId == null) return;
    
    final profile = await getProfile();
    if (profile == null) return;

    final currentStreak = profile['streak_days'] as int? ?? 0;
    // Logic to verify if streak continues would go here (check last_session_at)
    // For MVP, we simply increment if requested (Integration Layer will handle logic)
    
    await _supabase.from('profiles').update({
      'streak_days': currentStreak + 1,
    }).eq('id', userId!);
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
