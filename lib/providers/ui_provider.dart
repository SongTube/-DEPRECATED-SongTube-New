import 'package:flutter/material.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/ui/components/fancy_scaffold.dart';

enum CurrentPlayer { music, video }

class UiProvider extends ChangeNotifier {

  /// Loads the User's preferred ThemeMode from local or remote storage.
  ThemeMode get themeMode {
    final savedMode = sharedPreferences.getInt('themeMode') ?? 0;
    switch (savedMode) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    switch (theme) {
      case ThemeMode.system:
        await sharedPreferences.setInt('themeMode', 0);
        break;
      case ThemeMode.light:
        await sharedPreferences.setInt('themeMode', 1);
        break;
      case ThemeMode.dark:
        await sharedPreferences.setInt('themeMode', 2);
        break;
    }
    notifyListeners();
  }

  // Determines the current player so we allow the user to switch
  // between the MusicPlayer of the VideoPlayer
  CurrentPlayer _currentPlayer = CurrentPlayer.video;
  CurrentPlayer get currentPlayer => _currentPlayer;
  set currentPlayer(CurrentPlayer player) {
    _currentPlayer = player;
    notifyListeners();
  }

  // Switch Between Players
  void switchPlayers() {
    if (_currentPlayer == CurrentPlayer.video) {
      currentPlayer = CurrentPlayer.music;
    } else {
      currentPlayer = CurrentPlayer.video;
    }
  }

  // Floating Music/Video Widget Controller
  FloatingWidgetController fwController =
    FloatingWidgetController();

}