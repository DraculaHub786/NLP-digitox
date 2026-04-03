import 'package:just_audio/just_audio.dart';

class WhiteNoisePlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> play() async {
    if (!_isInitialized) {
      await _init();
    }
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
    // Using a looping sine wave as placeholder for white noise
    // In production, you'd load actual white noise audio files from assets
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.3);
    
    // For now, using a silent loop - in production add white noise audio files to assets
    // Example: await _player.setAsset('assets/audio/white_noise.mp3');
    
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

  String get assetPath {
    // These would be actual audio files in production
    return 'assets/audio/${name}.mp3';
  }
}
