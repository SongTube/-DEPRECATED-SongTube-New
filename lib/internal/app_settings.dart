import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
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

class AppSettings {

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
  static bool get enableMusicPlayerBlur {
    return sharedPreferences.getBool(enableMusicPlayerBlurKey) ?? true;
  }
  static set enableMusicPlayerBlur(bool value) {
    sharedPreferences.setBool(enableMusicPlayerBlurKey, value);
  }
  static double get musicPlayerBackdropOpacity {
    return sharedPreferences.getDouble(musicPlayerBackdropOpacityKey) ?? 0.2;
  }
  static set musicPlayerBackdropOpacity(double value) {
    sharedPreferences.setDouble(musicPlayerBackdropOpacityKey, value);
  }
  static double get musicPlayerBlurStrenght {
    return sharedPreferences.getDouble(musicPlayerBlurStrenghtKey) ?? 50;
  }
  static set musicPlayerBlurStrenght(double value) {
    sharedPreferences.setDouble(musicPlayerBlurStrenghtKey, value);
  }
}