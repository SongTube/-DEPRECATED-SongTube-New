import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:songtube/internal/ffmpeg/converter.dart';
import 'package:songtube/internal/global.dart';

// FFmpeg Related Keys
const defaultFfmpegTaskKey = 'defaultFfmpegTask';

// App Save Directories Keys
const musicDirectoryKey = 'music_directory';
const videoDirectoryKey = 'video_directory';

// Music Player Keys
const enableMusicPlayerBlurKey = 'enablePlayerBlurKey';
const musicPlayerBackdropOpacityKey = 'musicPlayerBlurOpacity';
const musicPlayerBlurStrenghtKey = 'musicPlayerBlurStrenght';
const musicPlayerArtworkZoomKey = 'musicPlayerArtworkZoom';

// Home Screen Settings
const defaultLandingPageKey = 'defaultLandingPage';

// Download Keys
const maxSimultaneousDownloadsKey = 'maxSimultaneousDownloads';

// Watch History Status
const enableWatchHistoryKey = 'enableWatchHistory';

// Background Playback Key (Alpha Feature)
const enableBackgroundPlaybackKey = 'enableBackgroundPlayback';

// Auto Picture in Picture mode
const enableAutoPictureInPictureModeKey = 'enableAutoPictureInPictureMode';

// Last video quality saved
const lastVideoQualityKey = 'lastVideoQuality';

// Enable Material You Colors
const enableMaterialYouColorsKey = 'enableMaterialYouColors';

class AppSettings extends ChangeNotifier {

  // Initialize App Settings
  static Future<void> initSettings() async {
    final musicPath = sharedPreferences.getString(musicDirectoryKey);
    final videoPath = sharedPreferences.getString(videoDirectoryKey);
    // Check for our media directories, if they're null we have to set a default path
    if (musicPath == null) {
      final defaultMusicDirectory = await AndroidPathProvider.musicPath;
      await sharedPreferences.setString(musicDirectoryKey, defaultMusicDirectory);
    }
    if (videoPath == null) {
      final defaultVideoDirectory = await AndroidPathProvider.moviesPath;
      await sharedPreferences.setString(videoDirectoryKey, defaultVideoDirectory);
    }
  }

  // Home Screen Settings
  static int get defaultLandingPage => sharedPreferences.getInt(defaultLandingPageKey) ?? 0;
  static set defaultLandingPage(int value) {
    sharedPreferences.setInt(defaultLandingPageKey, value);
  }

  // Downloads Settings
  static int get maxSimultaneousDownloads => sharedPreferences.getInt(maxSimultaneousDownloadsKey) ?? 3;
  static set maxSimultaneousDownloads(int value) {
    sharedPreferences.setInt(maxSimultaneousDownloadsKey, value);
  }

  // Watch History
  static bool get enableWatchHistory => sharedPreferences.getBool(enableWatchHistoryKey) ?? true;
  static set enableWatchHistory(bool value) {
    sharedPreferences.setBool(enableWatchHistoryKey, value);
  }

  // FFmpeg Default Task
  static FFmpegTask get defaultFfmpegTask {
    if (sharedPreferences.containsKey(defaultFfmpegTaskKey)) {
      final task = sharedPreferences.get(defaultFfmpegTaskKey);
      if (task == 'aac') {
        return FFmpegTask.convertToAAC;
      } else if (task == 'mp3') {
        return FFmpegTask.convertToMP3;
      } else if (task == 'ogg') {
        return FFmpegTask.convertToOGG;
      } else {
        return FFmpegTask.convertToAAC;
      }
    } else {
      return FFmpegTask.convertToAAC;
    }
  }
  static set defaultFfmpegTask(FFmpegTask task) {
    final format = task.toString().split('.').last.split('convertTo').last.toLowerCase();
    sharedPreferences.setString(defaultFfmpegTaskKey, format);
  }

  // Default download directorie for Music
  static Directory get musicDirectory {
    final path = sharedPreferences.getString(musicDirectoryKey)!;
    return Directory(path);
  }
  static set musicDirectory(Directory directory) {
    final path = directory.path;
    sharedPreferences.setString(musicDirectoryKey, path);
  }

  // Default download directorie for Videos
  static Directory get videoDirectory {
    final path = sharedPreferences.getString(videoDirectoryKey)!;
    return Directory(path);
  }
  static set videoDirectory(Directory directory) {
    final path = directory.path;
    sharedPreferences.setString(videoDirectoryKey, path);
  }

  // MusicPlayer Settings
  bool get enableMusicPlayerBlur {
    return sharedPreferences.getBool(enableMusicPlayerBlurKey) ?? false;
  }
  set enableMusicPlayerBlur(bool value) {
    sharedPreferences.setBool(enableMusicPlayerBlurKey, value);
    notifyListeners();
  }
  double get musicPlayerBackdropOpacity {
    return sharedPreferences.getDouble(musicPlayerBackdropOpacityKey) ?? 0.2;
  }
  set musicPlayerBackdropOpacity(double value) {
    sharedPreferences.setDouble(musicPlayerBackdropOpacityKey, value);
    notifyListeners();
  }
  double get musicPlayerBlurStrenght {
    return sharedPreferences.getDouble(musicPlayerBlurStrenghtKey) ?? 50;
  }
  set musicPlayerBlurStrenght(double value) {
    sharedPreferences.setDouble(musicPlayerBlurStrenghtKey, value);
    notifyListeners();
  }
  double get musicPlayerArtworkZoom {
    return sharedPreferences.getDouble(musicPlayerArtworkZoomKey) ?? 1;
  }
  set musicPlayerArtworkZoom(double value) {
    sharedPreferences.setDouble(musicPlayerArtworkZoomKey, value);
    notifyListeners();
  }

  // Background Playback (Alpha)
  static bool get enableBackgroundPlayback => sharedPreferences.getBool(enableBackgroundPlaybackKey) ?? false;
  static set enableBackgroundPlayback(bool value) {
    sharedPreferences.setBool(enableBackgroundPlaybackKey, value);
  }

  // Auto Picture in Picture mode
  static bool get enableAutoPictureInPictureMode => sharedPreferences.getBool(enableAutoPictureInPictureModeKey) ?? true;
  static set enableAutoPictureInPictureMode(bool value) {
    sharedPreferences.setBool(enableAutoPictureInPictureModeKey, value);
  }

  // Cached last video quality
  static String get lastVideoQuality => sharedPreferences.getString(lastVideoQualityKey) ?? '720';
  static set lastVideoQuality(String qualityString) {
    sharedPreferences.setString(lastVideoQualityKey, qualityString);
  }

  // Enable Material You Colors
  bool get enableMaterialYou => sharedPreferences.getBool(enableMaterialYouColorsKey) ?? false;
  set enableMaterialYou(bool value) {
    sharedPreferences.setBool(enableMaterialYouColorsKey, value);
    notifyListeners();
  }

}