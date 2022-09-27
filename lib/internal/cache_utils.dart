import 'dart:convert';

import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/song_item.dart';

class CacheUtils {

  static List<SongItem> get cacheSongs {
    if (sharedPreferences.getString('deviceSongs') != null) {
      final List<dynamic> songsMap = jsonDecode(sharedPreferences.getString('deviceSongs')!);
      return List<SongItem>.generate(songsMap.length, (index) {
        return SongItem.fromMap(songsMap[index]);
      });
    } else {
      return <SongItem>[];
    }
  }

  static set cacheSongs(List<SongItem> songs) {
    if (songs.isNotEmpty) {
      final map = List<Map<String, dynamic>>.generate(
        songs.length, (index) => songs[index].toMap());
      sharedPreferences.setString('deviceSongs', jsonEncode(map));
    }
  }

  

}