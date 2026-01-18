import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound effect types
enum SoundEffect {
  cardFlip,
  cardMatch,
  cardMismatch,
  comboBonus,
  levelComplete,
  gameOver,
  buttonTap,
  starEarned,
}

/// Audio service for managing game sounds and music
class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  /// Sound file paths
  static const Map<SoundEffect, String> _soundPaths = {
    SoundEffect.cardFlip: 'sounds/card_flip.mp3',
    SoundEffect.cardMatch: 'sounds/card_match.mp3',
    SoundEffect.cardMismatch: 'sounds/card_mismatch.mp3',
    SoundEffect.comboBonus: 'sounds/combo.mp3',
    SoundEffect.levelComplete: 'sounds/level_complete.mp3',
    SoundEffect.gameOver: 'sounds/game_over.mp3',
    SoundEffect.buttonTap: 'sounds/button_tap.mp3',
    SoundEffect.starEarned: 'sounds/star.mp3',
  };

  AudioService() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _sfxPlayer.setReleaseMode(ReleaseMode.release);
  }

  /// Set sound enabled state
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _sfxPlayer.stop();
    }
  }

  /// Set music enabled state
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  /// Play a sound effect
  Future<void> playSound(SoundEffect effect) async {
    if (!_soundEnabled) return;

    final path = _soundPaths[effect];
    if (path == null) return;

    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      // Silently fail if sound file is missing
    }
  }

  /// Play background music
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.play(AssetSource('music/background.mp3'));
      await _musicPlayer.setVolume(0.3);
    } catch (e) {
      // Silently fail if music file is missing
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _musicPlayer.resume();
  }

  /// Dispose audio players
  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}

/// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});
