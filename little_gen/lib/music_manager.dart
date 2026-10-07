import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicManager {
  static final AudioPlayer bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  
  static bool isBgmEnabled = true;
  static bool isVoiceoverEnabled = true;
  
  static void init() {
    bgmPlayer.setVolume(0.5);
  }

  static void playClickSound() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(0.8);
      await _sfxPlayer.play(AssetSource('audio/pop.mp3'));
    } catch (_) {}
  }

  static String? _currentTrack;

  static void playBgm(String assetName) async {
    if (!isBgmEnabled) return;
    
    if (_currentTrack == assetName && bgmPlayer.state == PlayerState.playing) {
      debugPrint("BGM $assetName is already playing.");
      return; 
    }
    _currentTrack = assetName;
    debugPrint("Attempting to play BGM: audio/$assetName");
    try {
      await bgmPlayer.stop();
      await bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await bgmPlayer.play(AssetSource('audio/$assetName'));
      debugPrint("BGM $assetName started playing successfully.");
    } catch (e) {
      debugPrint("Error playing BGM $assetName: $e");
    }
  }

  static void stopBgm() async {
    await bgmPlayer.stop();
  }

  static void resumeBgm() async {
    if (isBgmEnabled && _currentTrack != null) {
      playBgm(_currentTrack!);
    }
  }

  static void setVolume(double volume) {
    if (isBgmEnabled) {
      bgmPlayer.setVolume(volume);
    }
  }

  static Future<void> playVoiceover(AudioPlayer player, String assetPath) async {
    if (!isVoiceoverEnabled) return;
    
    debugPrint("Attempting to play Voiceover: $assetPath");
    bool wasPlayingBgm = bgmPlayer.state == PlayerState.playing;
    
    try {
      if (wasPlayingBgm) {
        await bgmPlayer.pause();
      }
    } catch (e) {
      debugPrint("Error pausing BGM: $e");
    }
    
    try {
      player.setVolume(1.0); 
      await player.play(AssetSource(assetPath));
      debugPrint("Voiceover $assetPath started playing.");
    } catch (e) {
      debugPrint("Error playing voiceover $assetPath: $e");
      if (wasPlayingBgm && isBgmEnabled) await bgmPlayer.resume();
      return;
    }
    
    player.onPlayerComplete.first.then((_) async {
      debugPrint("Voiceover $assetPath completed. Checking BGM resume.");
      if (wasPlayingBgm && _currentTrack != null && isBgmEnabled) {
        await bgmPlayer.resume();
      }
    });
  }
}
