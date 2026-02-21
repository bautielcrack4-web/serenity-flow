import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔊 Sound Service — Haptic-style audio feedback
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final _player = AudioPlayer();
  bool _enabled = true;
  bool _initialized = false;

  static const _prefKey = 'sounds_enabled';

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefKey) ?? true;
    await _player.setVolume(0.4);
  }

  bool get enabled => _enabled;

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  Future<void> _play(String file) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$file'));
    } catch (e) {
      debugPrint('SoundService error: $e');
    }
  }

  /// Soft tap for buttons and UI interactions
  Future<void> playTap() => _play('tap_soft.mp3');

  /// Success chime for achievements and completions
  Future<void> playSuccess() => _play('success.mp3');

  /// Water drop for hydration tracker
  Future<void> playWaterDrop() => _play('water_drop.mp3');

  /// Completion sound for finishing tasks/sessions
  Future<void> playComplete() => _play('complete.mp3');
}
