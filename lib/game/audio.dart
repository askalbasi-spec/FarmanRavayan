import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound effects and background music. Every call is safe: if audio is not
/// available on the platform (or in tests) it silently does nothing.
class GameAudio {
  GameAudio._();

  static const soundKey = 'settings_sound_enabled';
  static const musicKey = 'settings_music_enabled';

  static bool soundOn = true;
  static bool musicOn = true;
  static bool _loaded = false;
  static bool _musicPlaying = false;
  static AudioPlayer? _music;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      soundOn = prefs.getBool(soundKey) ?? true;
      musicOn = prefs.getBool(musicKey) ?? true;
      _loaded = true;
    } catch (_) {}
  }

  static Future<void> setSound(bool value) async {
    soundOn = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(soundKey, value);
    } catch (_) {}
  }

  static Future<void> setMusic(bool value) async {
    musicOn = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(musicKey, value);
    } catch (_) {}
    if (value) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  /// Plays a short effect: tap, card, hit, heal, win or lose.
  static Future<void> sfx(String name) async {
    if (!_loaded) await load();
    if (!soundOn) return;
    try {
      final player = AudioPlayer();
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(AssetSource('audio/$name.wav'), volume: 0.8);
    } catch (_) {}
  }

  static Future<void> startMusic() async {
    if (!_loaded) await load();
    if (!musicOn || _musicPlaying) return;
    try {
      _musicPlaying = true;
      final player = _music ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('audio/music.wav'), volume: 0.28);
    } catch (_) {
      _musicPlaying = false;
    }
  }

  static Future<void> pauseForBackground() async {
    try {
      await _music?.pause();
    } catch (_) {}
  }

  static Future<void> resumeFromBackground() async {
    if (!musicOn) return;
    try {
      if (_music != null && _musicPlaying) {
        await _music!.resume();
      } else {
        await startMusic();
      }
    } catch (_) {}
  }

  static Future<void> stopMusic() async {
    _musicPlaying = false;
    try {
      await _music?.stop();
    } catch (_) {}
  }
}
