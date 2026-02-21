import 'package:flutter/foundation.dart';
import 'package:serenity_flow/models/user_profile.dart';
import 'package:serenity_flow/services/supabase_service.dart';

/// Singleton that holds the current user's profile loaded from Supabase.
/// Call [load] once after login / onboarding. All screens read from [profile].
class UserProfileProvider {
  UserProfileProvider._();
  static final instance = UserProfileProvider._();

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _loading = false;
  bool get loading => _loading;

  /// The user's weight at the very first weight log (their starting point)
  double? _startWeight;
  double? get startWeight => _startWeight;

  /// Load profile from Supabase. Safe to call multiple times — skips if
  /// already loaded unless [force] is true.
  Future<void> load({bool force = false}) async {
    if (_profile != null && !force) return;
    if (_loading) return;
    _loading = true;

    try {
      final data = await SupabaseService().getProfile();
      if (data != null) {
        _profile = UserProfile.fromMap(data);
        debugPrint('✅ UserProfile loaded: ${_profile!.displayName}, exercise=${_profile!.preferredExercise}');
      }
      // Load the oldest weight log as the starting weight reference
      final logs = await SupabaseService().getWeightLogs(limit: 100);
      if (logs.isNotEmpty) {
        // logs are newest-first, so last element is the oldest
        _startWeight = (logs.last['weight'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('❌ UserProfile load error: $e');
    } finally {
      _loading = false;
    }
  }

  /// Quick accessors with safe defaults
  String get displayName => _profile?.displayName ?? 'Yuna';
  double? get currentWeight => _profile?.currentWeight;
  double? get targetWeight => _profile?.targetWeight;
  int get currentStreak => _profile?.currentStreak ?? 0;
  int get totalXP => _profile?.totalXP ?? 0;
  String get preferredExercise => _profile?.preferredExercise ?? 'none';
  String? get goalType => _profile?.goalType;
  double? get weightToLose => _profile?.weightToLose;
  double get progressPercent {
    final current = currentWeight;
    final target = targetWeight;
    final start = _startWeight;
    // Need start weight, current weight, and target. Start must be > target for weight-loss.
    if (current == null || target == null || start == null) return 0;
    final totalToLose = start - target;
    if (totalToLose <= 0) return 0; // not a weight-loss goal or bad data
    final lost = start - current;
    if (lost <= 0) return 0; // haven't lost any weight yet
    return (lost / totalToLose).clamp(0.0, 1.0);
  }

  /// Update weight in memory (after logging a new weight entry)
  Future<void> setCurrentWeight(double weight) async {
    await load(force: true);
  }

  /// Clear profile on logout
  void clear() {
    _profile = null;
    _startWeight = null;
  }
}
