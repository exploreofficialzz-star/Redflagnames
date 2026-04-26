import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    await _player.setVolume(0.8);
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
  }

  Future<void> _play(String assetPath) async {
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {}
  }

  /// Play when analysis starts
  Future<void> playAnalyzing() => _play('sounds/woosh.wav');

  /// Play when result appears
  Future<void> playReveal() => _play('sounds/dramatic.wav');

  /// Play for high/extreme chaos results
  Future<void> playLaugh() => _play('sounds/laugh.wav');

  /// Play for low chaos (green flag)
  Future<void> playGreenFlag() => _play('sounds/level_up.wav');

  /// Play when sharing
  Future<void> playShare() => _play('sounds/ding.wav');

  /// Play for button taps
  Future<void> playTap() => _play('sounds/woosh.wav');

  /// Play alert for extreme chaos
  Future<void> playAlert() => _play('sounds/alert.wav');

  void dispose() {
    _player.dispose();
  }
}
