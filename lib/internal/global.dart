import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songtube/internal/artwork_manager.dart';

import '../services/audio_service.dart';

// Initialize All Global Variables
Future<void> initGlobals() async {
  sharedPreferences = await SharedPreferences.getInstance();
  songArtworkPath = await getApplicationDocumentsDirectory();
  audioHandler = await AudioService.init(builder: () =>
    StAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.artxdev.songtube',
      androidNotificationChannelName: 'SongTube',
    )
  );
}

// App Custom Accent Color
const accentColor = Color.fromARGB(255, 229, 12, 73);

// Shared Preferences for user settings and app caching and stuff
late SharedPreferences sharedPreferences;

// App initial Route getter and setter (First time default route is Intro Screen)
String get initialRoute => sharedPreferences.getString('initialRoute') ?? 'intro';
set initialRoute(String route) {
  sharedPreferences.setString('initialRoute', route);
}

// Audio Handler Singleton
late AudioHandler audioHandler;