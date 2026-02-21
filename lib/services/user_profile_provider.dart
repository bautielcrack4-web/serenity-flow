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
    if (current == null || target == null || current <= target) return 0;
    final startWeight = current;
    final totalToLose = startWeight - target;
    if (totalToLose <= 0) return 1.0;
    final lost = startWeight - current;
    return (lost / totalToLose).clamp(0.0, 1.0);
  }

  /// Clear profile on logout
  void clear() {
    _profile = null;
  }
}
