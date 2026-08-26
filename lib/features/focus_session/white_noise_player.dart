import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// PLACEHOLDER ambient-sound player for focus sessions (see todo.md P2 3.2).
///
/// Current state: no audio source is loaded at all — `play()` is a safe no-op,
/// so toggling the speaker icon produces no sound. This is intentional until
/// real ambient audio ships:
///
/// 1. Add looping audio assets under `assets/audio/` (e.g.
///    `white_noise.mp3`, `rain.mp3`, ...), register them in pubspec.yaml.
/// 2. In [_init], call `_player.setAsset(NoiseType.whiteNoise.assetPath)`
///    (or per selected type) before marking initialized.
/// 3. The UI in focus_session_screen.dart labels the control as a
///    placeholder; remove that label once real audio plays.
///
/// Kept wired to the (currently orphaned) FocusSessionScreen so the future
/// swap-in is a two-line change, not a rebuild.
class WhiteNoisePlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> play() async {
    if (!_isInitialized) {
      await _init();
    }
    // No source is set yet (placeholder) — just_audio no-ops safely instead
    // of throwing, so this stays harmless until real assets land.
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> _init() async {
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.3);

    // Placeholder: no audio source loaded yet. To enable real ambient sound:
    //   await _player.setAsset('assets/audio/white_noise.mp3');
    debugPrint(
        'WhiteNoisePlayer: placeholder mode — no audio asset bundled yet.');

    _isInitialized = true;
  }

  void dispose() {
    _player.dispose();
  }
}

enum NoiseType {
  whiteNoise,
  brownNoise,
  pinkNoise,
  rain,
  ocean,
  forest,
}

extension NoiseTypeExtension on NoiseType {
  String get displayName {
    switch (this) {
      case NoiseType.whiteNoise:
        return 'White Noise';
      case NoiseType.brownNoise:
        return 'Brown Noise';
      case NoiseType.pinkNoise:
        return 'Pink Noise';
      case NoiseType.rain:
        return 'Rain';
      case NoiseType.ocean:
        return 'Ocean Waves';
      case NoiseType.forest:
        return 'Forest';
    }
  }

  /// Asset path each type WILL use once real audio files are added under
  /// assets/audio/ (registered in pubspec.yaml at the same time).
  String get assetPath {
    return 'assets/audio/$name.mp3';
  }
}
