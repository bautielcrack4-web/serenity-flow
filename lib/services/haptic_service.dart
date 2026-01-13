import 'package:flutter/services.dart';

/// Premium haptic feedback patterns
class HapticPatterns {
  /// Success pattern - Double tap
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Warning pattern - Long vibration
  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Achievement unlocked - Triple tap celebration
  static Future<void> achievement() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  /// Level up - Ascending pattern
  static Future<void> levelUp() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 40));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 40));
    await HapticFeedback.heavyImpact();
  }

  /// Subtle scroll snap
  static Future<void> scrollSnap() async {
    await HapticFeedback.selectionClick();
  }

  /// Button press
  static Future<void> buttonPress() async {
    await HapticFeedback.mediumImpact();
  }

  /// Light tap
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Error/Cancel
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }
}
