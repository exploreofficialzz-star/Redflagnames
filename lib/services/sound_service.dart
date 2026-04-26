import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      await _player.setVolume(0.8);
      _initialized = true;
    } catch (_) {
      // Fail silently — sound is non-critical
      _initialized = true;
    }
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
    } catch (_) {}
  }

  Future<void> _play(String assetPath) async {
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Never let a sound error crash the app
    }
  }

  Future<void> playAnalyzing() => _play('sounds/woosh.wav');
  Future<void> playReveal()    => _play('sounds/dramatic.wav');
  Future<void> playLaugh()     => _play('sounds/laugh.wav');
  Future<void> playGreenFlag() => _play('sounds/level_up.wav');
  Future<void> playShare()     => _play('sounds/ding.wav');
  Future<void> playTap()       => _play('sounds/woosh.wav');
  Future<void> playAlert()     => _play('sounds/alert.wav');

  void dispose() {
    _player.dispose();
  }
}
