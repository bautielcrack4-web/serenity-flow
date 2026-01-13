import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  bool _isSoundEnabled = true;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
    if (!enabled) {
      _bgmPlayer.stop();
    }
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSoundEnabled) return;
    await _sfxPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
  }

  Future<void> playBowl() async {
    await playSfx('assets/audio/tibetan_bowl.mp3');
  }

  Future<void> playClick() async {
    await playSfx('assets/audio/click_soft.mp3');
  }

  Future<void> playSuccess() async {
    await playSfx('assets/audio/success_chime.mp3');
  }

  Future<void> playPop() async {
    // Simulating a satisfying pop with a slightly pitched up click if specific asset not processed
    await _sfxPlayer.setPlaybackRate(1.2); 
    await playSfx('assets/audio/click_soft.mp3');
    await _sfxPlayer.setPlaybackRate(1.0);
  }

  Future<void> playRise() async {
    // Simulating a rising tone
     await playSfx('assets/audio/tibetan_bowl.mp3'); 
  }

  Future<void> playHarmony() async {
     await playSfx('assets/audio/success_chime.mp3');
  }

  Future<void> startBgm(String assetPath) async {
    if (!_isSoundEnabled) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }
}

final audioService = AudioService();
